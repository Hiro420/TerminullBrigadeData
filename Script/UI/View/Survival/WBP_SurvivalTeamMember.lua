local WBP_SurvivalInfoItem_C = require("UI.View.Survival.WBP_SurvivalInfoItem_C")
local WBP_SurvivalTeamMember = UnLua.Class()

function WBP_SurvivalTeamMember:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  self.Btn_Fill.OnClicked:Add(self, self.BindOnFillButtonClicked)
end

function WBP_SurvivalInfoItem_C:Destruct()
  EventSystem.RemoveListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
end

function WBP_SurvivalTeamMember:InitInfo(PlayerInfo, Index, IsSelf, ParentView)
  self.PlayerInfo = PlayerInfo
  self.IsSelf = IsSelf
  self.ParentView = ParentView
  self.WBP_PlayerHeadIcon:SetIsShow(true)
  self.WBP_PlayerHeadIcon:InitInfo(PlayerInfo.portrait, PlayerInfo.level)
  self.TXT_Index:SetText(Index)
  self.TXT_Name:SetText(PlayerInfo.nickname)
  self.WBP_CommonInputBox:SetCheckFun(self, self.CheckCanAdd)
  self.WBP_CommonInputBox:SetCheckChangeFun(self.CheckCanChange)
  self.WBP_CommonInputBox:RefreshButtonState()
  self:SetInputBoxShow(IsSelf)
  self:BindHandle()
end

function WBP_SurvivalTeamMember:BindHandle()
  self.WBP_CommonInputBox.OnAddButtonClicked:Add(self, self.UpdateTicket)
  self.WBP_CommonInputBox.OnReduceButtonClicked:Add(self, self.UpdateTicket)
end

function WBP_SurvivalTeamMember:UnBindHandle()
  self.WBP_CommonInputBox.OnAddButtonClicked:Remove(self, self.UpdateTicket)
  self.WBP_CommonInputBox.OnReduceButtonClicked:Remove(self, self.UpdateTicket)
end

function WBP_SurvivalTeamMember:UpdateTicket(SelectNum)
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

function WBP_SurvivalTeamMember:SetInputBoxMaxNum()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, TableEnums.ENUMGameMode.SURVIVAL)
  if Result then
    local TickID = self.ParentView.TicketID
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameModeTicket, TickID)
    if Result then
      local MaxNum = RowInfo.costResources[1].value
      self.WBP_CommonInputBox:SetMaxNum(MaxNum)
    end
  end
end

function WBP_SurvivalTeamMember:SetInputBoxShow(IsShow)
  UpdateVisibility(self.CanvasPanel_Ticket, not IsShow)
  UpdateVisibility(self.CanvasPanel_InputBox, IsShow)
  self.TXT_TicketNum:SetText(LogicTeam.GetMemberTicketNum(self.PlayerInfo.roleid))
end

function WBP_SurvivalTeamMember:CheckCanAdd(CurNum)
  if LogicTeam.GetModeId() ~= TableEnums.ENUMGameMode.SURVIVAL then
    ShowWaveWindow(1465)
    return
  end
  local OwnNum = DataMgr.GetPackbackNumById(99019)
  if CurNum >= OwnNum then
    ShowWaveWindow(1462)
    return false
  end
  if LogicTeam.GetTeamTicketNum() >= self.ParentView.MaxNum then
    ShowWaveWindow(1463)
    return false
  end
  return CurNum < OwnNum and LogicTeam.GetTeamTicketNum() < self.ParentView.MaxNum
end

function WBP_SurvivalTeamMember:CheckCanChange(Num)
  local OwnNum = DataMgr.GetPackbackNumById(99019)
  local TeamMemberCount = math.clamp(#DataMgr.GetTeamMembersInfo(), 1, 3)
  local SingleNeed = self.ParentView.MaxNum / TeamMemberCount
  return Num <= OwnNum and Num <= SingleNeed
end

function WBP_SurvivalTeamMember:BindOnUpdateMyTeamInfo()
  if not self.PlayerInfo then
    return
  end
  if self.IsSelf then
    local OwnNum = DataMgr.GetPackbackNumById(99019)
    local SelectNum = LogicTeam.GetMemberTicketNum(DataMgr.GetUserId())
    self.WBP_CommonInputBox:UpdateSelectNum(LogicTeam.GetMemberTicketNum(self.PlayerInfo.roleid))
    self.WBP_CommonInputBox.Btn_Add:SetStyleByBottomStyleRowName(OwnNum > SelectNum and LogicTeam.GetTeamTicketNum() < self.ParentView.MaxNum and "FrenzyVirus_Btn_Changes_0" or "FrenzyVirus_Btn_Changes_enable")
    self.WBP_CommonInputBox.Btn_Reduce:SetStyleByBottomStyleRowName(0 ~= SelectNum and "FrenzyVirus_Btn_Changes_0" or "FrenzyVirus_Btn_Changes_enable")
  else
    self.TXT_TicketNum:SetText(LogicTeam.GetMemberTicketNum(self.PlayerInfo.roleid))
  end
end

function WBP_SurvivalTeamMember:BindOnFillButtonClicked()
  if LogicTeam.GetModeId() ~= TableEnums.ENUMGameMode.SURVIVAL then
    ShowWaveWindow(1465)
    return
  end
  local OwnNum = DataMgr.GetPackbackNumById(99019)
  if 0 == OwnNum then
    ShowWaveWindow(1462)
    return
  end
  local TeamMemberCount = math.clamp(#DataMgr.GetTeamMembersInfo(), 1, 3)
  local SingleNeed = self.ParentView.MaxNum / TeamMemberCount
  local TeamTickNum = LogicTeam.GetTeamTicketNum(true)
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
          LogicTeam.RequestPreDeductTicket(math.min(SingleNeed, OwnNum, self.ParentView.MaxNum - TeamTickNum))
        end
      })
    else
      LogicTeam.RequestPreDeductTicket(math.min(SingleNeed, OwnNum, self.ParentView.MaxNum - TeamTickNum))
    end
    if OwnNum >= SingleNeed then
      ShowWaveWindow(1464)
    else
      ShowWaveWindow(1462)
    end
  end
end

return WBP_SurvivalTeamMember
