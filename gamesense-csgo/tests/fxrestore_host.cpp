// Independent real-host check of FXSAVE/FXRSTOR environment restoration.
// This does not load the game, PE files or the recovered core.
#include <cstdio>
int main() {
    alignas(16) unsigned char before[512]{},after[512]{};
    asm volatile("fninit; fld1; fldpi; fxsave %0; fldln2; fxrstor %0; fxsave %1"
                 : "+m"(before),"=m"(after) : : "memory");
    int differences=0;
    for(int i=0;i<512;++i)if(before[i]!=after[i])++differences;
    std::printf("Real-host FXSAVE/FXRSTOR byte differences: %d\n",differences);
    return differences!=0;
}
