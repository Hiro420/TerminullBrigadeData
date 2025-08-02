local ChipSeasonSlotUnlockItem = Class()

function ChipSeasonSlotUnlockItem:InitChipSeasonSlotUnlockItem(bUnlock, SlotID)
  UpdateVisibility(self, true)
  self.StateCtrl_Slot:ChangeStatus(tostring(SlotID))
  if bUnlock then
    self.StateCtrl_Lock:ChangeStatus(ELock.UnLock)
  else
    self.StateCtrl_Lock:ChangeStatus(ELock.Lock)
  end
  self:PlayAnimation(self.Ani_Unlock)
end

function ChipSeasonSlotUnlockItem:Hide()
  UpdateVisibility(self, false)
end

function ChipSeasonSlotUnlockItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.StateCtrl_Hover:ChangeStatus(EHover.Hover)
end

function ChipSeasonSlotUnlockItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.StateCtrl_Hover:ChangeStatus(EHover.UnHover)
end

return ChipSeasonSlotUnlockItem
