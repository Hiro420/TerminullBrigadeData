local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local LoginData = require("Modules.Login.LoginData")
local EscKeyName = "PauseGame"
local DrawCardRuleView = Class(ViewBase)
function DrawCardRuleView:BindClickHandler()
  self.ScrollList.OnUserScrolled:Add(self, self.BindOnUserScrolled)
  self.Btn_Confirm.OnClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.ExitGameKey.OnMainButtonClicked:Add(self, self.BindOnEscKeyPressed)
end
function DrawCardRuleView:UnBindClickHandler()
  self.ScrollList.OnUserScrolled:Remove(self, self.BindOnUserScrolled)
  self.Btn_Confirm.OnClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.ExitGameKey.OnMainButtonClicked:Remove(self, self.BindOnEscKeyPressed)
end
function DrawCardRuleView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function DrawCardRuleView:BindOnUserScrolled(CurrentOffset)
  local EndOffset = self.ScrollList:GetScrollOffsetOfEnd()
  local ViewOffsetFraction = self.ScrollList:GetViewOffsetFraction()
  if 1.0 == EndOffset or CurrentOffset >= EndOffset then
    self.Btn_Confirm:SetIsEnabled(true)
  else
    self.Btn_Confirm:SetIsEnabled(false)
  end
end
function DrawCardRuleView:BindOnConfirmButtonClicked()
  local LoginSaveGameName = LoginData:GetLoginSavedGameName()
  local SaveGameObject
  if not UE.UGameplayStatics.DoesSaveGameExist(LoginSaveGameName, 0) then
    SaveGameObject = UE.UGameplayStatics.CreateSaveGameObject(UE.ULoginSaveGame:StaticClass())
  else
    SaveGameObject = UE.UGameplayStatics.LoadGameFromSlot(LoginSaveGameName, 0)
  end
  SaveGameObject:SetIsAgreePrivacyPolicy(true)
  UE.UGameplayStatics.SaveGameToSlot(SaveGameObject, LoginSaveGameName, 0)
  UIMgr:Hide(ViewID.UI_DrawCardRule)
end
function DrawCardRuleView:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_DrawCardRule)
end
function DrawCardRuleView:OnDestroy()
  self:UnBindClickHandler()
end
function DrawCardRuleView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:SetFocus()
  self.ScrollList:ScrollToStart()
  self.Btn_Confirm:SetIsEnabled(false)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function(self)
      self:BindOnUserScrolled(self.ScrollList:GetScrollOffset())
    end
  }, 0.05, false)
  if not IsListeningForInputAction(self, EscKeyName) then
    ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
end
function DrawCardRuleView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if IsListeningForInputAction(self, EscKeyName) then
    StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  end
end
return DrawCardRuleView
