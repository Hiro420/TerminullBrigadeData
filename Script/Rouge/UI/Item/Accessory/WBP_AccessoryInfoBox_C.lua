local WBP_AccessoryInfoBox_C = UnLua.Class()

function WBP_AccessoryInfoBox_C:LoadAccessoryInfo(AccessoryId)
  local gamestate = UE.UGameplayStatics.GetGameState(self)
  if gamestate then
    local rgAccessoryManager = gamestate:GetComponentByClass(UE.URGAccessoryManager.StaticClass())
    if rgAccessoryManager then
      local RGDataTableSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGDataTableSubsystem:StaticClass())
      if RGDataTableSubsystem then
        local itemData = RGDataTableSubsystem:K2_GetItemTableRow(rgAccessoryManager:GetAccessory(AccessoryId).InnerData.ConfigId)
        self.ItemNameText:SetText(UE.UKismetTextLibrary.Conv_StringToText(UE.UKismetStringLibrary.Concat_StrStr(UE.UKismetTextLibrary.Conv_TextToString(itemData.Name), UE.UKismetStringLibrary.Conv_IntToString(UE.URGArticleStatics.GetInstanceId(AccessoryId)))))
        self:LoadAccessoryInscription(AccessoryId)
      end
    end
  end
end

function WBP_AccessoryInfoBox_C:LoadAccessoryInscription(AccessoryId)
  self.AccessoryAttributeBox:ClearChildren()
  local results_stringArray = UE.URGAccessoryStatics.GetAccessoryInfo(self, AccessoryId)
  local length = results_stringArray:Length()
  local element, wbp_AttributeBox
  for i = 1, length do
    element = results_stringArray:Get(i)
    wbp_AttributeBox = UE.UWidgetBlueprintLibrary.Create(self, UE4.UClass.Load("WidgetBlueprint'/Game/Rouge/UI/Item/WBP_AttributeBox.WBP_AttributeBox_C'"), self:GetOwningPlayer())
    if wbp_AttributeBox then
      wbp_AttributeBox:UpdateBox(UE.UKismetTextLibrary.Conv_StringToText(element))
      self.AccessoryAttributeBox:AddChildToVerticalBox(wbp_AttributeBox)
    end
  end
end

return WBP_AccessoryInfoBox_C
