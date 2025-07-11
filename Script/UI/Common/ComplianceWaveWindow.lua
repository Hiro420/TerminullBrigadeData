local SelectType = {UnderSixteen = 13, UnderEighteen = 17}
local ViewBase = require("Framework.UIMgr.ViewBase")
local TopupData = require("Modules.Topup.TopupData")
local ComplianceWaveWindow = Class(ViewBase)
function ComplianceWaveWindow:BindClickHandler()
  self.CheckBox_IsUnderSixteen.OnCheckStateChanged:Add(self, self.BindOnUnderSixteenCheckStateChanged)
  self.CheckBox_IsUnderEighteen.OnCheckStateChanged:Add(self, self.BindOnUnderEighteenCheckStateChanged)
end
function ComplianceWaveWindow:BindOnUnderSixteenCheckStateChanged(IsChecked)
  if IsChecked then
    self.SelectIndex = SelectType.UnderSixteen
    self.CheckBox_IsUnderEighteen:SetIsChecked(false)
  elseif self.CheckBox_IsUnderEighteen:IsChecked() then
    self.SelectIndex = SelectType.UnderEighteen
  else
    self.SelectIndex = nil
  end
end
function ComplianceWaveWindow:BindOnUnderEighteenCheckStateChanged(IsChecked)
  if IsChecked then
    self.SelectIndex = SelectType.UnderEighteen
    self.CheckBox_IsUnderSixteen:SetIsChecked(false)
  elseif self.CheckBox_IsUnderSixteen:IsChecked() then
    self.SelectIndex = SelectType.UnderSixteen
  else
    self.SelectIndex = nil
  end
end
function ComplianceWaveWindow:UnBindClickHandler()
  self.CheckBox_IsUnderSixteen.OnCheckStateChanged:Remove(self, self.BindOnUnderSixteenCheckStateChanged)
  self.CheckBox_IsUnderEighteen.OnCheckStateChanged:Remove(self, self.BindOnUnderEighteenCheckStateChanged)
end
function ComplianceWaveWindow:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function ComplianceWaveWindow:OnDestroy()
  self:UnBindClickHandler()
end
function ComplianceWaveWindow:OnShow(...)
  self.IsClosing = false
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if not IsListeningForInputAction(self, "PauseGame") then
    ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
      self,
      ComplianceWaveWindow.CloseSelf
    })
  end
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.CloseSelf)
  self.Btn_Cancel.OnMainButtonClicked:Add(self, self.CloseSelf)
  self.Btn_Confirm.OnMainButtonClicked:Add(self, self.SelectAge)
  if not self.WBP_CommonTipBg:IsAnimationPlaying(self.WBP_CommonTipBg.Ani_in) then
    self.WBP_CommonTipBg:PlayAnimation(self.WBP_CommonTipBg.Ani_in, 0)
  end
  self.CheckBox_IsUnderSixteen:SetIsChecked(false)
  self.CheckBox_IsUnderEighteen:SetIsChecked(false)
  self.SelectIndex = nil
end
function ComplianceWaveWindow:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.CloseSelf)
  self.Btn_Cancel.OnMainButtonClicked:Remove(self, self.CloseSelf)
  self.Btn_Confirm.OnMainButtonClicked:Remove(self, self.SelectAge)
end
function ComplianceWaveWindow:CloseSelf()
  if self.IsClosing then
    return
  end
  self.IsClosing = true
  UIMgr:Hide(ViewID.UI_ComplianceWaveWindow)
end
function ComplianceWaveWindow:SelectAge()
  if not self.SelectIndex then
    ShowWaveWindow(220001)
    return
  end
  TopupData:SetTopupAge(self.SelectIndex, true, true)
  self:CloseSelf()
end
function ComplianceWaveWindow:Destruct()
end
return ComplianceWaveWindow
