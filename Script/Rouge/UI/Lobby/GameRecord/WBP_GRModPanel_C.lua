local WBP_GRModPanel_C = UnLua.Class()
function WBP_GRModPanel_C:Construct()
  EventSystem.AddListener(self, EventDef.GameRecordPanel.TypeButtonChanged, WBP_GRModPanel_C.OnTypeButtonChanged)
end
function WBP_GRModPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.GameRecordPanel.TypeButtonChanged, WBP_GRModPanel_C.OnTypeButtonChanged, self)
end
function WBP_GRModPanel_C:OnTypeButtonChanged(LastActiveWidget, CurActiveWidget, CurrentRoleInfoData)
  if CurActiveWidget == self then
    self.CurrentRoleInfoData = CurrentRoleInfoData
    self:UpdateGRModPanel()
    self:UpdateModLevel()
  end
end
function WBP_GRModPanel_C:UpdateGRModPanel()
  local finalLegendModTable = {}
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local Result, CharacterRow = GetRowDataForCharacter(self.CurrentRoleInfoData.HeroId)
    if Result then
      self.LegendMod:SetVisibility(UE.ESlateVisibility.Collapsed)
      local legendModConfig = CharacterRow.ModConfig.LegendConfig
      local legendModList = legendModConfig.LegendList
      local LegendModIdTable = legendModList:ToTable()
      if legendModList:Length() > 0 then
        for key, modInfo in pairs(self.CurrentRoleInfoData.ModList) do
          for key, value in pairs(LegendModIdTable) do
            if tonumber(modInfo.ModId) == tonumber(value) then
              local tempIdList = {}
              table.insert(tempIdList, value)
              table.insert(finalLegendModTable, tempIdList)
            end
          end
        end
        if table.count(finalLegendModTable) > 0 then
          self.LegendMod:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        end
        self.LegendMod:UpdateSingleModType(finalLegendModTable, legendModConfig.Name, legendModConfig.Icon)
      end
      for key, value in pairs(self.VerticalBox_SQE:GetAllChildren()) do
        value:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
      local widget
      for key, value in pairs(CharacterRow.ModConfig.QESList) do
        if value.ModType == UE.ERGModType.ESkillMod then
          widget = self.EMod
        end
        if value.ModType == UE.ERGModType.SSkillMod then
          widget = self.SMod
        end
        if value.ModType == UE.ERGModType.QSkillMod then
          widget = self.QMod
        end
        local ModIdList = {}
        for key, IdList in pairs(value.SkillList) do
          table.insert(ModIdList, IdList.LevelList:ToTable())
        end
        widget:UpdateSingleModType(ModIdList, value.Name, value.Icon)
        widget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
function WBP_GRModPanel_C:UpdateModLevel()
  for key, value in pairs(self.LegendMod.WBP_ModInfoBox.HorizontalBox_ModInfoBox:GetAllChildren()) do
    value:UpdateModInfoItem(1)
  end
  local ModInfoBoxTable = {}
  for key, value in pairs(self.VerticalBox_SQE:GetAllChildren()) do
    table.insert(ModInfoBoxTable, value.WBP_ModInfoBox)
  end
  local ModInfoItemTable = {}
  for key, modInfoBox in pairs(ModInfoBoxTable) do
    for key, modInfoItem in pairs(modInfoBox.HorizontalBox_ModInfoBox:GetAllChildren()) do
      table.insert(ModInfoItemTable, modInfoItem)
    end
  end
  for key, modInfoItem in pairs(ModInfoItemTable) do
    for key, modInfo in pairs(self.CurrentRoleInfoData.ModList) do
      for key, value in pairs(modInfoItem.ModIdList) do
        if value == modInfo.ModId then
          modInfoItem:UpdateModInfoItem(key)
        end
      end
    end
  end
end
return WBP_GRModPanel_C
