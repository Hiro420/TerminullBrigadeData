local WBP_HUD_ScrollSetLevelItem_C = UnLua.Class()

function WBP_HUD_ScrollSetLevelItem_C:UpdateScrollSetLevelItem(bIsReached, bIsPlayAni, bIsDelay)
  if bIsPlayAni then
    if bIsDelay then
      if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
        self.Timer = nil
      end
      if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
        self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
          self,
          self.PlayAni
        }, 0.23, false)
      end
    else
      self:PlayAnimation(self.ani_HUD_ScrollSetLevelItem_in)
    end
  end
  UpdateVisibility(self.URGImageActivated, bIsReached)
end

function WBP_HUD_ScrollSetLevelItem_C:PlayAni()
  self:PlayAnimation(self.ani_HUD_ScrollSetLevelItem_in)
end

function WBP_HUD_ScrollSetLevelItem_C:Destruct()
  self.Overridden.Destruct(self)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
end

return WBP_HUD_ScrollSetLevelItem_C
