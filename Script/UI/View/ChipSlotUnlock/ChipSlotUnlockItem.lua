local ChipSlotUnlockItem = Class()
function ChipSlotUnlockItem:InitChipSlotUnlockItem(bUnlock, SlotID, bShowUnlockEff)
  UpdateVisibility(self, true)
  self.StateCtrl_Slot:ChangeStatus(tostring(SlotID))
  if bUnlock then
    self.StateCtrl_Lock:ChangeStatus(ELock.UnLock)
  else
    self.StateCtrl_Lock:ChangeStatus(ELock.Lock)
  end
  if bShowUnlockEff then
    self:PlayAnimation(self.Ani_Unlock)
  end
end
function ChipSlotUnlockItem:Hide()
  UpdateVisibility(self, false)
end
function ChipSlotUnlockItem:OnMouseEnter(MyGeometry, MouseEvent)
  self.StateCtrl_Hover:ChangeStatus(EHover.Hover)
end
function ChipSlotUnlockItem:OnMouseLeave(MyGeometry, MouseEvent)
  self.StateCtrl_Hover:ChangeStatus(EHover.UnHover)
end
return ChipSlotUnlockItem
