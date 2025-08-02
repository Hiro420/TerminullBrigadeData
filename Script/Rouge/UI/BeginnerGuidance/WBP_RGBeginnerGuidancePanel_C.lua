local WBP_RGBeginnerGuidancePanel_C = UnLua.Class()

function WBP_RGBeginnerGuidancePanel_C:Construct()
  self.TypeWidgetReflication = {
    [UE.EBeginnerGuidanceTipType.Normal] = self.WBP_RGBeginnerGuidanceOperateTip,
    [UE.EBeginnerGuidanceTipType.Task] = self.WBP_RGBeginnerGuidanceTaskTip,
    [UE.EBeginnerGuidanceTipType.Movie] = self.WBP_RGBeginnerGuidanceMovieTip
  }
end

function WBP_RGBeginnerGuidancePanel_C:InitChildWidgetVis()
  self.MissionId = -1
  local AllChildren = self.MainPanel:GetAllChildren()
  for key, SingleWidget in pairs(AllChildren) do
    if SingleWidget:IsVisible() then
      if SingleWidget.Hide then
        SingleWidget:Hide()
      else
        SingleWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
  end
end

function WBP_RGBeginnerGuidancePanel_C:OnDisplay()
  self:InitChildWidgetVis()
end

function WBP_RGBeginnerGuidancePanel_C:RefreshInfoByTipIdList(TipIdList, MissionId)
  self.MissionId = MissionId
  local BResult, BeginnerGuidanceRowData = false
  for key, SingleBeginnerRowId in pairs(TipIdList) do
    BResult, BeginnerGuidanceRowData = GetRowData(DT.DT_RGBeginnerGuidanceTip, SingleBeginnerRowId)
    if BResult then
      local TargetWidget = self.TypeWidgetReflication[BeginnerGuidanceRowData.Type]
      if TargetWidget then
        if not TargetWidget:IsVisible() then
          TargetWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        end
        TargetWidget:RefreshInfo(SingleBeginnerRowId, self.MissionId)
      end
    end
  end
end

function WBP_RGBeginnerGuidancePanel_C:RefreshInfo(MissionId)
  self.MissionId = MissionId
  local Result, MissionRowData = GetRowData(DT.DT_Mission, tostring(self.MissionId))
  if not Result then
    print("WBP_RGBeginnerGuidancePanel_C:RefreshInfo not found Mission Row Data, MissionId:", self.MissionId)
    LogicBeginnerGuidance.HideBeginnerGuidanceMainPanel(MissionId)
    return
  end
  if MissionRowData.TipIdList:Length() <= 0 then
    print("WBP_RGBeginnerGuidancePanel_C:RefreshInfo TipIdList Length: 0")
    LogicBeginnerGuidance.HideBeginnerGuidanceMainPanel(MissionId)
    return
  end
  local BResult, BeginnerGuidanceRowData = false
  for key, SingleBeginnerRowId in pairs(MissionRowData.TipIdList) do
    BResult, BeginnerGuidanceRowData = GetRowData(DT.DT_RGBeginnerGuidanceTip, SingleBeginnerRowId)
    if BResult then
      local TargetWidget = self.TypeWidgetReflication[BeginnerGuidanceRowData.Type]
      if TargetWidget then
        if not TargetWidget:IsVisible() then
          TargetWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        end
        TargetWidget:RefreshInfo(SingleBeginnerRowId, self.MissionId)
      end
    end
  end
end

function WBP_RGBeginnerGuidancePanel_C:OpenUIByType(Type, BeginnerRowId)
  local TargetWidget = self.TypeWidgetReflication[Type]
  if TargetWidget then
    if not TargetWidget:IsVisible() then
      TargetWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    TargetWidget:RefreshInfo(BeginnerRowId)
  end
  return TargetWidget
end

function WBP_RGBeginnerGuidancePanel_C:OnUnDisplay()
  local AllChildren = self.MainPanel:GetAllChildren()
  for key, SingleWidget in pairs(AllChildren) do
    if SingleWidget:IsVisible() then
      SingleWidget:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end

function WBP_RGBeginnerGuidancePanel_C:OnMissionFinished(MissionId)
  local AllChildren = self.MainPanel:GetAllChildren()
  for key, SingleWidget in pairs(AllChildren) do
    if SingleWidget:IsVisible() and SingleWidget.MissionId == MissionId then
      if SingleWidget.Hide then
        SingleWidget:Hide()
      else
        UpdateVisibility(SingleWidget, false)
      end
    end
  end
end

function WBP_RGBeginnerGuidancePanel_C:CheckShouldBlockOpenOtherUI()
  return self.WBP_RGBeginnerGuidanceMovieTip:IsVisible()
end

return WBP_RGBeginnerGuidancePanel_C
