local WBP_AccessorySlotPanel_C = UnLua.Class()
function WBP_AccessorySlotPanel_C:UpdateAccessorySlots(AccessoryDataTable)
  for key, widget in pairs(self.CanvasPanel_AccessorySlotSet:GetAllChildren()) do
    widget:UpdateAccessorySlotItem(false, nil, nil)
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    for accessoryId, accessoryRarity in pairs(AccessoryDataTable) do
      local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(accessoryId), nil)
      if result then
        for key, widget in pairs(self.CanvasPanel_AccessorySlotSet:GetAllChildren()) do
          if widget.AccessoryType == accessoryData.AccessoryType then
            widget:UpdateAccessorySlotItem(true, accessoryId, accessoryRarity)
          end
        end
      end
    end
  end
end
return WBP_AccessorySlotPanel_C
