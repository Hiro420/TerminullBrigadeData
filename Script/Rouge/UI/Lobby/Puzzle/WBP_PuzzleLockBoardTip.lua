local WBP_PuzzleLockBoardTip = UnLua.Class()
function WBP_PuzzleLockBoardTip:Show(SlotId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleSlots, SlotId)
  self.Txt_Desc:SetText(RowInfo.desc)
end
return WBP_PuzzleLockBoardTip
