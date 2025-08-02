local ViewBase = require("Framework.UIMgr.ViewBase")
local SurvivalPanel = UnLua.Class()

function SurvivalPanel:Construct()
  self.CurSelectIndex = 0
end

function SurvivalPanel:BindClickHandler()
  self.Btn_Tips.OnHovered:Add(self, self.BindOnTipsHovered)
  self.Btn_Tips.OnUnhovered:Add(self, self.BindOnTipsUnhovered)
  self.Btn_Select.OnMainButtonClicked:Add(self, self.BindOnSelectClicked)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRoomMembersInfo, self.InitTeamMember)
end

function SurvivalPanel:UnBindClickHandler()
  self.Btn_Tips.OnHovered:Remove(self, self.BindOnTipsHovered)
  self.Btn_Tips.OnUnhovered:Remove(self, self.BindOnTipsUnhovered)
  self.Btn_Select.OnMainButtonClicked:Remove(self, self.BindOnSelectClicked)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, self.BindOnEscKeyPressed)
  EventSystem.RemoveListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  EventSystem.RemoveListener(self, EventDef.Lobby.UpdateRoomMembersInfo, self.InitTeamMember)
end

function SurvivalPanel:OnShow()
  self:BindClickHandler()
  self.CurSelectMode = TableEnums.ENUMGameMode.SURVIVAL
  self.OldTeamSet = {
    LogicTeam.GetWorldId(),
    LogicTeam.GetModeId(),
    LogicTeam.GetFloor()
  }
  local RowList = LuaTableMgr.GetLuaTableByName(TableNames.TBSurvival)
  self.SurvivalItems = {}
  if RowList then
    local Index = 1
    for index, RowInfo in ipairs(RowList) do
      local Item = GetOrCreateItem(self.HBox_Survival, Index, self.WBP_SurvivalInfoItem:StaticClass())
      table.insert(self.SurvivalItems, Index, Item)
      Item:InitInfo(RowInfo, self.CurSelectMode, self, index)
      if 0 == self.CurSelectIndex then
        if 1 == Index then
          Item:UpdateViewInfo()
        end
      elseif Index == self.CurSelectIndex then
        Item:UpdateViewInfo()
      end
      if not LogicTeam.IsCaptain() and Item.WorldId == LogicTeam.GetWorldId() then
        Item:UpdateViewInfo()
      end
      Index = Index + 1
    end
  end
  self:InitTeamMember()
  LogicTeam.BindOnTeamUpdate()
  self:PlayAnimation(self.Ani_in)
  UpdateVisibility(self.Btn_Select, LogicTeam.IsCaptain())
  self:SetEnhancedInputActionBlocking(true)
end

function SurvivalPanel:OnHide()
  self.WBP_SelfSurvivalTeamMember:UnBindHandle()
  self:UnBindClickHandler()
  self:SetEnhancedInputActionBlocking(false)
  UpdateVisibility(self.WBP_RuleDescription, false)
end

function SurvivalPanel:InitTeamMember()
  local TeamMember = DataMgr.GetTeamMembersInfo()
  local BasicInfo = DataMgr.GetBasicInfo()
  local TeamMemberItem = {
    self.WBP_SurvivalTeamMember_1,
    self.WBP_SurvivalTeamMember_2
  }
  local TeamMemberItemIndex = 1
  UpdateVisibility(self.WBP_SurvivalTeamMember_1, DataMgr.IsInTeam() and #TeamMember > 1)
  UpdateVisibility(self.WBP_SurvivalTeamMember_2, DataMgr.IsInTeam() and #TeamMember > 2)
  if nil == TeamMember or 1 == #TeamMember or 0 == #TeamMember then
    self.WBP_SelfSurvivalTeamMember:InitInfo(BasicInfo, 1, true, self)
  else
    for i, v in ipairs(TeamMember) do
      if v.roleid == DataMgr.GetUserId() then
        self.WBP_SelfSurvivalTeamMember:InitInfo(v, i, true, self)
      else
        TeamMemberItem[TeamMemberItemIndex]:InitInfo(v, i, false, self)
        TeamMemberItemIndex = TeamMemberItemIndex + 1
      end
    end
  end
end

function SurvivalPanel:SelectItemChange(CurLevelId, TickID, Index)
  for i, v in ipairs(self.SurvivalItems) do
    v:SetSelect(v.LevelId == CurLevelId)
    if v.LevelId == CurLevelId then
      self.TargetItem = v
    end
  end
  self.TickID = TickID
  self.CurSelectIndex = Index
  self.Btn_Select:SetStyleByBottomStyleRowName(self.TargetItem:IsUnlock() and "ViralFrenzy_Btn_Confirm" or "ViralFrenzy_Btn_Disable")
  local ModeId = LogicTeam.GetModeId()
  if ModeId == self.CurSelectMode then
    return
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameModeTicket, TickID)
  if Result then
    local TeamMemberCount = DataMgr.GetTeamMemberCount()
    self.TXT_NeedNum:SetText(RowInfo.costResources[1].value * TeamMemberCount)
  end
end

function SurvivalPanel:IsUnlock()
  if self.LevelInfo.initUnlock then
    return true
  end
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if RoleId == DataMgr.GetUserId() then
      if not ModeInfo[tostring(self.ModeId)] then
        return false
      elseif not ModeInfo[tostring(self.ModeId)][tostring(self.LevelInfo.gameWorldID)] then
        return false
      else
        return ModeInfo[tostring(self.ModeId)][tostring(self.LevelInfo.gameWorldID)] >= self.LevelInfo.floor
      end
    end
  end
end

function SurvivalPanel:BindOnUpdateMyTeamInfo()
  self.TXT_CurNum:SetText(LogicTeam.GetTeamTicketNum())
  local ModeId = LogicTeam.GetModeId()
  if not ModeId == self.CurSelectMode then
    return
  end
  for i, v in ipairs(self.HBox_Survival:GetAllChildren():ToTable()) do
    local CurWorldID = LogicTeam.GetWorldId()
    if v.LevelInfo.gameWorldID == CurWorldID then
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameModeTicket, v.TicketID)
      if Result then
        local TeamMemberCount = DataMgr.GetTeamMemberCount()
        self.MaxNum = RowInfo.costResources[1].value * TeamMemberCount
      end
      self.TargetItem = v
      return
    end
  end
  self:InitTeamMember()
end

function SurvivalPanel:BindOnTipsHovered()
  UpdateVisibility(self.WBP_RuleDescription, true)
end

function SurvivalPanel:BindOnTipsUnhovered()
  UpdateVisibility(self.WBP_RuleDescription, false)
end

function SurvivalPanel:BindOnSelectClicked()
  if not self.TargetItem.IsSelfUnlock then
    ShowWaveWindow(1461, {
      self.TargetItem:GetDependName(self.TargetItem.LevelInfo.dependIDs[1])
    })
    return
  end
  UIMgr:Hide(ViewID.UI_SurvivalPanel, true)
  UIMgr:Hide(ViewID.UI_MainModeSelection, true)
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, "LobbyLabel.LobbyMain")
end

function SurvivalPanel:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_SurvivalPanel, true)
  LogicTeam.RequestSetTeamDataToServer(self.OldTeamSet[1], self.OldTeamSet[2], self.OldTeamSet[3])
end

return SurvivalPanel
