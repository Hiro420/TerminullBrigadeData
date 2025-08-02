local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_RuleTaskCreditExchangePanel = Class(ViewBase)
local RuleTaskData = require("Modules.RuleTask.RuleTaskData")

function WBP_RuleTaskCreditExchangePanel:BindClickHandler()
end

function WBP_RuleTaskCreditExchangePanel:UnBindClickHandler()
end

function WBP_RuleTaskCreditExchangePanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_RuleTaskCreditExchangePanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_RuleTaskCreditExchangePanel:OnShow(TaskGroupId, IsShowByDetail)
  if IsShowByDetail then
    return
  end
  self.TaskGroupId = TaskGroupId
  self:RefreshItemList()
  self:RefreshProgressInfo()
  self:PlayAnimation(self.Ani_in)
  EventSystem.AddListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskRefresh)
end

function WBP_RuleTaskCreditExchangePanel:RefreshItemList(...)
  local Result, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, self.TaskGroupId)
  if not Result then
    print("WBP_RuleTaskCreditExchangePanel:RefreshItemList not found taskGroup row info!", self.TaskGroupId)
    return
  end
  local MainPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.CanvasPanel_Main)
  local MainPanelSize = MainPanelSlot:GetSize()
  local Anchors = UE.FAnchors()
  Anchors.Minimum = UE.FVector2D(0.0, 0.5)
  Anchors.Maximum = UE.FVector2D(0.0, 0.5)
  local Alignment = UE.FVector2D(0.5, 0.5)
  self.MaxTaskId = TaskGroupRowInfo.tasklist[#TaskGroupRowInfo.tasklist]
  local BResult, TaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskData, self.MaxTaskId)
  self.MaxPointNum = BResult and TaskRowInfo.targetEventsList[1].value or 1
  local Index = 1
  for i, SingleTaskId in ipairs(TaskGroupRowInfo.tasklist) do
    local Item = GetOrCreateItem(self.CanvasPanel_ItemList, Index, self.WBP_RuleTaskCreditExchangeItem:StaticClass())
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    Slot:SetAnchors(Anchors)
    Slot:SetAlignment(Alignment)
    Slot:SetAutoSize(true)
    local BResult, CurTaskRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskData, SingleTaskId)
    local CurPointNum = BResult and CurTaskRowInfo.targetEventsList[1].value or 0
    local PosX = MainPanelSize.X * (CurPointNum / self.MaxPointNum)
    Slot:SetPosition(UE.FVector2D(PosX, 0))
    Item:Show(SingleTaskId, self.TaskGroupId)
    Index = Index + 1
  end
  HideOtherItem(self.CanvasPanel_ItemList, Index)
end

function WBP_RuleTaskCreditExchangePanel:RefreshProgressInfo()
  local Result, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, self.TaskGroupId)
  if not Result then
    print("WBP_RuleTaskCreditExchangePanel:RefreshProgressInfo not found taskGroup row info!", self.TaskGroupId)
    return
  end
  local TargetPointNum = 0
  for i, SingleTaskId in ipairs(TaskGroupRowInfo.tasklist) do
    local CurPointNum = RuleTaskData:GetTaskCountValue(SingleTaskId)
    if TargetPointNum < CurPointNum then
      TargetPointNum = CurPointNum
    end
  end
  self.Txt_CurPoint:SetText(TargetPointNum)
  self.ProgressBar_Point:SetPercent(TargetPointNum / self.MaxPointNum)
end

function WBP_RuleTaskCreditExchangePanel:BindOnMainTaskRefresh(TaskGroupIdList)
  if not table.Contain(TaskGroupIdList, self.TaskGroupId) then
    return
  end
  self:RefreshProgressInfo()
  local AllChildren = self.CanvasPanel_ItemList:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshStatus()
  end
end

function WBP_RuleTaskCreditExchangePanel:OnHide()
  EventSystem.RemoveListenerNew(EventDef.MainTask.OnMainTaskRefres, self, self.BindOnMainTaskRefresh)
end

function WBP_RuleTaskCreditExchangePanel:Destruct(...)
  self:OnHide()
end

return WBP_RuleTaskCreditExchangePanel
