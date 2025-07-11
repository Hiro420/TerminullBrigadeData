local WBP_SingleHeroTalentIconItem_C = UnLua.Class()
local BottomStyle = {
  Gray = {
    BottomImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_12_png.RolePower_DNA_12_png",
    BottomBGImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_12_png.RolePower_DNA_12_png",
    SmallIconImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_07_png.RolePower_DNA_07_png",
    SmallFrameImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_06_png.RolePower_DNA_06_png"
  },
  Normal = {
    BottomImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_09_png.RolePower_DNA_09_png",
    BottomBGImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_08_png.RolePower_DNA_08_png",
    SmallIconImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_03_png.RolePower_DNA_03_png",
    SmallFrameImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_02_png.RolePower_DNA_02_png"
  },
  Selected = {
    BottomImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_11_png.RolePower_DNA_11_png",
    BottomBGImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_10_png.RolePower_DNA_10_png",
    SmallIconImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_05_png.RolePower_DNA_05_png",
    SmallFrameImg = "/Game/Rouge/UI/Texture/Role_new/Frames/RolePower_DNA_04_png.RolePower_DNA_04_png"
  }
}
function WBP_SingleHeroTalentIconItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_SingleHeroTalentIconItem_C.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, WBP_SingleHeroTalentIconItem_C.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, WBP_SingleHeroTalentIconItem_C.BindOnMainButtonUnHovered)
end
function WBP_SingleHeroTalentIconItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Lobby.HeroTalentIconItemClicked, self.TalentId)
end
function WBP_SingleHeroTalentIconItem_C:BindOnMainButtonHovered()
  self.Img_Hover:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end
function WBP_SingleHeroTalentIconItem_C:BindOnMainButtonUnHovered()
  self.Img_Hover:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_SingleHeroTalentIconItem_C:Show(TalentId, CurHeroId)
  if not TalentId or 0 == TalentId then
    self:Hide()
    return
  end
  self.CurHeroId = CurHeroId
  self.TalentId = TalentId
  self:SetVisibility(UE.ESlateVisibility.Visible)
  EventSystem.AddListener(self, EventDef.Lobby.HeroTalentIconItemClicked, WBP_SingleHeroTalentIconItem_C.BindOnHeroTalentIconItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateHeroTalentInfo, WBP_SingleHeroTalentIconItem_C.BindOnUpdateHeroTalentInfo)
  self.IsBound = true
  self:RefreshStatus()
  self:RefreshBottomStyle()
end
function WBP_SingleHeroTalentIconItem_C:RefreshBottomStyle()
  local CurLevel = DataMgr.GetHeroTalentLevelById(self.CurHeroId, self.TalentId)
  local MaxCanUpgradeLevel = LogicTalent.GetHeroTalentMaxCanUpgradeLevel(self.CurHeroId, self.TalentId)
  local Style
  if self.IsSelected then
    Style = BottomStyle.Selected
  elseif 0 == MaxCanUpgradeLevel or 0 == CurLevel and not LogicTalent.IsMeetHeroTalentRoleLevelCondition(self.CurHeroId, self.TalentId, CurLevel) then
    Style = BottomStyle.Gray
  else
    Style = BottomStyle.Normal
  end
  if not Style then
    return
  end
  SetImageBrushByPath(self.Img_Bottom, Style.BottomImg)
  SetImageBrushByPath(self.Img_BGBottom, Style.BottomBGImg)
  if not self.IsRight then
    SetImageBrushByPath(self.Img_LeftFrame, Style.SmallFrameImg)
    SetImageBrushByPath(self.Img_LeftIcon, Style.SmallIconImg)
  else
    SetImageBrushByPath(self.Img_RightFrame, Style.SmallFrameImg)
    SetImageBrushByPath(self.Img_RightIcon, Style.SmallIconImg)
  end
end
function WBP_SingleHeroTalentIconItem_C:RefreshStatus()
  local CurLevel = DataMgr.GetHeroTalentLevelById(self.CurHeroId, self.TalentId)
  local MaxCanUpgradeLevel = LogicTalent.GetHeroTalentMaxCanUpgradeLevel(self.CurHeroId, self.TalentId)
  self.Img_Lock:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Hover:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Txt_Progress:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  if 0 == MaxCanUpgradeLevel or 0 == CurLevel and not LogicTalent.IsMeetHeroTalentRoleLevelCondition(self.CurHeroId, self.TalentId, CurLevel) then
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  end
  self.Txt_Progress:SetText("LV." .. CurLevel)
  self:RefreshCanUpgradePanelStatus()
end
function WBP_SingleHeroTalentIconItem_C:RefreshCanUpgradePanelStatus()
  self.UpgradePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  local CurLevel = DataMgr.GetHeroTalentLevelById(self.CurHeroId, self.TalentId)
  if not LogicTalent.IsMeetPreHeroTalentGroupCondition(self.CurHeroId, self.TalentId, CurLevel + 1) then
    return
  end
  if LogicTalent.IsMeetHeroTalentRoleLevelCondition(self.CurHeroId, self.TalentId, CurLevel + 1) and LogicTalent.IsMeetHeroTalentUpgradeCostCondition(self.CurHeroId, self.TalentId, CurLevel + 1) then
    self.UpgradePanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  end
end
function WBP_SingleHeroTalentIconItem_C:BindOnHeroTalentIconItemClicked(TalentId)
  if TalentId == self.TalentId then
    self.IsSelected = true
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.IsSelected = false
    self.Img_Selected:SetVisibility(UE.ESlateVisibility.Hidden)
  end
  self:RefreshBottomStyle()
end
function WBP_SingleHeroTalentIconItem_C:BindOnUpdateHeroTalentInfo(HeroId)
  if HeroId ~= self.CurHeroId then
    return
  end
  self:RefreshStatus()
end
function WBP_SingleHeroTalentIconItem_C:Hide()
  self.IsBound = false
  self.TalentId = 0
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.HeroTalentIconItemClicked, WBP_SingleHeroTalentIconItem_C.BindOnHeroTalentIconItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateHeroTalentInfo, WBP_SingleHeroTalentIconItem_C.BindOnUpdateHeroTalentInfo, self)
end
function WBP_SingleHeroTalentIconItem_C:Destruct()
  self:Hide()
end
return WBP_SingleHeroTalentIconItem_C
