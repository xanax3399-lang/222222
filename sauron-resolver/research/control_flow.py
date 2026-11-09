import re
EXIT=-1
def successors(n):
 if n['terminal']:return []
 if n['branch']is not None:return [n['branch']]+([n['next']]if n['condition']else [])
 return [n['next']]if n['next']is not None else []

class Structurer:
 def __init__(self,nodes):
  self.by={n['pc']:n for n in nodes};self.numeric={};self.while_headers={};self.steps=0
  for n in nodes:
   if n['op']==43:
    latch=self.by[n['branch']]
    assert latch['op']==47 and latch['branch']==n['next']
    self.numeric[n['pc']]=latch
   if n['op']==117 and n['branch']<n['pc']:
    header=self.by[n['branch']]
    assert header['condition']and header['branch']>n['pc']
    self.while_headers[header['pc']]=header['branch']
 def postdominators(self,start,boundaries):
  todo=[start];seen=set();succ={}
  while todo:
   pc=todo.pop()
   if pc in seen or pc==EXIT:continue
   seen.add(pc);n=self.by[pc]
   dest=[EXIT if t in boundaries else t for t in successors(n)]or[EXIT]
   succ[pc]=dest;todo+=dest
  universe=seen|{EXIT};pd={pc:universe.copy()for pc in seen};pd[EXIT]={EXIT}
  for _ in range(len(seen)*3+10):
   changed=False
   for pc in sorted(seen,reverse=True):
    value={pc}|set.intersection(*(pd[t]for t in succ[pc]))
    if value!=pd[pc]:pd[pc]=value;changed=True
   if not changed:break
  else:raise AssertionError('Postdominators did not converge')
  return {pc:max(pd[pc]-{pc},key=lambda t:len(pd[t]))for pc in seen}
 def emit(self,start,stop=None,boundaries=None):
  bounds=dict(boundaries or {})
  if stop is not None:bounds[stop]=None
  if start in bounds:return [bounds[start]]if bounds[start]else []
  ipdom=self.postdominators(start,bounds)
  def walk(pc,until,active):
   out=[];seen=set()
   while pc is not None and pc!=EXIT and pc!=until:
    self.steps+=1
    if self.steps>40000:raise AssertionError('Excessive region duplication')
    if pc in bounds:
     if bounds[pc]:out.append(bounds[pc])
     return out
    if pc in seen or pc in active:raise AssertionError(('Unstructured cycle',pc,until))
    seen.add(pc);n=self.by[pc]
    if pc in self.numeric:
     latch=self.numeric[pc];exit=latch['next'];body=self.emit(n['next'],latch['pc'],{**bounds,exit:'break'})
     flag='loop_has_value_%d'%pc
     block=['do','    local '+flag+' = true']+['    '+s for s in n['statements']]
     block+=['    if '+n['condition']+' then']+['        '+s for s in latch['statements']]
     block+=['        '+flag+' = '+latch['condition'],'        if '+flag+' then']+['            '+s for s in latch['on_branch']]+['        end','    else']
     block+=['        '+s for s in n['on_fallthrough']]+['    end','    while '+flag+' do']
     block+=['        '+s for s in body]+['        '+s for s in latch['statements']]
     block+=['        '+flag+' = '+latch['condition'],'        if '+flag+' then']+['            '+s for s in latch['on_branch']]+['        end','    end','end']
     out+=block;pc=exit;continue
    if pc in self.while_headers:
     exit=self.while_headers[pc]
     assert not n['statements']and not n['on_branch']and not n['on_fallthrough']
     body=self.emit(n['next'],pc,{**bounds,exit:'break'})
     out+=['while not ('+n['condition']+') do']+['    '+s for s in body]+['end'];pc=exit;continue
    out+=n['statements']
    if n['terminal']:return out
    if n['branch']is None:pc=n['next'];continue
    if not n['condition']:pc=n['branch'];continue
    join=ipdom.get(pc,EXIT)
    if join in bounds:join=EXIT
    # Each edge keeps the assignments performed by the original branch.
    yes=n['on_branch']+walk(n['branch'],join,active|{pc})
    no=n['on_fallthrough']+walk(n['next'],join,active|{pc})
    if not yes and not no:pass
    elif not yes:out+=['if not ('+n['condition']+') then']+['    '+s for s in no]+['end']
    elif not no:out+=['if '+n['condition']+' then']+['    '+s for s in yes]+['end']
    else:out+=['if '+n['condition']+' then']+['    '+s for s in yes]+['else']+['    '+s for s in no]+['end']
    pc=join
   return out
  return walk(start,stop,set())
