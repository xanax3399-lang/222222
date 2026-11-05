-- Minimal loader. Implementations and capability inventory come from skeet.dll.
-- Requires Gamesense's existing permission for FFI/unsafe scripts.
local ffi = require('ffi')
ffi.cdef[[
typedef struct {
    unsigned int size,abi,loader_state,mode;
    unsigned int points_installed,points_calls,points_added;
    unsigned int brake_enabled,brake_installed,brake_applied;
    unsigned int crown_enabled,crown_installed,crown_added;
    unsigned int fire_installed,guard_enabled,guard_canceled;
    unsigned int recharge_enabled,recharge_overrides;
} GsnlSnapshot;
unsigned int gsnl_abi_version(void);
const char* gsnl_source(unsigned int* length);
int gsnl_snapshot(GsnlSnapshot* output,unsigned int size);
double gsnl_length3(double x,double y,double z);
double gsnl_dot3(double x,double y,double z,double a,double b,double c);
double gsnl_normalize_yaw(double yaw);
typedef struct {
    char magic[16];
    unsigned int abi,size;
    unsigned int (*version)(void);
    const char* (*source)(unsigned int* length);
    int (*snapshot)(GsnlSnapshot*,unsigned int);
    double (*length3)(double,double,double);
    double (*dot3)(double,double,double,double,double,double);
    double (*normalize_yaw)(double);
} GsnlApiTable;
]]
-- GS's FFI omits load and rejects external ffi.C function resolution.
-- Use the documented signature scanner and only our versioned descriptor.
local ok,address=pcall(client.find_signature,'skeet.dll','GSNL_API_V1_TAB!')
assert(ok and address~=nil,'GSNL: matching skeet.dll must already be loaded; bridge descriptor not found')
local descriptor=ffi.cast('const GsnlApiTable*',address)
assert(descriptor~=nil and ffi.string(descriptor.magic,16)=='GSNL_API_V1_TAB!' and
    descriptor.abi==0x10000 and descriptor.size==ffi.sizeof('GsnlApiTable'),'GSNL: invalid bridge descriptor')
assert(descriptor.version~=nil and descriptor.source~=nil and descriptor.snapshot~=nil and
    descriptor.length3~=nil and descriptor.dot3~=nil and descriptor.normalize_yaw~=nil,'GSNL: missing bridge functions')
local native={gsnl_abi_version=descriptor.version,gsnl_source=descriptor.source,
    gsnl_snapshot=descriptor.snapshot,gsnl_length3=descriptor.length3,
    gsnl_dot3=descriptor.dot3,gsnl_normalize_yaw=descriptor.normalize_yaw}
assert(native.gsnl_abi_version()==0x10000,'GSNL: incompatible native ABI')
local length=ffi.new('unsigned int[1]')
local source=native.gsnl_source(length)
assert(source~=nil and length[0]>0 and length[0]<1048576,'GSNL: invalid embedded source')
local factory,err=loadstring(ffi.string(source,length[0]),'@skeet.dll/gsnl')
assert(factory,err)
local gs={environment=_G,client=client,entity=entity,globals=globals,ui=ui,renderer=renderer,
    database=database,json=json or require('json'),bit=bit or require('bit')}
return factory()(native,gs,ffi)
