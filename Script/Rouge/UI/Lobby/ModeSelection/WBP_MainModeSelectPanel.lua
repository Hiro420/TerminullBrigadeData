local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local WBP_MainModeSelectPanel = Class(ViewBase)
local OpenSettingsKeyName = "OpenSettings"
local EscKeyName = "PauseGame"

function WBP_MainModeSelectPanel:BindClickHandler()
  self.EscFunctionalBtn.OnMainButtonClicked:Add(self, self.BindOnEscKeyPressed)
end

function WBP_MainModeSelectPanel:UnBindClickHandler()
  self.EscFunctionalBtn.OnMainButtonClicked:Remove(self, self.BindOnEscKeyPressed)
end

function WBP_MainModeSelectPanel:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_MainModeSelectPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_MainModeSelectPanel:OnShow(...)
  if not IsListeningForInputAction(self, EscKeyName) then
    ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
  EventSystem.AddListener(self, EventDef.ModeSelection.OnChangeThumbnailModeItem, self.BindOnChangeThumbnailModeItem)
  self.WBP_StartOrMatch:Show()
  UpdateVisibility(self.WBP_StartOrMatch, false)
  self:InitPanel()
  self:PlayAnimation(self.Ani_in, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
  self:PlayAnimation(self.Ani_loop, 0, 0)
end

function WBP_MainModeSelectPanel:OnHideByOther(...)
  local CurSelectItem = self:GetModeSelectItemPanel(self.CurSelectMode)
  if CurSelectItem and CurSelectItem.OnHideByOther then
    CurSelectItem:OnHideByOther()
  end
end

function WBP_MainModeSelectPanel:OnRollback(...)
  local CurSelectItem = self:GetModeSelectItemPanel(self.CurSelectMode)
  if CurSelectItem and CurSelectItem.OnRollback then
    CurSelectItem:OnRollback()
  end
end

function WBP_MainModeSelectPanel:InitPanel()
  self:RefreshModeSelectList()
  local AllChildren = self.CanvasPanel_ChildItemPanel:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    UpdateVisibility(SingleItem, false)
  end
  UpdateVisibility(self.MainModePanel, true)
  UpdateVisibility(self.LobbyFunctionSet, false)
  UpdateVisibility(self.CanvasPanel_ChildMainPanel, false)
  self.CurSelectMode = -1
end

function WBP_MainModeSelectPanel:RefreshModeSelectList(...)
  self.ModeSelectNavigationBarVisConfig = {}
  local AllChildren = self.ScrollList_ModeSelect:GetAllChildren()
  local FocusItem
  local NowGuideStepId = BeginnerGuideData.NowGuideStepId
  for k, SingleItem in pairs(AllChildren) do
    SingleItem:RefreshInfo()
    self.ModeSelectNavigationBarVisConfig[SingleItem.GameModeId] = SingleItem.IsShowNavigationBar
    SingleItem:PlayAnimation(SingleItem.Ani_in)
    local GuideStepIdList = SingleItem.GuideStepIdList:ToTable()
    if -1 ~= SingleItem.GuideStepId and table.Contain(GuideStepIdList, NowGuideStepId) and SingleItem:IsVisible() then
      FocusItem = SingleItem
    end
  end
  if FocusItem then
    self.ScrollList_ModeSelect:ScrollWidgetIntoView(FocusItem)
    self.ScrollList_ModeSelect:SetConsumeMouseWheel(UE.EConsumeMouseWheel.Never)
  else
    self.ScrollList_ModeSelect:SetConsumeMouseWheel(UE.EConsumeMouseWheel.WhenScrollingPossible)
  end
  local seasonModule = ModuleManager:Get("SeasonModule")
  if seasonModule:GetCurNormalMode() == TableEnums.ENUMGameMode.SEASONNORMAL then
    UpdateVisibility(self.WBP_ThumbnailModeItem_SeasonNormal, true)
    UpdateVisibility(self.WBP_ThumbnailModeItem_Normal, false)
  else
    UpdateVisibility(self.WBP_ThumbnailModeItem_SeasonNormal, false)
    UpdateVisibility(self.WBP_ThumbnailModeItem_Normal, true)
  end
end

function WBP_MainModeSelectPanel:OnShowLink(LinkParams, WorldIndex, Floor, ModeID)
  ChangeToLobbyAnimCamera()
  if not WorldIndex and LinkParams:IsValidIndex(1) then
    WorldIndex = LinkParams:GetRef(1).IntParam
  end
  local floor = 1
  if Floor then
    floor = Floor
  elseif LinkParams:IsValidIndex(2) then
    floor = LinkParams:GetRef(2).IntParam
  end
  local modeID = -1
  if LinkParams:IsValidIndex(3) then
    modeID = LinkParams:GetRef(3).IntParam
  else
    modeID = GetCurNormalMode()
  end
  if ModeID then
    modeID = ModeID
  else
  end
  if modeID >= 0 then
    EventSystem.Invoke(EventDef.ModeSelection.OnChangeThumbnailModeItem, modeID)
    EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeSelectionItem, WorldIndex, modeID)
    EventSystem.Invoke(EventDef.ModeSelection.OnChangeModeDifficultLevelItem, WorldIndex, floor, modeID)
  end
end

function WBP_MainModeSelectPanel:BindOnEscKeyPressed()
  local CurSelectItem = self:GetModeSelectItemPanel(self.CurSelectMode)
  if CurSelectItem and CurSelectItem.OnHide then
    CurSelectItem:OnHide()
    self:InitPanel()
  else
    if self.Ani_out then
      if self:IsAnimationPlaying(self.Ani_in) then
        self:StopAnimation(self.Ani_in)
      end
      self:PlayAnimationForward(self.Ani_out)
    else
      self:OnOutAnimationFinished()
    end
    EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
  end
end

function WBP_MainModeSelectPanel:GetModeSelectItemPanel(ModeIndex)
  local ModeSelectPanel = {
    [TableEnums.ENUMGameMode.NORMAL] = self.WBP_NormalWorldSelectionPanel,
    [TableEnums.ENUMGameMode.SEASONNORMAL] = self.WBP_NormalWorldSelectionPanel
  }
  return ModeSelectPanel[ModeIndex]
end

function WBP_MainModeSelectPanel:BindOnChangeThumbnailModeItem(ModeIndex, DefaultWorldId)
  self.CurSelectMode = ModeIndex
  if ModeIndex == TableEnums.ENUMGameMode.BOSSRUSH then
    UIMgr:Show(ViewID.UI_BossRush, true)
    return
  elseif ModeIndex == TableEnums.ENUMGameMode.SURVIVAL then
    UIMgr:Show(ViewID.UI_SurvivalPanel, true, TableEnums.ENUMGameMode.SURVIVAL)
    return
  elseif ModeIndex == TableEnums.ENUMGameMode.TOWERClIMBING then
    UIMgr:Show(ViewID.UI_ClimbTower, true)
    return
  end
  self.WBP_StartOrMatch:ChangeGameMode(self.CurSelectMode)
  local TargetChildPanel = self:GetModeSelectItemPanel(ModeIndex)
  UpdateVisibility(self.MainModePanel, not TargetChildPanel)
  UpdateVisibility(self.CanvasPanel_ChildMainPanel, TargetChildPanel)
  if TargetChildPanel then
    UpdateVisibility(TargetChildPanel, true)
    if TargetChildPanel.OnShow then
      TargetChildPanel:OnShow(self.CurSelectMode)
      self.WBP_StartOrMatch:PlayAnimation(self.WBP_StartOrMatch.Ani_WorldSelectionPanel_in)
    end
    UpdateVisibility(self.WBP_StartOrMatch.Overlay_AllCheckMatchingPanel, TargetChildPanel ~= self.WBP_NormalWorldSelectionPanel)
    UpdateVisibility(self.WBP_StartOrMatch.Overlay_AllCheckMatchingPanel_1, TargetChildPanel == self.WBP_NormalWorldSelectionPanel)
    self.WBP_StartOrMatch:UpdateCheckPanelTarget(TargetChildPanel ~= self.WBP_NormalWorldSelectionPanel)
    local IsShowNavigationBar = self.ModeSelectNavigationBarVisConfig[ModeIndex]
    UpdateVisibility(self.LobbyFunctionSet, false)
  else
    LogicTeam.RequestSetTeamDataToServer(DefaultWorldId, ModeIndex, DataMgr.GetFloorByGameModeIndex(DefaultWorldId, ModeIndex))
    self:BindOnEscKeyPressed()
  end
end

function WBP_MainModeSelectPanel:OnHide()
  self.WBP_StartOrMatch:ChangeGameMode(0, true)
  self.WBP_StartOrMatch:Hide()
  local CurSelectItem = self:GetModeSelectItemPanel(self.CurSelectMode)
  if CurSelectItem and CurSelectItem.OnHide then
    CurSelectItem:OnHide()
  end
  if IsListeningForInputAction(self, EscKeyName) then
    StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  end
  EventSystem.RemoveListener(EventDef.ModeSelection.OnChangeThumbnailModeItem, self.BindOnChangeThumbnailModeItem, self)
end

function WBP_MainModeSelectPanel:OnOutAnimationFinished()
  UIMgr:Hide(ViewID.UI_MainModeSelection, true)
end

function WBP_MainModeSelectPanel:OnAnimationFinished(Animation)
  if self.Ani_out == Animation then
    self:OnOutAnimationFinished()
  end
end

function WBP_MainModeSelectPanel:Destruct(...)
  self:OnHide()
  self:UnBindClickHandler()
end

return WBP_MainModeSelectPanel
