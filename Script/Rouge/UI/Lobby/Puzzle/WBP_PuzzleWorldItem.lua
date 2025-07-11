local WBP_PuzzleWorldItem = UnLua.Class()
local PuzzleData = require("Modules.Puzzle.PuzzleData")
function WBP_PuzzleWorldItem:Show(WorldId)
  self.WorldId = WorldId
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleWorld, self.WorldId)
  if not Result then
    return
  end
  UpdateVisibility(self, true)
  SetImageBrushByPath(self.Img_Icon, RowInfo.Icon)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  self.Txt_MaxNum:SetText(ConstTable.MatrixPuzzleWroldGridLimitNum)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleDrag, self, self.BindOnPuzzleDrag)
  EventSystem.AddListenerNew(EventDef.Puzzle.OnPuzzleboardDragCancelled, self, self.BindOnPuzzleboardDragCancelled)
end
function WBP_PuzzleWorldItem:BindOnPuzzleDrag(PuzzleId)
  local ResourceId = PuzzleData:GetPuzzleResourceIdByUid(PuzzleId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  if not Result then
    return
  end
  if RowInfo.worldID ~= self.WorldId then
    return
  end
  self:SetPreWorldUseNum(self.CurUseNum + RowInfo.gridNum)
end
function WBP_PuzzleWorldItem:BindOnPuzzleboardDragCancelled(...)
  self:SetPreWorldUseNum(self.CurUseNum)
end
function WBP_PuzzleWorldItem:RefreshUseNum(WorldUseNumList)
  local UseNum = 0
  if WorldUseNumList[self.WorldId] then
    UseNum = WorldUseNumList[self.WorldId]
  end
  self.CurUseNum = UseNum
  self:SetPreWorldUseNum(UseNum)
end
function WBP_PuzzleWorldItem:SetPreWorldUseNum(UseNum)
  self.Txt_CurUseNum:SetText(UseNum)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  local MaxGridNum = ConstTable.MatrixPuzzleWroldGridLimitNum
  if UseNum > MaxGridNum then
    self.RGStateController_WorldNum:ChangeStatus("Over")
    self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  else
    self.RGStateController_WorldNum:ChangeStatus("Normal")
    self:StopAnimation(self.Ani_loop)
  end
end
function WBP_PuzzleWorldItem:GetToolTipWidget(...)
end
function WBP_PuzzleWorldItem:OnMouseEnter()
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleWorldHoverStatus, true, self.WorldId)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleWorld, self.WorldId)
  if not Result then
    return
  end
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  local WidgetClassPath = "/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleWorldTip.WBP_PuzzleWorldTip_C"
  self.TipWidget = ShowCommonTips(nil, self, nil, WidgetClassPath)
  local Result, WorldRowInfo = GetRowData(DT.DT_GameMode, self.WorldId)
  if Result then
    self.TipWidget:Show(UE.FTextFormat(RowInfo.Desc, WorldRowInfo.Name, ConstTable.MatrixPuzzleWroldGridLimitNum, self.CurUseNum))
  end
end
function WBP_PuzzleWorldItem:OnMouseLeave()
  EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleWorldHoverStatus, false, self.WorldId)
  UpdateVisibility(self.TipWidget, false)
end
function WBP_PuzzleWorldItem:Hide()
  UpdateVisibility(self, false)
  self.CurUseNum = 0
  self:StopAnimation(self.Ani_loop)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleDrag, self, self.BindOnPuzzleDrag)
  EventSystem.RemoveListenerNew(EventDef.Puzzle.OnPuzzleboardDragCancelled, self, self.BindOnPuzzleboardDragCancelled)
end
function WBP_PuzzleWorldItem:Destruct()
  self:Hide()
end
return WBP_PuzzleWorldItem
