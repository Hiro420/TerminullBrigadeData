local WBP_BattleLagacyModifyRewardReminder_C = UnLua.Class()
local SpaceActionName = "Space"

function WBP_BattleLagacyModifyRewardReminder_C:Construct()
  self.Overridden.Construct(self)
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Add(self, self.SpaceKeyDown)
  self.Btn_Close.OnClicked:Add(self, self.SpaceKeyDown)
  self.Btn_ModifyHover.OnClicked:Add(self, self.SpaceKeyDown)
  self.Btn_ModifyHover.OnHovered:Add(self, self.OnHovered)
  self.Btn_ModifyHover.OnUnhovered:Add(self, self.OnUnhovered)
end

function WBP_BattleLagacyModifyRewardReminder_C:InitBattleLagacyModifyRewardReminder(CurBattleLagacyData, bIsFromSettle)
  self:PlayAnimation(self.Ani_in)
  local modifyId = tonumber(CurBattleLagacyData.BattleLagacyId)
  self.WBP_GenericModifyChooseItem:InitGenericModifyChooseItemByBattleLagacyReminder(modifyId)
  if bIsFromSettle then
    self.RGTextTitle:SetText(self.TextGetTitle)
  else
    self.RGTextTitle:SetText(self.TextActiveTitle)
  end
end

function WBP_BattleLagacyModifyRewardReminder_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  if not IsListeningForInputAction(self, SpaceActionName) then
    ListenForInputAction(SpaceActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.SpaceKeyDown
    })
  end
  self:SetFocus(true)
  self:SetEnhancedInputActionBlocking(true)
end

function WBP_BattleLagacyModifyRewardReminder_C:SpaceKeyDown()
  self:StopAnimation(self.Ani_in)
  if not self:IsAnimationPlaying(self.Ani_out) then
    self:PlayAnimation(self.Ani_out)
  end
end

function WBP_BattleLagacyModifyRewardReminder_C:OnHovered()
  self.WBP_GenericModifyChooseItem:OnHovered()
end

function WBP_BattleLagacyModifyRewardReminder_C:OnUnhovered()
  self.WBP_GenericModifyChooseItem:OnUnhovered()
end

function WBP_BattleLagacyModifyRewardReminder_C:OnKeyDown(MyGeometry, InKeyEvent)
  self:SpaceKeyDown()
  return self.Overridden.OnKeyDown(self, MyGeometry, InKeyEvent)
end

function WBP_BattleLagacyModifyRewardReminder_C:OnAnimationFinished(ani)
  if ani == self.Ani_out then
    RGUIMgr:CloseUI(UIConfig.WBP_BattleLagacyModifyRewardReminder_C.UIName)
  end
end

function WBP_BattleLagacyModifyRewardReminder_C:UnfocusInput()
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  self:SetEnhancedInputActionBlocking(false)
  if IsListeningForInputAction(self, SpaceActionName) then
    StopListeningForInputAction(self, SpaceActionName, UE.EInputEvent.IE_Pressed)
  end
  self:SetFocus(false)
  self.Overridden.UnfocusInput(self)
end

function WBP_BattleLagacyModifyRewardReminder_C:Destruct()
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Remove(self, self.SpaceKeyDown)
  self.Btn_Close.OnClicked:Remove(self, self.SpaceKeyDown)
  self.Btn_ModifyHover.OnClicked:Remove(self, self.SpaceKeyDown)
  self.Btn_ModifyHover.OnHovered:Remove(self, self.OnHovered)
  self.Btn_ModifyHover.OnUnhovered:Remove(self, self.OnUnhovered)
  self.Overridden.Destruct(self)
end

return WBP_BattleLagacyModifyRewardReminder_C
