local WBP_GenericModifyItem_C = UnLua.Class()

function WBP_GenericModifyItem_C:InitGenericModifyItem(ModifyId, bIsShowName)
  UpdateVisibility(self, true)
  UpdateVisibility(self.RGTextName, bIsShowName)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(ModifyId), nil)
  if ResultGenericModify then
    SetImageBrushBySoftObject(self.URGImageIcon, GenericModifyRow.Icon)
    local OutSaveData = GetLuaInscription(GenericModifyRow.Inscription)
    if OutSaveData and bIsShowName then
      local name = GetInscriptionName(GenericModifyRow.Inscription)
      self.RGTextName:SetText(name)
    end
    local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(GenericModifyRow.Rarity)
    if ItemRarityResult then
      if bIsShowName then
        self.RGTextName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
      end
      self.URGImageRarity:SetColorAndOpacity(ItemRarityData.GenericModifyRareBgColor)
      self.ImageRarityShadow:SetRenderOpacity(ItemRarityData.GenericModifyRareBgColor.A)
    end
  end
end

function WBP_GenericModifyItem_C:InitSpecificModifyItem(Inscription, bIsShowName, bIsFromIGuideSpecificModify)
  UpdateVisibility(self, true)
  UpdateVisibility(self.RGTextName, bIsShowName)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local OutSaveData = GetLuaInscription(Inscription)
  if OutSaveData then
    SetImageBrushByPath(self.URGImageIcon, OutSaveData.Icon)
    if bIsShowName then
      local name = GetInscriptionName(Inscription)
      self.RGTextName:SetText(name)
    end
  end
  local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(UE.ERGItemRarity.EIR_Legend)
  if ItemRarityResult then
    if bIsShowName then
      self.RGTextName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
    end
    self.URGImageRarity:SetColorAndOpacity(ItemRarityData.GenericModifyRareBgColor)
    self.ImageRarityShadow:SetRenderOpacity(ItemRarityData.GenericModifyRareBgColor.A)
  end
end

function WBP_GenericModifyItem_C:InitGenericModifyItemByMod(ModId, bIsShowName)
  UpdateVisibility(self, true)
  UpdateVisibility(self.RGTextName, bIsShowName)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local OutSaveData = GetLuaInscription(ModId)
  if OutSaveData then
    SetImageBrushByPath(self.URGImageIcon, OutSaveData.Icon)
    if bIsShowName then
      local name = GetInscriptionName(ModId)
      self.RGTextName:SetText(name)
    end
  end
  local ItemRarityResult, ItemRarityData = DTSubsystem:GetItemRarityTableRow(UE.ERGItemRarity.EIR_Legend)
  if ItemRarityResult then
    if bIsShowName then
      self.RGTextName:SetColorAndOpacity(ItemRarityData.GenericModifyDisplayNameColor)
    end
    self.URGImageRarity:SetColorAndOpacity(ItemRarityData.GenericModifyRareBgColor)
    self.ImageRarityShadow:SetRenderOpacity(ItemRarityData.GenericModifyRareBgColor.A)
  end
end

function WBP_GenericModifyItem_C:Hide()
  UpdateVisibility(self, false)
end

return WBP_GenericModifyItem_C
