local WBP_BattleMode_RuleTip_C = UnLua.Class()
function WBP_BattleMode_RuleTip_C:DoOpen(BattleModeId)
  LogicHUD:BindOnOptimalTargetChanged(nil)
  self.Countdown = self.CloseTime
  self.BattleModeId = BattleModeId
  self.Countdown = self.Countdown + 1
  self:RefreshCountdown()
  ListenForInputAction("Space", UE.EInputEvent.IE_Pressed, true, {
    self,
    function()
      self:DoClose(self.BattleModeId)
    end
  })
  if self.CloseTimer ~= nil and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CloseTimer) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.CloseTimer)
  end
  self.CloseTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self:RefreshCountdown()
    end
  }, 1, true)
  self:DisablePlayerInput()
  local Result, BattleModeTableRow = GetRowData(DT.DT_BattleMode, BattleModeId)
  if Result then
    self.Txt_Title:SetText(BattleModeTableRow.Name)
    self.DescText:SetText(BattleModeTableRow.Desc)
    local RGMovieSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGMovieSubSystem:StaticClass())
    if nil == RGMovieSubsystem then
      return
    end
    local MediaSrc = RGMovieSubsystem:GetMediaSource(BattleModeTableRow.MovieId)
    if nil == MediaSrc then
      print("WBP_BattleMode_RuleTip_C MediaSrc", MediaSrc)
      return
    end
    self.MediaPlayer:SetLooping(true)
    self.MediaPlayer:OpenSource(MediaSrc)
    self.MediaPlayer:Rewind()
  end
end
function WBP_BattleMode_RuleTip_C:DoClose(BattleModeId)
  if self.CloseTimer ~= nil and UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CloseTimer) then
    UE.UKismetSystemLibrary.K2_ClearTimerHandle(self, self.CloseTimer)
  end
  self:EnablePlayerInput()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    UIManager:K2_CloseUIByName("WBP_BattleMode_RuleTip_C")
  end
  StopListeningForInputAction(self, "Space", UE.EInputEvent.IE_Pressed)
end
function WBP_BattleMode_RuleTip_C:DisablePlayerInput()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InputComp = Character:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
  if not InputComp then
    return
  end
  InputComp:SetAllInputIgnored(true)
end
function WBP_BattleMode_RuleTip_C:EnablePlayerInput()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InputComp = Character:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
  if not InputComp then
    return
  end
  InputComp:SetAllInputIgnored(false)
end
function WBP_BattleMode_RuleTip_C:RefreshCountdown()
  self.Countdown = self.Countdown - 1
  if self.Countdown < 0 then
    self:DoClose(self.BattleModeId)
    return
  end
  local Countdown = NSLOCTEXT("WBP_BattleMode_RuleTip_C", "LimitPurchCountdownaseForever", "{0}\231\167\146\229\144\142\229\188\128\229\167\139")
  self.Countdowntext:SetText(UE.FTextFormat(Countdown(), math.floor(self.Countdown)))
end
return WBP_BattleMode_RuleTip_C
