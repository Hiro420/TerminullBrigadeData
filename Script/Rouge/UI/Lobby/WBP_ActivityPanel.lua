local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local PandoraModule = require("Modules.Pandora.PandoraModule")
local RedDotData = require("Modules.RedDot.RedDotData")
local WBP_ActivityPanel = Class(ViewBase)
function WBP_ActivityPanel:BindClickHandler()
end
function WBP_ActivityPanel:UnBindClickHandler()
end
function WBP_ActivityPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_ActivityPanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_ActivityPanel:OnShowLink(LinkParams, HeroId, ActivityIds, bByPandora, SecondTab, jumpParams)
  if ActivityIds and type(ActivityIds) == "table" and ActivityIds[1] then
    EventSystem.Invoke(EventDef.Activity.OnChangeActivityItemSelected, ActivityIds[1])
    if not self:IsAnimationPlaying(self.Ani_in) then
      self:PlayAnimation(self.Ani_in)
    end
    return
  elseif LinkParams:IsValidIndex(0) then
    local ActivityId = LinkParams:Get(0).IntParam
    if ActivityId then
      EventSystem.Invoke(EventDef.Activity.OnChangeActivityItemSelected, ActivityId)
      return
    end
  end
  if bByPandora then
    EventSystem.Invoke(EventDef.Activity.OnPandoraActivityTabSelected, SecondTab or "Other", jumpParams)
    return
  end
end
function WBP_ActivityPanel:OnShow(TargetActivityId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  EventSystem.AddListenerNew(EventDef.Activity.OnChangeActivityItemSelected, self, self.BindOnChangeActivityItemSelected)
  EventSystem.AddListenerNew(EventDef.Activity.OnPandoraRefreshActivitiesTab, self, self.BindRefreshActivitiesTab)
  EventSystem.AddListenerNew(EventDef.Activity.OnPandoraActivityTabSelected, self, self.BindOnPandoraActivityTabSelected)
  self:BindRefreshActivitiesTab()
  if TargetActivityId then
    EventSystem.Invoke(EventDef.Activity.OnChangeActivityItemSelected, TargetActivityId)
  end
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  if not self:IsAnimationPlaying(self.Ani_in) then
    self:PlayAnimation(self.Ani_in)
  end
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_ActivityPanel:BindRefreshActivitiesTab(bRefreshData)
  self.ActivityTabInfo = {}
  local Item = GetOrCreateItem(self.SecondaryTab, 1, self.SecondaryTabTem:StaticClass())
  local OtherName = NSLOCTEXT("WBP_ActivityPanel", "ActivityName", "\230\180\187\229\138\168")
  Item.Txt_MenuName:SetText(OtherName())
  Item.Txt_MenuNameSelected:SetText(OtherName())
  self.ActivityTabInfo.Other = Item
  UpdateVisibility(self.Overlay_SecondaryTab, false)
  Item:BindOnClicked(self, function()
    EventSystem.Invoke(EventDef.Activity.OnPandoraActivityTabSelected, "Other")
  end)
  UpdateVisibility(Item, true)
  if not bRefreshData then
    EventSystem.Invoke(EventDef.Activity.OnPandoraActivityTabSelected, "Other")
  end
  HideOtherItem(self.SecondaryTab, 2, true)
  if not PandoraModule.ActivityTabInfo then
    return
  end
  local Index = 2
  for index, Obj in ipairs(PandoraModule.ActivityTabInfo) do
    UpdateVisibility(self.Overlay_SecondaryTab, true)
    local Item = GetOrCreateItem(self.SecondaryTab, Index, self.SecondaryTabTem:StaticClass())
    UpdateVisibility(Item, true)
    Item.Txt_MenuName:SetText(Obj.tabName)
    Item.Txt_MenuNameSelected:SetText(Obj.tabName)
    self.ActivityTabInfo[Obj.appId] = Item
    if not bRefreshData then
      Item:SetSelect(false)
    end
    Item:BindOnClicked(self, function()
      EventSystem.Invoke(EventDef.Activity.OnPandoraActivityTabSelected, Obj.appId)
    end)
    local IsNewCreate = RedDotData:CreateRedDotState(tonumber(Obj.appId), "Activity_Tab")
    local RedDotState = {}
    RedDotState.Num = tonumber(Obj.redPoint)
    RedDotData:UpdateRedDotState(tonumber(Obj.appId), RedDotState)
    Index = Index + 1
    Item.WBP_RedDotView:ChangeRedDotId(tonumber(Obj.appId), "Activity_Tab")
  end
  HideOtherItem(self.SecondaryTab, Index, true)
  if not bRefreshData then
    local NewTargetActivityId = self:RefreshActivitiesItemList()
    self:RefreshPandoraActivitiesItem()
    if NewTargetActivityId then
      EventSystem.Invoke(EventDef.Activity.OnChangeActivityItemSelected, NewTargetActivityId)
    end
  else
    UpdateVisibility(self.ActivitiesItemList, false)
    UpdateVisibility(self.WBP_ActivityTitle, false)
  end
end
function WBP_ActivityPanel:RefreshActivitiesItemList(TargetActivityId)
  local ActivityGeneralTable = LuaTableMgr.GetLuaTableByName(TableNames.TBActivityGeneral)
  local CanShowActivityIdList = {}
  local UTCTimestamp = GetCurrentTimestamp(true)
  local ClientTimeOffset = GetCurrentTimestamp(false) - GetCurrentTimestamp(true)
  local CurTimestamp = ConvertTimestampToServerTimeByServerTimeZone(UTCTimestamp - ClientTimeOffset)
  for ActivityId, ActivityRowInfo in pairs(ActivityGeneralTable) do
    if ActivityRowInfo.isShow then
      local UIStartTimestamp = ConvertTimeStrToServerTimeByServerTimeZone(ActivityRowInfo.uiStartTime)
      local UIEndTimestamp = ConvertTimeStrToServerTimeByServerTimeZone(ActivityRowInfo.uiEndTime)
      if CurTimestamp >= UIStartTimestamp and CurTimestamp < UIEndTimestamp then
        table.insert(CanShowActivityIdList, ActivityId)
      end
    end
  end
  table.sort(CanShowActivityIdList, function(A, B)
    local AResult, ARowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, A)
    local BResult, BRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, B)
    if ARowInfo.rankScore == BRowInfo.rankScore then
      return A < B
    else
      return ARowInfo.rankScore > BRowInfo.rankScore
    end
  end)
  self.Index = 1
  for i, SingleActivityId in ipairs(CanShowActivityIdList) do
    local Item = GetOrCreateItem(self.ActivitiesItemList, self.Index, self.ActivityItemTemplate:StaticClass())
    Item:Show(SingleActivityId)
    self.Index = self.Index + 1
  end
  HideOtherItem(self.ActivitiesItemList, self.Index)
  TargetActivityId = TargetActivityId or CanShowActivityIdList[1]
  return TargetActivityId
end
function WBP_ActivityPanel:RefreshPandoraActivitiesItem()
  if PandoraModule.ActivityInfo == nil then
    return
  end
  for AppId, MsgObj in pairs(PandoraModule.ActivityInfo) do
    local Item = GetOrCreateItem(self.ActivitiesItemList, self.Index, self.ActivityItemTemplate:StaticClass())
    Item:ShowByPandora(MsgObj)
    self.Index = self.Index + 1
  end
  HideOtherItem(self.ActivitiesItemList, self.Index)
end
function WBP_ActivityPanel:ActivitiesTab(AppName)
  for Name, Item in pairs(self.ActivityTabInfo) do
    Item:SetSelect(Name == tostring(AppName))
  end
end
function WBP_ActivityPanel:BindOnPandoraActivityTabSelected(AppId, JumpParams)
  if self.SelTabAppId then
    ClosePandorApp(self.SelTabAppId)
  end
  if "Other" ~= AppId then
    self.SelTabAppId = AppId
    OpenPandorApp(AppId, JumpParams)
    self:BindOnChangeActivityItemSelected(nil, true)
  else
    self.SelTabAppId = nil
    local NewTargetActivityId = self:RefreshActivitiesItemList()
    self:RefreshPandoraActivitiesItem()
    if NewTargetActivityId then
      EventSystem.Invoke(EventDef.Activity.OnChangeActivityItemSelected, NewTargetActivityId)
      if not self:IsAnimationPlaying(self.Ani_in) then
        self:PlayAnimation(self.Ani_in)
      end
    end
  end
  self:ActivitiesTab(AppId)
end
function WBP_ActivityPanel:BindOnChangeActivityItemSelected(ActivityId, bByPandora)
  local LastShowActivityId = self.CurShowActivityId
  self.CurShowActivityId = ActivityId
  if LastShowActivityId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, LastShowActivityId)
    if Result and not UE.UKismetStringLibrary.IsEmpty(RowInfo.uiTemplate) then
      UIMgr:Hide(ViewID[RowInfo.uiTemplate])
    elseif PandoraModule.ActivityInfo and PandoraModule.ActivityInfo[LastShowActivityId] ~= nil then
      UIMgr:Hide(ViewID.UI_PandoraActivityPanel)
    end
  end
  if self.LastOpenPandorAppId then
    ClosePandorApp(self.LastOpenPandorAppId)
  end
  if self.CurShowActivityId then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBActivityGeneral, self.CurShowActivityId)
    if Result and not UE.UKismetStringLibrary.IsEmpty(RowInfo.uiTemplate) then
      UIMgr:Show(ViewID[RowInfo.uiTemplate], false, self.CurShowActivityId)
      UpdateVisibility(self.WBP_ActivityTitle, true)
      self.WBP_ActivityTitle:Show(self.CurShowActivityId)
      local TargetAnim = self[RowInfo.UITitleAnim]
      if TargetAnim then
        self:PlayAnimation(TargetAnim)
      end
    end
    UpdateVisibility(self.ActivitiesItemList, true)
  else
    UpdateVisibility(self.WBP_ActivityTitle, false)
    UpdateVisibility(self.ActivitiesItemList, false)
  end
  UpdateVisibility(self.WBP_ActivityTitle, not bByPandora)
  if bByPandora then
    self.LastOpenPandorAppId = ActivityId
    self:BindOnChangeActivityItemSelectedByPandora(ActivityId, LastShowActivityId)
  end
end
function WBP_ActivityPanel:BindOnChangeActivityItemSelectedByPandora(AppId, LastAppId)
  OpenPandorApp(AppId, "WBP_ActivityPanel")
end
function WBP_ActivityPanel:BindOnEscKeyPressed(...)
  UIMgr:Hide(ViewID.UI_ActivityPanel, true)
end
function WBP_ActivityPanel:OnPreHide(...)
  self:BindOnChangeActivityItemSelected(nil)
  EventSystem.RemoveListenerNew(EventDef.Activity.OnChangeActivityItemSelected, self, self.BindOnChangeActivityItemSelected)
  EventSystem.RemoveListenerNew(EventDef.Activity.OnPandoraRefreshActivitiesTab, self, self.BindRefreshActivitiesTab)
  EventSystem.RemoveListenerNew(EventDef.Activity.OnPandoraActivityTabSelected, self, self.BindOnPandoraActivityTabSelected)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  self:SetEnhancedInputActionBlocking(false)
end
function WBP_ActivityPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if self.SelTabAppId then
    ClosePandorApp(self.SelTabAppId)
    self.SelTabAppId = nil
  end
  self.LastOpenPandorAppId = nil
  self:SetEnhancedInputActionBlocking(false)
end
function WBP_ActivityPanel:Destruct(...)
  self:OnPreHide()
end
return WBP_ActivityPanel
