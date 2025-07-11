local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local WBP_StartOrMatch = UnLua.Class()
function WBP_StartOrMatch:Show(...)
  self.Button_StartMatch.OnClicked:Add(self, self.OnClicked_StartMatch)
  self.Button_StartMatch.OnHovered:Add(self, self.OnHovered_StartMatch)
  self.Button_StartMatch.OnUnhovered:Add(self, self.OnUnhovered_StartMatch)
  self.Button_StartMatch.OnPressed:Add(self, self.OnPressed_StartMatch)
  self.Button_StartMatch.OnReleased:Add(self, self.OnReleased_StartMatch)
  self.Btn_Matching.OnClicked:Add(self, self.BindOnMatchingButtonClicked)
  self.Btn_Matching_1.OnClicked:Add(self, self.BindOnMatchingButtonClicked)
  self.Btn_NotMatching.OnClicked:Add(self, self.BindOnNotMatchingButtonClicked)
  self.Btn_NotMatching_1.OnClicked:Add(self, self.BindOnNotMatchingButtonClicked)
  self.Button_Fill.OnClicked:Add(self, self.BindOnFillButtonClicked)
  self.WBP_CommonInputBox.OnAddButtonClicked:Add(self, self.UpdateTicket)
  self.WBP_CommonInputBox.OnReduceButtonClicked:Add(self, self.UpdateTicket)
  self.TargetCheckPanel = self.Overlay_AllCheckMatchingPanel
  self:ChangeStartMatchButtonHoverVis(false)
  self:OnMatchingCheckStateChanged(LogicTeam.GetIsDefaultNeedMatchTeammate())
  self:BindOnUpdateMyTeamInfo()
  local TeamInfo = DataMgr.GetTeamInfo()
  local TeamState = DataMgr.IsInTeam() and TeamInfo.state or LogicTeam.TeamState.Idle
  self:BindOnTeamStateChanged(TeamState, TeamState)
  if TeamState == LogicTeam.TeamState.Matching then
    UpdateVisibility(self.Overlay_1, true)
    UpdateVisibility(self.Overlay_0, false)
  else
    self:ChangeGameMode(nil, true)
  end
  print("WBP_StartOrMatch fun:Show")
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  EventSystem.AddListener(self, EventDef.Lobby.OnTeamStateChanged, self.BindOnTeamStateChanged)
  EventSystem.AddListener(self, EventDef.Lobby.GetRolesGameFloorData, self.BindOnGetRolesGameFloorData)
  EventSystem.AddListenerNew(EventDef.Lobby.OnChangeDefaultNeedMatchTeammate, self, self.BindOnChangeDefaultNeedMatchTeammate)
  EventSystem.AddListener(self, EventDef.Lobby.PredeductTicketSucc, self.StartMatchOrStartGame)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateResourceInfo, self.BindOnResourceUpdate)
  EventSystem.AddListenerNew(EventDef.Lobby.UpdateRoomMembersInfo, self, self.BindOnUdpateTeamMembersInfo)
end
function WBP_StartOrMatch:BindOnResourceUpdate()
  self:UpdateTicketStatus(false)
end
function WBP_StartOrMatch:StartMatchOrStartGame(bStartGameOrStartMatch)
  if not bStartGameOrStartMatch then
    return
  end
  print("WBP_StartOrMatch fun:StartMatchOrStartGame", self)
  if self:IsNeedMatch() then
    LogicTeam.RequestStartMatchToServer()
  else
    LogicTeam.RequestStartGameToServer()
  end
end
function WBP_StartOrMatch:BindOnUpdateMyTeamInfo(...)
  self:UpdateStartMatchButtonStatus()
  self:UpdateGameModeInfo()
  self:RefreshTeamFloorInfo()
  self:UpdateInputBoxNum()
end
function WBP_StartOrMatch:BindOnUdpateTeamMembersInfo(TargetPlayerList)
  self:UpdateTicketStatus(false)
end
function WBP_StartOrMatch:BindOnGetRolesGameFloorData()
  self:RefreshTeamFloorInfo()
end
function WBP_StartOrMatch:OnBindUIInput()
  if self.bBindConsoleInput then
    self.WBP_InteractTipWidgetStartGame:BindInteractAndClickEvent(self, self.OnClicked_StartMatch)
    self.WBP_InteractTipWidgetTeam:BindInteractAndClickEvent(self, self.BindOnMatchingButtonClicked)
  end
end
function WBP_StartOrMatch:OnUnBindUIInput()
  if self.bBindConsoleInput then
    self.WBP_InteractTipWidgetStartGame:UnBindInteractAndClickEvent(self, self.OnClicked_StartMatch)
    self.WBP_InteractTipWidgetTeam:UnBindInteractAndClickEvent(self, self.BindOnMatchingButtonClicked)
  end
end
function WBP_StartOrMatch:BindOnChangeDefaultNeedMatchTeammate(...)
  self:OnMatchingCheckStateChanged(LogicTeam.GetIsDefaultNeedMatchTeammate())
end
function WBP_StartOrMatch:RefreshTeamFloorInfo()
  UpdateVisibility(self.Img_CanNotStart, false)
  self.IsMatchFloorCondition = true
  if DataMgr.IsInTeam() and LogicTeam.IsCaptain() then
    local TeamInfo = DataMgr.GetTeamInfo()
    for i, SinglePlayerInfo in ipairs(TeamInfo.players) do
      if SinglePlayerInfo.id ~= DataMgr.GetUserId() then
        local Floor = DataMgr.GetTeamMemberGameFloorByModeAndWorld(SinglePlayerInfo.id, LogicTeam.GetModeId(), LogicTeam.GetWorldId())
        if Floor < LogicTeam.GetFloor() then
          UpdateVisibility(self.Img_CanNotStart, true)
          self.IsMatchFloorCondition = false
          break
        end
      end
    end
  end
end
function WBP_StartOrMatch:UpdateGameModeInfo(...)
  local CurModeId = LogicTeam.GetModeId()
  local Result, GameModeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, CurModeId)
  if Result then
    UpdateVisibility(self.TargetCheckPanel, GameModeRowInfo.CanMatching)
    if not GameModeRowInfo.CanMatching and LogicTeam.GetIsDefaultNeedMatchTeammate() then
      self:OnMatchingCheckStateChanged(false)
    end
  end
end
function WBP_StartOrMatch:BindOnTeamStateChanged(OldState, NewState)
  if NewState == LogicTeam.TeamState.Idle then
    self:UpdateGameModeInfo()
    if self.IsTeamMembersTick then
      UpdateVisibility(self.CanvasPanel_InputBox, true)
    end
  elseif NewState == LogicTeam.TeamState.Matching then
    UpdateVisibility(self.TargetCheckPanel, false)
    UpdateVisibility(self.Overlay_1, true)
    UpdateVisibility(self.Overlay_0, false)
    UpdateVisibility(self.CanvasPanel_InputBox, false)
  elseif NewState == LogicTeam.TeamState.None then
    self:UpdateGameModeInfo()
  end
  if NewState == LogicTeam.TeamState.Preparing then
    self.StartMatchPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.StartMatchPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  if OldState == LogicTeam.TeamState.Matching then
    self:ChangeGameMode(nil, true)
  end
end
function WBP_StartOrMatch:UpdateCheckPanelTarget(IsOriPanel)
  self.TargetCheckPanel = IsOriPanel and self.Overlay_AllCheckMatchingPanel or self.Overlay_AllCheckMatchingPanel_1
end
function WBP_StartOrMatch:ChangeGameMode(GameModeId, bInLobbyMainPanel)
  UpdateVisibility(self.Overlay_1, false)
  UpdateVisibility(self.Overlay_0, false)
  if bInLobbyMainPanel then
    UpdateVisibility(self.Overlay_0, bInLobbyMainPanel)
    return
  end
  UpdateVisibility(self.Overlay_1, GameModeId == TableEnums.ENUMGameMode.NORMAL)
  UpdateVisibility(self.Overlay_0, GameModeId == TableEnums.ENUMGameMode.TOWERClIMBING)
end
function WBP_StartOrMatch:PlayClickedAnimation()
  self:PlayAnimation(self.Ani_click)
end
function WBP_StartOrMatch:PlayPressedAnimation()
end
function WBP_StartOrMatch:PlayReleasedAnimation()
end
function WBP_StartOrMatch:OnClicked_StartMatch()
  EventSystem.Invoke(EventDef.BeginnerGuide.OnClickedLobbyStartMatchButton)
  self:PlayClickedAnimation()
  if self.NotResource then
    ShowWaveWindow(309001)
    return
  end
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.START_GAME) then
    return
  end
  if GetCurrentUTCTimestamp() - LogicTeam.LastClickStartButtonTime <= 1.0 then
    print("\229\188\128\229\167\139\230\184\184\230\136\143\230\140\137\233\146\174\231\130\185\229\135\187\229\134\183\229\141\180\228\184\173")
    return
  end
  LogicTeam.SetLastClickStartButtonTime(GetCurrentUTCTimestamp())
  local ButtonFunction = function(...)
    if DataMgr.IsInTeam() then
      local TeamInfo = DataMgr.GetTeamInfo()
      local RoleId = DataMgr.GetUserId()
      if TeamInfo.state ~= LogicTeam.TeamState.Battle and TeamInfo.state ~= LogicTeam.TeamState.Recruiting then
        if TeamInfo.state == LogicTeam.TeamState.Matching then
          if not self:IsNeedMatch() then
            local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
            if RGWaveWindowManager then
              RGWaveWindowManager:ShowWaveWindow(1100, {})
            end
          end
          LogicTeam.RequestStopMatchToServer()
        elseif RoleId == TeamInfo.captain then
          if not self.IsMatchFloorCondition then
            print("WBP_StartOrMatch \230\151\160\230\179\149\229\188\128\229\167\139\230\184\184\230\136\143\239\188\140\233\154\190\229\186\166\228\184\141\229\140\185\233\133\141")
            return
          end
          self:UpdateTicketStatus(true)
        end
      elseif TeamInfo.state == LogicTeam.TeamState.Recruiting then
        print("\233\152\159\228\188\141\231\138\182\230\128\129\230\173\163\229\156\168\230\139\155\229\139\159\228\184\173")
      else
        print("\233\152\159\228\188\141\231\138\182\230\128\129\230\173\163\229\156\168\230\136\152\230\150\151\228\184\173")
      end
    else
      LogicTeam.RequestCreateTeamToServer({
        self,
        function()
          if not self.IsMatchFloorCondition then
            print("WBP_StartOrMatch \230\151\160\230\179\149\229\188\128\229\167\139\230\184\184\230\136\143\239\188\140\233\154\190\229\186\166\228\184\141\229\140\185\233\133\141")
            return
          end
          self:UpdateTicketStatus(true)
        end
      })
    end
    if UIMgr:IsShow(ViewID.UI_MainModeSelection) then
      UIMgr:Hide(ViewID.UI_MainModeSelection)
      UIMgr:Show(ViewID.UI_LobbyPanel)
    end
  end
  local TeamInfo = DataMgr.GetTeamInfo()
  if DataMgr.IsInTeam() and TeamInfo.state == LogicTeam.TeamState.Matching then
    ButtonFunction()
  elseif not self:IsNeedMatch() and LogicTeam.GetModeId() == TableEnums.ENUMGameMode.NORMAL and (not DataMgr.IsInTeam() or table.count(TeamInfo.players) <= 1) and LogicTeam.GetFloor() >= self.MinShowTeamTipLevel then
    ShowWaveWindowWithDelegate(1410, {}, {
      self,
      function()
        LogicTeam.SetIsDefaultNeedMatchTeammate(true)
        ButtonFunction()
      end
    }, {self, ButtonFunction})
  else
    local CombatCoefficent = LogicLobby.GetCombatPowerCoefficcent()
    if -1 ~= CombatCoefficent and CombatCoefficent < self.CombatPowerCoefficentTipValue then
      ShowWaveWindowWithDelegate(305006, {}, {self, ButtonFunction})
    else
      ButtonFunction()
    end
  end
end
function WBP_StartOrMatch:IsNeedMatch()
  local IsChecked = LogicTeam.GetIsDefaultNeedMatchTeammate()
  if DataMgr.IsInTeam() then
    local TeamInfo = DataMgr.GetTeamInfo()
    if TeamInfo.players and LogicTeam.IsFullTeam() then
      IsChecked = false
    end
  end
  return IsChecked
end
function WBP_StartOrMatch:OnHovered_StartMatch()
  self:ChangeStartMatchButtonHoverVis(true)
end
function WBP_StartOrMatch:ChangeStartMatchButtonHoverVis(IsHover)
  if IsHover then
    self.Image_loop:SetVisibility(UE.ESlateVisibility.selfHitTestInvisible)
    self.Image_loop_1:SetVisibility(UE.ESlateVisibility.selfHitTestInvisible)
  else
    self.Image_loop:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_loop_1:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_StartOrMatch:OnUnhovered_StartMatch()
  self:ChangeStartMatchButtonHoverVis(false)
end
function WBP_StartOrMatch:OnPressed_StartMatch()
  self:PlayPressedAnimation()
end
function WBP_StartOrMatch:OnReleased_StartMatch()
  self:PlayReleasedAnimation()
end
function WBP_StartOrMatch:BindOnMatchingButtonClicked(...)
  self:OnMatchingCheckStateChanged(false)
end
function WBP_StartOrMatch:BindOnNotMatchingButtonClicked(...)
  LuaAddClickStatistics("LobbyAutomaticMatching")
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.MATCH) then
    return
  end
  self:OnMatchingCheckStateChanged(true)
end
function WBP_StartOrMatch:BindOnFillButtonClicked()
  local OwnNum = DataMgr.GetPackbackNumById(self.CostResId)
  if 0 == OwnNum then
    ShowWaveWindow(1462)
    return
  end
  local TeamMemberCount = math.clamp(#DataMgr.GetTeamMembersInfo(), 1, 3)
  local SingleNeed = self.MaxNum / TeamMemberCount
  local SingleTick = LogicTeam:GetMemberTicketNum(DataMgr:GetUserId())
  if SingleNeed < SingleTick then
    if not DataMgr.IsInTeam() then
      LogicTeam.RequestCreateTeamToServer({
        self,
        function()
          LogicTeam.RequestPreDeductTicket(SingleNeed)
        end
      })
    else
      LogicTeam.RequestPreDeductTicket(SingleNeed)
    end
    ShowWaveWindow(1464)
  elseif SingleNeed > SingleTick then
    if not DataMgr.IsInTeam() then
      LogicTeam.RequestCreateTeamToServer({
        self,
        function()
          LogicTeam.RequestPreDeductTicket(math.min(SingleNeed, OwnNum))
        end
      })
    else
      LogicTeam.RequestPreDeductTicket(math.min(SingleNeed, OwnNum))
    end
    if OwnNum >= SingleNeed then
      ShowWaveWindow(1464)
    else
      ShowWaveWindow(1462)
    end
  end
end
function WBP_StartOrMatch:OnMatchingCheckStateChanged(IsChecked)
  if IsChecked then
    self.StateCtrl_Match:ChangeStatus(EMatch.Match)
    self.StateCtrl_Match_1:ChangeStatus(EMatch.Match)
  else
    self.StateCtrl_Match:ChangeStatus(EMatch.Alone)
    self.StateCtrl_Match_1:ChangeStatus(EMatch.Alone)
  end
  LogicTeam.SetIsDefaultNeedMatchTeammate(IsChecked)
  self:UpdateStartMatchButtonStatus()
  PlaySound2DEffect(1, "")
end
function WBP_StartOrMatch:UpdateStartMatchButtonStatus()
  self:UpdateTicketStatus(false)
  local TeamInfo = DataMgr.GetTeamInfo()
  if DataMgr.IsInTeam() and TeamInfo.state == LogicTeam.TeamState.Matching then
    self.Txt_StartMatch:SetText(self.MatchingText)
    self.Txt_StartMatch_Projection:SetText(self.MatchingText)
    return
  end
  if DataMgr.IsInTeam() and not LogicTeam.IsCaptain() then
    self.Txt_StartMatch:SetText(self.WaitCaptainText)
    self.Txt_StartMatch_Projection:SetText(self.WaitCaptainText)
    return
  end
  if self:IsNeedMatch() then
    self.Txt_StartMatch:SetText(self.StartMatchText)
    self.Txt_StartMatch_Projection:SetText(self.StartMatchText)
    return
  end
  self.Txt_StartMatch:SetText(self.StartGameText)
  self.Txt_StartMatch_Projection:SetText(self.StartGameText)
  self:UpdateModeStatus()
end
function WBP_StartOrMatch:UpdateTicketStatus(bStartGameOrStartMatch)
  UpdateVisibility(self.CanvasPanel_InputBox, false)
  local CurModeId = LogicTeam.GetModeId()
  local CurWorldId = LogicTeam.GetWorldId()
  local TicketId = -1
  local TBGameFloorUnlock = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  for LevelId, LevelInfo in pairs(TBGameFloorUnlock) do
    if LevelInfo.gameWorldID == tonumber(CurWorldId) and LevelInfo.gameMode == tonumber(CurModeId) then
      TicketId = LevelInfo.ticketID
    end
  end
  self.TicketId = TicketId
  self.IsTeamMembersTick = false
  local TBTicket = LuaTableMgr.GetLuaTableByName(TableNames.TBGameModeTicket)
  if TBTicket[TicketId] then
    local TicketNum = 0
    local TicketIcon = ""
    local TicketSum = 0
    for key, value in pairs(TBTicket[TicketId].costResources) do
      self.CostResId = value.key
      local RowInfo = LogicOutsidePackback.GetResourceInfoById(value.key)
      TicketIcon = RowInfo.Icon
      local ResourceNum = LogicOutsidePackback.GetResourceNumById(value.key)
      TicketSum = ResourceNum
      TicketNum = value.value
      break
    end
    SetImageBrushByPath(self.TicketsIcon, TicketIcon)
    if TBTicket[TicketId].costType == TableEnums.ENUMGameModeCostResType.ONLYCAPTAIN and bStartGameOrStartMatch then
      self.Text_CurTicket:SetText(TicketSum)
      if LogicTeam.IsCaptain() and DataMgr.IsInTeam() then
        local MyTeamInfo = DataMgr.GetTeamInfo()
        local JsonParam = {
          teamID = MyTeamInfo.teamid,
          ticket = TicketNum
        }
        HttpCommunication.Request("team/predeductticket", JsonParam, {
          GameInstance,
          function()
            self:StartMatchOrStartGame(bStartGameOrStartMatch)
          end
        }, {})
      end
    elseif TBTicket[TicketId].costType == TableEnums.ENUMGameModeCostResType.TEAMMEMBER then
      self.IsTeamMembersTick = true
      local TeamMemberCount = math.clamp(#DataMgr.GetTeamMembersInfo(), 1, 3)
      if not DataMgr.IsInTeam() then
        TeamMemberCount = 1
      end
      if LogicTeam.CurTeamState ~= LogicTeam.TeamState.Matching then
        UpdateVisibility(self.CanvasPanel_InputBox, true)
      end
      self.WBP_CommonInputBox:SetCheckFun(self, self.CheckCanAdd)
      self.WBP_CommonInputBox:SetCheckChangeFun(self.CheckCanChange)
      TicketSum = LogicTeam.GetTeamTicketNum()
      self.Text_CurTicket:SetText(LogicTeam.GetTeamTicketNum())
      TicketNum = TicketNum * TeamMemberCount
      self.MaxNum = TicketNum
      self.WBP_CommonInputBox:SetMaxNum(TicketNum)
      self:StartMatchOrStartGame(bStartGameOrStartMatch)
    else
      self:StartMatchOrStartGame(bStartGameOrStartMatch)
    end
    self.TicketsNum:SetText(TicketNum)
    self.NotResource = TicketSum < TicketNum
    UpdateVisibility(self.TicketsPanel, true)
    if DataMgr.IsInTeam() and not LogicTeam.IsCaptain() then
      if self.NotResource then
        self.RGStateController_Num:ChangeStatus("Error_Colt")
      else
        self.RGStateController_Num:ChangeStatus("Def_Colt")
      end
    elseif self.NotResource then
      self.RGStateController_Num:ChangeStatus("Error")
    else
      self.RGStateController_Num:ChangeStatus("Def")
    end
  elseif 0 == TicketId or -1 == TicketId then
    self.NotResource = false
    UpdateVisibility(self.CanvasPanel_InputBox, false)
    self.RGStateController_Num:ChangeStatus("Def")
    UpdateVisibility(self.TicketsPanel, false)
    self:StartMatchOrStartGame(bStartGameOrStartMatch)
  end
  if CurModeId == TableEnums.ENUMGameMode.BOSSRUSH then
    EventSystem.Invoke(EventDef.Lobby.UpdateTicketStatus, self.NotResource)
  else
    EventSystem.Invoke(EventDef.Lobby.UpdateTicketStatus, false)
  end
end
function WBP_StartOrMatch:CheckCanAdd(CurNum)
  local OwnNum = DataMgr.GetPackbackNumById(self.CostResId)
  local MaxNum = 0
  local CurModeId = LogicTeam.GetModeId()
  local CurWorldId = LogicTeam.GetWorldId()
  local TBGameFloorUnlock = LuaTableMgr.GetLuaTableByName(TableNames.TBGameFloorUnlock)
  local TickID = 0
  for LevelId, LevelInfo in pairs(TBGameFloorUnlock) do
    if LevelInfo.gameWorldID == tonumber(CurWorldId) and LevelInfo.gameMode == tonumber(CurModeId) then
      TickID = LevelInfo.ticketID
    end
  end
  local TickResult, TickRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameModeTicket, TickID)
  if TickResult then
    local TeamMemberCount = math.clamp(#DataMgr.GetTeamMembersInfo(), 1, 3)
    MaxNum = TickRowInfo.costResources[1].value * TeamMemberCount
  end
  if MaxNum <= LogicTeam.GetTeamTicketNum() then
    ShowWaveWindow(1463)
  elseif CurNum >= OwnNum then
    ShowWaveWindow(1462)
  end
  return CurNum < OwnNum and MaxNum > LogicTeam.GetTeamTicketNum()
end
function WBP_StartOrMatch:CheckCanChange(Num)
  local OwnNum = DataMgr.GetPackbackNumById(self.CostResId)
  local TeamMemberCount = math.clamp(#DataMgr.GetTeamMembersInfo(), 1, 3)
  local SingleNeed = self.MaxNum / TeamMemberCount
  return Num <= OwnNum and Num <= SingleNeed
end
function WBP_StartOrMatch:Hide(...)
  self.Button_StartMatch.OnClicked:Remove(self, self.OnClicked_StartMatch)
  self.Button_StartMatch.OnHovered:Remove(self, self.OnHovered_StartMatch)
  self.Button_StartMatch.OnUnhovered:Remove(self, self.OnUnhovered_StartMatch)
  self.Button_StartMatch.OnPressed:Remove(self, self.OnPressed_StartMatch)
  self.Button_StartMatch.OnReleased:Remove(self, self.OnReleased_StartMatch)
  self.Btn_Matching.OnClicked:Remove(self, self.BindOnMatchingButtonClicked)
  self.Btn_Matching_1.OnClicked:Remove(self, self.BindOnMatchingButtonClicked)
  self.Btn_NotMatching.OnClicked:Remove(self, self.BindOnNotMatchingButtonClicked)
  self.Btn_NotMatching_1.OnClicked:Remove(self, self.BindOnNotMatchingButtonClicked)
  self.WBP_CommonInputBox.OnAddButtonClicked:Remove(self, self.UpdateTicket)
  self.WBP_CommonInputBox.OnReduceButtonClicked:Remove(self, self.UpdateTicket)
  print("WBP_StartOrMatch fun:Hide")
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfo, self.BindOnResourceUpdate, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.OnTeamStateChanged, self.BindOnTeamStateChanged, self)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OnChangeDefaultNeedMatchTeammate, self, self.BindOnChangeDefaultNeedMatchTeammate)
  EventSystem.RemoveListener(EventDef.Lobby.PredeductTicketSucc, self.StartMatchOrStartGame, self)
  EventSystem.RemoveListenerNew(EventDef.Lobby.UpdateRoomMembersInfo, self, self.BindOnUdpateTeamMembersInfo)
end
function WBP_StartOrMatch:UpdateTicket(SelectNum)
  if not DataMgr.IsInTeam() then
    LogicTeam.RequestCreateTeamToServer({
      self,
      function()
        LogicTeam.RequestPreDeductTicket(SelectNum)
      end
    })
  else
    LogicTeam.RequestPreDeductTicket(SelectNum)
  end
end
function WBP_StartOrMatch:UpdateInputBoxNum()
  local TickNum = LogicTeam.GetMemberTicketNum(DataMgr.GetUserId())
  local OwnNum = DataMgr.GetPackbackNumById(99019)
  if self.MaxNum then
    self.WBP_CommonInputBox:UpdateSelectNum(TickNum)
    self.WBP_CommonInputBox.Btn_Add:SetStyleByBottomStyleRowName(TickNum < OwnNum and LogicTeam.GetTeamTicketNum() < self.MaxNum and "FrenzyVirus_Btn_Changes_0" or "FrenzyVirus_Btn_Changes_enable")
    self.WBP_CommonInputBox.Btn_Reduce:SetStyleByBottomStyleRowName(0 ~= TickNum and "FrenzyVirus_Btn_Changes_0" or "FrenzyVirus_Btn_Changes_enable")
  end
end
function WBP_StartOrMatch:UpdateModeStatus()
  local CurModeId = LogicTeam.GetModeId()
  if CurModeId ~= TableEnums.ENUMGameMode.TOWERClIMBING or not ClimbTowerData:MeetFaultScore() then
  end
end
function WBP_StartOrMatch:Destruct(...)
  self:Hide()
end
return WBP_StartOrMatch
