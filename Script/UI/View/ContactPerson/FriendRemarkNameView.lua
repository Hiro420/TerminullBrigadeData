local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local ContactPersonHandler = require("Protocol.ContactPerson.ContactPersonHandler")
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
local FriendRemarkNameView = Class(ViewBase)
local EscKeyName = "PauseGame"

function FriendRemarkNameView:BindClickHandler()
  self.Btn_Exit.OnClicked:Add(self, self.BindOnExitButtonClicked)
  self.Btn_Confirm.OnClicked:Add(self, self.BindOnConfirmButtonClicked)
  if self.WBP_InteractTipWidget then
    self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.BindOnEscKeyPressed)
  end
end

function FriendRemarkNameView:UnBindClickHandler()
  self.Btn_Exit.OnClicked:Remove(self, self.BindOnExitButtonClicked)
  self.Btn_Confirm.OnClicked:Remove(self, self.BindOnConfirmButtonClicked)
  if self.WBP_InteractTipWidget then
    self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.BindOnEscKeyPressed)
  end
end

function FriendRemarkNameView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function FriendRemarkNameView:OnDestroy()
  self:UnBindClickHandler()
end

function FriendRemarkNameView:OnShow(PlayerInfo)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.PlayerInfo = PlayerInfo
  EventSystem.AddListener(self, EventDef.ContactPerson.OnRemarkNameSuccess, self.BindOnRemarkNameSuccess)
  if not IsListeningForInputAction(self, EscKeyName) then
    ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
  self:PushInputAction()
  self.Edit_RemarkName:SetText("")
  self:SetEnhancedInputActionPriority(1)
  self:SetEnhancedInputActionBlocking(true)
end

function FriendRemarkNameView:OnRollback()
  self:SetEnhancedInputActionPriority(1)
  self:SetEnhancedInputActionBlocking(true)
end

function FriendRemarkNameView:OnHideByOther()
  self:SetEnhancedInputActionPriority(0)
  self:SetEnhancedInputActionBlocking(false)
end

function FriendRemarkNameView:BindOnExitButtonClicked()
  UIMgr:Hide(ViewID.UI_FriendRemarkName)
end

function FriendRemarkNameView:BindOnConfirmButtonClicked()
  local TargetRemarkName = tostring(self.Edit_RemarkName:GetText())
  local FriendInfo = ContactPersonData:GetFriendInfoById(self.PlayerInfo.roleid)
  if UE.UKismetStringLibrary.IsEmpty(TargetRemarkName) and (not FriendInfo or UE.UKismetStringLibrary.IsEmpty(FriendInfo.remarkName)) then
    UIMgr:Hide(ViewID.UI_FriendRemarkName)
    return
  end
  local StrLength = UE.UKismetStringLibrary.Len(TargetRemarkName)
  if StrLength > 7 then
    print("\230\150\135\230\156\172\232\182\133\232\191\1357\228\184\170\229\173\151")
    if 0 ~= self.TextOutNumberWaveId then
      ShowWaveWindow(self.TextOutNumberWaveId, {})
    end
    return
  end
  ContactPersonHandler:RequestRemarkNameToServer(self.PlayerInfo.roleid, TargetRemarkName)
end

function FriendRemarkNameView:BindOnRemarkNameSuccess()
  UIMgr:Hide(ViewID.UI_FriendRemarkName)
end

function FriendRemarkNameView:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_FriendRemarkName)
end

function FriendRemarkNameView:OnHide()
  self.FriendInfo = nil
  EventSystem.RemoveListener(EventDef.ContactPerson.OnRemarkNameSuccess, self.BindOnRemarkNameSuccess, self)
  if IsListeningForInputAction(self, EscKeyName) then
    StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  end
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:SetEnhancedInputActionPriority(0)
  self:SetEnhancedInputActionBlocking(false)
end

return FriendRemarkNameView
