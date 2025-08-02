local SpaceActionName = "Space"
local ViewBase = require("Framework.UIMgr.ViewBase")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local WBP_MovieLevelSequence = Class(ViewBase)
local EscName = "PauseGame"
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end

function WBP_MovieLevelSequence:BindClickHandler()
  EventSystem.AddListener(self, EventDef.DrawCard.OnDrawCardShowFinished, self.BindOnDrawCardShowFinished)
end

function WBP_MovieLevelSequence:UnBindClickHandler()
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardShowFinished, self.BindOnDrawCardShowFinished, self)
end

function WBP_MovieLevelSequence:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_MovieLevelSequence:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_MovieLevelSequence:OnPreHide()
  if self.SequencePlayer then
    self:LevelSequenceFinish(true)
  end
  self:SetEnhancedInputActionBlocking(false)
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.EscPress)
end

function WBP_MovieLevelSequence:OnShow(SkinId, ShowNext, CallBack, escFunc, Seq, bIsDrawCardShow)
  self.Seq = Seq
  self.bIsDrawCardShow = bIsDrawCardShow
  if self.AsyncLoadSequenceHandleID and self.AsyncLoadSequenceHandleID > 0 then
    UE.URGAssetManager.CancelAsyncLoad(self.AsyncLoadSequenceHandleID)
    self.AsyncLoadSequenceHandleID = nil
  end
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.EscPress)
  self.SkinId = SkinId
  self.ShowNext = ShowNext
  self.CallBack = CallBack
  self.AsyncLoadingEnd = false
  self.HideLobbyLevel = false
  self:PlayAnimation(self.FadeStart)
  self.escFunc = escFunc
  LogicAudio.bIsPlayingMovie = true
  self:SetEnhancedInputActionBlocking(true)
  UE.UAudioManager.StopWwiseEventByName(LogicAudio.LastAkEventName1)
  local seq = Seq or LogicRole.GetSkinSequence(self.SkinId)
  if seq then
    self:PlaySeq(seq)
  else
    self:LevelSequenceFinish()
  end
end

function WBP_MovieLevelSequence:ShowNextCharacter()
  self.bIsWaitingShowNextCharacter = false
  if self.ShowNext then
    local ResID = GetTbSkinRowNameBySkinID(self.SkinId)
    local CharacterSkin = Logic_Mall.GetDetailRowDataByResourceId(ResID)
    local SkinId = CharacterSkin.SkinID
    local HeroId = CharacterSkin.CharacterID
    local WeaponId = DataMgr.GetShowWeaponId(HeroId)
    local WeaponSkinId = SkinData.GetEquipedWeaponSkinIdByWeaponResId(WeaponId)
    GetAppearanceActor(self):InitAppearanceActor(HeroId, SkinId, WeaponSkinId, nil, self.bIsDrawCardShow, self.bIsDrawCardShow, function()
      GetAppearanceActor(self):UpdateActived(true)
      if self.bIsDrawCardShow then
        UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
          GameInstance,
          function()
            GetAppearanceActor(self):ChangeTransformByIndex(2)
            GetAppearanceActor(self):InitRoleScaleByHeroId(HeroId)
          end
        })
      end
    end)
  end
end

function WBP_MovieLevelSequence:PlaySkinSound()
  local result, row = GetRowData(DT.DT_HeirloomSkin, tostring(self.SkinId))
  local heirloogMediaData
  if result and row.HeirloomMediaDataAry:IsValidIndex(1) then
    heirloogMediaData = row.HeirloomMediaDataAry:Get(1)
  end
  if heirloogMediaData then
    local MovieSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
    if MovieSubSys then
      if self.LastAkEventName then
        UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
        self.LastAkEventName = nil
      end
      self.LastAkEventName = MovieSubSys:GetAkEventName(heirloogMediaData.MediaId)
      UE.UAudioManager.PlaySound2DByName(self.LastAkEventName, "SkinView:UpdateMovie")
    end
  end
end

function WBP_MovieLevelSequence:OnHide()
  self:LevelSequenceFinish(true)
  StopListeningForInputAction(self, SpaceActionName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.EscPress)
end

function WBP_MovieLevelSequence:SequenceFinished()
  if self.SequencePlayer then
    if self.LastAkEventName then
      UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
      self.LastAkEventName = nil
    end
    if not self.bIsDrawCardShow then
      self.SequencePlayer:K2_DestroyActor()
      self.SequenceActor:K2_DestroyActor()
      self.SequencePlayer = nil
      self.SequenceActor = nil
    end
  end
end

function WBP_MovieLevelSequence:PlaySeq(SoftObjPath)
  if self.SequencePlayer then
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
  end
  if self.AsyncLoadSequenceHandleID and self.AsyncLoadSequenceHandleID > 0 then
    UE.URGAssetManager.CancelAsyncLoad(self.AsyncLoadSequenceHandleID)
    self.AsyncLoadSequenceHandleID = nil
  end
  local Path = UE.UKismetSystemLibrary.BreakSoftObjectPath(SoftObjPath)
  self.AsyncLoadSequenceHandleID = UE.URGAssetManager.Lua_AsyncLoadAsset(Path, function(loadPath)
    self.AsyncLoadSequenceHandleID = nil
    self.AsyncLoadingEnd = true
    self:StartShowSequence()
  end, function()
    print("Failid async load asset: ", Path)
    self:LevelSequenceFinish()
  end)
  self.RegisterHide = false
  self.TimerPlaySeq = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      local Lobby_02 = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "Lobby_02")
      if Lobby_02 and Lobby_02.bShouldBeVisible and not self.Seq then
        Lobby_02.OnLevelHidden:Add(self, self.LevelHide)
        self.RegisterHide = true
      else
        self:LevelHide()
      end
      LogicRole.ShowOrLoadLevel(self.SkinId, true)
    end
  }, 0.02, false)
end

function WBP_MovieLevelSequence:LevelHide()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.Timer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerShowNextCharacter) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimerShowNextCharacter)
  end
  local delayTime = 0.1
  if self.bIsDrawCardShow then
    delayTime = self.DrawCardShowInitCharacterDelayTime
  end
  self.bIsWaitingShowNextCharacter = true
  self.TimerShowNextCharacter = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self:ShowNextCharacter()
    end
  }, delayTime, false)
  self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self:LevelHideAfter()
    end
  }, 0.1, false)
end

function WBP_MovieLevelSequence:LevelHideAfter()
  self.HideLobbyLevel = true
  self:StartShowSequence()
end

function WBP_MovieLevelSequence:CanShowSequence()
  if not self.AsyncLoadingEnd then
    return false
  end
  if not self.HideLobbyLevel then
    return false
  end
  return true
end

function WBP_MovieLevelSequence:StartShowSequence()
  if not self:CanShowSequence() then
    return
  end
  local Lobby_02 = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "Lobby_02")
  if Lobby_02 and self.RegisterHide then
    Lobby_02.OnLevelHidden:Remove(self, self.LevelHide)
    self.RegisterHide = false
  end
  local seqSubSys = UE.URGSequenceSubsystem.GetInstance(self)
  if not seqSubSys then
    self:LevelSequenceFinish()
    return
  end
  local seq = self.Seq or LogicRole.GetSkinSequence(self.SkinId)
  if seq then
    local setting = UE.FMovieSceneSequencePlaybackSettings()
    setting.bPauseAtEnd = true
    self.SequencePlayer = seqSubSys:CreatePlayerFromLevelSequence(self, seq, setting)
    if self.SequencePlayer == nil then
      print("[WBP_SettlementView_C::Play] Player or SequenceActor is Empty!")
      self:LevelSequenceFinish()
      return
    end
    self.SequenceActor = self.SequencePlayer.SequenceActor
    if LogicRole.GetSequenceActor() then
      self.SequencePlayer:SetInstanceData(LogicRole.GetSequenceActor(), UE.FTransform())
    end
    self.SequencePlayer.OnFinished:Add(self, self.LevelSequenceFinish)
    self.SequencePlayer:Play()
    self:PlaySkinSound()
  end
  self:PlayAnimation(self.FadeOut)
end

function WBP_MovieLevelSequence:LevelSequenceFinish(ByHideForce)
  if self.AsyncLoadSequenceHandleID and self.AsyncLoadSequenceHandleID > 0 then
    UE.URGAssetManager.CancelAsyncLoad(self.AsyncLoadSequenceHandleID)
    self.AsyncLoadSequenceHandleID = nil
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.Timer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerPlaySeq) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimerPlaySeq)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerShowNextCharacter) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimerShowNextCharacter)
    if self.bIsWaitingShowNextCharacter then
      self:ShowNextCharacter()
    end
  end
  self:SequenceFinished()
  LogicAudio.bIsPlayingMovie = false
  local Lobby_02 = UE.UGameplayStatics.GetStreamingLevel(GameInstance, "Lobby_02")
  if Lobby_02 and self.RegisterHide then
    Lobby_02.OnLevelHidden:Remove(self, self.LevelHide)
    self.RegisterHide = false
  end
  if self.CallBack then
    self.CallBack()
  end
  if not ByHideForce then
    UIMgr:Hide(ViewID.UI_MovieLevelSequence, true)
  end
  if self.ShowNext then
    LogicRole.ShowOrLoadLevel(self.SkinId)
    local AppearanceActorTemp = GetAppearanceActor(self)
    if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
      self.AppearanceActor:AppearanceToggleSkipEnter(false)
      if not self.bIsDrawCardShow then
        self.AppearanceActor:RefreshRoleAniStatus(self.SkinId)
      end
      UE.UAudioManager.StopWwiseEventByName(LogicAudio.LastAkEventName1)
      local result, row = GetRowData(DT.DT_DisplaySkin, self.SkinId)
      if result then
        local AkEventName = row.SkinSound.AppearanceSound
        UE.UAudioManager.PlaySound2DByName(AkEventName, "OnLobbyChangeHero")
        LogicAudio.LastAkEventName1 = AkEventName
      end
    end
  else
    LogicRole.ShowOrLoadLevel(-1)
    LogicRole.ShowLevelForSequence(true)
  end
end

function WBP_MovieLevelSequence:SpacePress()
  if not self:CanShowSequence() then
    return
  end
  self:LevelSequenceFinish()
end

function WBP_MovieLevelSequence:EscPress()
  if not self:CanShowSequence() then
    return
  end
  self:LevelSequenceFinish()
end

function WBP_MovieLevelSequence:BindOnDrawCardShowFinished()
  if self.SequencePlayer and self.bIsDrawCardShow then
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
  end
end

return WBP_MovieLevelSequence
