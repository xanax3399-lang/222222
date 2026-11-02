#include "../neverlose/ui/menu_view.h"
#include "imgui.h"
#include <algorithm>
#include <cassert>
#include <cmath>
#include <cstdio>
#include <fstream>
#include <string>
#include <vector>
static void frame(cs2_menu::ViewState& s){auto& io=ImGui::GetIO();io.DisplaySize=ImVec2(820,560);io.DeltaTime=1.f/60;ImGui::NewFrame();cs2_menu::draw(s);ImGui::Render();assert(ImGui::GetDrawData()->TotalVtxCount>100);}
static void render(const std::string& name,const unsigned char* atlas,int tw,int th){
    const int width=820,height=560;std::vector<unsigned char> pixels(width*height*3,10);
    auto cross=[](ImVec2 a,ImVec2 b,ImVec2 p){return (b.x-a.x)*(p.y-a.y)-(b.y-a.y)*(p.x-a.x);};
    auto data=ImGui::GetDrawData();
    for(const ImDrawList* list:data->CmdLists){for(const auto& cmd:list->CmdBuffer){if(cmd.UserCallback)continue;
      for(unsigned idx=cmd.IdxOffset;idx<cmd.IdxOffset+cmd.ElemCount;idx+=3){
        const auto& a=list->VtxBuffer[list->IdxBuffer[idx]+cmd.VtxOffset];const auto& b=list->VtxBuffer[list->IdxBuffer[idx+1]+cmd.VtxOffset];const auto& c=list->VtxBuffer[list->IdxBuffer[idx+2]+cmd.VtxOffset];
        float area=cross(a.pos,b.pos,c.pos);if(std::abs(area)<.001f)continue;
        int x0=std::max({0,int(std::floor(std::min({a.pos.x,b.pos.x,c.pos.x}))),int(cmd.ClipRect.x)}),x1=std::min({width,int(std::ceil(std::max({a.pos.x,b.pos.x,c.pos.x}))),int(cmd.ClipRect.z)});
        int y0=std::max({0,int(std::floor(std::min({a.pos.y,b.pos.y,c.pos.y}))),int(cmd.ClipRect.y)}),y1=std::min({height,int(std::ceil(std::max({a.pos.y,b.pos.y,c.pos.y}))),int(cmd.ClipRect.w)});
        for(int y=y0;y<y1;++y)for(int x=x0;x<x1;++x){ImVec2 p(x+.5f,y+.5f);float u=cross(b.pos,c.pos,p)/area,v=cross(c.pos,a.pos,p)/area,w=1-u-v;if(u<0||v<0||w<0)continue;
          int tx=std::clamp(int((a.uv.x*u+b.uv.x*v+c.uv.x*w)*tw),0,tw-1),ty=std::clamp(int((a.uv.y*u+b.uv.y*v+c.uv.y*w)*th),0,th-1);
          auto ch=[&](unsigned shift){return float((a.col>>shift)&255)*u+float((b.col>>shift)&255)*v+float((c.col>>shift)&255)*w;};
          float alpha=(ch(24)/255.f)*(atlas[(ty*tw+tx)*4+3]/255.f);
          for(int k=0;k<3;++k){float col=ch(k*8)*atlas[(ty*tw+tx)*4+k]/255.f;pixels[(y*width+x)*3+k]=(unsigned char)(col*alpha+pixels[(y*width+x)*3+k]*(1-alpha));}
        }
      }
    }}
    std::ofstream out(name,std::ios::binary);out<<"P6\n"<<width<<" "<<height<<"\n255\n";out.write((char*)pixels.data(),pixels.size());
}
int main(int argc,char** argv){
    ImGui::CreateContext();auto& io=ImGui::GetIO();io.IniFilename=nullptr;ImFontConfig cfg;cfg.SizePixels=16;io.Fonts->AddFontDefault(&cfg);
    unsigned char* tex;int w,h;io.Fonts->GetTexDataAsRGBA32(&tex,&w,&h);io.Fonts->SetTexID((ImTextureID)1);
    cs2_menu::ViewState s;std::string out=argc>1?argv[1]:".";
    for(int page=0;page<4;++page){s.page=page;frame(s);frame(s);render(out+"/menu-page-"+std::to_string(page)+".ppm",tex,w,h);}
    s.page=2;io.AddMousePosEvent(762,40);frame(s);io.AddMouseButtonEvent(0,true);frame(s);io.AddMouseButtonEvent(0,false);frame(s);
    assert(s.close && "Close button must respond to pointer input");
    s.close=false;
    auto click=[&](float x,float y){io.AddMousePosEvent(x,y);frame(s);io.AddMouseButtonEvent(0,true);frame(s);io.AddMouseButtonEvent(0,false);frame(s);};
    click(70,297);assert(s.page==3 && "Sidebar must navigate to Profiles");
    click(275,212);assert(s.save_profile && "Save profile action must be dispatched");
    click(470,212);assert(s.reset_profile && "Reset action must be dispatched");

    ImGui::DestroyContext();std::puts("PASS: four pages rendered; Close, sidebar navigation, Save and Reset clicks dispatched");
}
