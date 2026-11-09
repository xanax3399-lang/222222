"""Recover lexical conditions from decompiler labels, preserving native loops."""
from pathlib import Path
import re,io,contextlib,copy,json,sys
from luaparser import ast,astnodes as N
import source_ast as H
R=Path(__file__).resolve().parent
from control_flow import Structurer
def parse(s):
 with contextlib.redirect_stdout(io.StringIO()):return ast.parse(s)
def render(node):
 with contextlib.redirect_stdout(io.StringIO()):return ast.to_lua_source(node)
raw=(R/'source.raw.lua').read_text();preserved={}
# CLOSE 19 after the bit-backed extractor closes its three captured locals.
raw=raw.replace('  if L19_1 then\n    L19_1 = _G', '  if L19_1 then\n    local L19_1, L20_1, L21_1\n    L19_1 = _G',1)
from lupa.luajit21 import LuaRuntime
literal_lua=LuaRuntime(encoding=None)
def long_literal(m):
 value=literal_lua.eval(('function()return '+m[0]+' end').encode())()
 return '"'+''.join(chr(c)if 32<=c<127 and c not in (34,92)else '\\%03d'%c for c in value)+'"'
raw=re.sub(r'\[(=*)\[[\s\S]*?\]\1\]',long_literal,raw)
def protect(m):
 value=m[0]
 if '\\'not in value and all(ord(c)<128 for c in value):return value
 marker='__SIGMA_DEC14_LITERAL_%d__'%len(preserved);preserved[marker]=value;return marker
tree=parse(re.sub(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',protect,raw))
report=[]
def kind_name(node):
 value=getattr(node,'id',None)or getattr(node,'name',None)or getattr(node,'label',None)
 return value.id if isinstance(value,N.Name)else value
def jumps(node):
 if isinstance(node,H.FUNCTIONS):return set(),set()
 gs={kind_name(node)}if isinstance(node,N.Goto)else set();ls={kind_name(node)}if isinstance(node,N.Label)else set()
 for _,_,c in H.children(node):
  a,b=jumps(c);gs|=a;ls|=b
 return gs,ls
def process(block):
 # Nested functions and loops have separate local control regions.
 def nested(node):
  if isinstance(node,H.FUNCTIONS):process(node.body);return
  if isinstance(node,(N.Fornum,N.Forin,N.While,N.Repeat)):
   process(node.body);return
  for _,_,c in H.children(node):nested(c)
 for stmt in block.body:nested(stmt)
 gotos,labels=jumps(block)
 if not gotos and not labels:return
 if gotos-labels:raise AssertionError(('cross region jumps',gotos-labels))
 nodes=[];markers={}
 def new(statements=None,branch=None,condition=None,nxt=None,terminal=False):
  pc=len(nodes);nodes.append({'pc':pc,'op':0,'statements':statements or [],'branch':branch,'condition':condition,'next':nxt,'terminal':terminal,'on_branch':[],'on_fallthrough':[]});return pc
 end=new(terminal=True)
 def build(seq,after):
  nxt=after
  for stmt in reversed(seq):
   if isinstance(stmt,N.Label):markers[kind_name(stmt)]=nxt
   elif isinstance(stmt,N.Goto):nxt=new(branch=('label',kind_name(stmt)))
   elif isinstance(stmt,(N.If,N.ElseIf)):
    no=build(stmt.orelse.body,nxt)if isinstance(stmt.orelse,N.Block)else build([stmt.orelse],nxt)if stmt.orelse is not None else nxt
    yes=build(stmt.body.body,nxt);nxt=new(branch=yes,condition=render(stmt.test),nxt=no)
   else:
    terminal=isinstance(stmt,N.Return)or isinstance(stmt,N.Do)and stmt.body.body and isinstance(stmt.body.body[-1],N.Return)
    nxt=new(statements=[render(stmt)],nxt=None if terminal else nxt,terminal=terminal)
  return nxt
 start=build(block.body,end)
 for node in nodes:
  if isinstance(node['branch'],tuple):node['branch']=markers[node['branch'][1]]
 output=Structurer(nodes).emit(start)
 (R/'last_region.lua').write_text('\n'.join(output))
 block.body=parse('\n'.join(output)).body.body
 report.append({'gotos_removed':len(gotos),'nodes':len(nodes)})
def normalize_elseifs(node):
 for _,_,child in list(H.children(node)):normalize_elseifs(child)
 if isinstance(node,(N.If,N.ElseIf))and isinstance(node.orelse,N.ElseIf):
  value=node.orelse;node.orelse=N.Block([N.If(test=value.test,body=value.body,orelse=value.orelse)])
normalize_elseifs(tree)
# Restore open result-list arity, which an all-locals decompilation expands
# into fixed registers (e.g. string.char(bit_extract(...), nil, ...)).
with contextlib.redirect_stdout(io.StringIO()):import lift as BYTECODE
function_id=0;arity_repairs=[]
def repair_function(fn,fid):
 builder=BYTECODE.builders[fid]
 open_registers={ins[1]for ins in builder.native if ins[0]=='CALL'and ins[3]==0}
 def block(b):
  out=[]
  for i,stmt in enumerate(b.body):
   for _,_,child in H.children(stmt):
    if isinstance(child,N.Block):block(child)
   if isinstance(stmt,N.Assign)and len(stmt.values)==1 and isinstance(stmt.values[0],N.Call)and len(stmt.targets)>1 and all(isinstance(t,N.Name)for t in stmt.targets):
    m=re.fullmatch(r'L(\d+)_\d+',stmt.targets[0].id)
    if m and int(m[1])in open_registers and int(m[1])+len(stmt.targets)==builder.maxreg:
     names=[t.id for t in stmt.targets]
     following=b.body[i+1]if i+1<len(b.body)else None
     replaced=[False]
     name='returned_%d_%d'%(fid,len(arity_repairs))
     replacement=parse('unpack('+name+', 1, '+name+'.n)').body.body[0]if False else N.Call(func=N.Name('unpack'),args=[N.Name(name),N.Number(1),N.Index(value=N.Name(name),idx=N.Name('n'),notation=N.IndexNotation.DOT)])
     def consume(node):
      if isinstance(node,H.FUNCTIONS):return
      values=node.args if isinstance(node,N.Call)else node.values if isinstance(node,N.Return)else None
      if values is not None and len(values)>=len(names)and all(isinstance(v,N.Name)and v.id==n for v,n in zip(values[-len(names):],names)):
       values[-len(names):]=[copy.deepcopy(replacement)];replaced[0]=True
      for _,_,child in H.children(node):consume(child)
     if following is not None:consume(following)
     if replaced[0]:
      out.append(N.LocalAssign(targets=[N.Name(name)],values=[N.Call(func=N.Name('__dec14_pack_results'),args=stmt.values)]))
      stmt.values=[copy.deepcopy(replacement)];arity_repairs.append({'function':fid,'register':int(m[1]),'results_preserved':True})
   out.append(stmt)
  b.body=out
 block(fn.body)
 def nested(node):
  global function_id
  if isinstance(node,H.FUNCTIONS):
   function_id+=1;repair_function(node,function_id);return
  for _,_,child in H.children(node):nested(child)
 for stmt in fn.body.body:nested(stmt)
root_fn=N.AnonymousFunction(args=[],body=tree.body)
repair_function(root_fn,0)
assert function_id==30,function_id
(R/'arity_recovery.json').write_text(json.dumps(arity_repairs,indent=2)+'\n')
process(tree.body)
def lists(node):
 if isinstance(node,N.Field)and isinstance(node.key,N.Number)and node._first_token is not None and node._first_token.text!='[':
  node.key=N.Name('__SIGMA_DEC14_LIST__');node.between_brackets=True
 for _,_,c in H.children(node):lists(c)
lists(tree)
s=render(tree);s=re.sub(r'\[__SIGMA_DEC14_LIST__\]\s*=\s*','',s)
s=re.sub(r'\b__SIGMA_DEC14_LITERAL_\d+__\b',lambda m:preserved[m[0]],s)
(R/'recovered.structured.lua').write_text(s+'\n')
(R/'source_structure_report.json').write_text(json.dumps(report,indent=2)+'\n')
print('Structured',len(report),'regions')
