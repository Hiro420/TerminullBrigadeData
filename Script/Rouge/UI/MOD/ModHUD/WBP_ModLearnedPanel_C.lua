local WBP_ModLearnedPanel_C = UnLua.Class()
function WBP_ModLearnedPanel_C:Construct()
  local gameState = UE.UGameplayStatics.GetGameState(self)
  if not gameState then
    return
  end
  local modManager = gameState:GetComponentByClass(UE.UMODManager:StaticClass())
  if not modManager then
    return
  end
  self.modComponent = nil
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    self.modComponent = pawn:GetComponentByClass(UE.UMODComponent.StaticClass())
  end
  self.modManager = modManager
  self:BindOnModRefreshDelegate(true)
end
function WBP_ModLearnedPanel_C:Destruct()
  self:BindOnModRefreshDelegate(false)
  self.modManager = nil
end
function WBP_ModLearnedPanel_C:BindOnModRefreshDelegate(Bind)
  if self.modManager then
    if Bind then
      self.modManager.OnModRefreshDelegate:Add(self, self.OnModRefreshDelegate)
    else
      self.modManager.OnModRefreshDelegate:Remove(self, self.OnModRefreshDelegate)
    end
  end
end
function WBP_ModLearnedPanel_C:OnModRefreshDelegate()
  self:UpdateModList()
end
function WBP_ModLearnedPanel_C:UpdateModList()
  if self.modComponent then
    local CharacterMOD
    CharacterMOD = self.modComponent:GetCharacterMODByChooseType(UE.ERGMODChooseType.Character, CharacterMOD)
    local finalModArray = UE.TArray(UE.FMODContent)
    finalModArray:Append(CharacterMOD.LegendContentList)
    finalModArray:Append(CharacterMOD.MODContentList)
    local legendLength = CharacterMOD.LegendContentList:Length()
    self.UniformGridPanel:ClearChildren()
    local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModHUD/WBP_ModLearnedItem.WBP_ModLearnedItem_C")
    local widget
    local tempRow = 0
    local tempColumn = 5
    local bIsLegend = false
    for key, value in pairs(finalModArray) do
      widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
      if widget then
        if key > legendLength then
          bIsLegend = false
        else
          bIsLegend = true
        end
        widget:UpdateModInfo(value, bIsLegend)
        self.UniformGridPanel:AddChildToUniformGrid(widget, tempRow, tempColumn)
        tempColumn = tempColumn - 1
        if -1 == tempColumn then
          tempRow = tempRow + 1
          tempColumn = 5
        end
      end
    end
  end
end
return WBP_ModLearnedPanel_C
