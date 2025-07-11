local RecruitHandler = require("Protocol.Recruit.RecruitHandler")
local RapidJson = require("rapidjson")
local DifficultyText = NSLOCTEXT("WBP_RecruitWindow_C", "DifficultyText", "\233\154\190\229\186\166")
local WBP_RecruitingTipPanel_C = UnLua.Class()
function WBP_RecruitingTipPanel_C:Construct()
end
function WBP_RecruitingTipPanel_C:OnShow()
  self.StartRecruitingTime = GetTimeWithServerDelta()
  self.IsOpenApplyList = false
  UpdateVisibility(self.ApplyList, self.IsOpenApplyList)
  UpdateVisibility(self.BG_CloseBtn, self.IsOpenApplyList)
  self.ApplyItems = {}
  self.ApplyPlayerInfos = {}
  self.ScrollBox_ApplyList:ClearChildren()
  self.Btn_OpenApplyList.OnClicked:Add(self, self.OnClicked_BtnOpenApplyList)
  self.Btn_Clsoe.OnClicked:Add(self, self.OnClicked_BtnOpenApplyList)
  self.WBP_InteractTipWidgetCanel:BindInteractAndClickEvent(self, self.CancelRecruit)
  EventSystem.AddListener(self, EventDef.Recruit.StopRecruit, self.BindOnStopRecruit)
  EventSystem.AddListener(self, EventDef.Recruit.GetRecruitApplyList, self.BindOnGetRecruitApplyList)
  EventSystem.AddListener(self, EventDef.Recruit.AgreeRecruitApply, self.BindOnAgreeRecruitApply)
  EventSystem.AddListener(self, EventDef.Recruit.RefuseRecruitApply, self.BindOnRefuseRecruitApply)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateRoomMembersInfo)
  EventSystem.AddListener(self, EventDef.WSMessage.ApplyJoinRecruitTeam, self.BindOnApplyJoinRecruitTeam)
  self:UpdateMatchingTimeText()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RecruitingTimeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RecruitingTimeTimer)
  end
  self.RecruitingTimeTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self:UpdateMatchingTimeText()
    end
  }, 1.0, true, 0.0)
  local teamMembersInfo = DataMgr.GetTeamMembersInfo()
  self:SetTeamInfo(teamMembersInfo)
  self.WBP_RedDotView:SetNum(0)
  self.IsClose = false
  if self:IsAnimationPlaying(self.Ani_text_out) then
    self:StopAnimation(self.Ani_text_out)
  end
  self:PlayAnimation(self.Ani_list_in, 0)
end
function WBP_RecruitingTipPanel_C:OnClicked_BtnOpenApplyList()
  if 0 == #self.ApplyItems then
    ShowWaveWindow(305001)
    return
  end
  self.IsOpenApplyList = not self.IsOpenApplyList
  self:PlayListAnimation()
  UpdateVisibility(self.BG_CloseBtn, self.IsOpenApplyList)
  if self.IsOpenApplyList then
    RecruitHandler:SendGetRecruitApplyList(DataMgr.MyTeamInfo.teamid)
  else
    self.ScrollBox_ApplyList:ClearChildren()
  end
end
function WBP_RecruitingTipPanel_C:PlayListAnimation()
  if self.IsOpenApplyList then
    self:StopAnimation(self.Ani_text_out)
    UpdateVisibility(self.ApplyList, self.IsOpenApplyList)
    self:PlayAnimation(self.Ani_text_in, 0)
  else
    self:StopAnimation(self.Ani_text_in)
    self:PlayAnimation(self.Ani_text_out, 0)
  end
end
function WBP_RecruitingTipPanel_C:CancelRecruit()
  if DataMgr.IsInTeam() then
    RecruitHandler:SendStopRecruit(DataMgr.MyTeamInfo.teamid)
  end
end
function WBP_RecruitingTipPanel_C:RemoveEvent()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RecruitingTimeTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RecruitingTimeTimer)
  end
  self.Btn_OpenApplyList.OnClicked:Remove(self, self.OnClicked_BtnOpenApplyList)
  self.Btn_Clsoe.OnClicked:Remove(self, self.OnClicked_BtnOpenApplyList)
  self.WBP_InteractTipWidgetCanel:UnBindInteractAndClickEvent(self, self.CancelRecruit)
  EventSystem.RemoveListener(EventDef.Recruit.StopRecruit, self.BindOnStopRecruit)
  EventSystem.RemoveListener(EventDef.Recruit.GetRecruitApplyList, self.BindOnGetRecruitApplyList)
  EventSystem.RemoveListener(EventDef.Recruit.AgreeRecruitApply, self.BindOnAgreeRecruitApply)
  EventSystem.RemoveListener(EventDef.Recruit.RefuseRecruitApply, self.BindOnRefuseRecruitApply)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateRoomMembersInfo)
  EventSystem.RemoveListener(EventDef.WSMessage.ApplyJoinRecruitTeam, self.BindOnApplyJoinRecruitTeam)
end
function WBP_RecruitingTipPanel_C:BindOnStopRecruit()
  self:RemoveEvent()
  self:StopAnimation(self.Ani_list_in)
  if self.IsClose then
    return
  end
  self.IsClose = true
  self:PlayAnimation(self.Ani_list_out, 0)
  if self.IsOpenApplyList then
    self:PlayAnimation(self.Ani_text_out, 0)
  end
end
function WBP_RecruitingTipPanel_C:OnAnimationFinished(Animation)
  if self.Ani_list_out == Animation and self.IsClose then
    UpdateVisibility(self, false)
  end
  if self.Ani_text_out == Animation then
    UpdateVisibility(self.ApplyList, self.IsOpenApplyList)
  end
end
function WBP_RecruitingTipPanel_C:BindOnUpdateRoomMembersInfo(TeamMambersInfo)
  self:SetTeamInfo(TeamMambersInfo)
end
function WBP_RecruitingTipPanel_C:BindOnApplyJoinRecruitTeam(Json)
  local JsonTable = RapidJson.decode(Json)
  local roleID = JsonTable.id
  DataMgr.GetOrQueryPlayerInfo({roleID}, false, function(playerInfoList)
    local playerInfo = playerInfoList[1].playerInfo
    local ApplyItem = GetOrCreateItem(self.ScrollBox_ApplyList, #self.ApplyItems + 1, self.WBP_RecruitApplyItem:GetClass())
    ApplyItem:InitApplyItemInfo(playerInfo)
    self.ApplyPlayerInfos[playerInfo.roleid] = playerInfo
    ApplyItem.Parent = self
    table.insert(self.ApplyItems, ApplyItem)
    HideOtherItem(self.ScrollBox_ApplyList, #self.ApplyItems + 1)
    self.WBP_RedDotView:SetNum(#self.ApplyItems)
  end)
end
function WBP_RecruitingTipPanel_C:BindOnGetRecruitApplyList(ResultList)
  local ApplyIDList = {}
  for i, ID in ipairs(ResultList.recruitList) do
    table.insert(ApplyIDList, ID)
  end
  DataMgr.GetOrQueryPlayerInfo(ApplyIDList, false, function(playerInfoList)
    self.ApplyItems = {}
    self.ScrollBox_ApplyList:ClearChildren()
    for i, v in ipairs(playerInfoList) do
      local playerInfo = v.playerInfo
      local ApplyItem = GetOrCreateItem(self.ScrollBox_ApplyList, #self.ApplyItems + 1, self.WBP_RecruitApplyItem:GetClass())
      ApplyItem:InitApplyItemInfo(playerInfo)
      self.ApplyPlayerInfos[playerInfo.roleid] = playerInfo
      ApplyItem.Parent = self
      table.insert(self.ApplyItems, ApplyItem)
    end
    self.WBP_RedDotView:SetNum(#self.ApplyItems)
    HideOtherItem(self.ScrollBox_ApplyList, #self.ApplyItems + 1)
  end)
end
function WBP_RecruitingTipPanel_C:BindOnRefuseRecruitApply()
  self.WBP_RedDotView:SetNum(#self.ApplyItems)
end
function WBP_RecruitingTipPanel_C:BindOnAgreeRecruitApply()
  self.WBP_RedDotView:SetNum(#self.ApplyItems)
end
function WBP_RecruitingTipPanel_C:UpdateMatchingTimeText()
  local fmt = "mm:ss"
  if self:GetCurMatchingTime() >= 60 then
    fmt = "mm:ss"
  end
  local TimeText = Format(self:GetCurMatchingTime(), fmt, false)
  self.TXT_RecruitingTime_Num:SetText(TimeText)
end
function WBP_RecruitingTipPanel_C:GetCurMatchingTime()
  return math.floor(GetTimeWithServerDelta() - self.StartRecruitingTime)
end
function WBP_RecruitingTipPanel_C:SetTeamInfo(TeamMambersInfo)
  local isCaptain = LogicTeam.IsCaptain()
  if #TeamMambersInfo >= 3 and isCaptain then
    self:BindOnStopRecruit()
  end
  local allHeadIcon = {
    self.WBP_PlayerHeadIcon_1,
    self.WBP_PlayerHeadIcon_2,
    self.WBP_PlayerHeadIcon_3
  }
  local captainID = DataMgr.GetTeamInfo().captain
  for i, v in ipairs(allHeadIcon) do
    if i > #TeamMambersInfo then
      v:SetIsShow(false)
      v:SetIsCaptain(false)
    else
      v:SetIsShow(true)
      v:InitInfo(TeamMambersInfo[i].portrait, TeamMambersInfo[i].level, self, TeamMambersInfo[i].roleid)
      v:SetIsCaptain(captainID == TeamMambersInfo[i].roleid)
    end
  end
end
function WBP_RecruitingTipPanel_C:SetGameInfo(ModeID, WorldID, Floor)
  local Result, RowInfo = GetRowData(DT.DT_GameMode, tostring(WorldID))
  if Result then
    local modeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGameMode)
    local InfoText = UE.FTextFormat(self.RecruitInfoText, modeTable[ModeID].Name, RowInfo.Name, DifficultyText, Floor)
    self.TXT_Difficulty:SetText(InfoText)
  end
end
function WBP_RecruitingTipPanel_C:RemoveApplyItem(RoleID)
  for i, ApplyItem in ipairs(self.ApplyItems) do
    if ApplyItem.RoleID == RoleID then
      table.RemoveItem(self.ApplyItems, ApplyItem)
      if 0 == #self.ApplyItems then
        if self.IsOpenApplyList then
          self:StopAnimation(self.Ani_text_in)
          self:PlayAnimation(self.Ani_text_out, 0)
        end
        self.IsOpenApplyList = false
        UpdateVisibility(self.BG_CloseBtn, self.IsOpenApplyList)
      end
      return
    end
  end
end
function WBP_RecruitingTipPanel_C:OnHovered_HeadIcon(bIsShow, PlayerInfo, TargetItem, RoleId)
  if bIsShow then
    local playerInfo = PlayerInfo
    playerInfo = playerInfo or self:GetPlayerInfoById(RoleId)
    self.WBP_SocialPlayerInfoTips:InitSocailPlayerInfoTips(playerInfo)
    local GeometryItem = TargetItem:GetCachedGeometry()
    local GeometryCanvasPanelTips = self:GetCachedGeometry()
    local Pos = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryCanvasPanelTips, GeometryItem)
    local slotCanvas = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.WBP_SocialPlayerInfoTips)
    slotCanvas:SetPosition(Pos)
  else
    self.WBP_SocialPlayerInfoTips:Hide()
  end
end
function WBP_RecruitingTipPanel_C:OnClicked_HeadIcon(MousePosition, SourceFrom, RoleId)
  local PlayerInfo = self:GetPlayerInfoById(RoleId)
  if PlayerInfo then
    UIMgr:Show(ViewID.UI_ContactPersonOperateButtonPanel, nil, MousePosition, PlayerInfo, SourceFrom)
  end
end
function WBP_RecruitingTipPanel_C:GetPlayerInfoById(RoleId)
  for i, v in ipairs(DataMgr:GetTeamMembersInfo()) do
    if v.roleid == RoleId then
      return v
    end
  end
  return nil
end
return WBP_RecruitingTipPanel_C
