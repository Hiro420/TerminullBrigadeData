local WBP_ModLearnedItem_C = UnLua.Class()
local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(1, 0.300544, 0.029557, 1.0)
}
function WBP_ModLearnedItem_C:UpdateModInfo(FMODContent, bIsLegend)
  local modId = FMODContent.MODID
  local modChooseType = UE.ERGMODChooseType.Character
  local modLevel = FMODContent.Level + 1
  local linearColor = UE.FLinearColor()
  local ModIconBack
  if bIsLegend then
    linearColor = CostTextColor.Yellow
    ModIconBack = self.LegendModBackIcon
  else
    linearColor = CostTextColor.White
    ModIconBack = self.NormalModBackIcon
  end
  self.Image_Mod:SetColorAndOpacity(linearColor)
  local modBackIconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ModIconBack)
  if modBackIconObj then
    local modBackBrush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(modBackIconObj, 0, 0)
    self.Image_ModBack:SetBrush(modBackBrush)
  end
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if logicCommandDataSubsystem then
    local OutSaveData = GetLuaInscription(modId)
    if OutSaveData then
      SetImageBrushByPath(self.Image_Mod, OutSaveData.Icon, {X = 32, Y = 32})
    else
      print("OutSaveData is null.")
    end
  end
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    local modComponent = pawn:GetComponentByClass(UE.UMODComponent.StaticClass())
    if modComponent then
      local modType = modComponent:GetModTypeById(modId)
      self.HorizontalBox_ModLevel:ClearChildren()
      local widget
      local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModView/WBP_ModViewLevel.WBP_ModViewLevel_C")
      local margin = UE.FMargin()
      margin.Left = 2.5
      margin.right = 2.5
      local slot
      for i = 1, modLevel do
        widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
        if widget then
          widget:InitInfo(bIsLegend)
          slot = self.HorizontalBox_ModLevel:AddChild(widget)
          if slot then
            slot:SetPadding(margin)
          end
        end
      end
      for key, value in iterator(self.HorizontalBox_ModLevel:GetAllChildren()) do
        value:UpdateActiveInfo(false)
      end
      local widget
      local levelWidgets = self.HorizontalBox_ModLevel:GetAllChildren()
      for i = 1, modLevel do
        if levelWidgets:IsValidIndex(i) then
          widget = self.HorizontalBox_ModLevel:GetChildAt(i - 1)
          widget:UpdateActiveInfo(true)
        end
      end
    else
      print("modComponent is null.")
    end
  else
    print("Pawn is null.")
  end
end
return WBP_ModLearnedItem_C
