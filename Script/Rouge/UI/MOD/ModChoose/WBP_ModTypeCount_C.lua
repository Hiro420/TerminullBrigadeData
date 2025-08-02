local WBP_ModTypeCount_C = UnLua.Class()

function WBP_ModTypeCount_C:Construct()
  self.Button_Type.OnClicked:Add(self, WBP_ModTypeCount_C.OnClicked_Button_Type)
end

function WBP_ModTypeCount_C:Destruct()
  self.Button_Type.OnClicked:Remove(self, WBP_ModTypeCount_C.OnClicked_Button_Type)
end

function WBP_ModTypeCount_C:InitModTypeInfo(ModInfo)
  if not ModInfo then
    print("ModInfo is null.")
    return
  end
  self.ModInfo = ModInfo
  self.ModType = self.ModInfo.ModType
  self.TextBlock_Title:SetText(ModInfo.Name)
  local ModIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ModInfo.Icon)
  if ModIconObj then
    local ModBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(ModIconObj, 30, 20)
    self.Image_Title:SetBrush(ModBrush)
  end
end

function WBP_ModTypeCount_C:UpdateModTypeInfo()
  if not self.ModInfo then
    print("ModInfo is null.")
    return
  end
  self.ChooseType = UE.ERGMODChooseType.Character
  local modComponent = self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass())
  if modComponent then
    local nowNumber, MaxNumber
    MaxNumber, nowNumber = modComponent:GetTotalModNumByType(self.ModType, nowNumber, self.ChooseType)
    print("UpdateModTypeInfo   \239\188\154" .. "ModType " .. tostring(self.ModType) .. " / " .. "nowNumber " .. tostring(nowNumber))
    self.TextBlock_Number:SetText(tostring(nowNumber))
  end
end

function WBP_ModTypeCount_C:OnClicked_Button_Type()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager:IsValid() then
    local mainPanelWidgetClass = UE.UClass.Load("/Game/Rouge/UI/Core/MainPanel/WBP_MainPanel.WBP_MainPanel_C")
    local success = UIManager:Switch(mainPanelWidgetClass, true)
    if success then
      local mainPanelWidget = UIManager:K2_GetUI(mainPanelWidgetClass)
      if mainPanelWidget:IsValid() then
        mainPanelWidget:ActivateModPanel()
      end
    end
  end
end

return WBP_ModTypeCount_C
