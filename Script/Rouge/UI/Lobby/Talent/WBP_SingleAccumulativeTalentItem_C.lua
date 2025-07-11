local WBP_SingleAccumulativeTalentItem_C = UnLua.Class()
function WBP_SingleAccumulativeTalentItem_C:InitInfo(Step, TalentId, Type, PreStepTalentId, NextStepTalentId)
  self.Step = Step
  self.TalentId = TalentId
  self.Type = Type
  self.PreStepTalentId = PreStepTalentId
  self.NextStepTalentId = NextStepTalentId
  self.WBP_SingleTalentItem:InitInfo(TalentId, Type)
  self.Txt_Step:SetText(tostring(self.Step))
  if self.NextStepTalentId ~= nil then
    self.ProgressSizeBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.ProgressSizeBox:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  EventSystem.AddListener(self, EventDef.Lobby.UpdateCommonTalentInfo, self.BindOnUpdateCommonTalentsInfo)
end
function WBP_SingleAccumulativeTalentItem_C:BindOnUpdateCommonTalentsInfo()
  self:RefreshCostTip()
end
function WBP_SingleAccumulativeTalentItem_C:RefreshStatus()
  self.WBP_SingleTalentItem:RefreshStatus()
  self:RefreshCostTip()
end
function WBP_SingleAccumulativeTalentItem_C:RefreshCostTip()
  local PreLevel = 1
  if self.PreStepTalentId ~= nil then
    PreLevel = DataMgr.GetCommonTalentLevelById(self.PreStepTalentId)
  end
  local RealLevel = DataMgr.GetCommonTalentLevelById(self.TalentId)
  if 0 ~= PreLevel and 0 == RealLevel then
    self.CostTipPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local TalentInfo = LogicTalent.GetTalentTableRow(self.TalentId)
    local TalentLevelInfo = TalentInfo[1]
    local CostInfo = TalentLevelInfo.ArrCost[1]
    local FinalValue = CostInfo.value - DataMgr.GetCommonTalentsAccumulativeCostById(CostInfo.key)
    local Result, ResourceRow = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, CostInfo.key)
    if Result then
      SetImageBrushByPath(self.Img_CostIcon, ResourceRow.Icon)
    else
      print("WBP_SingleAccumulativeTalentItem_C:RefreshCostTip not found TBGenral RowInfo, Id:", CostInfo.key)
    end
    self.Txt_CostDesc:SetText(tostring(FinalValue))
  else
    self.CostTipPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_SingleAccumulativeTalentItem_C:RefreshProgress()
  if self.NextStepTalentId == nil then
    self.ProgressSizeBox:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  local CurTalentGroupRow = LogicTalent.GetTalentTableRow(self.TalentId)
  local CurLevelTalentInfo = CurTalentGroupRow and CurTalentGroupRow[1]
  local NextTalentGroupRow = LogicTalent.GetTalentTableRow(self.NextStepTalentId)
  local NextStepTalentInfo = NextTalentGroupRow and NextTalentGroupRow[1]
  if not CurLevelTalentInfo or not NextStepTalentInfo then
    print(string.format("WBP_SingleAccumulativeTalentItem_C:RefreshProgress not found talent table row, %d or %d", self.TalentId, self.NextStepTalentId))
    return
  end
  local CurStepCostInfo = CurLevelTalentInfo.ArrCost[1]
  local NextStepCostInfo = NextStepTalentInfo.ArrCost[1]
  if not CurStepCostInfo or not NextStepCostInfo then
    print(string.format("WBP_SingleAccumulativeTalentItem_C:RefreshProgress not found talent table Cost info, %d or %d", self.TalentId, self.NextStepTalentId))
    return
  end
  self.ProgressSizeBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local CurCostNum = DataMgr.GetCommonTalentsAccumulativeCostById(CurStepCostInfo.key)
  self.Progress_AccumulativeNum:SetPercent(math.clamp((CurCostNum - CurStepCostInfo.value) / (NextStepCostInfo.value - CurStepCostInfo.value), 0, 1))
end
function WBP_SingleAccumulativeTalentItem_C:Hide()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateCommonTalentInfo, self.BindOnUpdateCommonTalentsInfo, self)
end
function WBP_SingleAccumulativeTalentItem_C:Destruct()
  self:Hide()
end
return WBP_SingleAccumulativeTalentItem_C
