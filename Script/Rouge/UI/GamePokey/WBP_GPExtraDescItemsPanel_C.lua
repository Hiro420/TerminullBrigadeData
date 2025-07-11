local WBP_GPExtraDescItemsPanel_C = UnLua.Class()
function WBP_GPExtraDescItemsPanel_C:UpdateInscriptionAdditions(InscriptionIdArray)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_GPExtraDescItemsPanel_C: DTSubsystem is null.")
    return
  end
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not logicCommandDataSubsystem then
    print("WBP_GPExtraDescItemsPanel_C: logicCommandDataSubsystem is null.")
    return
  end
  local finalKeyArray = UE.TArray(0)
  for key, value in pairs(InscriptionIdArray) do
    local inscriptionInfo = GetLuaInscription(value)
    if inscriptionInfo and inscriptionInfo.ModAdditionalNoteMap then
      for k, v in ipairs(inscriptionInfo.ModAdditionalNoteMap) do
        finalKeyArray:Add(k)
      end
    else
      print("inscriptionInfo Is Null.")
    end
  end
  local finalKeyArrayLength = finalKeyArray:Length()
  local padding = UE.FMargin()
  if finalKeyArrayLength > 0 then
    local widgetPath = "/Game/Rouge/UI/HUD/Pickup/WBP_InscriptionExtraDescItem.WBP_InscriptionExtraDescItem_C"
    UpdateWidgetContainer(self.VerticalBox_ExtraDescItems, finalKeyArrayLength, widgetPath, padding, self, self:GetOwningPlayer())
    for key, value in pairs(self.VerticalBox_ExtraDescItems:GetAllChildren()) do
      local Result, RowInfo = DTSubsystem:GetModAdditionalNoteTableRow(finalKeyArray:Get(key), nil)
      if Result then
        value:InitInfo(RowInfo)
      end
    end
    self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
return WBP_GPExtraDescItemsPanel_C
