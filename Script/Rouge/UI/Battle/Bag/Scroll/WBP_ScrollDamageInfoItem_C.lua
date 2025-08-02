local WBP_ScrollDamageInfoItem_C = UnLua.Class()

function WBP_ScrollDamageInfoItem_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ScrollDamageInfoItem_C:InitScrollItem(UserId, DamageInfo)
  local DamageValue = UE.URGBlueprintLibrary.GetStatisticDataInt64StrUserId(UserId, DamageInfo.DataId)
  local DamageUnit = DamageInfo.UnitName
  if DamageInfo.bIsHideWhenZero and 0.0 == DamageValue then
    self:Hide()
    return
  end
  UpdateVisibility(self, true)
  if DamageInfo.bIsDamage then
    local totalDamage = UE.URGStatisticsLibrary.GetTotalDamage(UserId)
    local DamagePercent = 0.0
    if totalDamage > 0 then
      DamagePercent = DamageValue / totalDamage * 100
    end
    DamageUnit = string.format("(%.2f%%)", DamagePercent)
  end
  self.TextBlock_DamageName:SetText(DamageInfo.DataName)
  self.TextBlock_DamageValue:SetText(math.ceil(DamageValue))
  self.TextBlock_DamageUnit:SetText(DamageUnit)
  self.TextBlock_DamageName:SetColorAndOpacity(DamageInfo.DataColor)
  self.TextBlock_DamageValue:SetColorAndOpacity(DamageInfo.DataColor)
  self.TextBlock_DamageUnit:SetColorAndOpacity(DamageInfo.DataColor)
end

function WBP_ScrollDamageInfoItem_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_ScrollDamageInfoItem_C:Destruct()
end

return WBP_ScrollDamageInfoItem_C
