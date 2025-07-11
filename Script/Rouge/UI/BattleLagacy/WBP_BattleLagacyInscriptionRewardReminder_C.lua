local WBP_BattleLagacyInscriptionRewardReminder_C = UnLua.Class()
local SpaceActionName = "Space"
function WBP_BattleLagacyInscriptionRewardReminder_C:Construct()
  self.Overridden.Construct(self)
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Add(self, self.SpaceKeyDown)
  self.Btn_Close.OnClicked:Add(self, self.SpaceKeyDown)
end
function WBP_BattleLagacyInscriptionRewardReminder_C:InitBattleLagacyInscriptionRewardReminder(CurBattleLagacyData, bIsFromSettle)
  local inscriptionId = tonumber(CurBattleLagacyData.BattleLagacyId)
  if inscriptionId > 0 then
    local inscriptionData = GetLuaInscription(inscriptionId)
    if inscriptionData then
      local name = GetInscriptionName(inscriptionId)
      local desc = GetLuaInscriptionDesc(inscriptionId)
      self.RGTextName:SetText(name)
      self.RGTextDesc:SetText(desc)
    end
  end
  if bIsFromSettle then
    self:PlayAnimation(self.Ani_in)
    self.RGTextTitle:SetText(self.TextGetTitle)
  else
    self:PlayAnimation(self.Ani_in2)
    self.RGTextTitle:SetText(self.TextActiveTitle)
  end
end
function WBP_BattleLagacyInscriptionRewardReminder_C:FocusInput()
  self.Overridden.FocusInput(self)
  self:SetFocus(true)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  if not IsListeningForInputAction(self, SpaceActionName) then
    ListenForInputAction(SpaceActionName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.SpaceKeyDown
    })
  end
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_BattleLagacyInscriptionRewardReminder_C:SpaceKeyDown()
  self:StopAnimation(self.Ani_in)
  self:StopAnimation(self.Ani_in2)
  if not self.bIsClose then
    self.bIsClose = true
    self:PlayAnimation(self.Ani_out)
  end
end
function WBP_BattleLagacyInscriptionRewardReminder_C:OnKeyDown(MyGeometry, InKeyEvent)
  self:SpaceKeyDown()
  return self.Overridden.OnKeyDown(self, MyGeometry, InKeyEvent)
end
function WBP_BattleLagacyInscriptionRewardReminder_C:OnAnimationFinished(ani)
  if ani == self.Ani_out then
    EventSystem.Invoke(EventDef.BattleLagacy.OnBattleLagacyInscriptionReminderClose)
    RGUIMgr:CloseUI(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName)
  end
end
function WBP_BattleLagacyInscriptionRewardReminder_C:UnfocusInput()
  SetInputIgnore(self:GetOwningPlayerPawn(), false)
  self:SetEnhancedInputActionBlocking(false)
  if IsListeningForInputAction(self, SpaceActionName) then
    StopListeningForInputAction(self, SpaceActionName, UE.EInputEvent.IE_Pressed)
  end
  self:SetFocus(false)
  self.Overridden.UnfocusInput(self)
end
function WBP_BattleLagacyInscriptionRewardReminder_C:Destruct()
  self.WBP_InteractTipWidget.Btn_Main.OnClicked:Remove(self, self.SpaceKeyDown)
  self.Btn_Close.OnClicked:Remove(self, self.SpaceKeyDown)
  self.Overridden.Destruct(self)
end
function WBP_BattleLagacyInscriptionRewardReminder_C:OnUnDisplay(bIsPlaySound)
  self.bIsClose = false
  self.Overridden.OnUnDisplay(self, bIsPlaySound)
end
return WBP_BattleLagacyInscriptionRewardReminder_C
