local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local HeirloomHandler = require("Protocol.Appearance.Heirloom.HeirloomHandler")
local RedDotData = require("Modules.RedDot.RedDotData")
local EscName = "PauseGame"
local HideAppearanceView = "HideAppearanceView"
local SubViewId = {
  ViewID.UI_Skin,
  ViewID.UI_Heirloom,
  ViewID.UI_Communication
}
local CurrentSelectIndex = 1
local ToggleItemList = {}
local AppearanceView = Class(ViewBase)

function AppearanceView:OnBindUIInput()
  self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.OnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.OnSelectNextMenu)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
end

function AppearanceView:OnUnBindUIInput()
  self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.OnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.OnSelectNextMenu)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
end

function AppearanceView:BindClickHandler()
  self.RGToggleGroupFirst.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
end

function AppearanceView:UnBindClickHandler()
  self.RGToggleGroupFirst.OnCheckStateChanged:Remove(self, self.OnFirstGroupCheckStateChanged)
end

function AppearanceView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("AppearanceViewModel")
  self:BindClickHandler()
end

function AppearanceView:OnDestroy()
  self:UnBindClickHandler()
end

function AppearanceView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.viewModel:UpdateCurHeroId(...)
  self.RGToggleGroupFirst:SelectId(EAppearanceToggleStatus.Skin)
  CurrentSelectIndex = 1
  EventSystem.AddListener(self, EventDef.Heirloom.ChangeAppearanceViewToggleGroupSelect, self.BindOnChangeAppearanceViewToggleGroupSelect)
  local tbParam = {
    ...
  }
  local CurHeroId = tbParam[1]
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if CharacterTable and CharacterTable[CurHeroId] then
    self.RGTextRoleName:SetText(CharacterTable[CurHeroId].Name)
  end
  local TargetEquippedInfo = DataMgr.GetEquippedWeaponList(CurHeroId)
  if not TargetEquippedInfo then
    LogicOutsideWeapon.RequestEquippedWeaponInfo(CurHeroId)
  end
  self.bIsAppearanceViewIsShow = false
  self:ListenForUpdateAppearanceShowInputAction()
  ToggleItemList = {}
  table.insert(ToggleItemList, EAppearanceToggleStatus.Skin)
  local TargetHeirloomId = -1
  local AllHeirloomIds = HeirloomData:GetAllHeirloomByHeroId(CurHeroId)
  for index, SingleHeirloomId in ipairs(AllHeirloomIds) do
    TargetHeirloomId = SingleHeirloomId
    break
  end
  if -1 == TargetHeirloomId then
    self.HeirloomButtonPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.HeirloomButtonPanel:SetVisibility(UE.ESlateVisibility.Visible)
    table.insert(ToggleItemList, EAppearanceToggleStatus.Heirloom)
  end
  table.insert(ToggleItemList, EAppearanceToggleStatus.Communication)
  self.SkinRedDotView:ChangeRedDotIdByTag(CurHeroId)
  self.HeirloomRedDotView:ChangeRedDotIdByTag(CurHeroId)
  self.CommunicationRedDotView:ChangeRedDotIdByTag(CurHeroId)
end

function AppearanceView:OnShowLink(LinkParams)
  local firstToggleIdx = 1
  if LinkParams:IsValidIndex(1) then
    firstToggleIdx = LinkParams:GetRef(1).IntParam
  end
  self.RGToggleGroupFirst:SelectId(firstToggleIdx)
  self.viewModel:SwitchLink(firstToggleIdx, LinkParams)
end

function AppearanceView:BindOnChangeAppearanceViewToggleGroupSelect(AppearanceToggleStatus)
  self.RGToggleGroupFirst:SelectId(AppearanceToggleStatus)
end

function AppearanceView:OnHide()
  LogicRole.HideAndUnloadAllBgStreamLevel()
  UpdateVisibility(self.CanvasPanelRoot, true)
  EventSystem.RemoveListener(EventDef.Heirloom.ChangeAppearanceViewToggleGroupSelect, self.BindOnChangeAppearanceViewToggleGroupSelect, self)
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end

function AppearanceView:ListenForEscInputAction(bWithoutAni)
  for i, v in ipairs(SubViewId) do
    local luaInst = UIMgr:GetLuaFromActiveView(v)
    if luaInst and UE.RGUtil.IsUObjectValid(luaInst) then
      UpdateVisibility(luaInst, true)
    end
    UIMgr:Hide(v, nil, nil, bWithoutAni)
  end
  UIMgr:Hide(ViewID.UI_Apearance, true, nil, bWithoutAni)
end

function AppearanceView:ListenForUpdateAppearanceShowInputAction()
  local skinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
  if UE.RGUtil.IsUObjectValid(skinView) and CheckIsVisility(self.WBP_AppearanceMovieList) then
    return
  end
  local heirloomView = UIMgr:GetLuaFromActiveView(ViewID.UI_Heirloom)
  if UE.RGUtil.IsUObjectValid(heirloomView) and CheckIsVisility(self.WBP_AppearanceMovieList) then
    return
  end
  if UIMgr:IsShow(ViewID.UI_Communication) then
    return
  end
  if self.bIsAppearanceViewIsShow then
    self.bIsAppearanceViewIsShow = false
  else
    self.bIsAppearanceViewIsShow = true
  end
  for i, v in ipairs(SubViewId) do
    local luaInst = UIMgr:GetLuaFromActiveView(v)
    if luaInst and UE.RGUtil.IsUObjectValid(luaInst) then
      UpdateVisibility(luaInst.CanvasPanelRoot, self.bIsAppearanceViewIsShow)
    end
  end
  UpdateVisibility(self.CanvasPanelRoot, self.bIsAppearanceViewIsShow)
end

function AppearanceView:UpdateUIColor(UIColor)
  self.RGTextTitle:SetColorAndOpacity(UIColor)
  self.RGTextRoleName:SetColorAndOpacity(UIColor)
end

function AppearanceView:OnFirstGroupCheckStateChanged(SelectId)
  print("AppearanceView:OnFirstGroupCheckStateChanged", SelectId)
  if SelectId == EAppearanceToggleStatus.Heirloom then
    LuaAddClickStatistics("AppearanceHeirloom")
  end
  self.viewModel:Switch(SelectId)
end

function AppearanceView:OnSelectPrevMenu()
  CurrentSelectIndex = CurrentSelectIndex - 1
  if CurrentSelectIndex < 1 then
    CurrentSelectIndex = #ToggleItemList
  end
  self.RGToggleGroupFirst:SelectId(ToggleItemList[CurrentSelectIndex])
end

function AppearanceView:OnSelectNextMenu()
  CurrentSelectIndex = CurrentSelectIndex + 1
  if CurrentSelectIndex > #ToggleItemList then
    CurrentSelectIndex = 1
  end
  self.RGToggleGroupFirst:SelectId(ToggleItemList[CurrentSelectIndex])
end

return AppearanceView
