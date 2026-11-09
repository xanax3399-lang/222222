"""Flow-aware reconstruction of the native Lua program into editable source.

Aliases are snapshots: writes to dependencies and possible captured-variable
effects invalidate them. Native closures are optimized in independent scopes.
"""
from pathlib import Path
import copy,contextlib,io,re,json
from luaparser import ast,astnodes as N
import source_ast as H
ROOT=Path(__file__).resolve().parent
statistics={'dead_assignments':0,'inline_assignments':0,'declarations_removed':0,'functions':0}
FUNCTIONS=H.FUNCTIONS
def pure_value(v):return isinstance(v,(N.Name,N.Number,N.String,N.TrueExpr,N.FalseExpr,N.Nil))
def literal(v):return pure_value(v)and not isinstance(v,N.Name)
def signature(v):
 with contextlib.redirect_stdout(io.StringIO()):return ast.to_lua_source(v)
def meet(a,b):return {k:v for k,v in a.items()if k in b and signature(v)==signature(b[k])}
def readonly_captures(fn):
 own=H.declarations(fn);position=0;last_write={};first_capture={};loop_writes=set();loop_captures=set();child_writes=set()
 def external_writes(child,shadow=None):
  local=H.declarations(child);blocked=set(shadow or set())|local
  def walk(node):
   if isinstance(node,FUNCTIONS):external_writes(node,blocked);return
   if isinstance(node,(N.Assign,N.LocalAssign)):
    for target in node.targets:
     if isinstance(target,N.Name)and target.id in own and target.id not in blocked:child_writes.add(target.id)
   for _,_,value in H.children(node):walk(value)
  walk(child.body)
 def walk(node,in_loop=False):
  nonlocal position
  position+=1
  if isinstance(node,FUNCTIONS):
   for name in H.free_names(node)&own:
    first_capture.setdefault(name,position)
    if in_loop:loop_captures.add(name)
   external_writes(node);return
  if isinstance(node,(N.Assign,N.LocalAssign)):
   # Assignment takes effect after evaluating function-literal RHS captures.
   for value in node.values:walk(value,in_loop)
   position+=1
   for target in node.targets:
    if isinstance(target,N.Name):
     last_write[target.id]=position
     if in_loop:loop_writes.add(target.id)
    else:walk(target,in_loop)
   return
  for _,_,value in H.children(node):walk(value,in_loop or isinstance(node,(N.While,N.Repeat,N.Fornum,N.Forin)))
 walk(fn.body)
 return {name for name,where in first_capture.items()if last_write.get(name,-1)<where and name not in child_writes and not(name in loop_writes and name in loop_captures)}

def optimize(fn,immutable_inherited=None):
 statistics['functions']+=1
 own=H.declarations(fn);inherited=H.free_names(fn);captured=H.creations(fn.body)&own
 immutable_inherited=set(immutable_inherited or set())-own
 immutable=readonly_captures(fn)|immutable_inherited
 def invalidate(known,names):
  for k,v in list(known.items()):
   if k in names or H.references(v)&names:known.pop(k,None)
 def expr(node,known,active):
  if isinstance(node,FUNCTIONS):
   optimize(node,immutable);active|=(H.free_names(node)&own)-immutable;return node
  if isinstance(node,N.Name):
   if node.id not in known:return node
   value=copy.deepcopy(known[node.id])
   if isinstance(value,N.String)or isinstance(value,N.Name)and value.id.startswith('__SIGMA_LITERAL_'):value.wrapped=True
   return value
  if isinstance(node,N.Index):
   node.value=expr(node.value,known,active)
   if node.notation==N.IndexNotation.SQUARE:node.idx=expr(node.idx,known,active)
   invalidate(known,active);return node
  if isinstance(node,N.Call):
   node.func=expr(node.func,known,active)
   node.args=[expr(v,known,active)for v in node.args]
   invalidate(known,active);return node
  if isinstance(node,N.Invoke):
   node.source=expr(node.source,known,active);node.args=[expr(v,known,active)for v in node.args]
   invalidate(known,active);return node
  if isinstance(node,N.BinaryOp):
   node.left=expr(node.left,known,active);after_left=known.copy()
   node.right=expr(node.right,known,active)
   if isinstance(node,(N.AndLoOp,N.OrLoOp)):
    joint=meet(after_left,known);known.clear();known.update(joint)
   else:invalidate(known,active)
   return node
  for field,index,child in list(H.children(node)):
   # DOT names and declaration/function parameters are identifiers, not values.
   value=expr(child,known,active)
   if index is None:setattr(node,field,value)
   else:getattr(node,field)[index]=value
  if isinstance(node,N.UnaryOp):invalidate(known,active)
  return node
 def block_forward(block,known=None,active=None):
  known=dict(known or {});active=set(inherited-immutable if active is None else active)
  for stmt in block.body:
   stmt._active_captures=active.copy()
   if isinstance(stmt,(N.Assign,N.LocalAssign)):
    # LHS indexed addresses are resolved before RHS calls in Lua assignment.
    for target in stmt.targets:
     if isinstance(target,N.Index):
      target.value=expr(target.value,known,active)
      if target.notation==N.IndexNotation.SQUARE:target.idx=expr(target.idx,known,active)
    values=[expr(v,known,active)for v in stmt.values];stmt.values=values
    defs={v.id for v in stmt.targets if isinstance(v,N.Name)}
    invalidate(known,defs)
    for i,target in enumerate(stmt.targets):
     if not isinstance(target,N.Name):continue
     value=values[i]if i<len(values)else N.Nil()if not values or pure_value(values[-1])else None
     if value is not None and pure_value(value)and not(H.references(value)&defs):known[target.id]=copy.deepcopy(value)
    if any(isinstance(t,N.Index)for t in stmt.targets):invalidate(known,active)
   elif isinstance(stmt,N.If):
    stmt.test=expr(stmt.test,known,active)
    yes,ya=block_forward(stmt.body,known,active)
    if stmt.orelse is not None:
     assert isinstance(stmt.orelse,N.Block);no,na=block_forward(stmt.orelse,known,active)
    else:no,na=known.copy(),active.copy()
    known=meet(yes,no);active|=ya|na
   elif isinstance(stmt,N.Do):known,active=block_forward(stmt.body,known,active)
   elif isinstance(stmt,(N.While,N.Repeat,N.Fornum,N.Forin)):
    modified=H.writes(stmt);active|=(H.creations(stmt)&own)-immutable;invalidate(known,modified|active)
    if isinstance(stmt,N.Fornum):invalidate(known,{stmt.target.id})
    if isinstance(stmt,N.Forin):invalidate(known,{t.id for t in stmt.targets})
    for field,index,child in list(H.children(stmt)):
     if field in ('body','target','targets'):continue
     value=expr(child,known,active)
     if index is None:setattr(stmt,field,value)
     else:getattr(stmt,field)[index]=value
    _,inside=block_forward(stmt.body,known,active);active|=inside;invalidate(known,modified|active)
   else:
    for field,index,child in list(H.children(stmt)):
     value=expr(child,known,active)
     if index is None:setattr(stmt,field,value)
     else:getattr(stmt,field)[index]=value
   stmt._active_after=active.copy()
  return known,active
 block_forward(fn.body)
 def liveness(block,after):
  live=set(after);out=[]
  for stmt in reversed(block.body):
   active=getattr(stmt,'_active_after',set());stmt._live_after=live.copy()
   if isinstance(stmt,(N.Assign,N.LocalAssign)):
    defs={t.id for t in stmt.targets if isinstance(t,N.Name)}
    safe=all(pure_value(v)for v in stmt.values)and len(defs)==len(stmt.targets)
    if safe and not isinstance(stmt,N.LocalAssign)and not defs&live:
     statistics['dead_assignments']+=1;continue
    if len(stmt.values)==1 and isinstance(stmt.values[0],N.Nil)and len(defs)==len(stmt.targets)and not isinstance(stmt,N.LocalAssign):
     stmt.targets=[t for t in stmt.targets if t.id in live]
     if not stmt.targets:statistics['dead_assignments']+=1;continue
     defs={t.id for t in stmt.targets}
    reads=set().union(*(H.references(v)for v in stmt.values))if stmt.values else set()
    for target in stmt.targets:
     if not isinstance(target,N.Name):reads|=H.references(target)
    live=(live-defs)|reads
    if H.effects(stmt):live|=active
   elif isinstance(stmt,N.If):live=liveness(stmt.body,live)| (liveness(stmt.orelse,live)if stmt.orelse is not None else live)|H.references(stmt.test)
   elif isinstance(stmt,N.Do):live=liveness(stmt.body,live)
   elif isinstance(stmt,(N.While,N.Repeat,N.Fornum,N.Forin)):
    demand=H.references(stmt)|live|active;liveness(stmt.body,demand);live|=demand
   elif isinstance(stmt,N.Return):live=set().union(*(H.references(v)for v in stmt.values))|active
   else:live|=H.references(stmt)|active
   out.append(stmt)
  block.body=list(reversed(out));return live
 liveness(fn.body,captured)
 # Join adjacent snapshot assignments when the use evaluates that snapshot
 # first, or when an indexed LHS address is entirely private and effect-free.
 def combine(block):
  out=[]
  for stmt in block.body:
   for _,_,child in H.children(stmt):
    if isinstance(child,N.Block):combine(child)
   if out and isinstance(stmt,N.Assign)and len(stmt.values)==1:
    prev=out[-1]
    if isinstance(prev,N.Assign)and len(prev.targets)==len(prev.values)==1 and isinstance(prev.targets[0],N.Name):
     name=prev.targets[0].id;active=getattr(stmt,'_active_captures',set())
     if name in own and name not in active and not isinstance(prev.values[0],FUNCTIONS):
      value=stmt.values[0]
      field='value'if isinstance(value,N.Index)else 'func'if isinstance(value,N.Call)else 'left'if isinstance(value,N.BinaryOp)else 'operand'if isinstance(value,N.UnaryOp)else None
      same_target=len(stmt.targets)==1 and isinstance(stmt.targets[0],N.Name)and stmt.targets[0].id==name
      if same_target and field and isinstance(getattr(value,field,None),N.Name)and getattr(value,field).id==name:
       def count(n):return (1 if isinstance(n,N.Name)and n.id==name else 0)+sum(count(c)for field,_,c in H.children(n)if not(isinstance(n,N.Index)and field=='idx'and n.notation==N.IndexNotation.DOT))
       if count(value)==1:
        replacement=copy.deepcopy(prev.values[0]);replacement.wrapped=True;setattr(value,field,replacement);out.pop();statistics['inline_assignments']+=1
   if out and isinstance(stmt,N.Assign)and len(stmt.targets)==len(stmt.values)==1:
    prev=out[-1]
    if isinstance(prev,N.Assign)and len(prev.targets)==len(prev.values)==1 and isinstance(prev.targets[0],N.Name)and isinstance(stmt.values[0],N.Name):
     name=prev.targets[0].id;active=getattr(stmt,'_active_captures',set());target=stmt.targets[0]
     safe_address=isinstance(target,N.Name)or isinstance(target,N.Index)and isinstance(target.value,N.Name)and target.value.id in own and target.value.id not in active and (literal(target.idx)or target.notation==N.IndexNotation.DOT)
     if stmt.values[0].id==name and name in own and name not in active and name not in getattr(stmt,'_live_after',set())and safe_address and not isinstance(prev.values[0],FUNCTIONS):
      stmt.values[0]=copy.deepcopy(prev.values[0]);out.pop();statistics['inline_assignments']+=1
   out.append(stmt)
  block.body=out
 combine(fn.body)
 def used_names(node):
  if isinstance(node,N.LocalAssign):return set().union(*(used_names(v)for v in node.values))if node.values else set()
  if isinstance(node,N.Index)and node.notation==N.IndexNotation.DOT:return used_names(node.value)
  if isinstance(node,N.Name):return {node.id}
  return set().union(*(used_names(c)for _,_,c in H.children(node)))if list(H.children(node))else set()
 used=used_names(fn.body)
 def trim(block):
  out=[]
  for stmt in block.body:
   if isinstance(stmt,N.LocalAssign)and not stmt.values:
    count=len(stmt.targets);stmt.targets=[t for t in stmt.targets if t.id in used];statistics['declarations_removed']+=count-len(stmt.targets)
    if not stmt.targets:continue
   for _,_,child in H.children(stmt):
    if isinstance(child,N.Block):trim(child)
   out.append(stmt)
  block.body=out
 trim(fn.body)

def transform(path,output):
 raw=path.read_text();preserved={}
 def protect(m):
  text=m[0]
  if '\\'not in text and all(ord(c)<128 for c in text):return text
  marker='__SIGMA_LITERAL_%d__'%len(preserved);preserved[marker]=text;return marker
 protected=re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',protect,raw)
 with contextlib.redirect_stdout(io.StringIO()):tree=ast.parse(protected)
 for stmt in tree.body.body:
  if isinstance(stmt,FUNCTIONS):optimize(stmt)
  else:
   for _,_,child in H.children(stmt):
    if isinstance(child,FUNCTIONS):optimize(child)
 def fields(node):
  if isinstance(node,N.Field)and isinstance(node.key,N.Number)and node._first_token is not None and node._first_token.text!='[':
   node.key=N.Name('__SIGMA_LIST_FIELD__');node.between_brackets=True
  for _,_,child in H.children(node):fields(child)
 fields(tree)
 with contextlib.redirect_stdout(io.StringIO()):text=ast.to_lua_source(tree)
 text=re.sub(r'\[__SIGMA_LIST_FIELD__\]\s*=\s*','',text)
 text=re.sub(r'\b__SIGMA_LITERAL_\d+__\b',lambda m:preserved[m[0]],text)
 output.write_text('-- Reconstructed editable Lua. Names inferred from use; see README_EDITABLE_RU.txt.\n'+text+'\n')
if __name__=='__main__':
 transform(ROOT/'new_sigma_pred.full_source.lua',ROOT/'new_sigma_pred.editable.lua')
 transform(ROOT/'native_test_factories.lua',ROOT/'editable_test_factories.lua')
 (ROOT/'editable_transform.json').write_text(json.dumps(statistics,indent=2)+'\n')
 print(statistics)
