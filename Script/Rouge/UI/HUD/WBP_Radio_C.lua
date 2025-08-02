local WBP_Radio_C = UnLua.Class()
local ReplaceTextKeywordList = {
  ["{name}"] = function(self)
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return ""
    end
    local PS = PC.PlayerState
    if not PS then
      return ""
    end
    return PS:GetUserNickName()
  end
}

function WBP_Radio_C:Construct()
  self.AudioPriority = 0
  local EmitterManager = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.UEmitterManager:StaticClass())
  if EmitterManager then
    EmitterManager.OnVoiceDuration:Add(self, WBP_Radio_C.BindOnVoiceDuration)
  end
end

function WBP_Radio_C:BindOnVoiceDuration(EventName, ExternalFileName, Duration, Speaker)
  print("BindOnVoiceDuration", EventName, ExternalFileName, Duration)
  if EventName ~= self.CurPlayingEventName then
    return
  end
  local CurExecuteTime = 0
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PropertyTimer) then
    CurExecuteTime = UE.UKismetSystemLibrary.K2_GetTimerElapsedTimeHandle(self, self.PropertyTimer)
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PropertyTimer)
  end
  local RealTimerTime = Duration / 1000 - CurExecuteTime
  if RealTimerTime <= 0 then
    self:SwitchToNextStepLevel()
  else
    self.PropertyTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function(self)
        print("Radio End By Voice Duration")
        self:SwitchToNextStepLevel()
      end
    }, RealTimerTime, false)
  end
end

function WBP_Radio_C:ShowRadio(Id, Params)
  self.Id = Id
  self.Params = Params
  self.IsShow = true
  PlaySound2DEffect(20001, "WBP_Radio_C:ShowRadio")
  if not self:IsVisible() then
    self:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  end
  self:StopAllAnimations()
  self:PlayAnimationForward(self.ani_radio_in)
  self:PlayAnimation(self.ani_radio_loop, 0.0, 0, UE.EUMGSequencePlayMode.Forward, 1.0)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, RowInfo = DTSubsystem:GetRadioRowInfoByID(Id, nil)
  if not Result then
    print("WBP_Radio_C not found radio rowInfo in dt_radioCondition, please check the config! Id is" .. Id)
    return
  end
  self.RadioProperties = {}
  for i, SingleRadioProperty in iterator(RowInfo.RadioProperties) do
    local RadioPropertyList = {PriorityId = 0, PropertyInfo = nil}
    RadioPropertyList.PriorityId = SingleRadioProperty.PriorityId
    RadioPropertyList.PropertyInfo = SingleRadioProperty
    table.insert(self.RadioProperties, RadioPropertyList)
  end
  table.sort(self.RadioProperties, function(A, B)
    return A.PriorityId < B.PriorityId
  end)
  table.insert(LogicRadio.RadioPlayedList, self.Id)
  self.NextInterval = RowInfo.NextInterval
  local StartMapRadioInfo = LogicRadio.GetStartMapRadioInfoTable()
  if self.Id == StartMapRadioInfo.RadioId then
    print("WBP_Radio_C:ShowRadio \230\155\180\230\150\176\230\150\176\230\137\139\229\133\179\229\175\185\232\175\157\230\146\173\230\148\190\232\191\155\229\186\166, \229\189\147\229\137\141\232\191\155\229\186\166:", StartMapRadioInfo.ProgressIndex)
    self.CurShowIndex = StartMapRadioInfo.ProgressIndex
    LogicRadio.UpdateStartMapRadioProgress(self.Id, self.CurShowIndex + 1)
  else
    self.CurShowIndex = 1
  end
  self:UpdatePropertyInfo()
end

function WBP_Radio_C:SwitchNextRadio()
  self.MainRadioPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.CurShowIndex = 1
  LogicRadio.RemoveRadioPlayListById(self.Id)
  local RadioShowList = LogicRadio.RadioPlayList[1]
  if RadioShowList then
    self:ShowRadio(RadioShowList.ID, RadioShowList.Params)
  else
    self:HideRadio()
  end
end

function WBP_Radio_C:ReplaceTextByKeyword(InText)
  local Text = InText
  for Keyword, Func in pairs(ReplaceTextKeywordList) do
    local TargetStr = Func(self)
    Text = UE.UKismetStringLibrary.Replace(Text, Keyword, TargetStr, UE.ESearchCase.IgnoreCase)
  end
  return Text
end

function WBP_Radio_C:UpdatePropertyInfo()
  if not self.RadioProperties[self.CurShowIndex] then
    self.CurShowIndex = 1
    LogicRadio.RemoveRadioPlayListById(self.Id)
    local RadioShowList = LogicRadio.RadioPlayList[1]
    if RadioShowList then
      self.MainRadioPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      if 0 == self.NextInterval then
        self.MainRadioPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self:ShowRadio(RadioShowList.ID, RadioShowList.Params)
      else
        self.NextRadioIntervalTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
          self,
          function(self)
            self.MainRadioPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
            self:ShowRadio(RadioShowList.ID, RadioShowList.Params)
          end
        }, self.NextInterval, false)
      end
    else
      self:HideRadio()
    end
    return
  end
  print("UpdateRadio", self.Id, self.CurShowIndex)
  local CurShowProperty = self.RadioProperties[self.CurShowIndex]
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  print("UpdateRadioName", CurShowProperty.PropertyInfo.Name)
  local Text = self:ReplaceTextByKeyword(CurShowProperty.PropertyInfo.TextContent)
  Text = WaveWindowManager:FormatTextByOrder(Text, self.Params)
  local Name = self:ReplaceTextByKeyword(CurShowProperty.PropertyInfo.Name)
  Name = WaveWindowManager:FormatTextByOrder(Name, self.Params)
  self.Txt_Name:SetText("[" .. tostring(Name) .. "] : ")
  self.Txt_SpeakerName:SetText(Name)
  self.Txt_Content:SetText("<RadioWhite>" .. tostring(Text) .. "</>")
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(CurShowProperty.PropertyInfo.HeadIcon) then
    self.HeadIconPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    SetImageBrushBySoftObject(self.Img_HeadIcon, CurShowProperty.PropertyInfo.HeadIcon)
    SetImageBrushBySoftObject(self.Img_AnimHeadIcon, CurShowProperty.PropertyInfo.HeadIcon)
  else
    self.HeadIconPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local GameState = UE.UGameplayStatics.GetGameState(self)
  local PlayingId = UE.UAudioManager.PlayVoice3DByName(CurShowProperty.PropertyInfo.AudioPath, GameState, self.AudioPriority, "VO_Radio", 1, "WBP_Radio_C:UpdatePropertyInfo")
  self.CurPlayingEventName = CurShowProperty.PropertyInfo.AudioPath
  self.AudioPriority = self.AudioPriority + 1
  print("radioCurPlayingEventName", self.CurPlayingEventName, PlayingId)
  local Duration = CurShowProperty.PropertyInfo.Duration
  if 0 == Duration then
    Duration = self.DefaultRadioDuration
  end
  self.PropertyTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      print("RadioEndByDefaultDuration")
      self:SwitchToNextStepLevel()
    end
  }, Duration, false)
end

function WBP_Radio_C:SwitchToNextStepLevel()
  self.MainRadioPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  local CurShowProperty = self.RadioProperties[self.CurShowIndex]
  self.CurShowIndex = self.CurShowIndex + 1
  local NextShowProperty = self.RadioProperties[self.CurShowIndex]
  LogicRadio.UpdateStartMapRadioProgress(self.Id, self.CurShowIndex + 1)
  if 0 == CurShowProperty.PropertyInfo.NextDelayTime or not NextShowProperty then
    self.MainRadioPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:UpdatePropertyInfo()
  else
    self.PropertyIntervalTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function(self)
        self.MainRadioPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self:UpdatePropertyInfo()
      end
    }, CurShowProperty.PropertyInfo.NextDelayTime, false)
  end
end

function WBP_Radio_C:HideRadio()
  self:StopAllAnimations()
  self:PlayAnimation(self.ani_radio_out, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0)
  self.CurPlayingEventName = ""
  self.IsShow = false
  self.AudioPriority = 0
  PlaySound2DEffect(20002, "WBP_Radio_C:HideRadio")
end

function WBP_Radio_C:OnAnimationFinished(Animation)
  print("WBP_Radio_C:OnAnimationFinished, ", UE.UKismetSystemLibrary.GetDisplayName(self.ani_radio_out))
  if Animation == self.ani_radio_out and not self.IsShow then
    print("HideRadioPanel")
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_Radio_C:Destruct()
  self.IsShow = false
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PropertyTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PropertyTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.PropertyIntervalTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.PropertyIntervalTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.NextRadioIntervalTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.NextRadioIntervalTimer)
  end
  local EmitterManager = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.UEmitterManager:StaticClass())
  if EmitterManager then
    EmitterManager.OnVoiceDuration:Remove(self, self.BindOnVoiceDuration)
  end
  LogicRadio.RadioPlayList = {}
end

return WBP_Radio_C
