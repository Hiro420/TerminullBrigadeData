local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local EscName = "PauseGame"
local RecruitMainView = Class(ViewBase)
local NotFilterText = NSLOCTEXT("WBP_RecruitWindow_C", "NotFilterText", "\229\133\168\233\131\168")
local DifficultyText = NSLOCTEXT("WBP_RecruitWindow_C", "DifficultyText", "\233\154\190\229\186\166")

function RecruitMainView:BindClickHandler()
end

function RecruitMainView:UnBindClickHandler()
end

function RecruitMainView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("RecruitMainViewModel")
  self:BindClickHandler()
end

function RecruitMainView:OnDestroy()
end

function RecruitMainView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.IsFilter = true
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.EscView)
  self.Btn_ChangeList.OnClicked:Add(self, self.OnClicked_BtnChangeList)
  self.Btn_Filter.OnClicked:Add(self, self.OnClicked_BtnFilter)
  self.Btn_Recruit.OnClicked:Add(self, self.OnClicked_BtnRecruit)
  self.Btn_stop.OnClicked:Add(self, self.OnClicked_Btnstop)
  self.Btn_QuickJoin.OnClicked:Add(self, self.OnClicked_BtnQuickJoin)
  self.Btn_QuickJoin.OnClicked:Add(self, self.OnClicked_BtnQuickJoin)
  self.Btn_CancelFilter.OnClicked:Add(self, self.OnClicked_BtnCancelFilter)
  self.IsInit = true
  self:ClearTimerList()
  HideOtherItem(self.ScrollBox_TeamList, 1)
  self.viewModel:InitRecruitTeamList()
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.EscView
    })
  end
  self.IsClose = false
  self:PlayAnimation(self.Ani_in)
  if self.Ani_loop then
    self:PlayAnimation(self.Ani_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  end
  LogicRole.ShowOrHideRoleMainHero(false)
end

function RecruitMainView:ClearTimerList()
  if self.TimerList then
    for _, timer in pairs(self.TimerList) do
      if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(timer) then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, timer)
      end
    end
  end
  self.TimerList = {}
end

function RecruitMainView:OnPreHide()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.EscView)
  self.Btn_ChangeList.OnClicked:Remove(self, self.OnClicked_BtnChangeList)
  self.Btn_Filter.OnClicked:Remove(self, self.OnClicked_BtnFilter)
  self.Btn_Recruit.OnClicked:Remove(self, self.OnClicked_BtnRecruit)
  self.Btn_stop.OnClicked:Remove(self, self.OnClicked_Btnstop)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self:StopAllAnimations()
  self:ClearTimerList()
end

function RecruitMainView:OnHide()
  self:StopAllAnimations()
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
end

function RecruitMainView:UpdateRecruitList(TeamList)
  local Interval = 0
  if self.IsInit then
    Interval = 0.2
    self.IsInit = false
  end
  self:ClearTimerList()
  self.ScrollBox_TeamList:ScrollToStart()
  for i, TeamInfo in ipairs(TeamList) do
    local teamInfoItem = GetOrCreateItem(self.ScrollBox_TeamList, i, self.WBP_RecruitItem:GetClass())
    if 1 == i and 0 == Interval then
      UpdateVisibility(teamInfoItem, true)
      teamInfoItem:InitTeamItemInfo(TeamInfo, self)
    else
      UpdateVisibility(teamInfoItem, false)
      local ShowTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        function()
          UpdateVisibility(teamInfoItem, true)
          teamInfoItem:InitTeamItemInfo(TeamInfo, self)
        end
      }, 0.05 * (i - 1) + Interval, false)
      self.TimerList[i] = ShowTimer
    end
  end
  if self.ScrollBox_TeamList:GetChildrenCount() > #TeamList then
    for i = #TeamList + 1, self.ScrollBox_TeamList:GetChildrenCount() do
      local item = self.ScrollBox_TeamList:GetChildAt(i - 1)
      item.TeamData = nil
    end
  end
  UpdateVisibility(self.CanvasPanel_Empty, 0 == #TeamList)
  HideOtherItem(self.ScrollBox_TeamList, #TeamList + 1)
end

function RecruitMainView:TestInitTeamItemInfo()
  self.WBP_SquadItem:InitTeamItemInfo()
end

function RecruitMainView:EscView()
  if self.IsOpenWindow then
    UpdateVisibility(self.WBP_RecruitWindow, false)
    self.IsOpenWindow = false
    return
  end
  self:StopAnimation(self.Ani_in)
  if self:IsAnimationPlaying(self.Ani_out) then
    return
  end
  self.IsClose = true
  self:PlayAnimation(self.Ani_out)
end

function RecruitMainView:OnAnimationFinished(Animation)
  if self.Ani_out == Animation and self.IsClose then
    UIMgr:Hide(ViewID.UI_RecruitMainView, true)
  end
end

function RecruitMainView:OnClicked_BtnChangeList()
  local AutoJoin = self.IsFilter and self.viewModel.FilterAutoJoin or false
  local Floor = self.IsFilter and self.viewModel.FilterFloor or 0
  local GameMode = self.IsFilter and self.viewModel.FilterGameMode or 0
  local World = self.IsFilter and self.viewModel.FilterWorld or 0
  self.viewModel:SendGetRecruitTeamList(AutoJoin, Floor, GameMode, World)
  self:PlayAnimation(self.Ani_refresh, 0)
end

function RecruitMainView:OnClicked_BtnFilter()
  self.WBP_RecruitWindow:ShowWindow(false, self)
  self.IsOpenWindow = true
end

function RecruitMainView:OnClicked_BtnRecruit()
  if not self.CheckIsCaptain() then
    return
  end
  self.IsOpenWindow = true
  self.WBP_RecruitWindow:ShowWindow(true, self)
end

function RecruitMainView:OnClicked_Btnstop()
  if DataMgr.IsInTeam() then
    RecruitHandler:SendStopRecruit(DataMgr.MyTeamInfo.teamid)
  end
end

function RecruitMainView:OnClicked_BtnQuickJoin()
  if not self.CheckIsCaptain() then
    return
  end
  local ShowItemList = {}
  for i, v in pairs(self.ScrollBox_TeamList:GetAllChildren()) do
    if v.TeamData then
      table.insert(ShowItemList, v)
    end
  end
  if #ShowItemList > 0 then
    local RandomTeamIndex = math.random(1, #ShowItemList)
    local SelectTeam = ShowItemList[RandomTeamIndex]
    SelectTeam:BtnApply_Onclicked()
  else
    ShowWaveWindow(1189)
  end
end

function RecruitMainView:OnClicked_BtnCancelFilter()
  self:UpdateFilterState(false)
end

function RecruitMainView:SetFilterParams(AutoJoin, Floor, GameMode, WorldID)
  self.viewModel.FilterAutoJoin = AutoJoin
  self.viewModel.FilterFloor = Floor
  self.viewModel.FilterGameMode = GameMode
  self.viewModel.FilterWorld = WorldID
  self.viewModel:RefreshItemList()
end

function RecruitMainView:CheckIsCaptain()
  if not LogicTeam:IsCaptain() then
    ShowWaveWindow(15007)
    return false
  else
    return true
  end
end

function RecruitMainView:SendGetRolesGameInfo()
  local roleIds = {}
  if #DataMgr.MyTeamInfo == nil or 0 == #DataMgr.MyTeamInfo.players then
    table.insert(roleIds, DataMgr.UserId)
  else
    for i, v in ipairs(DataMgr.MyTeamInfo.players) do
      table.insert(roleIds, v.id)
    end
  end
  self.viewModel:SendRolesGameFloorData(roleIds)
end

function RecruitMainView:UpdateFilterInfo(ModeID, WorldID, Floor)
  local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(WorldID))
  if Result then
    local modeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGameMode)
    local InfoText = UE.FTextFormat(self.RecruitInfoText, modeTable[ModeID].Name, RowInfo.Name, self.DifficultyText, Floor)
    self.Txt_Difficulty:SetText(InfoText)
    self:UpdateFilterState(true)
  end
end

function RecruitMainView:UpdateFilterState(IsFilter)
  self.IsFilter = IsFilter
  UpdateVisibility(self.Txt_Difficulty, IsFilter)
  if not self.IsFilter then
    self.viewModel:SendGetRecruitTeamList(false, 0, 0, 0)
    self.Txt_Difficulty:SetText(NotFilterText)
  end
end

function RecruitMainView:ShowPlayerInfoTips(bIsShow, PlayerInfo, TargetItem)
  if bIsShow then
    self.WBP_SocialPlayerInfoTips:InitSocailPlayerInfoTips(PlayerInfo)
    local GeometryItem = TargetItem:GetCachedGeometry()
    local GeometryCanvasPanelTips = self:GetCachedGeometry()
    local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelTips, GeometryItem)
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SocialPlayerInfoTips)
    slotCanvas:SetPosition(Pos)
  else
    self.WBP_SocialPlayerInfoTips:Hide()
  end
end

return RecruitMainView
