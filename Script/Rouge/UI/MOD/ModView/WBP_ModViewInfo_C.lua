local WBP_ModViewInfo_C = UnLua.Class()

function WBP_ModViewInfo_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.Image_ModHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_ModViewInfo_C:OnMouseLeave(MouseEvent)
  self.Image_ModHover:SetVisibility(UE.ESlateVisibility.Hidden)
end

local CostTextColor = {
  White = UE.FLinearColor(1.0, 1.0, 1.0, 1.0),
  Yellow = UE.FLinearColor(1, 0.300544, 0.029557, 1.0)
}

function WBP_ModViewInfo_C:InitModInfo(bIsLegend, InitModID, ChooseType, ModType)
  self.InitModID = InitModID
  self.CurrentModID = InitModID
  self.ChooseType = ChooseType
  self.ModType = ModType
  local linearColor = UE.FLinearColor()
  if bIsLegend then
    linearColor = CostTextColor.Yellow
  else
    linearColor = CostTextColor.White
  end
  self.Image_Mod:SetColorAndOpacity(linearColor)
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if logicCommandDataSubsystem then
    local OutSaveData = GetLuaInscription(InitModID)
    if OutSaveData then
      SetImageBrushByPath(self.Image_Mod, OutSaveData.Icon)
    else
      print("OutSaveData is null.")
    end
  end
  local pawn = self:GetOwningPlayerPawn()
  if pawn then
    self.modComponent = pawn:GetComponentByClass(UE.UMODComponent.StaticClass())
    if self.modComponent then
      self.modMaxLevel = self.modComponent:GetMaxMODLevel(self.InitModID, self.ChooseType, self.ModType)
      print("ModID :" .. self.CurrentModID .. "//" .. "ChooseType" .. self.ChooseType .. "//" .. "ModType" .. self.ModType .. "//" .. "CurrentMaxLevel" .. "\239\188\154" .. tostring(self.modMaxLevel))
      self.HorizontalBox_ModLevel:ClearChildren()
      local widget
      local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModView/WBP_ModViewLevel.WBP_ModViewLevel_C")
      local margin = UE.FMargin()
      margin.Left = 2.5
      margin.right = 2.5
      local slot
      for i = 1, self.modMaxLevel do
        widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
        if widget then
          widget:InitInfo(bIsLegend)
          slot = self.HorizontalBox_ModLevel:AddChild(widget)
          if slot then
            slot:SetPadding(margin)
          end
        end
      end
      self:UpdateModInfo()
    else
      print("modComponent is null.")
    end
  else
    print("Pawn is null.")
  end
end

function WBP_ModViewInfo_C:UpdateModInfo()
  if self.modComponent then
    self:UpdateModIDFromLevelList()
    self.modLevel = self.modComponent:GetMODLevel(self.CurrentModID, self.ChooseType, self.ModType) + 1
    print("ModID :" .. self.CurrentModID .. "//" .. "ChooseType" .. self.ChooseType .. "//" .. "ModType" .. self.ModType .. "//" .. "CurrentModLevel" .. "\239\188\154" .. tostring(self.modLevel - 1))
    if self.modLevel < 1 then
      self.Image_Mod:SetOpacity(0.3)
      return
    else
      self.Image_Mod:SetOpacity(1)
    end
    for key, value in iterator(self.HorizontalBox_ModLevel:GetAllChildren()) do
      value:UpdateActiveInfo(false)
    end
    local widget
    local levelWidgets = self.HorizontalBox_ModLevel:GetAllChildren()
    for i = 1, self.modLevel do
      if levelWidgets:IsValidIndex(i) then
        widget = self.HorizontalBox_ModLevel:GetChildAt(i - 1)
        widget:UpdateActiveInfo(true)
      end
    end
  end
end

function WBP_ModViewInfo_C:GetToolTipWidget()
  if self.InitModID > 0 and self.modComponent then
    local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModView/WBP_ModViewTip.WBP_ModViewTip_C")
    local toolTipWidget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
    if toolTipWidget then
      local modLevelList = self.modComponent:GetLevelList(self.InitModID, self.ChooseType, self.ModType)
      local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
      if logicCommandDataSubsystem then
        local OutSaveData = GetLuaInscription(self.InitModID)
        if OutSaveData then
          toolTipWidget:InitModTipInfo(OutSaveData, self.modLevel, modLevelList)
          return toolTipWidget
        end
      end
    end
  else
    return nil
  end
end

function WBP_ModViewInfo_C:UpdateModIDFromLevelList()
  local gameState = UE.UGameplayStatics.GetGameState(self)
  if not gameState then
    return
  end
  local modManager = gameState:GetComponentByClass(UE.UMODManager:StaticClass())
  if not modManager then
    return
  end
  if self.modComponent then
    local modLevelList = self.modComponent:GetLevelList(self.InitModID, self.ChooseType, self.ModType)
    local hasLearned
    for key, value in pairs(modLevelList) do
      self.CurrentModID = value
      hasLearned = modManager:GetLearnedByModId(self:GetOwningPlayerPawn(), value, self.ModType)
      if not hasLearned then
        return
      end
    end
  end
end

return WBP_ModViewInfo_C
