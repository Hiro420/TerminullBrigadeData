local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local WBP_InviteTeamTip_C = UnLua.Class()
function WBP_InviteTeamTip_C:Construct()
  self.Btn_Confirm.OnClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_Refuse.OnClicked:Add(self, self.BindOnRefuseButtonClicked)
  EventSystem.AddListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacyLogin, self, self.OnGetCurrBattleLagacyLogin)
end
function WBP_InviteTeamTip_C:ClearSession()
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    return
  end
  local RGPlayerSessionSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGPlayerSessionSubsystem:StaticClass())
  if RGPlayerSessionSubsystem then
    RGPlayerSessionSubsystem:Clear()
  end
end
function WBP_InviteTeamTip_C:BindOnConfirmButtonClicked()
  self:ClearSession()
  if not LogicTeam.IsTeammate(self.InviterInfo.InviterId) then
    if self.InviterInfo.IsApply then
      LogicTeam.RequestAgreeJoinTeamToServer(self.InviterInfo.InviterId, self.InviterInfo.TeamId, self.InviterInfo.InviteJoinTeamInfo.joinway)
    else
      LogicTeam.RequestJoinTeamToServer(self.InviterInfo.TeamId, self.InviterInfo.InviteJoinTeamInfo.joinway)
    end
  else
    ShowWaveWindow(15000)
  end
  if self.CheckBox_IngoreInvite:IsChecked() then
    LogicTeam.AddIngoreTeamInviteList(self.InviterInfo.InviterId)
  end
  LogicTeam.ShowNextTeamInviteTipWindow()
end
function WBP_InviteTeamTip_C:BindOnRefuseButtonClicked()
  self:ClearSession()
  if not LogicTeam.IsTeammate(self.InviterInfo.InviterId) then
    if self.InviterInfo.IsApply then
      LogicTeam.RequestRefuseFriendJoinTeam(self.InviterInfo.InviterId, self.InviterInfo.TeamId)
    else
      LogicTeam.RequestRefuseJoinFriendTeam(self.InviterInfo.InviterId, self.InviterInfo.TeamId)
    end
  else
    ShowWaveWindow(15000)
  end
  if self.CheckBox_IngoreInvite:IsChecked() then
    LogicTeam.AddIngoreTeamInviteList(self.InviterInfo.InviterId)
  end
  LogicTeam.ShowNextTeamInviteTipWindow()
end
function WBP_InviteTeamTip_C:OnGetCurrBattleLagacyLogin()
  UpdateVisibility(self.RGTextBattleLagacyInvalid, false)
  if self.InviterInfo and self.InviterInfo.InviteJoinTeamInfo and BattleLagacyData.CurBattleLagacyData ~= nil and BattleLagacyData.CurBattleLagacyData.BattleLagacyId ~= "0" then
    print("WBP_InviteTeamTip_C:OnGetCurrBattleLagacyLogin", self.InviterInfo.InviteJoinTeamInfo.floor, UE.URGMatchSettings.GetSettings().MaxDifficultId)
    if self.InviterInfo.InviteJoinTeamInfo.floor > UE.URGMatchSettings.GetSettings().MaxDifficultId then
      UpdateVisibility(self.RGTextBattleLagacyInvalid, true)
    end
  end
end
function WBP_InviteTeamTip_C:RefreshInfo(InviterInfo)
  self.InviterInfo = InviterInfo
  self:OnGetCurrBattleLagacyLogin()
  self.Txt_Name:SetText(self.InviterInfo.PlayerInfo.nickname)
  if self.InviterInfo.IsApply then
    self.Txt_InviteDesc:SetText(self.ApplyText)
  else
    self.Txt_InviteDesc:SetText(self.InviteText)
  end
  if CheckIsInNormal(self.InviterInfo.InviteJoinTeamInfo.gameMode) then
    local BResult, WorldRowInfo = GetRowData(DT.DT_GameMode, self.InviterInfo.InviteJoinTeamInfo.world)
    if BResult then
      self.Txt_WorldName:SetText(WorldRowInfo.Name)
    end
  else
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameMode, self.InviterInfo.InviteJoinTeamInfo.gameMode)
    if Result then
      self.Txt_WorldName:SetText(RowInfo.Name)
    end
  end
  self.Txt_DifficultLevel:SetText(LogicTeam.GetModeDifficultDisplayText(self.InviterInfo.InviteJoinTeamInfo.gameMode, self.InviterInfo.InviteJoinTeamInfo.floor, self.InviterInfo.InviteJoinTeamInfo.world))
  if self.WBP_PlayerInfoHeadIconItem then
    self.WBP_PlayerInfoHeadIconItem:InitPlayerInfoHeadIconItem(self.InviterInfo.PlayerInfo.portrait)
  end
  self.CheckBox_IngoreInvite:SetIsChecked(false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimeHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimeHandle)
  end
  self.CurRemainTime = self.Duration
  self.Txt_RemainTime:SetText(tostring(self.CurRemainTime))
  self.RemainTimeHandle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self.CurRemainTime = self.CurRemainTime - 1
      self.Txt_RemainTime:SetText(tostring(self.CurRemainTime))
      if self.CurRemainTime <= 0 then
        if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimeHandle) then
          UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimeHandle)
        end
        self:BindOnRefuseButtonClicked()
      end
    end
  }, 1.0, true)
  self:StopAllAnimations()
  self.IsInitiativeStop = true
  self:PlayAnimationForward(self.Ani_in)
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_InviteTeamTip_C self.InviterInfo.InviterId: %s", tostring(self.InviterInfo.InviterId)))
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_InviteTeamTip_C self.InviterInfo.PlayerInfo.channelUID: %s", tostring(self.InviterInfo.PlayerInfo.channelUID)))
  if self.PlatformPanel then
    UpdateVisibility(self.PlatformPanel, false)
  end
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(self.InviterInfo.InviterId, false, self.InviterInfo.PlayerInfo.channelUID)
  end
end
function WBP_InviteTeamTip_C:PlayOutAnimation()
  self.IsInitiativeStop = false
  self:PlayAnimationForward(self.Ani_out)
end
function WBP_InviteTeamTip_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out and not self.IsInitiativeStop then
    UIMgr:Hide(ViewID.UI_InviteTeamTip)
  end
end
function WBP_InviteTeamTip_C:OnHide()
  self.InviterInfo = {}
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimeHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimeHandle)
  end
end
function WBP_InviteTeamTip_C:Destruct()
  EventSystem.RemoveListenerNew(EventDef.BattleLagacy.OnGetCurrBattleLagacyLogin, self, self.OnGetCurrBattleLagacyLogin)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimeHandle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimeHandle)
  end
end
return WBP_InviteTeamTip_C
