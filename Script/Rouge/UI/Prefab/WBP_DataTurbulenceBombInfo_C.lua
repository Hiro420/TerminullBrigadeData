local WBP_DataTurbulenceBombInfo_C = UnLua.Class()
local AnimPlayTime = 3
local CountdownTimeConfig = 10
local Level_Dataflow_Countdown = "Level_Dataflow_Countdown"
local Level_Dataflow_Explosion = "Level_Dataflow_Explosion"

function WBP_DataTurbulenceBombInfo_C:LuaTick(InDeltaTime)
  self:UpdateWidgetPosition()
  if self.CurSegment == UE.ERGDeliverSegment.Segment2 then
    self.CountdownTime = self.CountdownTime - InDeltaTime
    if self.CountdownTime < 0 then
      return
    end
    self.txt_Countdown:SetVisibility(UE.ESlateVisibility.Visible)
    self.txt_Countdown:SetText(math.ceil(self.CountdownTime))
    local CurrentTime = CountdownTimeConfig - self.CountdownTime
    if CurrentTime - self.LastAnimPlayedTime >= 1 then
      self:PlayVoice(Level_Dataflow_Countdown, self.OwningBomb)
      if self.CountdownTime <= AnimPlayTime then
        if self:IsAnimationPlaying(self.Ani_countdown) then
          self:StopAnimation(self.Ani_countdown)
        end
        self:PlayAnimation(self.Ani_countdown)
        if self.CountdownTime <= 3 and not self.IsSpecialAnimPlayed then
          if self:IsAnimationPlaying(self.Ani_countdown_red_in) then
            self:StopAnimation(self.Ani_countdown_red_in)
          end
          self:PlayAnimation(self.Ani_countdown_red_in)
          self.IsSpecialAnimPlayed = true
          self:PlayVoice(Level_Dataflow_Explosion, self.OwningBomb)
        end
      end
      self.LastAnimPlayedTime = CurrentTime
    end
  end
end

function WBP_DataTurbulenceBombInfo_C:Destruct()
  if self.OwningBomb then
    self.OwningBomb.OnDeliverSegmentChange:Remove(self, WBP_DataTurbulenceBombInfo_C.OnSegmentChange)
  end
end

function WBP_DataTurbulenceBombInfo_C:SetOwningBomb(OwningBomb)
  self.OwningBomb = OwningBomb
  self:InitWidget()
end

function WBP_DataTurbulenceBombInfo_C:InitWidget()
  if self.OwningBomb then
    self.OwningBomb.OnDeliverSegmentChange:Remove(self, WBP_DataTurbulenceBombInfo_C.OnSegmentChange)
    self.OwningBomb.OnDeliverSegmentChange:Add(self, WBP_DataTurbulenceBombInfo_C.OnSegmentChange)
    CountdownTimeConfig = self.OwningBomb:GetCountdownTime()
  end
  self.txt_Countdown:SetVisibility(UE.ESlateVisibility.Hidden)
  self:PlayAnimation(self.Ani_in)
  self.CurSegment = UE.ERGDeliverSegment.Segment1
  self.LastAnimPlayedTime = 0
  self.IsSpecialAnimPlayed = false
  self.CountdownTime = 0
end

function WBP_DataTurbulenceBombInfo_C:OnSegmentChange(CurSegment)
  self.CurSegment = CurSegment
  if self.CurSegment == UE.ERGDeliverSegment.Segment1 then
    self.txt_Countdown:SetVisibility(UE.ESlateVisibility.Hidden)
    self:PlayAnimation(self.Ani_in)
  elseif self.CurSegment == UE.ERGDeliverSegment.Segment2 then
    self.IsSpecialAnimPlayed = false
    if self.OwningBomb then
      self.CountdownTime = CountdownTimeConfig
      self.txt_Countdown:SetVisibility(UE.ESlateVisibility.Visible)
      self.txt_Countdown:SetText(math.ceil(self.CountdownTime))
    else
      error("Bombself.OwningBomb is error")
    end
  elseif self.CurSegment == UE.ERGDeliverSegment.Segment3 then
    self.txt_Countdown:SetVisibility(UE.ESlateVisibility.Hidden)
    self:PlayAnimation(self.Ani_forewarn)
  elseif self.CurSegment == UE.ERGDeliverSegment.Segment4 then
    self:PlayAnimation(self.Ani_bang)
  end
end

local MappedRangeValueClamped = function(Value, InMin, InMax, OutMin, OutMax)
  if InMin == InMax then
    error("Input range is invalid (InMin should not be equal to InMax)")
  end
  local normalized = (Value - InMin) / (InMax - InMin)
  local mappedValue = OutMin + (OutMax - OutMin) * normalized
  return math.clamp(mappedValue, OutMin, OutMax)
end

function WBP_DataTurbulenceBombInfo_C:UpdateWidgetPosition()
  local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
  if CameraManager and self.OwningBomb then
    local CameraLocation = CameraManager:GetCameraLocation()
    local OwnerLocation = self.OwningBomb:K2_GetActorLocation()
    local Distance = UE.UKismetMathLibrary.Vector_Distance(CameraLocation, OwnerLocation)
    local TargetDistance = math.clamp(Distance, self.MinDistance, self.MaxDistance)
    local ScaleFactor = MappedRangeValueClamped(TargetDistance, self.MaxDistance, self.MinDistance, self.MinScale, self.MaxScale)
    self:SetRenderScale(UE.FVector2D(ScaleFactor, ScaleFactor))
  end
end

function WBP_DataTurbulenceBombInfo_C:PlayVoice(EventName, Speaker)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if RGSoundSubsystem then
    RGSoundSubsystem:PlaySound3DByName(EventName, Speaker, nil, false, "")
  end
end

return WBP_DataTurbulenceBombInfo_C
