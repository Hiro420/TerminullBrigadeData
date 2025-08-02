local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local LoginData = require("Modules.Login.LoginData")
local EscKeyName = "PauseGame"
local UserAgreementView = Class(ViewBase)

function UserAgreementView:BindClickHandler()
  self.ScrollList.OnUserScrolled:Add(self, self.BindOnUserScrolled)
  self.Btn_Confirm.OnClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.ExitGameKey.OnMainButtonClicked:Add(self, self.BindOnEscKeyPressed)
  if not IsListeningForInputAction(self, EscKeyName) then
    ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
end

function UserAgreementView:UnBindClickHandler()
  self.ScrollList.OnUserScrolled:Remove(self, self.BindOnUserScrolled)
  self.Btn_Confirm.OnClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.ExitGameKey.OnMainButtonClicked:Remove(self, self.BindOnEscKeyPressed)
  if IsListeningForInputAction(self, EscKeyName) then
    StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  end
end

function UserAgreementView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function UserAgreementView:BindOnUserScrolled(CurrentOffset)
  local EndOffset = self.ScrollList:GetScrollOffsetOfEnd()
  local ViewOffsetFraction = self.ScrollList:GetViewOffsetFraction()
  if 1.0 == EndOffset or CurrentOffset >= EndOffset then
    self.Btn_Confirm:SetIsEnabled(true)
  else
    self.Btn_Confirm:SetIsEnabled(false)
  end
end

function UserAgreementView:OnDestroy()
  self:UnBindClickHandler()
end

function UserAgreementView:OnShow(...)
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
end

function UserAgreementView:BindOnConfirmButtonClicked()
  local LoginSaveGameName = LoginData:GetLoginSavedGameName()
  local SaveGameObject
  if not UE.UGameplayStatics.DoesSaveGameExist(LoginSaveGameName, 0) then
    SaveGameObject = UE.UGameplayStatics.CreateSaveGameObject(UE.ULoginSaveGame:StaticClass())
  else
    SaveGameObject = UE.UGameplayStatics.LoadGameFromSlot(LoginSaveGameName, 0)
  end
  SaveGameObject:SetIsAgreeUserAgreement(true)
  UE.UGameplayStatics.SaveGameToSlot(SaveGameObject, LoginSaveGameName, 0)
  UIMgr:Hide(ViewID.UI_UserAgreement)
  UIMgr:Show(ViewID.UI_PrivacyPolicy)
end

function UserAgreementView:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_UserAgreement)
end

function UserAgreementView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

return UserAgreementView
