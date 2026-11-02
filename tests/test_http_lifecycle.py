from pathlib import Path
from lupa.luajit21 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]

FIXTURE = '''
records, responses, schedule_count = {}, {}, 0
truthy_iterator=function(f,s,c) return f,s,c end
ffi={new=function() return {[0]=0} end,
     string=function(buffer,len) return buffer.data:sub(1,len) end}
local function live(handle)
    local r=assert(records[handle]); assert(not r.released, "Use after release")
    return r
end
value_50={}
value_55=function(_,handle,key,size) live(handle); size[0]=10; return true end
value_56=function(_,handle,key,buf,len) live(handle); buf.data='text/plain'; return true end
value_57=function(_,handle,size)
    local r=live(handle); if not r.ready then return false end
    size[0]=#r.body; return true
end
value_58=function(_,handle,buf,size) buf.data=live(handle).body; return true end
value_60=function(_,handle) live(handle).released=true end
client={delay_call=function(_,fn) assert(type(fn)=='function'); schedule_count=schedule_count+1 end}
'''

CASES = '''
local function request(client, handle, ready, body, callback)
    records[handle]={ready=ready,body=body}
    client.requests[#client.requests+1]=Request.new(handle, 'fixture', callback or function(response)
        responses[#responses+1]=response
    end)
end
local a=Http.new({timeout=1})
request(a,1,true,'a')
request(a,2,true,'b')
Http._process_tasks(a)
assert(#a.requests==0 and #responses==2)
assert(responses[1].state==Http.state.ok and responses[2].state==Http.state.ok)
assert(responses[1].header.content_type=='text/plain')
assert(records[1].released and records[2].released)
-- Successful completion at the timeout boundary must not also time out.
Http._process_tasks(a)
assert(#responses==2)
request(a,3,false,'pending')
Http._process_tasks(a)
assert(#responses==3 and responses[3].state==Http.state.timed_out)
assert(records[3].released)
request(a,4,true,'')
Http._process_tasks(a)
assert(#responses==4 and responses[4].state==Http.state.no_response)
-- A callback may add a request; the new request waits until the next poll.
request(a,5,true,'enqueue',function(response)
    responses[#responses+1]=response
    request(a,6,true,'later')
end)
Http._process_tasks(a)
assert(#responses==5 and #a.requests==1 and not records[6].released)
Http._process_tasks(a)
assert(#responses==6 and #a.requests==0 and records[6].released)
-- Pending requests keep their handles, then complete on a later poll.
local b=Http.new({timeout=3})
request(b,7,false,'delayed')
Http._process_tasks(b)
assert(#b.requests==1 and b.requests[1].ticks==1 and not records[7].released)
records[7].ready=true
Http._process_tasks(b)
assert(#b.requests==0 and responses[7].state==Http.state.ok)
return 7
'''

def run():
    source = (ROOT/'outlaw_source.lua').read_text()
    section = source.split('    local index = {}\n    index.new =',1)[1]
    section = 'local index = {}\nindex.new =' + section.split('    local state = { task_interval = 0.1, timeout = 25 }',1)[0]
    lua=LuaRuntime()
    lua.execute(FIXTURE)
    lua.globals().Http, lua.globals().Request = lua.execute(section+'\nreturn index_3,index')
    assert callable(lua.globals().Http._get_header)
    return lua.execute(CASES)

if __name__ == '__main__':
    print('HTTP lifecycle:',run(),'request outcomes checked')
