#pragma once
namespace stock_native {
// Entity properties are not limited to 16-bit offsets. Bound metadata arithmetic
// to a 1 MiB entity span, checking both addition and the complete field width.
constexpr int netvar_extent=0x100000;
constexpr int netvar_offset(int parent,int relative,int width=4) {
    if(parent<0||relative<0||width<1||width>netvar_extent||
       parent>netvar_extent-width||relative>netvar_extent-width-parent)return -1;
    return parent+relative;
}
}
