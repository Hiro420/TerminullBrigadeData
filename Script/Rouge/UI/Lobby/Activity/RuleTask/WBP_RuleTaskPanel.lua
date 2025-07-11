local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")
local RuleTaskHandler = require("Protocol.RuleTask.RuleTaskHandler")
local WBP_RuleTaskPanel = Class(ViewBase)
function WBP_RuleTaskPanel:BindClickHandler()
  self.Btn_ReceiveMainReward.OnMainButtonClicked:Add(self, self.BindOnReceiveMainRewardButtonClicked)
  self.Btn_MainRewardDetail.OnClicked:Add(self, self.BindOnMainRewardDetailButtonClicked)
end
function WBP_RuleTaskPanel:UnBindClickHandler()
  self.Btn_ReceiveMainReward.OnMainButtonClicked:Remove(self, self.BindOnReceiveMainRewardButtonClicked)
  self.Btn_MainRewardDetail.OnClicked:Remove(self, self.BindOnMainRewardDetailButtonClicked)
end
function WBP_RuleTaskPanel:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("RuleTaskViewModel")
  self:BindClickHandler()
end
function WBP_RuleTaskPanel:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_RuleTaskPanel:OnShow(ActivityId)
  self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  self.ViewModel:InitInfo(ActivityId)
  self.ActivityId = ActivityId
  EventSystem.AddListener(self, EventDef.RuleTask.OnShowRuleTaskDetailPanel, self.BindOnShowRuleTaskDetailPanel)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskGroupRefresh)
  EventSystem.AddListenerNew(EventDef.RuleTask.ChangeRuleTaskItemTipVis, self, self.BindOnChangeRuleTaskItemTipVis)
  EventSystem.AddListenerNew(EventDef.RuleTask.OnMainRewardStateChanged, self, self.BindOnMainRewardStateChanged)
  Logic_MainTask.PullTask(self.ViewModel:GetAllTaskGroupList())
  RuleTaskHandler:RequestGetRuleTaskDataToServer(self.ActivityId)
  UpdateVisibility(self.WBP_RuleTaskItemTip, false)
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.ActivityId)
  self:InitRuleTaskItemPanel()
  self:InitMainRewardPanel()
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
end
function WBP_RuleTaskPanel:InitMainRewardPanel()
  local Result, RuleTaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleTask, self.ActivityId)
  UpdateVisibility(self.CanvasPanel_MainReward, Result)
  if not Result then
    print("WBP_RuleTaskPanel:InitMainRewardPanel not found ruletask row info! Please check TBRuleTask!", self.ActivityId)
    return
  end
  UIMgr:Show(ViewID.UI_RuleTaskCreditExchangePanel, false, RuleTaskRowInfo.creditExchangeTaskGroupId)
  SetImageBrushByPath(self.Img_MainRewardIcon, RuleTaskRowInfo.fullActivationRewardIcon)
  local TargetResourceId
  if RuleTaskRowInfo.fullActivationReward[1] then
    TargetResourceId = RuleTaskRowInfo.fullActivationReward[1].key
    self.MainRewardResourceId = TargetResourceId
  end
  if not TargetResourceId then
    print("WBP_RuleTaskPanel:InitMainRewardPanel not found mainrewardid! Please check TBRuleTask!", self.ActivityId)
    return
  end
  local Result, ResourceRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, TargetResourceId)
  if not Result then
    print("WBP_RuleTaskPanel:InitMainRewardPanel not found Resource row info! Please check TBGeneral!", TargetResourceId)
    return
  end
  self.CanShowMainRewardToolTip = true
  UpdateVisibility(self.Overlay_MainRewardDetail, ResourceRowInfo.Type == TableEnums.ENUMResourceType.HeroSkin)
  if ResourceRowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
    self.Txt_MainRewardName:SetText(ResourceRowInfo.Name)
  end
  self:RefreshMainRewardStatus()
end
function WBP_RuleTaskPanel:RefreshMainRewardStatus(...)
  local AllMainTaskGroupList = self.ViewModel:GetMainTaskGroupList()
  local MaxNum = #AllMainTaskGroupList
  self.Txt_MaxRuleTaskNum:SetText(MaxNum)
  local FinishNum = 0
  for i, SingleTaskGroupId in ipairs(AllMainTaskGroupList) do
    local CurStatus = RuleTaskData:GetTaskGroupState(SingleTaskGroupId)
    if CurStatus == ETaskGroupState.Finished or CurStatus == ETaskGroupState.GotAward then
      FinishNum = FinishNum + 1
    end
  end
  self.Txt_CurFinishRuleTaskNum:SetText(FinishNum)
  self:RefreshReceiveMainRewardButtonStatus()
end
function WBP_RuleTaskPanel:GetMainRewardIconToolTipWidget()
  if not self.CanShowMainRewardToolTip then
    return
  end
  if not self.MainRewardTipClass then
    return
  end
  return GetTips(self.MainRewardResourceId, self.MainRewardTipClass)
end
function WBP_RuleTaskPanel:RefreshReceiveMainRewardButtonStatus(...)
  local AllMainTaskGroupList = self.ViewModel:GetMainTaskGroupList()
  local MaxNum = #AllMainTaskGroupList
  self.Txt_MaxRuleTaskNum:SetText(MaxNum)
  local FinishNum = 0
  for i, SingleTaskGroupId in ipairs(AllMainTaskGroupList) do
    local CurStatus = RuleTaskData:GetTaskGroupState(SingleTaskGroupId)
    if CurStatus == ETaskGroupState.Finished or CurStatus == ETaskGroupState.GotAward then
      FinishNum = FinishNum + 1
    end
  end
  UpdateVisibility(self.CanvasPanel_Lock, MaxNum > FinishNum)
  UpdateVisibility(self.CanvasPanel_UnReceived, FinishNum == MaxNum and RuleTaskData:GetMainRewardState(self.ActivityId) ~= EMainRewardState.Received)
  UpdateVisibility(self.CanvasPanel_Received, FinishNum == MaxNum and RuleTaskData:GetMainRewardState(self.ActivityId) == EMainRewardState.Received)
  if FinishNum == MaxNum and RuleTaskData:GetMainRewardState(self.ActivityId) == EMainRewardState.Received then
    self.Btn_ReceiveMainReward:SetContentText(self.ReceivedText)
  else
    self.Btn_ReceiveMainReward:SetContentText(self.CanReceiveText)
  end
  self.CanReceiveMainReward = FinishNum == MaxNum and RuleTaskData:GetMainRewardState(self.ActivityId) ~= EMainRewardState.Received
end
function WBP_RuleTaskPanel:InitRuleTaskItemPanel()
  local Result, RuleTaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleTask, self.ActivityId)
  UpdateVisibility(self.CanvasPanel_RuleTask, Result)
  if not Result then
    print("WBP_RuleTaskPanel:InitRuleTaskItemPanel not found ruletask row info! Please check TBRuleTask!")
    return
  end
  self.FinishRuleTaskImgList = {}
  local AllChildren = self.CanvasPanel_RuleTask:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    local TargetRuleInfoId = RuleTaskRowInfo.ruleInfoList[SingleItem.Index + 1]
    local TargetFinishImg = self.CanvasPanel_FinishRuleTaskImg:GetChildAt(SingleItem.Index)
    if TargetRuleInfoId then
      SingleItem:Show(TargetRuleInfoId)
      self.FinishRuleTaskImgList[TargetRuleInfoId] = TargetFinishImg
    else
      SingleItem:Hide()
      UpdateVisibility(TargetFinishImg, false)
    end
  end
end
function WBP_RuleTaskPanel:BindOnMainTaskGroupRefresh(TaskGroupIdList)
  local IsNeedRefresh = false
  local AllMainTaskGroupList = self.ViewModel:GetMainTaskGroupList()
  for i, SingleTaskGroupId in ipairs(AllMainTaskGroupList) do
    if table.Contain(TaskGroupIdList, SingleTaskGroupId) then
      IsNeedRefresh = true
      break
    end
  end
  if IsNeedRefresh then
    self:RefreshMainRewardStatus()
    local AllChildren = self.CanvasPanel_RuleTask:GetAllChildren()
    for k, SingleItem in pairs(AllChildren) do
      SingleItem:RefreshStatus()
    end
    for RuleInfoId, FinishImg in pairs(self.FinishRuleTaskImgList) do
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleInfo, RuleInfoId)
      if Result then
        local Status = RuleTaskData:GetTaskGroupState(RowInfo.MainTaskGroupId)
        UpdateVisibility(FinishImg, Status == ETaskGroupState.Finished or Status == ETaskGroupState.GotAward)
      else
        UpdateVisibility(FinishImg, false)
      end
    end
  end
end
function WBP_RuleTaskPanel:BindOnReceiveMainRewardButtonClicked(...)
  if not self.CanReceiveMainReward then
    return
  end
  local Result, RuleTaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBRuleTask, self.ActivityId)
  if Result then
    local OptionalGift = {}
    for index, value in ipairs(RuleTaskRowInfo.fullActivationReward) do
      if self:IsOptional(value.key) then
        if nil == OptionalGift[value] then
          OptionalGift[value] = 1
        else
          OptionalGift[value] = OptionalGift[value] + 1
        end
      end
    end
    if 0 == #OptionalGift then
      RuleTaskHandler:RequestReceiveRewardToServer(self.ActivityId)
    else
      ShowOptionalGiftWindow(OptionalGift, self.ActivityId, _G.EOptionalGiftType.Rule)
    end
  end
end
function WBP_RuleTaskPanel:IsOptional(ResourcesID)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TBGeneral[ResourcesID] then
    return TBGeneral[ResourcesID].Type == TableEnums.ENUMResourceType.OptionalGift
  end
  return false
end
function WBP_RuleTaskPanel:BindOnMainRewardDetailButtonClicked(...)
  local Result, HeroSkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, self.MainRewardResourceId)
  if not Result then
    print("WBP_RuleTaskPanel:BindOnMainRewardDetailButtonClicked not found Resource row info! Please check TBCharacterSkin!", self.MainRewardResourceId)
    return
  end
  if ComLink(1014, nil, HeroSkinRowInfo.CharacterID) then
    local SkinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
    if SkinView then
      SkinView:SelectHeroSkin(HeroSkinRowInfo.SkinID, true)
    end
  end
end
function WBP_RuleTaskPanel:BindOnShowRuleTaskDetailPanel(RuleInfoId)
  UIMgr:Show(ViewID.UI_RuleTaskDetailPanel, false, RuleInfoId)
end
function WBP_RuleTaskPanel:BindOnChangeRuleTaskItemTipVis(IsShow, RuleInfoId, IsRight)
  UpdateVisibility(self.WBP_RuleTaskItemTip, IsShow)
  if IsShow then
    self.WBP_RuleTaskItemTip:Show(RuleInfoId)
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_RuleTaskItemTip)
    local TargetPos
    if IsRight then
      TargetPos = self.RightTipPos
    else
      TargetPos = self.LeftTipPos
    end
    Slot:SetPosition(TargetPos)
  end
end
function WBP_RuleTaskPanel:BindOnMainRewardStateChanged()
  self:RefreshReceiveMainRewardButtonStatus()
end
function WBP_RuleTaskPanel:OnPreHide()
  EventSystem.RemoveListenerNew(EventDef.RuleTask.OnShowRuleTaskDetailPanel, self, self.BindOnShowRuleTaskDetailPanel)
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskGroupRefresh)
  EventSystem.RemoveListenerNew(EventDef.RuleTask.ChangeRuleTaskItemTipVis, self, self.BindOnChangeRuleTaskItemTipVis)
  EventSystem.RemoveListenerNew(EventDef.RuleTask.OnMainRewardStateChanged, self, self.BindOnMainRewardStateChanged)
  UIMgr:Hide(ViewID.UI_RuleTaskCreditExchangePanel, false)
  self:StopAllAnimations()
  local AllChildren = self.CanvasPanel_RuleTask:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
end
function WBP_RuleTaskPanel:OnHide()
  self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
end
function WBP_RuleTaskPanel:Destruct(...)
  self:OnPreHide()
end
return WBP_RuleTaskPanel
