local WBP_LockWordTip_C = UnLua.Class()
local LockFloorText = NSLOCTEXT("WBP_LockTip", "LockFloorText", "\228\187\165\228\184\139\233\152\159\229\145\152\230\156\170\232\167\163\233\148\129\232\175\165\233\154\190\229\186\166")
local LockModeText = NSLOCTEXT("WBP_LockTip", "LockFloorText", "\228\187\165\228\184\139\233\152\159\229\145\152\230\156\170\232\167\163\233\148\129\232\175\165\230\168\161\229\188\143")
function WBP_LockWordTip_C:Construct()
end
function WBP_LockWordTip_C:Show(TeamMember, IsMode)
  local TeammateInfos = {
    [1] = self.Teammate_Info,
    [2] = self.Teammate_Info_1
  }
  for i, Widget in ipairs(TeammateInfos) do
    if TeamMember[i] then
      local ShowNameWidget = 1 == i and self.Txt_Name or self.Txt_Name_1
      local ShowHeadWidget = 1 == i and self.ComPortraitItem or self.ComPortraitItem_1
      local TeamMembersInfo = DataMgr.GetTeamMembersInfo()
      local TeamMemberInfo
      for index, v in ipairs(TeamMembersInfo) do
        if v.roleid == TeamMember[i] then
          TeamMemberInfo = v
          break
        end
      end
      ShowNameWidget:SetText(TeamMemberInfo.nickname)
      local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(TeamMemberInfo.portrait)
      if PortraitRowInfo then
        ShowHeadWidget:InitComPortraitItem(PortraitRowInfo.portraitIconPath, PortraitRowInfo.EffectPath)
      end
      UpdateVisibility(Widget, true)
      self:PlayAnimation(self.Ani_in)
      self.Txt_Reason:SetText(IsMode and LockModeText or LockFloorText)
    else
      UpdateVisibility(Widget, false)
    end
  end
end
function WBP_LockWordTip_C:Destruct()
end
return WBP_LockWordTip_C
