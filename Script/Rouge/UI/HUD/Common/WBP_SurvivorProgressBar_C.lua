local WBP_SurvivorProgressBar_C = UnLua.Class()
function WBP_SurvivorProgressBar_C:Construct()
  self.RuleID = nil
  UpdateVisibility(self.SmallWave, false)
  UpdateVisibility(self.BigWave, false)
  local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SmallWave)
  self.SmallWaveBasePos = UE.FVector2D(0, 0)
  self.SmallWaveBaseSize = UE.FVector2D(0, 0)
  self.SmallBrush = self.SmallWave.Brush
  if CanvasPanelSlot then
    self.SmallWaveBasePos = CanvasPanelSlot:GetPosition()
    self.SmallWaveBaseSize = CanvasPanelSlot:GetSize()
  end
  self.BigWaveBasePos = UE.FVector2D(0, 0)
  self.BigWaveBaseSize = UE.FVector2D(0, 0)
  self.BigBrush = self.BigWave.Brush
  local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.BigWave)
  if CanvasPanelSlot then
    self.BigWaveBasePos = CanvasPanelSlot:GetPosition()
    self.BigWaveBaseSize = CanvasPanelSlot:GetSize()
  end
  self.BarLength = 900
  local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.LocationPanel)
  if CanvasPanelSlot then
    self.BarLength = CanvasPanelSlot:GetSize().X
  end
  self.ImageItemDict = {}
end
function WBP_SurvivorProgressBar_C:ClearImageDict()
  for _, ImageItem in pairs(self.ImageItemDict) do
    ImageItem:RemoveFromParent()
  end
  for i = 1, 10 do
    if self["NumNode_" .. tostring(i)] then
      UpdateVisibility(self["NumNode_" .. tostring(i)], false)
    end
  end
  self.ImageItemDict = {}
end
function WBP_SurvivorProgressBar_C:UpdateImageDict()
  for index, ImageItem in pairs(self.ImageItemDict) do
    if index < self.WaveIndex then
      ImageItem:SetColorAndOpacity(self.OpacityHalf)
    else
      ImageItem:SetColorAndOpacity(self.OpacityWhole)
    end
  end
end
function WBP_SurvivorProgressBar_C:ShowBar(WaveIndex, RuleID)
  if self.RuleID ~= RuleID then
    self.RuleID = RuleID
    self:InitProgressBar()
  end
  self.WaveIndex = WaveIndex
  self:UpdateBar()
  if self.IsShow then
    return
  end
  self.IsShow = true
  self.IsClose = false
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimation(self.Anim_IN)
end
function WBP_SurvivorProgressBar_C:UpdateBar()
  local TotalWave = LogicSurvivor.GetTotalWave(self.RuleID)
  self.WaveProgressBar:SetPercent(self.WaveIndex / TotalWave)
  self:UpdateImageDict()
end
function WBP_SurvivorProgressBar_C:InitProgressBar()
  self:ClearImageDict()
  local WaveIds = LogicSurvivor.GetWaveIds(self.RuleID)
  local TotalWave = LogicSurvivor.GetTotalWave(self.RuleID)
  local IndexLen = self.BarLength / TotalWave
  local NumShow = 0
  for index, WaveId in pairs(WaveIds) do
    if index > TotalWave then
      return
    end
    local WaveType = LogicSurvivor.GetWaveTypeByIndex(self.RuleID, index)
    if WaveType == UE.ESurvivorWaveType.Elite then
      NumShow = NumShow + 1
      if self["NumNode_" .. tostring(NumShow)] then
        UpdateVisibility(self["NumNode_" .. tostring(NumShow)], true)
        self["NumNode_" .. tostring(NumShow)]:SetText(tostring(index))
        local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self["NumNode_" .. tostring(NumShow)])
        if CanvasPanelSlot then
          local posY = CanvasPanelSlot:GetPosition().Y
          CanvasPanelSlot:SetPosition(UE.FVector2D(self.SmallWaveBasePos.X + index * IndexLen, posY))
        end
      end
    elseif WaveType == UE.ESurvivorWaveType.Boss then
      NumShow = NumShow + 1
      if self["NumNode_" .. tostring(NumShow)] then
        UpdateVisibility(self["NumNode_" .. tostring(NumShow)], true)
        self["NumNode_" .. tostring(NumShow)]:SetText(tostring(index))
        local CanvasPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self["NumNode_" .. tostring(NumShow)])
        if CanvasPanelSlot then
          local posY = CanvasPanelSlot:GetPosition().Y
          CanvasPanelSlot:SetPosition(UE.FVector2D(self.BigWaveBasePos.X + index * IndexLen, posY))
        end
      end
    end
  end
end
function WBP_SurvivorProgressBar_C:HideBar()
  self:StopAnimation(self.Anim_IN)
  if not self.IsClose then
    self.IsClose = true
    self:PlayAnimation(self.Anim_OUT)
  end
end
function WBP_SurvivorProgressBar_C:OnAnimationFinished(InAnimation)
  if InAnimation == self.Anim_OUT and self.IsClose then
    self.IsShow = false
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_SurvivorProgressBar_C:Destruct()
  self:ClearImageDict()
end
return WBP_SurvivorProgressBar_C
