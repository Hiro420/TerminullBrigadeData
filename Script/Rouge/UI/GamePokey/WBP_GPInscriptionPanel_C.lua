local WBP_GPInscriptionPanel_C = UnLua.Class()
function WBP_GPInscriptionPanel_C:Construct()
  EventSystem.AddListener(self, EventDef.GamePokey.OnAccessorySlotHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotHovered)
  EventSystem.AddListener(self, EventDef.GamePokey.OnAccessorySlotUnHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotUnHovered)
  EventSystem.AddListener(self, EventDef.GamePokey.OnAccessorySlotHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotHovered)
  EventSystem.AddListener(self, EventDef.GamePokey.OnAccessorySlotUnHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotUnHovered)
end
function WBP_GPInscriptionPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.GamePokey.OnAccessorySlotHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotHovered)
  EventSystem.RemoveListener(EventDef.GamePokey.OnAccessorySlotUnHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotUnHovered)
  EventSystem.RemoveListener(EventDef.GamePokey.OnAccessorySlotHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotHovered)
  EventSystem.RemoveListener(EventDef.GamePokey.OnAccessorySlotUnHovered, WBP_GPInscriptionPanel_C.OnAccessorySlotUnHovered)
end
function WBP_GPInscriptionPanel_C:UpdateInscriptionsDes(Weapon)
  if Weapon then
    local accessoryComponent = Weapon:GetComponentByClass(UE.URGAccessoryComponent:StaticClass())
    if accessoryComponent then
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem then
        local widgetPath = "/Game/Rouge/UI/GamePokey/WBP_GPInscriptionItem.WBP_GPInscriptionItem_C"
        local padding = UE.FMargin()
        local accessoryInscriptionDataArray = UE.TArray(UE.FAccessoryInscriptionData)
        for key, value in iterator(accessoryComponent:GetOwnedAccessories()) do
          local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(value)
          local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(configId))
          if result and accessoryData.AccessoryType ~= UE.ERGAccessoryType.EAT_Barrel then
            local accessoryManager = UE.URGAccessoryStatics.GetAccessoryManager(self)
            if accessoryManager then
              local findValue = accessoryData.InscriptionMap:FindRef(accessoryManager:GetAccessory(value).InnerData.ItemRarity)
              if findValue then
                accessoryInscriptionDataArray:Append(findValue.Inscriptions)
              end
            end
          end
        end
        local arrayLength = accessoryInscriptionDataArray:Length()
        if arrayLength > 0 then
          self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        else
          self:SetVisibility(UE.ESlateVisibility.Collapsed)
        end
        UpdateWidgetContainer(self.ScrollBox_Inscriptions, arrayLength, widgetPath, padding, self, self:GetOwningPlayer())
        local itemInscription
        for key, value in pairs(self.ScrollBox_Inscriptions:GetAllChildren()) do
          itemInscription = accessoryInscriptionDataArray:Get(key)
          if itemInscription and itemInscription.bIsShowInUI then
            value:UpdateInscriptionDes(itemInscription.InscriptionId)
            value:SetTextWidthOverride(365)
          else
            value:SetVisibility(UE.ESlateVisibility.Collapsed)
          end
        end
      end
    end
  end
end
function WBP_GPInscriptionPanel_C:OnAccessorySlotHovered(AccessoryId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("DTSubsystem is null.")
    return
  end
  local type, configId, InstanceId = UE.URGArticleStatics.BreakArticleId(AccessoryId)
  local result, accessoryData = DTSubsystem:GetAccessoryTableRow(tonumber(configId))
  if result then
    local accessoryManager = UE.URGAccessoryStatics.GetAccessoryManager(self)
    if accessoryManager then
      local findValue = accessoryData.InscriptionMap:FindRef(accessoryManager:GetAccessory(AccessoryId).InnerData.ItemRarity)
      if findValue then
        local arrayInscriptionData = findValue.Inscriptions
        local arrayInscriptionID = {}
        for key, value in pairs(arrayInscriptionData) do
          table.insert(arrayInscriptionID, value.InscriptionId)
        end
        for key, value in pairs(self.ScrollBox_Inscriptions:GetAllChildren()) do
          if table.Contain(arrayInscriptionID, value.InscriptionId) then
            value:UpdateInscriptionDesOpacity(true)
          else
            value:UpdateInscriptionDesOpacity(false)
          end
        end
      end
    end
  end
end
function WBP_GPInscriptionPanel_C:OnAccessorySlotUnHovered()
  for key, value in pairs(self.ScrollBox_Inscriptions:GetAllChildren()) do
    value:UpdateInscriptionDesOpacity(true)
  end
end
return WBP_GPInscriptionPanel_C
