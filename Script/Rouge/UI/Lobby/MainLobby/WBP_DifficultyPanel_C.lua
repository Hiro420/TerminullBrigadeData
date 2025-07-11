local WBP_DifficultyPanel_C = UnLua.Class()
function WBP_DifficultyPanel_C:InitScrollBox()
  self.UniformGridPanel_Difficulty:ClearChildren()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local dataTable = DTSubsystem:GetDataTable("LobbyDifficulty")
    if dataTable then
      local rowNames = UE.TArray(UE.FName)
      rowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
      local widget
      local widgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/MainLobby/WBP_DifficultySlot.WBP_DifficultySlot_C")
      local unlock_floor = DataMgr.GetGameFloorByGameMode()
      local column = 0
      local row = 0
      for key, value in iterator(rowNames) do
        local result, lobbyDifficultyTableRow = DTSubsystem:GetLobbyDifficultyTableRow(tonumber(value))
        if result then
          widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
          if widget then
            if unlock_floor >= lobbyDifficultyTableRow.DifficultyID then
              lobbyDifficultyTableRow.bInitUnLock = true
            else
              lobbyDifficultyTableRow.bInitUnLock = false
            end
            widget:InitInfo(lobbyDifficultyTableRow)
            local Margin = UE.FMargin()
            Margin.Left = 20
            widget:SetPadding(Margin)
            self.UniformGridPanel_Difficulty:AddChildToUniformGrid(widget, column, row)
            widget.ButtonClickedDelegate:Add(self, WBP_DifficultyPanel_C.OnClicked_Difficulty)
            row = row + 1
            if row > 6 then
              column = column + 1
              row = 0
            end
          end
        end
      end
      self:InitChooseDifficultySlot()
    end
  end
end
function WBP_DifficultyPanel_C:InitChooseDifficultySlot()
  local arrayWidgets = self.UniformGridPanel_Difficulty:GetAllChildren()
  local index
  for key, value in iterator(arrayWidgets) do
    index = key
    if value.bUnlock == false then
      index = key - 1
      break
    end
  end
  local widget = arrayWidgets:Get(1)
  if widget then
    widget:OnClicked_Difficulty()
  end
end
function WBP_DifficultyPanel_C:OnClicked_Difficulty(widget)
  self.ChooseDifficultySlot = widget
  for key, value in iterator(self.UniformGridPanel_Difficulty:GetAllChildren()) do
    if widget ~= value then
      value:ShowButtonChooseState(false)
    end
  end
end
return WBP_DifficultyPanel_C
