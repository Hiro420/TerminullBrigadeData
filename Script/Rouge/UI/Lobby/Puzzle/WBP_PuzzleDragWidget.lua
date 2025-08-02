local WBP_PuzzleDragWidget = UnLua.Class()
local PuzzleRotateName = "PuzzleRotate"
local PuzzleData = require("Modules.Puzzle.PuzzleData")

function WBP_PuzzleDragWidget:Show(Coordinate, PuzzleId)
  if not IsListeningForInputAction(self, PuzzleRotateName, UE.EInputEvent.IE_Pressed) then
    ListenForInputAction(PuzzleRotateName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnPuzzleRotateKeyPressed
    })
  end
  self.PuzzleId = PuzzleId
  self.RotateIndex = 1
  self:RefreshItemPos(Coordinate)
end

function WBP_PuzzleDragWidget:RefreshItemPos(Coordinate)
  local PuzzleView = UIMgr:GetLuaFromActiveView(ViewID.UI_Puzzle)
  local Size = PuzzleView.BoardItemSize
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SingleHexItem)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  local MaxGridNum = ConstTable.MatrixPuzzleWroldGridLimitNum
  local Index = 1
  local CoordinateGroup = {}
  for k, SingleCoordinate in pairs(Coordinate) do
    if not CoordinateGroup[SingleCoordinate.key] then
      CoordinateGroup[SingleCoordinate.key] = {}
    end
    CoordinateGroup[SingleCoordinate.key][SingleCoordinate.value] = 1
  end
  for k, SingleCoordinate in pairs(Coordinate) do
    local Item = GetOrCreateItem(self.CanvasPanel_Main, Index, self.WBP_SingleHexItem:StaticClass())
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    if Slot then
      Slot:SetAnchors(TemplateSlot:GetAnchors())
      Slot:SetAlignment(TemplateSlot:GetAlignment())
      local PosX = 1.5 * Size.X * SingleCoordinate.key
      local PosY = Size.Y * (0 - (-SingleCoordinate.key - SingleCoordinate.value) + SingleCoordinate.value)
      Slot:SetPosition(UE.FVector2D(PosX, PosY))
      Slot:SetAutoSize(true)
    end
    Item:Show(self.PuzzleId, SingleCoordinate, CoordinateGroup, nil, Index - 1)
    if next(PuzzleData:GetPendingDragSlotList()) ~= nil then
      Item:UpdateIsOverWorldNumStatus(false)
    else
      local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(self.PuzzleId)
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
      local CurWorldUseNum = PuzzleView.WorldUseNumList[RowInfo.worldID] or 0
      Item:UpdateIsOverWorldNumStatus(MaxGridNum < CurWorldUseNum + RowInfo.gridNum)
    end
    Item:UpdateSelectedVis(true)
    UpdateVisibility(Item, true)
    Index = Index + 1
  end
  HideOtherItem(self.CanvasPanel_Main, Index, true)
  if next(PuzzleData:GetPendingDragSlotList()) ~= nil then
    local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(self.PuzzleId)
    for i, SinglePosition in ipairs(ShapeRowInfo.changePositions) do
      local IsMatch = true
      for index, SingleItemPosition in ipairs(SinglePosition.pos) do
        if Coordinate[index].key ~= SingleItemPosition.key or Coordinate[index].value ~= SingleItemPosition.value then
          IsMatch = false
          break
        end
      end
      if IsMatch then
        self.RotateIndex = i + 1
        break
      end
    end
  end
end

function WBP_PuzzleDragWidget:BindOnPuzzleRotateKeyPressed(IsRightMouse)
  if not IsRightMouse then
    local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(self:GetOwningPlayer(), UE.UCommonInputSubsystem:StaticClass())
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    local RotateKey = LogicGameSetting.GetCurPlayerMappableKey("PuzzleRotate", CurrentInputType)
    if UE.UKismetInputLibrary.Key_IsMouseButton(RotateKey) then
      return
    end
  end
  PlaySound2DByName(self.RotateSoundName, "WBP_PuzzleDragWidget:BindOnPuzzleRotateKeyPressed")
  local DragOperation = UE.UWidgetBlueprintLibrary.GetDragDroppingContent()
  local PuzzleResourceId = PuzzleData:GetPuzzleResourceIdByUid(DragOperation.PuzzleId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, PuzzleResourceId)
  if not Result then
    return
  end
  if not self.RotateIndex then
    self.RotateIndex = 1
  end
  local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(self.PuzzleId)
  local RotateCoordinate = ShapeRowInfo.changePositions[self.RotateIndex]
  if not RotateCoordinate then
    RotateCoordinate = ShapeRowInfo.changePositions[1]
    self.RotateIndex = 1
  end
  if not RotateCoordinate then
    return
  end
  self.RotateIndex = self.RotateIndex + 1
  local PuzzleViewModel = UIModelMgr:Get("PuzzleViewModel")
  PuzzleViewModel:UpdatePuzzleDragCoordinate(RotateCoordinate.pos)
  EventSystem.Invoke(EventDef.Puzzle.OnRotatePuzzleDragCoordinate, RotateCoordinate.pos)
end

function WBP_PuzzleDragWidget:Destruct(...)
  if IsListeningForInputAction(self, PuzzleRotateName, UE.EInputEvent.IE_Pressed) then
    StopListeningForInputAction(self, PuzzleRotateName, UE.EInputEvent.IE_Pressed)
  end
end

return WBP_PuzzleDragWidget
