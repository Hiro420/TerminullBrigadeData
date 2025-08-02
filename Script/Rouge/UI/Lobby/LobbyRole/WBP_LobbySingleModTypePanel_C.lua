local WBP_LobbySingleModTypePanel_C = UnLua.Class()

function WBP_LobbySingleModTypePanel_C:InitModInfo(ModInfo)
  local bIsLegend = false
  if ModInfo.ModType == UE.ERGModType.LegendMod then
    bIsLegend = true
  end
  self.UniformGridPanel_Mod:ClearChildren()
  local tempModTable = {}
  local ModIDTable = {}
  local tempLevelList = {}
  local MaxColumn
  if bIsLegend then
    MaxColumn = 2
    tempModTable = ModInfo.LegendList:ToTable()
    for key, value in ipairs(tempModTable) do
      table.insert(tempLevelList, value)
      table.insert(ModIDTable, tempLevelList)
      tempLevelList = {}
    end
  else
    MaxColumn = 1
    tempModTable = ModInfo.SkillList:ToTable()
    for key, value in ipairs(tempModTable) do
      tempLevelList = value.LevelList:ToTable()
      table.insert(ModIDTable, tempLevelList)
    end
  end
  local widgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/LobbyRole/Mod/WBP_LobbyModViewInfo.WBP_LobbyModViewInfo_C")
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
  self.WBP_LobbyModTitleInfo:InitModTitles(bIsLegend, ModInfo, table.count(ModIDTable))
end

function WBP_LobbySingleModTypePanel_C:UpdateModInfo()
  local widget
  for key, value in iterator(self.UniformGridPanel_Mod:GetAllChildren()) do
    value:UpdateModInfo()
  end
end

return WBP_LobbySingleModTypePanel_C
