#include "yaw_binding.h"
#include <cstdio>
#include <cstdlib>
#include <initializer_list>
using namespace stock_native;
static unsigned checks=0;
static void check(YawSpec spec,int offset,unsigned expected){unsigned method=99;const int got=yaw_component(spec,method);++checks;if(got!=offset||method!=expected){std::fprintf(stderr,"yaw binding FAIL: %s got %d/%u\n",spec.name?spec.name:"null",got,method);std::exit(1);}}
int main(){
 check({"m_angEyeAngles[1]",1,0xb348,1,0,-1},0xb348,YawScalar);
 for(const char* name:{"m_angEyeAngles","m_angEyeAngles[0]"}) {
  for(int type:{2,3})check({name,type,0xb344,1,0,-1},0xb348,YawVector);
  check({name,5,0xb344,3,4,1},0xb348,YawArray);
  check({name,5,0xb344,2,8,1},0xb34c,YawArray);
  check({name,1,0xb344,1,0,-1},-1,YawUnavailable); // Pitch alone cannot establish yaw.
  check({name,5,0xb344,1,4,1},-1,YawUnavailable);
  check({name,5,0xb344,3,3,1},-1,YawUnavailable);
  check({name,5,0xb344,3,4,0},-1,YawUnavailable);
  check({name,4,0xb344,3,4,1},-1,YawUnavailable);
 }
 check({"m_angEyeAngles[1]",0,0xb348,1,0,-1},-1,YawUnavailable);
 check({"unrelated",2,0xb344,3,4,1},-1,YawUnavailable);
 check({nullptr,2,0xb344,3,4,1},-1,YawUnavailable);
 check({"m_angEyeAngles",2,0xffff,3,4,1},-1,YawUnavailable);
 check({"m_angEyeAngles",2,-4,3,4,1},-1,YawUnavailable);
 std::printf("{\"checks\":%u,\"typed_vector_and_array_yaw\":true,\"unpaired_pitch_rejected\":true,\"gameplay_tested\":false}\n",checks);
}
