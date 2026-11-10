from pathlib import Path
from dataclasses import dataclass,field
from collections import Counter
import re,sys,json
from tree_sitter import Language,Parser
import tree_sitter_lua
sys.setrecursionlimit(20000)
ROOT=Path(__file__).resolve().parent
if not (ROOT/'original.lua').exists() and (ROOT.parent/'original.lua').exists():ROOT=ROOT.parent
INPUT=ROOT/'original.lua'
SRC=INPUT.read_bytes();TREE=Parser(Language(tree_sitter_lua.language())).parse(SRC)
assert not TREE.root_node.has_error

def text(n):return SRC[n.start_byte:n.end_byte].decode() if n else ''
def line(n):return n.start_point.row+1

def kids(n,t):return [c for c in n.named_children if c.type==t]
@dataclass
class Binding:
 id:int
 old:str
 node:object
 scope:object
 kind:str
 refs:list=field(default_factory=list)
 values:list=field(default_factory=list)
 fields:set=field(default_factory=set)
 methods:set=field(default_factory=set)
 new:str=''

class Scope:
 def __init__(self,parent=None,node=None):self.parent=parent;self.node=node;self.names={}
 def lookup(self,name):return self.names.get(name) or (self.parent.lookup(name) if self.parent else None)

class Analysis:
 def __init__(self):self.bindings=[];self.uses={};self.functions=[];self.blocks=[];self.scopes=[];self.unresolved=Counter();self.global_names=set()
 def declare(self,node,scope,kind='local'):
  b=Binding(len(self.bindings)+1,text(node),node,scope,kind);self.bindings.append(b);scope.names[b.old]=b;self.use(node,scope);return b
 def use(self,node,scope):
  b=scope.lookup(text(node))
  if b:b.refs.append(node);self.uses[node.start_byte]=b
  else:self.unresolved[text(node)]+=1;self.global_names.add(text(node))
  return b
 def scope(self,parent,node):
  s=Scope(parent,node);self.scopes.append(s);return s
 def block(self,node,scope):
  if node is None:return
  self.blocks.append((node,scope))
  for c in node.named_children:self.walk(c,scope)
 def function(self,n,s,label=None):
  inner=self.scope(s,n);params=n.child_by_field_name('parameters');name=n.child_by_field_name('name')
  if name and name.type=='method_index_expression':inner.names['self']=Binding(-1,'self',None,inner,'implicit')
  args=[]
  if params:
   for p in params.named_children:
    if p.type=='identifier':args.append(self.declare(p,inner,'parameter'))
  self.functions.append({'node':n,'scope':inner,'args':args,'label':label or ('anonymous_'+str(line(n)))})
  self.block(n.child_by_field_name('body'),inner)
 def field_root(self,n):
  names=[]
  while n and n.type in ('dot_index_expression','method_index_expression','bracket_index_expression'):
   f=n.child_by_field_name('field') or n.child_by_field_name('method')
   if f and f.type in ('identifier','string','number'):names.insert(0,text(f).strip('"\''))
   n=n.child_by_field_name('table')
  return n,names
 def record(self,target,value,s):
  if target.type=='identifier':
   b=s.lookup(text(target))
   if b and value is not None:b.values.append(value)
  else:
   root,path=self.field_root(target)
   if root and root.type=='identifier':
    b=s.lookup(text(root))
    if b and path:
     b.fields.add(path[0])
     if value and value.type=='function_definition':b.methods.add(path[-1])
 def walk(self,n,s):
  k=n.type
  if k in ('comment','string','number','nil','true','false','vararg_expression','label_statement','goto_statement'):return
  if k=='identifier':self.use(n,s);return
  if k=='variable_declaration':
   a=next((c for c in n.named_children if c.type=='assignment_statement'),None)
   vl=(a or n).child_by_field_name('variables') or next((c for c in (a or n).named_children if c.type=='variable_list'),None)
   el=next((c for c in a.named_children if c.type=='expression_list'),None) if a else None
   values=el.named_children if el else []
   for v in values:self.walk(v,s)
   for i,t in enumerate(vl.named_children):
    b=self.declare(t,s)
    if i<len(values):b.values.append(values[i])
   return
  if k=='assignment_statement':
   vl=next(c for c in n.named_children if c.type=='variable_list');el=next(c for c in n.named_children if c.type=='expression_list')
   for t in vl.named_children:self.walk(t,s)
   for i,t in enumerate(vl.named_children):self.record(t,el.named_children[i] if i<len(el.named_children) else None,s)
   for v in el.named_children:self.walk(v,s)
   return
  if k=='function_declaration':
   name=n.child_by_field_name('name');is_local=any(c.type=='local' for c in n.children)
   if is_local:
    b=self.declare(name,s,'function');b.values.append(n)
   else:self.walk(name,s)
   self.function(n,s,text(name));return
  if k=='function_definition':self.function(n,s);return
  if k=='do_statement':self.block(n.child_by_field_name('body'),self.scope(s,n));return
  if k=='while_statement':self.walk(n.child_by_field_name('condition'),s);self.block(n.child_by_field_name('body'),self.scope(s,n));return
  if k=='repeat_statement':
   inner=self.scope(s,n);self.block(n.child_by_field_name('body'),inner);self.walk(n.child_by_field_name('condition'),inner);return
  if k in ('if_statement','elseif_statement'):
   self.walk(n.child_by_field_name('condition'),s);self.block(n.child_by_field_name('consequence'),self.scope(s,n))
   for i,c in enumerate(n.children):
    if n.field_name_for_child(i)=='alternative':self.walk(c,s)
   return
  if k=='else_statement':self.block(n.child_by_field_name('body'),self.scope(s,n));return
  if k=='for_statement':
   clause=n.child_by_field_name('clause');inner=self.scope(s,n)
   if clause.type=='for_numeric_clause':
    for fieldname in ['start','end','step']:
     x=clause.child_by_field_name(fieldname)
     if x:self.walk(x,s)
    self.declare(clause.child_by_field_name('name'),inner,'loop')
   else:
    for x in kids(clause,'expression_list'):self.walk(x,s)
    for x in kids(clause,'variable_list'):
     for t in x.named_children:self.declare(t,inner,'loop')
   self.block(n.child_by_field_name('body'),inner);return
  if k in ('dot_index_expression','method_index_expression'):
   self.walk(n.child_by_field_name('table'),s);return
  if k=='field':
   value=n.child_by_field_name('value');name=n.child_by_field_name('name')
   if n.children[0].type=='[' and name:self.walk(name,s)
   if value:self.walk(value,s)
   return
  if k=='block':self.block(n,self.scope(s,n));return
  for c in n.named_children:self.walk(c,s)
 def run(self):
  top=self.scope(None,TREE.root_node);self.block(TREE.root_node,top)
  for b in self.bindings:
   for v in b.values:
    if v.type=='table_constructor':
     for f in kids(v,'field'):
      name=f.child_by_field_name('name');value=f.child_by_field_name('value')
      if name and name.type in ('identifier','string'):
       key=text(name).strip('"\'');b.fields.add(key)
       if value and value.type=='function_definition':b.methods.add(key)
  return self

if __name__=='__main__':
 a=Analysis().run()
 out=[]
 for b in a.bindings:
  if b.fields or b.kind=='function' or line(b.node)<650:
   out.append({'id':b.id,'name':b.old,'line':line(b.node),'kind':b.kind,'refs':len(b.refs),'fields':sorted(b.fields),'methods':sorted(b.methods),'values':[{'line':line(v),'type':v.type,'head':text(v).strip()[:160]}for v in b.values[:6]]})
 (ROOT/'bindings_inventory.json').write_text(json.dumps(out,indent=2))
 (ROOT/'statistics.json').write_text(json.dumps({'bindings':len(a.bindings),'functions':len(a.functions),'uses':len(a.uses),'globals':dict(a.unresolved)},indent=2))
 print('Bindings',len(a.bindings),'functions',len(a.functions),'uses',len(a.uses),'unresolved',a.unresolved.most_common(15))
 for b in a.bindings:
  if len(b.methods)>=3:print(b.id,b.old,line(b.node),','.join(sorted(b.methods))[:200])
