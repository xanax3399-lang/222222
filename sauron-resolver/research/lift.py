"""Translate decoded PSU primitive operations to a standard Lua 5.1 chunk."""
from pathlib import Path
import re,json,struct,collections
R=Path(__file__).resolve().parent
g=json.loads((R/'liftgraph.json').read_text());objects=g['objects']
def table(v):return dict(objects[v['ref']]['items'])
protos=[]
def visit(ref):
 p=table(ref);p['_ref']=ref['ref'];protos.append(p)
 for _,c in sorted(table(p[2]).items()):visit(c)
visit(table(g['root'])['proto'])
parts={int(k):v for k,v in json.loads((R/'parts.json').read_text()).items()}
report=[];compiled={};nups=collections.defaultdict(int)
OP='MOVE LOADK LOADBOOL LOADNIL GETUPVAL GETGLOBAL GETTABLE SETGLOBAL SETUPVAL SETTABLE NEWTABLE SELF ADD SUB MUL DIV MOD POW UNM NOT LEN CONCAT JMP EQ LT LE TEST TESTSET CALL TAILCALL RETURN FORLOOP FORPREP TFORLOOP SETLIST CLOSE CLOSURE VARARG'.split()
def atom(raw):
 if isinstance(raw,dict)and'bytes'in raw:return bytes.fromhex(raw['bytes'])
 if isinstance(raw,str):return raw.encode()
 return raw
class Build:
 def __init__(self,p,fid):self.p=p;self.fid=fid;self.code=table(p[1]);self.nodes={};self.constants=[];self.priority=set();self.maxreg=max(p[3]+2,2);self.pending=[1];self.childrefs=table(p[2]);self.children=[]
 def reg(self,x):assert isinstance(x,int)and x>=0,(self.fid,x);self.maxreg=max(self.maxreg,x+1);return x
 def k(self,x):
  x=atom(x)
  for i,v in enumerate(self.constants):
   if type(x)==type(v)and x==v:return i
  self.constants.append(x);return len(self.constants)-1
 def rk(self,x,const=False):
  if not const:return self.reg(x)
  i=self.k(x);self.priority.add(i);return 256+i
 def compile(self):
  while self.pending:
   pc=self.pending.pop()
   if pc in self.nodes:continue
   assert pc in self.code,('invalid target',self.fid,pc)
   ins=table(self.code[pc]);opcode=ins[1]
   ps=parts[opcode]
   for offset,text in enumerate(ps):
    current=pc+offset
    if current in self.nodes:raise AssertionError(('overlapping macro',self.fid,current))
    fields=table(self.code[current]);a,b,c=fields.get(2),fields.get(3),fields.get(4)
    out=[];targets=[];terminal=False;extra=0
    def emit(op,A=0,B=0,C=0):out.append([op,A,B,C])
    def jump(target):emit('JMP',0,target);targets.append(target)
    def call(ret):
     match=re.search(r'l \[ ([A-Za-z]) \] \( (.*?) \)',text)
     if 'M ( l ,'in text:
      arg=0 if re.search(r'M \( l , [A-Za-z] \+ 1 , Q \)',text)else b-a+1
     elif re.search(r'l \[ [A-Za-z] \] \( l \[ [A-Za-z] \+ 1 \] \)',text):arg=2
     else:arg=1
     emit('CALL',self.reg(a),arg,ret)
     if arg>0:self.reg(a+arg-1)
    # PSU linked bytecode: direct opcode translation, no dispatcher retained.
    if opcode==97:pass
    elif opcode==61:jump(b);terminal=True
    elif opcode in (1,19,36,42,44,46,54,73,76,110):
     lhsconst=opcode in (1,76,110);rhsconst=opcode in (42,44,54,73)
     cmp={1:'>',19:'>=',36:'~=',42:'~=',44:'>=',46:'==',54:'==',73:'<',76:'>=',110:'<'}[opcode]
     lb,rc=self.rk(a,lhsconst),self.rk(c,rhsconst)
     if cmp=='>':lb,rc=rc,lb;cmp='<'
     if cmp=='>=':lb,rc=rc,lb;cmp='<='
     emit({'==':'EQ','~=':'EQ','<':'LT','<=':'LE'}[cmp],1 if cmp=='~='else 0,lb,rc)
     jump(fields[6]);jump(b);terminal=True
    elif opcode in (63,101):
     emit('TEST',self.reg(a),0,1 if opcode==63 else 0);jump(fields[6]);jump(b);terminal=True
    elif opcode==24:
     emit('TEST',self.reg(c),0,0);jump(fields[6]);emit('MOVE',self.reg(a),self.reg(c));jump(b);terminal=True
    elif opcode in (85,98):
     child=self.childrefs[b];emit('CLOSURE',self.reg(a),b)
     descriptors=table(fields[5]) if opcode==98 else {}
     nups[child['ref']]=max(nups[child['ref']],c if opcode==98 else 0)
     for ix,desc in sorted(descriptors.items()):
      dd=table(desc);emit('MOVE' if dd[0]==0 else 'GETUPVAL',0,dd[1],0)
      if dd[0]==0:self.reg(dd[1])
    elif opcode==118:
     emit('FORLOOP',self.reg(a),b);self.reg(a+3);targets.append(b)
    elif opcode==48:
     matches=[q for q,ref in self.code.items() if table(ref).get(1)==118 and table(ref).get(2)==a and table(ref).get(3)==fields[6] and q>current]
     assert len(matches)==1,('for matching',self.fid,current,matches)
     emit('FORPREP',self.reg(a),matches[0]);targets.append(matches[0]);self.reg(a+3)
    elif opcode==115:
     emit('TFORLOOP',self.reg(a),0,c);self.reg(a+c+2);jump(b);jump(fields[6]);terminal=True
    elif opcode in (6,37,39,77,83,111):
     if opcode==83:emit('TAILCALL',self.reg(a),0,0);emit('RETURN',a,0)
     elif opcode==39:emit('RETURN',0,1)
     elif opcode==37:emit('RETURN',self.reg(a),2)
     elif opcode==77:emit('RETURN',self.reg(a),3);self.reg(a+1)
     elif opcode==6:emit('RETURN',self.reg(a),0)
     else:emit('RETURN',self.reg(a),b+2);self.reg(a+b)
     terminal=True
    elif opcode==0:emit('CONCAT',self.reg(a),self.reg(b),self.reg(c))
    elif opcode in (58,114):emit('SETLIST',self.reg(a),0 if opcode==114 else b-a,c)
    elif opcode==82:emit('LOADNIL',self.reg(a),self.reg(b))
    elif opcode==32:emit('VARARG',self.reg(a),0)
    elif opcode in (2,10,11,26,28,51,66,69,78,91,94,96,119):
     args=0 if opcode in (69,91) else 1 if opcode in (11,51,94) else 2 if opcode in (2,10,66,96) else b-a+1
     ret=0 if opcode in (11,28,66,91) else 1 if opcode in (2,78,94) else c-a+2 if opcode in (96,119) else 2
     emit('CALL',self.reg(a),args,ret)
     if args>0:self.reg(a+args-1)
     if ret>1:self.reg(a+ret-2)
    elif opcode in (13,):emit('SELF',self.reg(a),self.reg(b),self.rk(c,True));self.reg(a+1)
    elif opcode in (23,90):emit('NEWTABLE',self.reg(a))
    elif opcode==62:emit('LOADK',self.reg(a),self.k(b))
    elif opcode in (84,112):emit('LOADBOOL',self.reg(a),int(b!=0))
    elif opcode==67:emit('GETUPVAL',self.reg(a),b)
    elif opcode==104:emit('GETGLOBAL',self.reg(a),self.k(b))
    elif opcode==116:emit('MOVE',self.reg(a),self.reg(b))
    elif opcode==117:emit('LEN',self.reg(a),self.reg(b))
    elif opcode==64:emit('UNM',self.reg(a),self.reg(b))
    elif opcode==81:emit('NOT',self.reg(a),self.reg(b))
    elif opcode in (20,120):emit('GETTABLE',self.reg(a),self.reg(b),self.rk(c,opcode==20))
    elif opcode in (3,72,74,75):emit('SETTABLE',self.reg(a),self.rk(b,opcode in (72,74)),self.rk(c,opcode in (3,72)))
    elif opcode in (4,21,27,33,35,45,52,70,71,86,88,92,107):
     name={4:'MOD',21:'MUL',27:'DIV',33:'SUB',35:'SUB',45:'SUB',52:'MUL',70:'POW',71:'MUL',86:'DIV',88:'POW',92:'ADD',107:'ADD'}[opcode]
     emit(name,self.reg(a),self.rk(b,opcode in (33,70,71)),self.rk(c,opcode in (4,21,45,86,88,107)))
    else:raise AssertionError(('unknown opcode',self.fid,current,opcode,text))
    nxt=fields[6]
    if not terminal:targets.append(nxt)
    self.nodes[current]={'ops':out,'next':None if terminal else nxt,'template':text,'fields':fields}
    self.pending+=targets
    if extra:
     assert len(ps)==1;break
    if terminal:break
  # Thread unconditional trampolines and use the standard test+jump layout.
  def resolved(pc):
   seen=set()
   while pc in self.nodes and len(self.nodes[pc]['ops'])==1 and self.nodes[pc]['ops'][0][0]=='JMP':
    if pc in seen:return pc
    seen.add(pc);pc=self.nodes[pc]['ops'][0][2]
   return pc
  aliases={pc:resolved(pc)for pc in self.nodes}
  self.nodes={pc:node for pc,node in self.nodes.items()if aliases[pc]==pc}
  ordered=sorted(self.nodes)
  for idx,pc in enumerate(ordered):
   node=self.nodes[pc]
   for ins in node['ops']:
    if ins[0]in ['JMP','FORLOOP','FORPREP']:ins[2]=aliases.get(ins[2],ins[2])
   if node['next']is not None:node['next']=aliases.get(node['next'],node['next'])
   nextpc=ordered[idx+1]if idx+1<len(ordered)else None
   seq=node['ops']
   if len(seq)==3 and seq[0][0]in ['EQ','LT','LE','TEST','TESTSET','TFORLOOP']and seq[1][0]==seq[2][0]=='JMP':
    if seq[2][2]==nextpc:seq.pop();node['next']=nextpc
    elif seq[1][2]==nextpc and seq[0][0]in ['EQ','LT','LE','TEST']:
     if seq[0][0]=='TEST':seq[0][3]=1-seq[0][3]
     else:seq[0][1]=1-seq[0][1]
     seq[1]=seq[2];seq.pop();node['next']=nextpc
  native=[];positions={}
  for pc in ordered:
   positions[pc]=len(native);node=self.nodes[pc];native+=node['ops']
   if node['next']is not None and node['next']!=(ordered[ordered.index(pc)+1]if ordered.index(pc)+1<len(ordered)else None):native.append(['JMP',0,node['next'],0])
  for pc,node in self.nodes.items():
   for op in node['ops']:
    if op[0]in ['JMP','FORLOOP','FORPREP']:
     assert op[2]in positions,('missing native target',self.fid,op,sorted(positions))
  if not native or native[-1][:3]!=['RETURN',0,1]:native.append(['RETURN',0,1,0])
  self.native=native;self.positions=positions
  assert len(self.priority)<=256,('RK priority overflow',self.fid,len(self.priority))
  order=sorted(self.priority)+[i for i in range(len(self.constants))if i not in self.priority];remap={old:new for new,old in enumerate(order)}
  self.constants=[self.constants[i]for i in order]
  for ins in native:
   if ins[0]in ['LOADK','GETGLOBAL','SETGLOBAL']:ins[2]=remap[ins[2]]
   slots=[3]if ins[0]in ['GETTABLE','SELF']else [2,3]if ins[0]in ['SETTABLE','ADD','SUB','MUL','DIV','MOD','POW','EQ','LT','LE']else []
   for k in slots:
    if ins[k]>=256:ins[k]=256+remap[ins[k]-256]
  report.append({'function':self.fid,'vm_entries':len(self.nodes),'native_instructions':len(native),'constants':len(self.constants),'stack':self.maxreg})
  return self
builders=[]
for fid,p in enumerate(protos):
 b=Build(p,fid);builders.append(b);b.compile()
print('Translated',len(builders),'functions')
(R/'lift_report.json').write_text(json.dumps(report,indent=2)+'\n')

def u32(n):return struct.pack('<I',n)
def string(value):
 if value is None:return struct.pack('<Q',0)
 if isinstance(value,str):value=value.encode()
 return struct.pack('<Q',len(value)+1)+value+b'\0'
def chunk(b):
 data=string('@sauron_recovered')+u32(0)+u32(0)
 assert b.maxreg<=250,('stack too big',b.fid,b.maxreg)
 data+=bytes([nups[b.p['_ref']],b.p[3],2,b.maxreg])
 encoded=[]
 for pc,ins in enumerate(b.native):
  op,a,bb,c=(ins+[0]*4)[:4];num=OP.index(op)
  if op in ['JMP','FORLOOP','FORPREP']:
   bb=b.positions[bb]-pc-1+131071
   assert 0<=bb<262144
   word=num+(a<<6)+(bb<<14)
  elif op in ['LOADK','GETGLOBAL','SETGLOBAL','CLOSURE']:word=num+(a<<6)+(bb<<14)
  else:
   assert isinstance(a,int) and isinstance(bb,int) and isinstance(c,int),('noninteger',b.fid,ins)
   assert 0<=a<256 and 0<=bb<512 and 0<=c<512,('encode',b.fid,ins)
   word=num+(a<<6)+(c<<14)+(bb<<23)
  encoded.append(u32(word))
 data+=u32(len(encoded))+b''.join(encoded)+u32(len(b.constants))
 for k in b.constants:
  if k is None:data+=b'\x00'
  elif isinstance(k,bool):data+=b'\x01'+bytes([int(k)])
  elif isinstance(k,(int,float)):data+=b'\x03'+struct.pack('<d',k)
  elif isinstance(k,bytes):data+=b'\x04'+string(k)
  else:raise ValueError(k)
 children=[next(x for x in builders if x.p['_ref']==ref['ref'])for _,ref in sorted(b.childrefs.items())]
 data+=u32(len(children))+b''.join(chunk(c)for c in children)
 data+=u32(0)+u32(0)+u32(0)
 return data
(R/'recovered.luac').write_bytes(b'\x1bLua\x51\x00\x01\x04\x08\x04\x08\x00'+chunk(builders[0]))
