local WBP_PuzzleSpecifiedBoard = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")

function WBP_PuzzleSpecifiedBoard:Show(HeroId, SlotLockList, InSlotEquipList, PuzzleInfoList, GemPackageInfoList)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleHero, HeroId)
  if Result then
    SetImageBrushByPath(self.Img_Bottom, RowInfo.BottomIcon)
  end
  local Size = self.BoardItemSize
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.PuzzleboardItemTemplate)
  local Index = 1
  local BoardCoordinate = PuzzleData:GetPuzzleboardCoordinateByHeroId(HeroId)
  if not BoardCoordinate then
    return
  end
  local SlotEquipList = {}
  local PuzzleEquipList = {}
  for i, SingleSlotInfo in ipairs(InSlotEquipList) do
    for index, SlotId in ipairs(SingleSlotInfo.Slots) do
      SlotEquipList[SlotId] = tostring(SingleSlotInfo.UniqueID)
    end
    PuzzleEquipList[tostring(SingleSlotInfo.UniqueID)] = SingleSlotInfo.Slots
  end
  for CoordinateX, SingleCoordinateInfo in pairs(BoardCoordinate) do
    for CoordinateY, SlotId in pairs(SingleCoordinateInfo) do
      local Item = GetOrCreateItem(self.Canvaspanel_Puzzleboard, Index, self.PuzzleboardItemTemplate:StaticClass())
      local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
      if Slot then
        Slot:SetAnchors(TemplateSlot:GetAnchors())
        Slot:SetAlignment(TemplateSlot:GetAlignment())
        local PosX = 1.5 * Size.X * CoordinateX
        local PosY = Size.Y * (0 - (-CoordinateX - CoordinateY) + CoordinateY)
        Slot:SetPosition(UE.FVector2D(PosX, PosY))
        Slot:SetAutoSize(true)
      end
      local Status = SlotEquipList[SlotId]
      if not Status then
        local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, SlotId)
        if 0 == RowInfo.unlock or table.Contain(SlotLockList, SlotId) then
          Status = EPuzzleSlotStatus.Empty
        else
          Status = EPuzzleSlotStatus.Lock
        end
      end
      local PackageInfo = PuzzleInfoList[Status] and PuzzleInfoList[Status].Base
      local DetailInfo = PuzzleInfoList[Status] and PuzzleInfoList[Status].detail
      Item:ShowBySpecifiedData(CoordinateX, CoordinateY, SlotId, Status, PackageInfo, DetailInfo, PuzzleEquipList, GemPackageInfoList)
      Index = Index + 1
    end
  end
  HideOtherItem(self.Canvaspanel_Puzzleboard, Index, true)
end

function WBP_PuzzleSpecifiedBoard:Hide(...)
  local AllChildren = self.Canvaspanel_Puzzleboard:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
end

function WBP_PuzzleSpecifiedBoard:Destruct(...)
  self:Hide()
end

return WBP_PuzzleSpecifiedBoard
