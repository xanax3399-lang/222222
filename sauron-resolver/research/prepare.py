import json,re
from pathlib import Path
R=Path(__file__).resolve().parent;g=json.loads((R/'graph.json').read_text());O=g['objects'];tab=lambda x:dict(O[x['ref']]['items'])
P=[]
def visit(r):
 p=tab(r);P.append((r['ref'],p))
 for _,c in sorted(tab(p[620912]).items()):visit(c)
visit(tab(g['root'])['proto']);print('prototypes',len(P))
ops=json.loads((R/'opcodes.json').read_text());parts={}
for k,v in ops.items():
 v=re.sub(r'e \[ n \]','e [ 2 ]',v);v=re.sub(r'e \[ a \]','e [ 3 ]',v);v=re.sub(r'e \[ t \]','e [ 4 ]',v)
 v=re.sub(r'\bd \[','L [',v);v=re.sub(r'\bu \[','n [',v);v=re.sub(r'\br \(','M (',v);v=re.sub(r'\bs \(','R (',v);v=re.sub(r'\bc\b','Q',v)
 ps=[re.sub(r'\s*;\s*',';',x).strip('; ') for x in re.split(r'e = e \[ o \] ;?',v)]
 parts[int(k)]=ps
(R/'parts.json').write_text(json.dumps(parts,indent=2));unique=sorted(set(x for v in parts.values()for x in v));(R/'primitives.txt').write_text('\n\n'.join(unique));print('primitives',len(unique));print((R/'primitives.txt').read_text())
# graph adapter
new=[]
def enc(v):
 if not isinstance(v,dict)or 'ref'not in v:return v
 return v
# preserve identities but replace proto/entry keys and refs to index targets
for ob in O:new.append({'id':ob['id'],'items':ob['items']})
for ref,p in P:
 code=tab(p['eG2e3x']);idx={v['ref']:k+1 for k,v in code.items()};rows=[]
 for k,v in sorted(code.items()):
  ins=tab(v);fs={1:ins.get(-747398),2:ins.get('pfr'),3:ins.get(223723),4:ins.get(677648),5:ins.get('dBALt')}
  if isinstance(fs[3],dict)and fs[3].get('ref')in idx:fs[3]=idx[fs[3]['ref']]
  nextref=ins.get(978345);fs[6]=idx.get(nextref.get('ref'))if isinstance(nextref,dict)else None
  new[v['ref']]['items']=list(fs.items());rows.append((k+1,v))
 new[p['eG2e3x']['ref']]['items']=rows
 new[ref]['items']=[(1,p['eG2e3x']),(2,p[620912]),(3,p['XZZq']),(4,p['bhYwMSt'])]
(R/'liftgraph.json').write_text(json.dumps({'objects':new,'root':g['root']}))
