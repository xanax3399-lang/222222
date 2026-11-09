from pathlib import Path
import json,re
from lupa.lua54 import LuaRuntime
ROOT=Path(__file__).resolve().parent
t=json.loads((ROOT/'tokens.json').read_text())
stack=[];ifs={}
for i,v in enumerate(t):
 if v in ('if','function','while','for','repeat','do'):
  if v=='do'and stack and stack[-1].get('await_do'):
   stack[-1]['await_do']=False;continue
  stack.append({'kind':v,'start':i,'await_do':v in ('while','for'),'branches':[]})
 elif v=='then':
  assert stack[-1]['kind']=='if'
  node=stack[-1]
  a=node.get('cond_start',node['start']+1)
  node['branches'].append({'condition':t[a:i],'start':i+1})
 elif v in ('elseif','else'):
  assert stack[-1]['kind']=='if'
  node=stack[-1];node['branches'][-1]['end']=i
  if v=='elseif':node['cond_start']=i+1
  else:node['branches'].append({'condition':None,'start':i+1})
 elif v=='end':
  node=stack.pop();assert node['kind']!='repeat'
  if node['kind']=='if':
   node['end']=i;node['branches'][-1]['end']=i;ifs[node['start']]=node
 elif v=='until':
  node=stack.pop();assert node['kind']=='repeat'
assert not stack
lua=LuaRuntime()
def prune(a,b,op):
 out=[];i=a
 while i<b:
  n=ifs.get(i)
  if n and all(x['condition']is None or all(re.fullmatch(r'\d+|i|not|and|or|[()<>=~]+',z)for z in x['condition'])for x in n['branches']):
   for branch in n['branches']:
    cond=branch['condition']
    if cond is None or lua.eval('function(i)return '+' '.join(cond)+' end')(op):
     out+=prune(branch['start'],branch['end'],op);break
   i=n['end']+1
  else:out.append(t[i]);i+=1
 return out
start=next(i for i in ifs if t[i:i+5]==['if','(','i','<=','59'])
end=ifs[start]['end']+1
ops={str(op):' '.join(prune(start,end,op))for op in range(121)}
(ROOT/'opcodes.json').write_text(json.dumps(ops,indent=2))
(ROOT/'opcodes.txt').write_text('\n\n'.join(str(k)+': '+v for k,v in ops.items())+'\n')
print('opcode bodies',len(ops))
