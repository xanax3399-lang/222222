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
void* __stdcall GetModuleHandleA(const char* name);
void* __stdcall GetProcAddress(void* module, const char* name);
]]
local kernel = ffi.load('kernel32.dll')
local module = kernel.GetModuleHandleA('skeet.dll')
assert(module~=nil,'GSNL: matching skeet.dll must already be loaded; this loader never injects or loads another core')
local native={}
local signatures={gsnl_abi_version='unsigned int(*)(void)',gsnl_source='const char*(*)(unsigned int*)',
    gsnl_snapshot='int(*)(GsnlSnapshot*,unsigned int)',gsnl_length3='double(*)(double,double,double)',
    gsnl_dot3='double(*)(double,double,double,double,double,double)',gsnl_normalize_yaw='double(*)(double)'}
for name,signature in pairs(signatures)do
    local address=kernel.GetProcAddress(module,name)
    assert(address~=nil,'GSNL: missing '..name..'; update skeet.dll and injector from the API-bridge archive')
    native[name]=ffi.cast(signature,address)
end
assert(native.gsnl_abi_version()==0x10000,'GSNL: incompatible native ABI')
local length=ffi.new('unsigned int[1]')
local source=native.gsnl_source(length)
assert(source~=nil and length[0]>0 and length[0]<1048576,'GSNL: invalid embedded source')
local factory,err=loadstring(ffi.string(source,length[0]),'@skeet.dll/gsnl')
assert(factory,err)
local gs={environment=_G,client=client,entity=entity,globals=globals,ui=ui,renderer=renderer,
    database=database,json=json or require('json'),bit=bit or require('bit')}
return factory()(native,gs,ffi)
