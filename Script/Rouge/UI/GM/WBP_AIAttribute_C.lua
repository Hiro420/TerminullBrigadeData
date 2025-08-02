local WBP_AIAttribute_C = UnLua.Class()

function WBP_AIAttribute_C:Construct()
  local AIAttributeSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UAIAttributeGISubsystem:StaticClass())
  if AIAttributeSubsystem then
    AIAttributeSubsystem.OnAIAttributeDisplayStateChange:Add(self, WBP_AIAttribute_C.BindOnAIAttributeDisplayStateChange)
  end
end

function WBP_AIAttribute_C:BindOnAIAttributeDisplayStateChange()
  local AIAttributeSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.UAIAttributeGISubsystem:StaticClass())
  if AIAttributeSubsystem and AIAttributeSubsystem.IsAIAttributeShowing then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
    if UIManager then
      local GMClass = UE.UClass.Load("/Game/Rouge/UI/GM/WBP_GMWindow.WBP_GMWindow_C")
      UIManager:K2_CloseUI(GMClass)
    end
  end
end

return WBP_AIAttribute_C
