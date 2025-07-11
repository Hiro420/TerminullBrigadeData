local WBP_WorldSlot_C = UnLua.Class()
function WBP_WorldSlot_C:Construct()
  self.Button_WorldType.OnClicked:Add(self, WBP_WorldSlot_C.OnClicked_WorldType)
  self.Button_WorldType.OnHovered:Add(self, WBP_WorldSlot_C.OnHovered_WorldType)
  self.Button_WorldType.OnUnhovered:Add(self, WBP_WorldSlot_C.OnUnhovered_WorldType)
end
function WBP_WorldSlot_C:Destruct()
  self.Button_WorldType.OnClicked:Remove(self, WBP_WorldSlot_C.OnClicked_WorldType)
  self.Button_WorldType.OnHovered:Remove(self, WBP_WorldSlot_C.OnHovered_WorldType)
  self.Button_WorldType.OnUnhovered:Remove(self, WBP_WorldSlot_C.OnUnhovered_WorldType)
end
function WBP_WorldSlot_C:OnClicked_WorldType()
  if self.bChoose == true then
    return
  end
  self.ButtonClickedDelegate:Broadcast(self)
  self:ShowButtonChooseState(true)
end
function WBP_WorldSlot_C:OnHovered_WorldType()
  self:ShowButtonHoverState(true)
end
function WBP_WorldSlot_C:OnUnhovered_WorldType()
  self:ShowButtonHoverState(false)
end
function WBP_WorldSlot_C:InitInfo(TableRow)
  self.TableRow = TableRow
  self.TextBlock_WorldName:SetText(TableRow.WorldDisplayName)
  self:LoadWorldTypeIcon(TableRow.SpriteIcon)
  self:CheckSlotUnlock()
  self:CheckButtonDisableState()
end
function WBP_WorldSlot_C:CheckSlotUnlock()
  if self.TableRow.bInitUnLock == false then
    self.bUnlock = false
  else
    self.bUnlock = true
  end
end
function WBP_WorldSlot_C:CheckButtonDisableState()
  if self.bUnlock == false then
    self.Button_WorldType:SetIsEnabled(false)
    self.Image_Unlock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Button_WorldType:SetIsEnabled(true)
    self.Image_Unlock:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_WorldSlot_C:ShowButtonChooseState(Show)
  if Show then
    self.Border_Clicked:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Border_Clicked:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function WBP_WorldSlot_C:ShowButtonHoverState(Show)
  if Show then
    self.Border_Hover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Border_Hover:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
return WBP_WorldSlot_C
