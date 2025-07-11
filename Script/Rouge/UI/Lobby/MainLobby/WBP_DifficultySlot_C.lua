local WBP_DifficultySlot_C = UnLua.Class()
function WBP_DifficultySlot_C:Construct()
  self.ButtonWithSound_Difficulty.OnClicked:Add(self, WBP_DifficultySlot_C.OnClicked_Difficulty)
end
function WBP_DifficultySlot_C:Destruct()
  self.ButtonWithSound_Difficulty.OnClicked:Remove(self, WBP_DifficultySlot_C.OnClicked_Difficulty)
end
function WBP_DifficultySlot_C:OnClicked_Difficulty()
  if self.bChoose == true then
    return
  end
  self.ButtonClickedDelegate:Broadcast(self)
  self:ShowButtonChooseState(true)
end
function WBP_DifficultySlot_C:InitInfo(TableRow)
  self.TableRow = TableRow
  self.TextBlock_DifficultyName:SetText(TableRow.DifficultyDisplayName)
  self:CheckSlotUnlock()
  self:CheckTextColor()
end
function WBP_DifficultySlot_C:CheckSlotUnlock()
  if self.TableRow.bInitUnLock == false then
    self.bUnlock = false
  else
    self.bUnlock = true
  end
end
function WBP_DifficultySlot_C:CheckTextColor()
  if self.bUnlock == false then
    self.TextBlock_DifficultyName:SetColorAndOpacity(self.LockColor)
    self.ButtonWithSound_Difficulty:SetIsEnabled(false)
  else
    self.TextBlock_DifficultyName:SetColorAndOpacity(self.UnlockColor)
    self.ButtonWithSound_Difficulty:SetIsEnabled(true)
  end
  if self.bChoose == true then
    self.TextBlock_DifficultyName:SetColorAndOpacity(self.ChooseColor)
    self.ButtonWithSound_Difficulty:SetIsEnabled(true)
  end
end
function WBP_DifficultySlot_C:ShowButtonChooseState(Show)
  if Show then
    self.Image_Choose:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_ChooseTop:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.bChoose = true
  else
    self.Image_Choose:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_ChooseTop:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.bChoose = false
  end
  self:CheckTextColor()
end
return WBP_DifficultySlot_C
