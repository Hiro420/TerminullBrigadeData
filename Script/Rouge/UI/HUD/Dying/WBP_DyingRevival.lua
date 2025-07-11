local WBP_DyingRevival = UnLua.Class()
local SingleDyingTxt = NSLOCTEXT("WBP_DyingRevival", "SingleDyingTxt", "\229\183\178\229\128\146\229\156\176")
local AllDyingTxt = NSLOCTEXT("WBP_DyingRevival", "AllDyingTxt", "\233\152\159\228\188\141\229\133\168\233\131\168\229\128\146\229\156\176")
local SingleRevivalTime = NSLOCTEXT("WBP_DyingRevival", "SingleRevivalTime", "\229\137\169\228\189\153\229\164\141\230\180\187\230\172\161\230\149\176")
local TeamRevivalTime = NSLOCTEXT("WBP_DyingRevival", "TeamRevivalTime", "\233\152\159\228\188\141\229\137\169\228\189\153\229\164\141\230\180\187\230\172\161\230\149\176")
local FreeRevival = NSLOCTEXT("WBP_DyingRevival", "FreeRevival", "\229\133\141\232\180\185\229\164\141\230\180\187")
local GiveUpRevival = NSLOCTEXT("WBP_DyingRevival", "GiveUpRevival", "\230\148\190\229\188\131")
local RevivalCoin = NSLOCTEXT("WBP_DyingRevival", "RevivalCoin", "\229\164\141\230\180\187\229\184\129")
local ChooseRevivalType = NSLOCTEXT("WBP_DyingRevival", "ChooseRevivalType", "\232\175\183\233\128\137\230\139\169\229\164\141\230\180\187\230\150\185\229\188\143\239\188\154")
local IsUseFreeRevival = NSLOCTEXT("WBP_DyingRevival", "IsUseFreeRevival", "\230\152\175\229\144\166\229\133\141\232\180\185\229\164\141\230\180\187")
local UseFreeRevival = NSLOCTEXT("WBP_DyingRevival", "UseFreeRevival", "\229\133\141\232\180\185\229\164\141\230\180\187(+{0}\229\136\134\233\146\159)")
local RevivalEvent = "Revival"
local GiveUpEvent = "GiveUpRevival"
function WBP_DyingRevival:Construct()
  self.IsAllDying = false
  ListenObjectMessage(nil, GMP.MSG_Game_PlayerRevivalSuccess, self, self.Bind_MSG_Game_PlayerRevivalSuccess)
  ListenObjectMessage(nil, GMP.MSG_Game_PlayerRevivalError, self, self.Bind_MSG_Game_PlayerRevivalError)
  ListenObjectMessage(nil, GMP.MSG_Game_AllPlayerDying, self, self.Bind_MSG_Game_AllPlayerDying)
end
function WBP_DyingRevival:Destruct()
  UnListenObjectMessage(GMP.MSG_Game_PlayerRevivalSuccess, self)
  UnListenObjectMessage(GMP.MSG_Game_PlayerRevivalError, self)
  UnListenObjectMessage(GMP.MSG_Game_AllPlayerDying, self)
end
function WBP_DyingRevival:BindKey()
  if not IsListeningForInputAction(self, RevivalEvent) then
    ListenForInputAction(RevivalEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForRevivalEvent
    })
  end
  if not IsListeningForInputAction(self, GiveUpEvent) then
    ListenForInputAction(GiveUpEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForGiveUpEvent
    })
  end
end
function WBP_DyingRevival:UnBindKey()
  if IsListeningForInputAction(self, RevivalEvent) then
    StopListeningForInputAction(self, RevivalEvent, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, GiveUpEvent) then
    StopListeningForInputAction(self, GiveUpEvent, UE.EInputEvent.IE_Pressed)
  end
end
function WBP_DyingRevival:ListenForRevivalEvent()
  local CanRevival = self:CheckCanRevival()
  if not CanRevival or self.IsHideInteract then
    print("WBP_DyingRevival RequestRevival fail CanRevival is " .. tostring(CanRevival) .. " IsHideInteract is " .. tostring(self.IsHideInteract))
    return
  end
  print("WBP_DyingRevival RequestRevival")
  UE.URGLevelLibrary.RequestRevival(self, self:GetUserId())
end
function WBP_DyingRevival:ListenForGiveUpEvent()
  if self.IsHideInteract then
    return
  end
  print("WBP_DyingRevival CancelRequestRevival")
  if self:CheckIsNormalMode() then
    UE.URGLevelLibrary.RequestFreeRevival(self, self:GetUserId())
  elseif self.IsAllDying then
    if self:CheckIsTeam() then
      UpdateVisibility(self.Overlay_GiveUpRevival, false)
      UpdateVisibility(self.Overlay_Revival, false)
      UpdateVisibility(self.HBox_Expand, false)
      self.IsHideInteract = true
    end
    UE.URGLevelLibrary.CancelRequestRevival(self, self:GetUserId())
  end
end
function WBP_DyingRevival:Bind_MSG_Game_PlayerRevivalSuccess(UserId, RevivalCount, RevivalCoinNum)
  if self:GetUserId() == UserId then
    UpdateVisibility(self, false)
  end
  self:UpdateWaitRescureText()
end
function WBP_DyingRevival:Bind_MSG_Game_PlayerRevivalError()
end
function WBP_DyingRevival:Bind_MSG_Game_AllPlayerDying(IsAllDying)
  self.IsAllDying = IsAllDying
  if IsAllDying then
    self:StartCountDown()
    self:ShowCancelInteractTip()
    UpdateVisibility(self.Overlay_Revival, true)
    if self:CheckIsTeam() then
      self:SetDyingTextIsSingle(false)
    end
  else
    self:StopCountDown()
    self:SetDyingTextIsSingle(true)
  end
end
function WBP_DyingRevival:ShowRevivalInfo()
  self.IsHideInteract = false
  self.Txt_CountDown:SetText("")
  self:PlayAnimation(self.Anim_IN)
  UpdateVisibility(self, true)
  UpdateVisibility(self.HBox_Expand, true)
  UpdateVisibility(self.Overlay_Revival, true)
  UpdateVisibility(self.Txt_TeamMode, self:CheckIsTeamMode())
  UpdateVisibility(self.Txt_Desc, self:CheckIsNormalMode())
  local TeamRevivalInfo, SelfRevivalInfo = self:GetTeamAndSelfRevivalInfo()
  if self:CheckIsTeamMode() then
    if TeamRevivalInfo.TeamFreeRevivalCount > 0 then
      self:SetOwnText(TeamRevivalInfo.TeamFreeRevivalCount)
      self.Txt_RevivalText:SetText(FreeRevival)
      self.WBP_InteractTipWidget_Revival:UpdateKeyDesc(FreeRevival)
      UpdateVisibility(self.Overlay_Expand, false)
    else
      self.Txt_RevivalText:SetText(RevivalCoin)
      self.WBP_InteractTipWidget_Revival:UpdateKeyDesc(RevivalCoin)
      self:SetOwnText(SelfRevivalInfo.RevivalCoinNum)
      UpdateVisibility(self.Overlay_Expand, true)
    end
  elseif SelfRevivalInfo.FreeRevivalCount > 0 then
    self:SetOwnText(SelfRevivalInfo.FreeRevivalCount)
    self.Txt_RevivalText:SetText(FreeRevival)
    self.WBP_InteractTipWidget_Revival:UpdateKeyDesc(FreeRevival)
    UpdateVisibility(self.Overlay_Expand, false)
  else
    UpdateVisibility(self.Overlay_Expand, true)
    self.Txt_RevivalText:SetText(RevivalCoin)
    self.WBP_InteractTipWidget_Revival:UpdateKeyDesc(RevivalCoin)
    self:SetOwnText(SelfRevivalInfo.RevivalCoinNum)
  end
  self:UpdateWaitRescureText()
  self:SetDyingInfo(SelfRevivalInfo.RevivalCount, SelfRevivalInfo.OnceCostCoinNum)
  if self:CheckCanRevival() then
    self.RGStateController_InteractY:ChangeStatus("Able")
  else
    self.RGStateController_InteractY:ChangeStatus("UnAble")
  end
  if self:CheckIsNormalMode() then
    UpdateVisibility(self.Overlay_Revival, self:CheckInPerfectTime())
    UpdateVisibility(self.CanvaxPanel_Own, self:CheckInPerfectTime())
    UpdateVisibility(self.TXT_RevivalFun, true)
    self.TXT_RevivalFun:SetText(self:CheckInPerfectTime() and ChooseRevivalType or IsUseFreeRevival)
    local FreeRevivalPunish = UE.FTextFormat(UseFreeRevival(), self:GetPunishTime() / 60)
    self.WBP_InteractTipWidget_GiveUp:UpdateKeyDesc(FreeRevivalPunish)
  else
    UpdateVisibility(self.TXT_RevivalFun, false)
    self.WBP_InteractTipWidget_GiveUp:UpdateKeyDesc(GiveUpRevival)
    self:ShowCancelInteractTip()
  end
  self:BindKey()
end
function WBP_DyingRevival:StartCountDown()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimer)
  end
  local TeamRevivalInfo = self:GetTeamAndSelfRevivalInfo()
  self.CountDownTime = math.floor(TeamRevivalInfo.RevivalTime)
  self.RemainTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.UpdateCountDown
  }, 1.0, true)
  self:SetCountDownShow(true)
end
function WBP_DyingRevival:StopCountDown()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.RemainTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.RemainTimer)
  end
  self:SetCountDownShow(false)
end
function WBP_DyingRevival:UpdateCountDown()
  if self.CountDownTime < 0 then
    return
  end
  self.Txt_CountDown:SetText(self.CountDownTime)
  if 0.0 == self.CountDownTime then
    UE.URGLevelLibrary.CancelRequestRevival(self, self:GetUserId())
  end
  self.CountDownTime = self.CountDownTime - 1
end
function WBP_DyingRevival:UpdateWaitRescureText()
  UpdateVisibility(self.Txt_WaitRescure, self:CheckIsTeam() and not self:CheckCanRevival())
end
function WBP_DyingRevival:UpdateRevivalInteract()
  UpdateVisibility(self.HBox_Expand, true)
end
function WBP_DyingRevival:SetDyingTextIsSingle(IsSingle)
  self.Txt_Death:SetText(IsSingle and SingleDyingTxt or AllDyingTxt)
end
function WBP_DyingRevival:SetDyingInfo(RevivalTime, Expand)
  self.Txt_RemainTimeNum:SetText(RevivalTime)
  self.Txt_ExpandNum:SetText(Expand)
end
function WBP_DyingRevival:SetOwnText(RevivalNum)
  self.Txt_OwnNum:SetText(RevivalNum)
end
function WBP_DyingRevival:SetCountDownShow(IsShow)
  UpdateVisibility(self.Txt_CountDown, IsShow)
end
function WBP_DyingRevival:ShowCancelInteractTip()
  if self.IsAllDying then
    UpdateVisibility(self.Overlay_GiveUpRevival, true)
    if not IsListeningForInputAction(self, GiveUpEvent) then
      ListenForInputAction(GiveUpEvent, UE.EInputEvent.IE_Pressed, true, {
        self,
        self.ListenForGiveUpEvent
      })
    end
  else
    UpdateVisibility(self.Overlay_GiveUpRevival, false)
  end
end
function WBP_DyingRevival:CheckCanRevival()
  local TeamRevivalInfo, SelfRevivalInfo = self:GetTeamAndSelfRevivalInfo()
  if self:CheckIsTeamMode() then
    if 0 == TeamRevivalInfo.TeamRevivalCount then
      return false
    end
    return TeamRevivalInfo.TeamFreeRevivalCount > 0 or SelfRevivalInfo.RevivalCoinNum >= SelfRevivalInfo.OnceCostCoinNum
  else
    if 0 == SelfRevivalInfo.RevivalCount then
      return false
    end
    return SelfRevivalInfo.FreeRevivalCount > 0 or SelfRevivalInfo.RevivalCoinNum >= SelfRevivalInfo.OnceCostCoinNum
  end
end
function WBP_DyingRevival:CheckIsTeam()
  local TeamRevivalInfo, SelfRevivalInfo = self:GetTeamAndSelfRevivalInfo()
  return TeamRevivalInfo.PlayerRevivalInfos:Num() > 1
end
function WBP_DyingRevival:CheckIsTeamMode()
  return UE.URGLevelLibrary.IsTeamRevivalMode(self)
end
function WBP_DyingRevival:CheckInPerfectTime()
  return UE.URGLevelLibrary.IsInPerfectTime(self)
end
function WBP_DyingRevival:CheckIsNormalMode()
  return LogicTeam.GetModeId() == TableEnums.ENUMGameMode.NORMAL or LogicTeam.GetModeId() == TableEnums.ENUMGameMode.SEASONNORMAL
end
function WBP_DyingRevival:GetPerfectTime()
  return UE.URGLevelLibrary:GetPerfectTime()
end
function WBP_DyingRevival:GetPunishTime()
  return UE.URGLevelLibrary:GetRevivalPunishTime()
end
function WBP_DyingRevival:GetSelfRevivalInfo()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    print("WBP_DyingRevival: GameState is Null")
    return
  end
  local PlayerRevivalManager = GS:GetComponentByClass(UE.URGPlayerRevivalManager:StaticClass())
  return PlayerRevivalManager:GetPlayerInfo(self:GetUserId())
end
function WBP_DyingRevival:GetTeamAndSelfRevivalInfo()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    print("WBP_DyingRevival: GameState is Null")
    return
  end
  local PlayerRevivalManager = GS:GetComponentByClass(UE.URGPlayerRevivalManager:StaticClass())
  local TeamRevivalInfo = PlayerRevivalManager.TeamRevivalInfo
  local SelfRevivalInfo = PlayerRevivalManager:GetPlayerInfo(self:GetUserId())
  return TeamRevivalInfo, SelfRevivalInfo
end
function WBP_DyingRevival:GetUserId()
  local UserId = DataMgr.GetUserId()
  if UserId then
    return tonumber(UserId)
  else
    local character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if character then
      UserId = character:GetUserId()
    end
    return UserId
  end
end
return WBP_DyingRevival
