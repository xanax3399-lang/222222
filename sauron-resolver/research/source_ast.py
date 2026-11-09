"""Polish ordinary lexical Lua; retain reads/calls with possible side effects."""
from pathlib import Path
import copy,re,json
from luaparser import ast,astnodes as N
ROOT=Path(__file__).resolve().parent
FUNCTIONS=(N.AnonymousFunction,N.Function,N.LocalFunction)
def children(node):
 for key,value in vars(node).items():
  if key.startswith('_')or key in ('comments','wrapped'):continue
  if isinstance(value,N.Node):yield key,None,value
  elif isinstance(value,list):
   for i,item in enumerate(value):
    if isinstance(item,N.Node):yield key,i,item
def all_names(node,include_functions=True):
 if isinstance(node,N.Name):return {node.id}
 if isinstance(node,FUNCTIONS)and not include_functions:return set()
 result=set()
 for key,_,child in children(node):
  if isinstance(node,N.Index)and key=='idx'and node.notation==N.IndexNotation.DOT:continue
  result|=all_names(child,include_functions)
 return result
def declarations(fn):
 result={a.id for a in fn.args if isinstance(a,N.Name)}
 def visit(node):
  if isinstance(node,FUNCTIONS):return
  if isinstance(node,N.LocalAssign):result.update(v.id for v in node.targets if isinstance(v,N.Name))
  if isinstance(node,N.Fornum):result.add(node.target.id)
  if isinstance(node,N.Forin):result.update(v.id for v in node.targets)
  for _,_,child in children(node):visit(child)
 visit(fn.body);return result
def free_names(fn):return all_names(fn.body)-declarations(fn)
def creations(node):
 if isinstance(node,FUNCTIONS):return free_names(node)
 result=set()
 for _,_,child in children(node):result|=creations(child)
 return result
def effects(node):
 if isinstance(node,FUNCTIONS):return False
 if isinstance(node,(N.Call,N.Invoke,N.Index)):return True
 return any(effects(c)for _,_,c in children(node))
def writes(node):
 if isinstance(node,FUNCTIONS):return set()
 result=set()
 if isinstance(node,(N.Assign,N.LocalAssign)):result|={v.id for v in node.targets if isinstance(v,N.Name)}
 for _,_,child in children(node):result|=writes(child)
 return result
def literal(node):return isinstance(node,(N.Number,N.String,N.TrueExpr,N.FalseExpr,N.Nil))
def key(node):return ast.to_lua_source(node)
def references(node):
 if isinstance(node,FUNCTIONS):return free_names(node)
 if isinstance(node,N.Name):return {node.id}
 result=set()
 for field,_,child in children(node):
  if isinstance(node,N.Index)and field=='idx'and node.notation==N.IndexNotation.DOT:continue
  result|=references(child)
 return result
statistics={'removed_assignments':0,'combined_assignments':0,'removed_declarations':0}

def polish(path):
 import contextlib,io
 raw=path.read_text();preserved={}
 def protect_literal(m):
  literal=m[0]
  if '\\'not in literal and all(ord(c)<128 for c in literal):return literal
  marker='__SIGMA_PRESERVED_LITERAL_%d__'%len(preserved);preserved[marker]=literal;return marker
 protected=re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',protect_literal,raw)
 with contextlib.redirect_stdout(io.StringIO()):tree=ast.parse(protected)
 def safe_function(fn):
  own=declarations(fn);captured=creations(fn.body)&own
  def rewrite(node):
   if isinstance(node,FUNCTIONS):safe_function(node);return
   for field,index,child in list(children(node)):
    rewrite(child)
   if isinstance(node,N.Index)and isinstance(node.idx,N.String):
    raw=node.idx.s.decode()if isinstance(node.idx.s,bytes)else node.idx.s
    if re.fullmatch(r'[A-Za-z_]\w*',raw)and raw not in {'and','break','do','else','elseif','end','false','for','function','if','in','local','nil','not','or','repeat','return','then','true','until','while'}:
     node.idx=N.Name(raw);node.notation=N.IndexNotation.DOT
  for stmt in fn.body.body:rewrite(stmt)
  def combine(block):
   out=[]
   for stmt in block.body:
    for _,_,child in children(stmt):
     if isinstance(child,N.Block):combine(child)
    if out and isinstance(stmt,N.Assign)and len(stmt.targets)==len(stmt.values)==1 and isinstance(stmt.targets[0],N.Name):
     prev=out[-1];name=stmt.targets[0].id
     if isinstance(prev,N.Assign)and len(prev.targets)==len(prev.values)==1 and isinstance(prev.targets[0],N.Name)and prev.targets[0].id==name and name in own and name not in captured and not isinstance(prev.values[0],FUNCTIONS):
      value=stmt.values[0];field='value'if isinstance(value,N.Index)else 'func'if isinstance(value,N.Call)else 'left'if isinstance(value,N.BinaryOp)else 'operand'if isinstance(value,N.UnaryOp)else None
      if field and isinstance(getattr(value,field,None),N.Name)and getattr(value,field).id==name:
       def count(n):return (1 if isinstance(n,N.Name)and n.id==name else 0)+sum(count(c)for _,_,c in children(n))
       if count(value)==1:
        replacement=copy.deepcopy(prev.values[0]);replacement.wrapped=True;setattr(value,field,replacement);out.pop();statistics['combined_assignments']+=1
    out.append(stmt)
   block.body=out
  combine(fn.body)
  def actual(node):
   if isinstance(node,N.LocalAssign):return set().union(*(actual(v)for v in node.values))if node.values else set()
   if isinstance(node,N.Index)and node.notation==N.IndexNotation.DOT:return actual(node.value)
   if isinstance(node,N.Name):return {node.id}
   return set().union(*(actual(c)for _,_,c in children(node)))if list(children(node))else set()
  used=actual(fn.body)
  def trim(block):
   out=[]
   for stmt in block.body:
    if isinstance(stmt,N.LocalAssign)and not stmt.values:
     old=len(stmt.targets);stmt.targets=[t for t in stmt.targets if t.id in used];statistics['removed_declarations']+=old-len(stmt.targets)
     if not stmt.targets:continue
    for _,_,child in children(stmt):
     if isinstance(child,N.Block):trim(child)
    out.append(stmt)
   block.body=out
  trim(fn.body)
 for statement in tree.body.body:
  if isinstance(statement,FUNCTIONS):safe_function(statement)
  else:
   for _,_,child in children(statement):
    if isinstance(child,FUNCTIONS):safe_function(child)
 def preserve_implicit_fields(node):
  if isinstance(node,N.Field)and isinstance(node.key,N.Number)and node._first_token is not None and node._first_token.text!='[':
   node.key=N.Name('__SIGMA_IMPLICIT_LIST_FIELD__');node.between_brackets=True
  for _,_,child in children(node):preserve_implicit_fields(child)
 preserve_implicit_fields(tree)
 with contextlib.redirect_stdout(io.StringIO()):text=ast.to_lua_source(tree)
 text=re.sub(r'\[__SIGMA_IMPLICIT_LIST_FIELD__\]\s*=\s*','',text)
 text=re.sub(r'\b__SIGMA_PRESERVED_LITERAL_\d+__\b',lambda m:preserved[m[0]],text)
 path.write_text('-- Reconstructed complete Lua; names are inferred. See README_FULL_RU.txt.\n'+text+'\n')

if __name__=='__main__':
 for name in ['new_sigma_pred.full_source.lua','native_test_factories.lua']:polish(ROOT/name)
 (ROOT/'full_source_polish.json').write_text(json.dumps(statistics,indent=2)+'\n')
 print(statistics)
