local WBP_WorldChoosePanel_C = UnLua.Class()
function WBP_WorldChoosePanel_C:Construct()
  self:InitUniformGridPanel()
end
function WBP_WorldChoosePanel_C:InitUniformGridPanel()
  self.ScrollBox_WorldSlot:ClearChildren()
  self.WorldSlotWidgetArray:Clear()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local dataTable = DTSubsystem:GetDataTable("WorldType")
    if dataTable then
      local rowNames = UE.TArray(UE.FName)
      rowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(dataTable)
      local widget
      local widgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/MainLobby/WBP_WorldSlot.WBP_WorldSlot_C")
      for key, value in iterator(rowNames) do
        local result, worldTypeData = DTSubsystem:GetWorldTypeTableRow(tonumber(value))
        if result and worldTypeData.bCanSelected then
          widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
          if widget then
            widget:InitInfo(worldTypeData)
            widget.ButtonClickedDelegate:Add(self, WBP_WorldChoosePanel_C.OnClicked_WorldType)
            self.WorldSlotWidgetArray:Add(widget)
          end
        end
      end
      self:InitSortWorldTypeSlot()
      self:InitChooseWorldSlot()
    end
  end
end
function WBP_WorldChoosePanel_C:InitSortWorldTypeSlot()
  local widgetTable = self.WorldSlotWidgetArray:ToTable()
  local unlockWorldSlotWidgetArray = {}
  local lockWorldSlotWidgetArray = {}
  for key, value in pairs(widgetTable) do
    if value.bUnlock then
      table.insert(unlockWorldSlotWidgetArray, value)
    else
      table.insert(lockWorldSlotWidgetArray, value)
    end
  end
  table.sort(unlockWorldSlotWidgetArray, function(A, B)
    return A.TableRow.SortPriority < B.TableRow.SortPriority
  end)
  table.sort(lockWorldSlotWidgetArray, function(A, B)
    return A.TableRow.SortPriority < B.TableRow.SortPriority
  end)
  for key, value in pairs(unlockWorldSlotWidgetArray) do
    self.ScrollBox_WorldSlot:AddChild(value)
    value:PlayAnimation(value.ani_worldslot_In)
  end
  for key, value in pairs(lockWorldSlotWidgetArray) do
    self.ScrollBox_WorldSlot:AddChild(value)
    value:PlayAnimation(value.ani_worldslot_In)
  end
end
function WBP_WorldChoosePanel_C:InitChooseWorldSlot()
  local arrayWidgets = self.ScrollBox_WorldSlot:GetAllChildren()
  if arrayWidgets:Length() > 0 then
    local widget = arrayWidgets:Get(1)
    if widget then
      widget:OnClicked_WorldType()
    end
  end
end
function WBP_WorldChoosePanel_C:OnClicked_WorldType(widget)
  self.ChooseWorldSlot = widget
  for key, value in iterator(self.ScrollBox_WorldSlot:GetAllChildren()) do
    if widget ~= value then
      value:ShowButtonChooseState(false)
    end
  end
  if widget.TableRow.ModeID > 1 then
    local game_floor = 1
    self.WBP_GameTypePanel:RequestSetGameFloor(game_floor)
    self.WBP_GameTypePanel:RequestSetGameMod(widget.TableRow.ModeID)
  end
end
return WBP_WorldChoosePanel_C
