local WBP_InteractScrollItem_C = UnLua.Class()
local ItemSizeY = 0
local ScrollListSizeY = 0

function WBP_InteractScrollItem_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_InteractScrollItem_C:InitInteractScrollIten(TargetActor, bIsSelect)
  if not UE.RGUtil.IsUObjectValid(TargetActor) then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true, true)
  local InteractComp = TargetActor:GetComponentByClass(UE.URGInteractComponent:StaticClass())
  local TipId = 0
  if InteractComp then
    TipId = InteractComp.TipId
    if TargetActor.GetInteractTipId then
      TipId = TargetActor:GetInteractTipId()
    end
  end
  local bResult, InteractTipRow = GetRowData(DT.DT_InteractTip, tostring(TipId))
  if bResult then
    SetImageBrushBySoftObject(self.URGImageIcon, InteractTipRow.InteractIcon)
    if bIsSelect then
      self.URGImageIcon:SetColorAndOpacity(InteractTipRow.SelectIconColor)
      self.URGImageBg:SetColorAndOpacity(InteractTipRow.NormalIconColor)
      local scale = self.SelectScale or 1.1
      self:SetRenderScale(UE.FVector2D(scale))
    else
      self.URGImageIcon:SetColorAndOpacity(InteractTipRow.NormalIconColor)
      self.URGImageBg:SetColorAndOpacity(InteractTipRow.SelectIconColor)
      self:SetRenderScale(UE.FVector2D(1))
    end
  end
  UpdateVisibility(self.URGImageSelect, bIsSelect)
end

function WBP_InteractScrollItem_C:Hide()
  UpdateVisibility(self, false)
end

return WBP_InteractScrollItem_C
