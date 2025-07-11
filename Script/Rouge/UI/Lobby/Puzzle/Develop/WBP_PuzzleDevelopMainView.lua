local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_PuzzleDevelopMainView = Class(ViewBase)
local ToggleIdToViewId = {
  [EPuzzleGemDevelopId.PuzzleStrengthen] = ViewID.UI_PuzzleRefactor,
  [EPuzzleGemDevelopId.PuzzleDecompose] = ViewID.UI_PuzzleDecompose,
  [EPuzzleGemDevelopId.GemUpgrade] = ViewID.UI_GemUpgrade,
  [EPuzzleGemDevelopId.GemDecompose] = ViewID.UI_GemDecompose
}
function WBP_PuzzleDevelopMainView:BindClickHandler()
  self.MenuToggleGroup.OnCheckStateChanged:Add(self, self.BindOnCheckStateChanged)
end
function WBP_PuzzleDevelopMainView:UnBindClickHandler()
  self.MenuToggleGroup.OnCheckStateChanged:Remove(self, self.BindOnCheckStateChanged)
end
function WBP_PuzzleDevelopMainView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_PuzzleDevelopMainView:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_PuzzleDevelopMainView:OnShow(SelectedPuzzleId, ToggleId)
  self.CurSelectPuzzleId = SelectedPuzzleId
  self.CurSelectGemId = SelectedPuzzleId
  if not ToggleId or ToggleId == EPuzzleGemDevelopId.PuzzleStrengthen or ToggleId == EPuzzleGemDevelopId.PuzzleDecompose then
    self.CurSelectGemId = nil
  else
    self.CurSelectPuzzleId = nil
  end
  local TargetToggleId = ToggleId or EPuzzleGemDevelopId.PuzzleStrengthen
  self.MenuToggleGroup:SelectId(TargetToggleId)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_PuzzleDevelopMainView:BindOnCheckStateChanged(ToggleId)
  local LastViewId = ToggleIdToViewId[self.SelectToggleId]
  if LastViewId then
    UIMgr:Hide(LastViewId, false)
  end
  self.SelectToggleId = ToggleId
  local TargetViewId = ToggleIdToViewId[ToggleId]
  if not TargetViewId then
    return
  end
  local TargetId
  if ToggleId == EPuzzleGemDevelopId.PuzzleStrengthen or ToggleId == EPuzzleGemDevelopId.PuzzleDecompose then
    TargetId = self.CurSelectPuzzleId
  else
    TargetId = self.CurSelectGemId
  end
  UIMgr:Show(TargetViewId, false, TargetId)
end
function WBP_PuzzleDevelopMainView:BindOnEscKeyPressed(...)
  local TargetSubViewId = ToggleIdToViewId[self.SelectToggleId]
  if TargetSubViewId then
    UIMgr:Hide(TargetSubViewId)
  end
  UIMgr:Hide(ViewID.UI_PuzzleDevelopMain, true)
end
function WBP_PuzzleDevelopMainView:OnHide()
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  self:SetEnhancedInputActionBlocking(false)
end
function WBP_PuzzleDevelopMainView:Destruct(...)
  self:OnHide()
end
return WBP_PuzzleDevelopMainView
