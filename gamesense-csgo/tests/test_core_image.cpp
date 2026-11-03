#include "../source/skeet/core_image.h"
#include <fstream>
#include <vector>
#include <cassert>
int main(int argc,char** argv) {
    assert(argc==2);std::ifstream in(argv[1],std::ios::binary);
    std::vector<char> data((std::istreambuf_iterator<char>(in)),{});
    assert(core_image::matches_original(data.data(),data.size()));
    assert(!core_image::matches_original(data.data(),data.size()-1));
    data[0x1ffb1]^=1;assert(!core_image::matches_original(data.data(),data.size()));
}
