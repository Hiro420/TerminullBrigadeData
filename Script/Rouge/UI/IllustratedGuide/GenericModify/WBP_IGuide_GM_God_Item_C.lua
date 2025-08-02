local WBP_IGuide_GM_God_Item_C = UnLua.Class()

function WBP_IGuide_GM_God_Item_C:Construct()
  self:InitIGuideItem()
  self:SetSelect(7 == self.GodId)
  self:OnFocusModify()
  self:CheckEffective()
end

function WBP_IGuide_GM_God_Item_C:CheckEffective()
  self.bEffective = true
  UpdateVisibility(self.Overlay_Lock, false)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    return
  end
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local WorldId = LevelSubSystem:GetGameMode()
  local Result, RowInfo = GetRowData(DT.DT_GameMode, WorldId)
  if Result then
    for index, value in ipairs(RowInfo.GenericModifyGroups:ToTable()) do
      if value == self.GodId then
        self.bEffective = true
        return
      end
    end
    UpdateVisibility(self.Overlay_Lock, true)
    self.bEffective = false
  end
end

function WBP_IGuide_GM_God_Item_C:InitIGuideItem()
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnGenericModifyGodItemClicked, WBP_IGuide_GM_God_Item_C.OnGodListItemClicked)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnFocusModify, WBP_IGuide_GM_God_Item_C.OnFocusModify)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnCustomNavigation_God, WBP_IGuide_GM_God_Item_C.OnCustomNavigation_God)
  local Result, RowInfo = GetRowData(DT.DT_GenericModifyGroup, self.GodId)
  if Result then
    SetImageBrushBySoftObject(self.Img_Icon, RowInfo.ChoosePanelIcon)
    SetImageBrushBySoftObject(self.Img_Icon_1, RowInfo.ChoosePanelIcon)
  end
end

function WBP_IGuide_GM_God_Item_C:SetSelect(bSelect)
  UpdateVisibility(self.Overlay_Select_straight, bSelect)
  UpdateVisibility(self.Overlay_Select_inverted, bSelect)
  UpdateVisibility(self.Img_Icon_1, not bSelect)
  if bSelect then
    self.ScaleWidget:SetUserSpecifiedScale(1.1)
    self:SetKeyboardFocus()
  else
    self.ScaleWidget:SetUserSpecifiedScale(1)
  end
end

function WBP_IGuide_GM_God_Item_C:SetCover(bCover)
  UpdateVisibility(self.Img_Cover_4, bCover)
end

function WBP_IGuide_GM_God_Item_C:SetMark(bMark)
  UpdateVisibility(self.Overlay_inverted, bMark)
  UpdateVisibility(self.Overlay_straight, bMark)
end

function WBP_IGuide_GM_God_Item_C:OnGodListItemClicked(GodId)
  self:SetSelect(GodId == self.GodId)
end

function WBP_IGuide_GM_God_Item_C:OnFocusModify()
  if Logic_IllustratedGuide.IsLobbyRoom() then
    self:SetMark(false)
    Logic_IllustratedGuide.CurFocusGenericModifySubGroup = nil
    return
  end
  local bMark = false
  local SubGroups = Logic_IllustratedGuide.CurFocusGenericModifySubGroup
  local GodGroupInfo = Logic_IllustratedGuide.GetAllModifiesOfGroup(self.GodId)
  if GodGroupInfo then
    for key, SubGroup in pairs(SubGroups) do
      if GodGroupInfo[SubGroup] then
        bMark = true
        break
      end
    end
  end
  self:SetMark(bMark)
end

function WBP_IGuide_GM_God_Item_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  PlaySound2DByName(self.ClickSoundName, "WBP_IGuide_GM_God_Item_C")
  if not Logic_IllustratedGuide.IsLobbyRoom() and not self.bEffective then
    ShowWaveWindow(102002)
    return
  end
  EventSystem.Invoke(EventDef.IllustratedGuide.OnGenericModifyGodItemClicked, self.GodId)
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_IGuide_GM_God_Item_C:OnMouseEnter(MyGeometry, MouseEvent)
  PlaySound2DByName(self.HoverSoundName, "WBP_IGuide_GM_God_Item_C")
  self:SetCover(true)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    EventSystem.Invoke(EventDef.IllustratedGuide.OnGenericModifyGodItemHover, self.GodId, true)
  end
end

function WBP_IGuide_GM_God_Item_C:OnMouseLeave(MyGeometry, MouseEvent)
  self:SetCover(false)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    EventSystem.Invoke(EventDef.IllustratedGuide.OnGenericModifyGodItemHover, self.GodId, false)
  end
end

function WBP_IGuide_GM_God_Item_C:OnCustomNavigation_God(GodId)
  if self.GodId == GodId then
    self:SetKeyboardFocus()
  end
end

return WBP_IGuide_GM_God_Item_C
