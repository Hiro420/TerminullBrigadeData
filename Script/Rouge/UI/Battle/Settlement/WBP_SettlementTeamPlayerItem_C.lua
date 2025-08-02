local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local WBP_SettlementTeamPlayerItem_C = UnLua.Class()

function WBP_SettlementTeamPlayerItem_C:Construct()
  self.DamageItemClass = UE.UClass.Load("/Game/Rouge/UI/Battle/WBP_SingleDamageItem.WBP_SingleDamageItem_C")
  self.ButtonCheck.OnClicked:Add(self, self.OnCheckPlayerInfoClick)
  self.BP_ButtonReport.OnClicked:Add(self, self.Report)
  self.Btn_RequestFriend.OnClicked:Add(self, self.RequestFriend)
  self.StateCtrl_AddFriend:ChangeStatus(EEnable.Enable)
  UpdateVisibility(self.PlatformPanel, false)
end

function WBP_SettlementTeamPlayerItem_C:Report()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.DELATE) then
    return
  end
  UIMgr:Show(ViewID.UI_ReportView, false, 3, self.PlayerId, self.RGTextName:GetText())
end

function WBP_SettlementTeamPlayerItem_C:RequestFriend()
  local func = function()
    if IsValidObj(self) then
      self.StateCtrl_AddFriend:ChangeStatus(EEnable.Disable)
    end
  end
  ContactPersonHandler:RequestAddFriendToServer(tostring(self.PlayerId), EOperateButtonPanelSourceFromType.RecentList, func)
end

function WBP_SettlementTeamPlayerItem_C:InitTitle(TitleInfo)
  self.TitleInfo = TitleInfo
  if TitleInfo then
    self.RGTextAchievementName:SetText(TitleInfo.TitleName)
    local ScoreTemp = TitleInfo.Score
    if type(TitleInfo.Score) == "number" then
      ScoreTemp = math.floor(TitleInfo.Score + 0.5)
    end
    if self.MvpInfo and self.MvpInfo.PlayerId == self.PlayerId then
      UpdateVisibility(self.CanvasPanelAchievement, false)
    else
      UpdateVisibility(self.CanvasPanelAchievement, true)
    end
  else
    self.CanvasPanelAchievement:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_SettlementTeamPlayerItem_C:InitPlayerInfo(PlayerId, Name, HeroId, ParentView)
  print("WBP_SettlementTeamPlayerItem_C:InitPlayerInfo", PlayerId, Name, HeroId)
  self.RGTextName:SetText(Name)
  local battleInfoList = LogicSettlement:GetBattleInfoList(PlayerId)
  for i, v in ipairs(battleInfoList) do
    local item = GetOrCreateItem(self.ScrollBoxBattleInfo, i, self.WBP_SettlementBattleInfoItem:GetClass())
    item:InitBattleRoleInfoData(v)
  end
  HideOtherItem(self.ScrollBoxBattleInfo, #battleInfoList + 1)
  UpdateVisibility(self.BP_ButtonReport, tostring(DataMgr:GetUserId()) ~= tostring(PlayerId), true)
  if not ContactPersonData:IsFriend(tostring(PlayerId)) then
    UpdateVisibility(self.Btn_RequestFriend, tostring(DataMgr:GetUserId()) ~= tostring(PlayerId), true)
  else
    UpdateVisibility(self.Btn_RequestFriend, false)
  end
  self.PlayerId = PlayerId
  self.ParentView = ParentView
  self:PlayAnimation(self.ani_settlementteamplayreltem_in)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_SettlementTeamPlayerItem_C PlayerId: %s", tostring(PlayerId)))
  if self.PlatformPanel then
    self.PlatformPanel:UpdateChannelInfo(PlayerId)
  end
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(PlayerId)
  end
end

function WBP_SettlementTeamPlayerItem_C:InitMvp(MvpInfo)
  self.MvpInfo = MvpInfo
  if MvpInfo and MvpInfo.PlayerId == self.PlayerId then
    UpdateVisibility(self.CanvasPanelMvp, true)
    UpdateVisibility(self.CanvasPanelAchievement, false)
  else
    UpdateVisibility(self.CanvasPanelMvp, false)
    UpdateVisibility(self.CanvasPanelAchievement, self.TitleInfo)
  end
end

function WBP_SettlementTeamPlayerItem_C:OnCheckPlayerInfoClick()
  if self.PlayerId and self.PlayerId > 0 and UE.RGUtil.IsUObjectValid(self.ParentView) then
    self.ParentView:ShowSettlementPlayerInfoView(self.PlayerId)
  end
end

function WBP_SettlementTeamPlayerItem_C:Destruct()
  self.ButtonCheck.OnClicked:Remove(self, self.OnCheckPlayerInfoClick)
end

return WBP_SettlementTeamPlayerItem_C
