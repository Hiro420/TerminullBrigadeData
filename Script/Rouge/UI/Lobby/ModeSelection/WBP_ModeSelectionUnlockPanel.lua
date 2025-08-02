local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local WBP_ModeSelectionUnlockPanel = Class(ViewBase)

function WBP_ModeSelectionUnlockPanel:BindClickHandler()
end

function WBP_ModeSelectionUnlockPanel:UnBindClickHandler()
end

function WBP_ModeSelectionUnlockPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_ModeSelectionUnlockPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_ModeSelectionUnlockPanel:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local tbParam = {
    ...
  }
  self.ShowFloorList = tbParam[1]
  self.ShowFloorWorldIdList = {}
  for WorldId, World in pairs(self.ShowFloorList) do
    table.insert(self.ShowFloorWorldIdList, WorldId)
  end
  self.IsWorldUnlock = false
  self:RefreshPanel()
  self:SetFocus()
end

function WBP_ModeSelectionUnlockPanel:RefreshPanel(...)
  local TargetWorldId = self.ShowFloorWorldIdList[1]
  if not TargetWorldId then
    UIMgr:Hide(ViewID.UI_ModeSelectionUnlockPanel)
    return
  end
  local TargetWorldFloor = self.ShowFloorList[TargetWorldId]
  table.remove(self.ShowFloorWorldIdList, 1)
  UpdateVisibility(self.CanvasPanel_WorldUnlock, false)
  UpdateVisibility(self.CanvasPanel_WorldFloorUnlock, false)
  local Result, WorldRowInfo = GetRowData(DT.DT_GameMode, tostring(TargetWorldId))
  if not Result then
    self:RefreshPanel()
    return
  end
  self.IsWorldUnlock = 0 == TargetWorldFloor
  if 0 == TargetWorldFloor then
    UpdateVisibility(self.CanvasPanel_WorldUnlock, true)
    self:PlayAnimationForward(self.WorldUnlockAnim_IN)
    SetImageBrushBySoftObject(self.Img_WorldIcon, WorldRowInfo.Icon)
    self.Txt_WorldName:SetText(WorldRowInfo.Name)
    local AResult, TaskGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBTaskGroupData, WorldRowInfo.UnlockTaskGroupId)
    UpdateVisibility(self.TaskGroupPanel, AResult)
    if AResult then
      SetImageBrushByPath(self.Img_TaskGroupIcon, TaskGroupRowInfo.icon)
      self.Txt_TaskGroupContent:SetText(TaskGroupRowInfo.content)
    end
    UpdateVisibility(self.ChipSlotPanel, 0 ~= WorldRowInfo.UnlockChipIdList:Length())
    local Index = 1
    for key, SingleChipSlotId in pairs(WorldRowInfo.UnlockChipIdList) do
      local Item = GetOrCreateItem(self.ChipSlotPanel, Index)
      Item:Show(SingleChipSlotId)
      Index = Index + 1
    end
    HideOtherItem(self.ChipSlotPanel, Index)
  else
    UpdateVisibility(self.CanvasPanel_WorldFloorUnlock, true)
    UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
      self,
      function()
        self:PlayAnimationForward(self.WorldFloorUnlockAnim_IN)
      end
    })
    SetImageBrushBySoftObject(self.Img_WorldIcon_FloorUnlock, WorldRowInfo.Icon)
    local FloorInfoText = NSLOCTEXT("WBP_ModeSelectionUnlockPanel", "FloorInfo", "{0}-\233\154\190\229\186\166{1}")
    self.Txt_FloorInfo:SetText(UE.FTextFormat(FloorInfoText, WorldRowInfo.Name, TargetWorldFloor))
  end
end

function WBP_ModeSelectionUnlockPanel:OnAnimationFinished(InAnimation)
  if InAnimation == self.WorldFloorUnlockAnim_IN then
    self:RefreshPanel()
  elseif InAnimation == self.WorldUnlockAnim_OUT then
    self:RefreshPanel()
  end
end

function WBP_ModeSelectionUnlockPanel:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.IsWorldUnlock then
    self:PlayAnimationForward(self.WorldUnlockAnim_OUT)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_ModeSelectionUnlockPanel:OnKeyDown(MyGeometry, InKeyEvent)
  if self.IsWorldUnlock then
    self:PlayAnimationForward(self.WorldUnlockAnim_OUT)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_ModeSelectionUnlockPanel:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

return WBP_ModeSelectionUnlockPanel
