local WBP_LobbyFunctionSet_C = UnLua.Class()

function WBP_LobbyFunctionSet_C:Construct()
  self:PlayInAnimation()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateBasicInfo, self.BindOnUpdateBasicInfo)
  EventSystem.AddListener(self, EventDef.Lobby.ExpChanged, self.UpdateLevelInfo)
  EventSystem.AddListener(self, EventDef.Lobby.OnIigwRequestPrivilege, self.UpdateNetBarState)
  self:BindOnUpdateMyTeamInfo()
  self:RefreshAccountInfo()
  self.Btn_AddTeam.OnClicked:Add(self, self.BindOnAddTeamButtonClicked)
  self.Btn_AddTeam.OnHovered:Add(self, self.BindOnAddTeamButtonHovered)
  self.Btn_AddTeam.OnUnhovered:Add(self, self.BindOnAddTeamButtonUnhovered)
  self.Btn_AccountInfo.OnClicked:Add(self, self.BindOnShowAchievement)
  self.Btn_NetBar.OnHovered:Add(self, self.BindOnNetBarButtonHovered)
  self.Btn_NetBar.OnUnhovered:Add(self, self.BindOnNetBarButtonUnhovered)
  self.WBP_MonthCardIcon:Show(DataMgr.GetUserId(), true, true)
end

function WBP_LobbyFunctionSet_C:BindOnAddTeamButtonClicked()
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("LobbyTeamEntrance")
  end
  if not DataMgr.IsInTeam() then
    LogicTeam.RequestCreateTeamToServer()
  end
  UIMgr:Show(ViewID.UI_MatchingPanel)
end

function WBP_LobbyFunctionSet_C:BindOnAddTeamButtonHovered()
  if not self.AddTeamHoveredPanel:IsVisible() then
    self.AddTeamHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAnimationForward(self.Ani_hover_in)
end

function WBP_LobbyFunctionSet_C:BindOnAddTeamButtonUnhovered()
  if not self.AddTeamHoveredPanel:IsVisible() then
    self.AddTeamHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAnimationForward(self.Ani_hover_out)
end

function WBP_LobbyFunctionSet_C:BindOnUpdateBasicInfo()
  self:RefreshAccountInfo()
end

function WBP_LobbyFunctionSet_C:UpdateNetBarState()
  if DataMgr.GetNetBarPrivilegeType() > 0 then
    self.HorizontalBox_PlayerInfo:SetVisibility(UE.ESlateVisibility.Visible)
    self.Btn_NetBar:SetVisibility(UE.ESlateVisibility.Visible)
  else
    self.Btn_NetBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_LobbyFunctionSet_C:BindOnNetBarButtonHovered()
  local Offset = UE.FVector2D(0, 10)
  self.HoverTips = ShowCommonTips(nil, self.Btn_NetBar, nil, "/Game/Rouge/UI/Common/WBP_CommonTipsNetBar.WBP_CommonTipsNetBar", nil, nil, Offset)
  if self.HoverTips then
    self.HoverTips:ShowTips()
  end
end

function WBP_LobbyFunctionSet_C:BindOnNetBarButtonUnhovered()
  UpdateVisibility(self.HoverTips, false)
end

function WBP_LobbyFunctionSet_C:BindOnShowAchievement()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.CAREER) then
    return
  end
  UIMgr:Show(ViewID.UI_PlayerInfoMain, true, DataMgr.GetUserId())
end

function WBP_LobbyFunctionSet_C:RefreshAccountInfo()
  self.Btn_NetBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.TextBlock_PlayerName:SetText(DataMgr.GetBasicInfo().nickname)
  self:UpdateLevelInfo()
  self.OwnAccountItem:Show(DataMgr.GetBasicInfo(), true)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_LobbyFunctionSet_C DataMgr.GetUserId(): %s", tostring(DataMgr.GetUserId())))
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(DataMgr.GetUserId())
  end
  self:UpdateNetBarState()
end

function WBP_LobbyFunctionSet_C:UpdateLevelInfo()
  local level = DataMgr.GetRoleLevel()
  self.TextBlock_Level:SetText(level)
end

function WBP_LobbyFunctionSet_C:BindOnUpdateMyTeamInfo()
  self.LobbyMembersPanel:Hide()
end

function WBP_LobbyFunctionSet_C:PlayInAnimation()
  self:PlayAnimation(self.ani_lobbyfunctionset_in)
end

function WBP_LobbyFunctionSet_C:PlayOutAnimation()
  self:PlayAnimation(self.ani_lobbyfunctionset_out)
end

function WBP_LobbyFunctionSet_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.ExpChanged, self.UpdateLevelInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateBasicInfo, self.BindOnUpdateBasicInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnIigwRequestPrivilege, self.UpdateNetBarState, self)
  self.Btn_AccountInfo.OnClicked:Remove(self, self.BindOnShowAchievement)
  self.WBP_MonthCardIcon:Hide()
end

return WBP_LobbyFunctionSet_C
