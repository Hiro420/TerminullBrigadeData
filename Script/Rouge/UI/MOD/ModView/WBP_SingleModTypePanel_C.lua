local WBP_SingleModTypePanel_C = UnLua.Class()

function WBP_SingleModTypePanel_C:InitModInfo(ModInfo)
  local bIsLegend = false
  if ModInfo.ModType == UE.ERGModType.LegendMod then
    bIsLegend = true
  end
  self.WBP_ModTitleInfo:InitModTitles(bIsLegend, ModInfo)
  self.UniformGridPanel_Mod:ClearChildren()
  local tempModTable = {}
  local ModIDTable = {}
  local MaxColumn
  if bIsLegend then
    MaxColumn = 2
    ModIDTable = ModInfo.LegendList:ToTable()
  else
    MaxColumn = 1
    tempModTable = ModInfo.SkillList:ToTable()
    for key, value in ipairs(tempModTable) do
      if value.LevelList:IsValidIndex(1) then
        table.insert(ModIDTable, value.LevelList:Get(1))
      end
    end
  end
  local widgetClass = UE.UClass.Load("/Game/Rouge/UI/MOD/ModView/WBP_ModViewInfo.WBP_ModViewInfo_C")
  local widget
  local row = 0
  local column = 0
  local translation = UE.FVector2D()
  for key, value in ipairs(ModIDTable) do
    widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
    if widget then
      widget:InitModInfo(bIsLegend, value, UE.ERGMODChooseType.Character, ModInfo.ModType)
      translation.X = 30 - column * 15 + 57.5 * row
      translation.Y = -46 * row
      widget:SetRenderTranslation(translation)
      self.UniformGridPanel_Mod:AddChildToUniformGrid(widget, row, column)
      column = column + 1
      if MaxColumn < column then
        row = row + 1
        column = 0
      end
    end
  end
end

function WBP_SingleModTypePanel_C:UpdateModInfo()
  self.WBP_ModTitleInfo:UpdateModTitles()
  local widget
  for key, value in iterator(self.UniformGridPanel_Mod:GetAllChildren()) do
    value:UpdateModInfo()
  end
end

return WBP_SingleModTypePanel_C
