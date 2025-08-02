local WBP_RGScrollSetWaveWindow_C = UnLua.Class()

function WBP_RGScrollSetWaveWindow_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_RGScrollSetWaveWindow_C:SetWaveWindowParam(WaveWindowParamParam)
  local SetData = UE.FRGAttributeModifySetContext()
  SetData.Level = WaveWindowParamParam.IntParam0
  SetData.SetId = WaveWindowParamParam.IntParam1
  self:Show(SetData, WaveWindowParamParam.IntParam2)
end

function WBP_RGScrollSetWaveWindow_C:UpdateSameCoexist()
  self.Overridden.UpdateSameCoexist(self)
  local SlotScrollSet = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_ScrollSetHintItem)
  if SlotScrollSet then
    SlotScrollSet:SetPosition(UE.FVector2D(SlotScrollSet:GetPosition().X, SlotScrollSet:GetPosition().Y - 150))
  end
end

function WBP_RGScrollSetWaveWindow_C:Show(ScrollSetData, AttributeModifyId)
  self.WBP_ScrollSetHintItem:InitScrollSetHintItem(ScrollSetData, AttributeModifyId, self.Info.Duration)
end

function WBP_RGScrollSetWaveWindow_C:Destruct()
  self.Overridden.Destruct(self)
end

function WBP_RGScrollSetWaveWindow_C:Hide()
end

return WBP_RGScrollSetWaveWindow_C
