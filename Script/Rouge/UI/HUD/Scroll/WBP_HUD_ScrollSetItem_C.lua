local WBP_HUD_ScrollSetItem_C = UnLua.Class()

function WBP_HUD_ScrollSetItem_C:InitHudScrollSetItem(AttributeModifySetData)
  self:PlayAni(AttributeModifySetData)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_HUD_ScrollSetItem_C:InitHudScrollSetItem not DTSubsystem")
    return nil
  end
  UpdateVisibility(self, true)
  local ResultModifySet, AttributeModifySetRow = DTSubsystem:GetAttributeModifySetDataById(AttributeModifySetData.SetId, nil)
  if ResultModifySet then
    SetImageBrushBySoftObject(self.URGImageScrollIcon, AttributeModifySetRow.SetIconWithBg)
    self.RGTextName:SetText(AttributeModifySetRow.SetName)
    local Index = 1
    local MaxLevel = Logic_Scroll:GetModifySetMaxLevel(AttributeModifySetData)
    for i = 1, MaxLevel do
      local InscriptionIdPtr = Logic_Scroll:GetInscriptionBySetLv(i, AttributeModifySetData.SetId)
      if InscriptionIdPtr then
        local WBP_HUD_ScrollSetLevelItemName = string.format("WBP_HUD_ScrollSetLevelItem%d", Index)
        if self[WBP_HUD_ScrollSetLevelItemName] then
          local bPlayAni = self.AttributeModifySetData and self.AttributeModifySetData.Level < AttributeModifySetData.Level and AttributeModifySetData.Level == i
          self[WBP_HUD_ScrollSetLevelItemName]:UpdateScrollSetLevelItem(i <= AttributeModifySetData.Level, bPlayAni, not self.AttributeModifySetData)
        end
        local setLvName = "SetLevel" .. Index
        if self[setLvName] then
          UpdateVisibility(self[setLvName], i <= AttributeModifySetData.Level)
        end
        Index = Index + 1
      end
    end
  end
  self.AttributeModifySetData = AttributeModifySetData
end

function WBP_HUD_ScrollSetItem_C:PlayAni(AttributeModifySetData)
  if not self.AttributeModifySetData or self.AttributeModifySetData.Level < AttributeModifySetData.Level then
    local nameAni = "ani_HUD_ScrollSetItem_in_" .. AttributeModifySetData.Level
    if self[nameAni] then
      self:PlayAnimation(self[nameAni])
    end
    return
  end
end

function WBP_HUD_ScrollSetItem_C:Hide()
  self.AttributeModifySetData = nil
  UpdateVisibility(self, false)
end

return WBP_HUD_ScrollSetItem_C
