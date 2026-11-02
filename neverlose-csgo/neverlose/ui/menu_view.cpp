#include "menu_view.h"
#include "imgui.h"
namespace cs2_menu {
void draw(ViewState& s) {
    ImGuiStyle& st=ImGui::GetStyle();
    st.WindowRounding=14; st.ChildRounding=10; st.FrameRounding=6; st.GrabRounding=5;
    st.WindowBorderSize=0; st.ChildBorderSize=1; st.FrameBorderSize=0;
    st.ItemSpacing=ImVec2(12,12); st.FramePadding=ImVec2(12,9);
    auto& c=st.Colors;
    const ImVec4 accent(s.settings.accent[0],s.settings.accent[1],s.settings.accent[2],1);
    c[ImGuiCol_WindowBg]=ImVec4(.055f,.058f,.075f,s.settings.opacity);
    c[ImGuiCol_ChildBg]=ImVec4(.075f,.079f,.10f,1);
    c[ImGuiCol_Border]=ImVec4(.15f,.16f,.20f,1);
    c[ImGuiCol_Text]=ImVec4(.91f,.92f,.96f,1);c[ImGuiCol_TextDisabled]=ImVec4(.48f,.51f,.60f,1);
    c[ImGuiCol_FrameBg]=ImVec4(.12f,.13f,.17f,1);c[ImGuiCol_FrameBgHovered]=ImVec4(.18f,.18f,.25f,1);
    c[ImGuiCol_FrameBgActive]=ImVec4(.22f,.20f,.32f,1);
    c[ImGuiCol_Button]=ImVec4(.13f,.13f,.18f,1);c[ImGuiCol_ButtonHovered]=ImVec4(.25f,.20f,.37f,1);
    c[ImGuiCol_ButtonActive]=accent;c[ImGuiCol_CheckMark]=accent;c[ImGuiCol_SliderGrab]=accent;
    c[ImGuiCol_Header]=ImVec4(.22f,.16f,.34f,1);c[ImGuiCol_HeaderHovered]=ImVec4(.25f,.20f,.38f,1);
    c[ImGuiCol_HeaderActive]=accent;c[ImGuiCol_SliderGrabActive]=accent;
    ImGui::SetNextWindowPos(ImVec2((ImGui::GetIO().DisplaySize.x-820)/2,(ImGui::GetIO().DisplaySize.y-560)/2),ImGuiCond_Always);
    ImGui::SetNextWindowSize(ImVec2(820,560),ImGuiCond_Always);
    ImGui::Begin("Neverlose CS:GO",nullptr,ImGuiWindowFlags_NoDecoration|ImGuiWindowFlags_NoResize|ImGuiWindowFlags_NoMove|ImGuiWindowFlags_NoSavedSettings);
    ImGui::SetWindowFontScale(s.settings.scale);
    ImGui::BeginChild("sidebar",ImVec2(170,0),false,ImGuiWindowFlags_NoScrollbar);
    ImGui::Dummy(ImVec2(1,13));ImGui::TextColored(accent,"N / NEVERLOSE");
    ImGui::TextDisabled("CS:GO LEGACY");ImGui::Dummy(ImVec2(1,35));
    const char* names[]={"Ragebot","Visuals","Interface","Profiles"};
    for(int i=0;i<4;++i){
        ImGui::PushID(i);
        if(ImGui::Selectable(names[i],s.page==i,0,ImVec2(145,39)))s.page=i;
        ImGui::PopID();
    }
    ImGui::SetCursorPosY(ImGui::GetWindowHeight()-66);
    ImGui::TextDisabled("INSERT / HOME");ImGui::TextDisabled("CS:GO Legacy");
    ImGui::EndChild();ImGui::SameLine();
    ImGui::BeginGroup();ImGui::Dummy(ImVec2(1,12));
    ImGui::TextUnformatted(names[s.page]);ImGui::SameLine();ImGui::SetCursorPosX(ImGui::GetWindowWidth()-75);
    if(ImGui::SmallButton("Close"))s.close=true;
    ImGui::TextDisabled(s.page==2?"A familiar look. Your own style.":"Your CS:GO workspace");
    ImGui::Dummy(ImVec2(1,17));
    ImGui::BeginChild("content",ImVec2(ImGui::GetContentRegionAvail().x-10,ImGui::GetContentRegionAvail().y-20),true);
    if(s.page==0){
        ImGui::TextUnformatted("Ragebot settings");ImGui::Separator();
        ImGui::TextWrapped("Use the existing game editor for aiming, accuracy and weapon profiles.");
        ImGui::Dummy(ImVec2(1,12));
        ImGui::BeginDisabled(!s.native_available);
        if(ImGui::Button("Open game settings",ImVec2(240,40)))s.open_native=true;
        ImGui::EndDisabled();
        if(!s.native_available)ImGui::TextWrapped("Press Insert in the game once to enable the game editor.");
        ImGui::Dummy(ImVec2(1,18));ImGui::TextDisabled("Insert closes the game editor again.");
    } else if(s.page==1){
        ImGui::TextUnformatted("Screen overlay");ImGui::Separator();
        ImGui::Checkbox("Watermark",&s.settings.watermark);
        ImGui::Checkbox("Session timer",&s.settings.session_time);
        ImGui::Dummy(ImVec2(1,16));ImGui::TextDisabled("Player and world visuals");
        ImGui::BeginDisabled(!s.native_available);
        if(ImGui::Button("Open game visuals",ImVec2(240,40)))s.open_native=true;
        ImGui::EndDisabled();
    } else if(s.page==2){
        ImGui::TextUnformatted("Appearance");ImGui::Separator();
        ImGui::ColorEdit3("Accent",s.settings.accent,ImGuiColorEditFlags_NoInputs);
        ImGui::SliderFloat("Panel opacity",&s.settings.opacity,.75f,1.f,"%.2f",ImGuiSliderFlags_None);
        ImGui::SliderFloat("Text scale",&s.settings.scale,.85f,1.25f,"%.2fx");
        ImGui::Dummy(ImVec2(1,16));ImGui::TextUnformatted("Live preview");
        ImGui::PushStyleColor(ImGuiCol_Button,accent);ImGui::Button("Neverlose",ImVec2(170,38));ImGui::PopStyleColor();
        ImGui::TextDisabled("Changes apply immediately.");
    } else {
        ImGui::TextUnformatted("Interface profile");ImGui::Separator();
        ImGui::TextWrapped("Save the appearance and screen overlay settings on this computer.");
        if(ImGui::Button("Save profile",ImVec2(170,40)))s.save_profile=true;
        ImGui::SameLine();if(ImGui::Button("Reset appearance",ImVec2(180,40)))s.reset_profile=true;
        if(s.saved)ImGui::TextColored(accent,"Profile saved");
        ImGui::Dummy(ImVec2(1,20));ImGui::TextDisabled("Weapon configurations stay in the game editor.");
    }
    ImGui::EndChild();ImGui::EndGroup();ImGui::End();
}
}
