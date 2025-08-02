local WBP_RiftGuardianBarInfo = UnLua.Class()

function WBP_RiftGuardianBarInfo:InitInfo(OwningActor)
  self.WBP_ProgressBar_Shield:InitInfo(OwningActor)
  self.WBP_ProgressBar_HP:InitInfo(OwningActor)
end

function WBP_RiftGuardianBarInfo:LuaTick()
  if self.TimeOffUTCStamp and self.TimeOffUTCStamp > 0 then
    local curtime = GetCurrentTimestamp(true)
    local time = self.TimeOffUTCStamp - curtime
    if time >= 0 then
      local duration = self.TimeOffStamp - self.SpawnTimeStamp
      self.Txt_Countdown:SetText(Format(time, "mm:ss"))
    else
      self.TimeOffUTCStamp = nil
      self.SpawnTimeStamp = nil
      self.Txt_Countdown:SetText(Format(0, "mm:ss"))
    end
  end
end

function WBP_RiftGuardianBarInfo:ShowRift(TimeOffUTCStamp, SpawnTimeStamp, TimeOffStamp)
  self.TimeOffUTCStamp = TimeOffUTCStamp
  self.SpawnTimeStamp = SpawnTimeStamp
  self.TimeOffStamp = TimeOffStamp
end

function WBP_RiftGuardianBarInfo:HideRift()
  self.TimeOffUTCStamp = nil
  self.SpawnTimeStamp = nil
  self.TimeOffStamp = nil
  UpdateVisibility(self.RGCanvasPanel_74, false)
end

return WBP_RiftGuardianBarInfo
