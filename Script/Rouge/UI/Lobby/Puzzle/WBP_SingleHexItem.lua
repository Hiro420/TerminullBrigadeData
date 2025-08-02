local WBP_SingleHexItem = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")

function WBP_SingleHexItem:Show(PuzzleId, Coordinate, CoordinateGroup, PuzzlePackageInfo, SlotIndex, PuzzleDetailInfo, GemPackageInfoList)
  self.PuzzleId = PuzzleId
  self.Coordinate = Coordinate
  self.PuzzlePackageInfo = PuzzlePackageInfo
  self.GemPackageInfoList = GemPackageInfoList
  local PackageInfo = self.PuzzlePackageInfo
  local ResourceId = self.PuzzlePackageInfo and self.PuzzlePackageInfo.resourceid
  if not PackageInfo then
    PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
    ResourceId = PackageInfo and tonumber(PackageInfo.resourceID)
    if not PackageInfo then
      return
    end
  end
  self.PuzzleDetailInfo = PuzzleDetailInfo
  local ResourceId = ResourceId
  local Result, ResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  SetImageBrushByPath(self.Img_Icon, ResRowInfo.SlotIcon)
  local Result, WorldRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleWorld, ResRowInfo.worldID)
  self.Img_Glow:SetColorAndOpacity(HexToFLinearColor(WorldRowInfo.ItemFXColor))
  self.Img_Loop:SetColorAndOpacity(HexToFLinearColor(WorldRowInfo.ItemLoopFXColor))
  local FrameColor = HexToFLinearColor(WorldRowInfo.ItemFrameColor)
  local AllFXItems = self.CanvasPanel_equipFX:GetAllChildren()
  for key, SingleItem in pairs(AllFXItems) do
    local DynamicMat = SingleItem:GetDynamicMaterial()
    if DynamicMat then
      DynamicMat:SetVectorParameterValue("sub_color", FrameColor)
    end
  end
  self:UpdateSelectedVis(false)
  self:RefreshSideSelectedVis(CoordinateGroup)
  self:UpdateEquipPanelVis(false)
  self:UpdateBoardEquipVis(false)
  if SlotIndex then
    self:RefreshGemItemStatus(SlotIndex)
  else
    UpdateVisibility(self.WBP_GemEquipItem, false)
    SetImageBrushByPath(self.Img_Main, WorldRowInfo.GridBottomIcon)
  end
end

function WBP_SingleHexItem:ChangeGemItemCanDragStatus(CanDrag)
  self.WBP_GemEquipItem:ChangeGemItemCanDragStatus(CanDrag)
end

function WBP_SingleHexItem:RefreshGemItemStatus(SlotIndex)
  local DetailInfo = self.PuzzleDetailInfo or PuzzleData:GetPuzzleDetailInfo(self.PuzzleId)
  local GemSlotInfo = {}
  if DetailInfo then
    GemSlotInfo = DetailInfo.GemSlotInfo or DetailInfo.gemslotinfo
  end
  local TargetGemId = GemSlotInfo[tostring(SlotIndex)] or nil
  UpdateVisibility(self.WBP_GemEquipItem, TargetGemId)
  local ResourceId = self.PuzzlePackageInfo and self.PuzzlePackageInfo.resourceid
  ResourceId = ResourceId or self.PuzzleId and PuzzleData:GetPuzzleResourceIdByUid(self.PuzzleId)
  if not ResourceId then
    return
  end
  local Result, ResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  local Result, WorldRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleWorld, ResRowInfo.worldID)
  if TargetGemId then
    local GemPackageInfo = self.GemPackageInfoList and self.GemPackageInfoList[TargetGemId]
    self.WBP_GemEquipItem:Show(TargetGemId, GemPackageInfo)
    SetImageBrushByPath(self.Img_Main, WorldRowInfo.HollowGridBottomIcon)
  else
    SetImageBrushByPath(self.Img_Main, WorldRowInfo.GridBottomIcon)
  end
end

function WBP_SingleHexItem:RefreshSideSelectedVis(CoordinateGroup)
  local EquipSlotCoordinate = {
    [0] = {
      [0] = 1
    }
  }
  if CoordinateGroup then
    EquipSlotCoordinate = CoordinateGroup
  else
    local SlotList = PuzzleData:GetSlotListByPuzzleId(self.PuzzleId)
    if not SlotList then
      return
    end
    local CenterSlotId = SlotList[1]
    if not CenterSlotId then
      return
    end
    local Result, SlotRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, CenterSlotId)
    local CenterOffsetX = 0 - SlotRowInfo.position.key
    local CenterOffsetY = 0 - SlotRowInfo.position.value
    for i, SingleSlotId in ipairs(SlotList) do
      if SingleSlotId ~= CenterSlotId then
        local Result, SlotRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, SingleSlotId)
        local Pos = SlotRowInfo.position
        if not EquipSlotCoordinate[Pos.key + CenterOffsetX] then
          EquipSlotCoordinate[Pos.key + CenterOffsetX] = {}
        end
        EquipSlotCoordinate[Pos.key + CenterOffsetX][Pos.value + CenterOffsetY] = 1
      end
    end
  end
  local IsShowTop = not EquipSlotCoordinate[self.Coordinate.key] or EquipSlotCoordinate[self.Coordinate.key][self.Coordinate.value - 1] == nil
  local IsShowTopLeft = not EquipSlotCoordinate[self.Coordinate.key - 1] or EquipSlotCoordinate[self.Coordinate.key - 1][self.Coordinate.value] == nil
  local IsShowBottomRight = not EquipSlotCoordinate[self.Coordinate.key + 1] or EquipSlotCoordinate[self.Coordinate.key + 1][self.Coordinate.value] == nil
  local IsShowBottom = not EquipSlotCoordinate[self.Coordinate.key] or EquipSlotCoordinate[self.Coordinate.key][self.Coordinate.value + 1] == nil
  local IsShowBottomLeft = not EquipSlotCoordinate[self.Coordinate.key - 1] or EquipSlotCoordinate[self.Coordinate.key - 1][self.Coordinate.value + 1] == nil
  local IsShowTopRight = not EquipSlotCoordinate[self.Coordinate.key + 1] or EquipSlotCoordinate[self.Coordinate.key + 1][self.Coordinate.value - 1] == nil
  UpdateVisibility(self.Canvas_Top, IsShowTop)
  UpdateVisibility(self.Canvas_TopLeft, IsShowTopLeft)
  UpdateVisibility(self.Canvas_BottomRight, IsShowBottomRight)
  UpdateVisibility(self.Canvas_Bottom, IsShowBottom)
  UpdateVisibility(self.Canvas_BottomLeft, IsShowBottomLeft)
  UpdateVisibility(self.Canvas_TopRight, IsShowTopRight)
  UpdateVisibility(self.Canvas_Top_Board, IsShowTop)
  UpdateVisibility(self.Canvas_TopLeft_Board, IsShowTopLeft)
  UpdateVisibility(self.Canvas_BottomRight_Board, IsShowBottomRight)
  UpdateVisibility(self.Canvas_Bottom_Board, IsShowBottom)
  UpdateVisibility(self.Canvas_BottomLeft_Board, IsShowBottomLeft)
  UpdateVisibility(self.Canvas_TopRight_Board, IsShowTopRight)
  UpdateVisibility(self.glow_top, IsShowTop)
  UpdateVisibility(self.glow_TopLeft, IsShowTopLeft)
  UpdateVisibility(self.glow_Topright, IsShowTopRight)
  UpdateVisibility(self.glow_Bottom, IsShowBottom)
  UpdateVisibility(self.glow_BottomLeft, IsShowBottomLeft)
  UpdateVisibility(self.glow_BottomRight, IsShowTopRight)
end

function WBP_SingleHexItem:UpdateSelectedVis(IsShow)
  UpdateVisibility(self.Overlay_Selected, IsShow)
end

function WBP_SingleHexItem:UpdateEquipPanelVis(IsShow)
  UpdateVisibility(self.Overlay_equip, IsShow)
end

function WBP_SingleHexItem:UpdateBoardEquipVis(IsShow)
  UpdateVisibility(self.Overlay_Board, IsShow)
end

function WBP_SingleHexItem:UpdateIsOverWorldNumStatus(IsOver)
  if IsOver then
    self.RGStateController_WorldNum:ChangeStatus("Over")
  else
    self.RGStateController_WorldNum:ChangeStatus("Normal")
  end
end

function WBP_SingleHexItem:PlayEquipAnim(...)
  self:PlayAnimation(self.Ani_equip)
end

function WBP_SingleHexItem:PlayEquipGemAnim(...)
  self.WBP_GemEquipItem:PlayEquipGemAnim()
end

function WBP_SingleHexItem:ShowOrHideGemHoverAnim(IsShow)
  if IsShow then
    self:PlayAnimation(self.Ani_xinpian_hover, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, true)
  else
    self:StopAnimation(self.Ani_xinpian_hover)
  end
end

function WBP_SingleHexItem:ShowOrHideEquipAnimImage(IsShow)
  if IsShow then
    self.Img_Loop:SetRenderOpacity(1.0)
    self.glow:SetRenderOpacity(1.0)
  else
    self.Img_Loop:SetRenderOpacity(0.0)
    self.glow:SetRenderOpacity(0.0)
  end
end

return WBP_SingleHexItem
