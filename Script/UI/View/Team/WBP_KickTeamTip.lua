local ViewBase = require("Framework.UIMgr.ViewBase")
local WBP_KickTeamTip = Class(ViewBase)
function WBP_KickTeamTip:BindClickHandler()
  self.Btn_TipConfirm.OnClicked:Add(self, self.BindOnConfirmButtonClicked)
  self.Btn_TipCancel.OnClicked:Add(self, self.BindOnCancelButtonClicked)
end
function WBP_KickTeamTip:UnBindClickHandler()
  self.Btn_TipConfirm.OnClicked:Remove(self, self.BindOnConfirmButtonClicked)
  self.Btn_TipCancel.OnClicked:Remove(self, self.BindOnCancelButtonClicked)
end
function WBP_KickTeamTip:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function WBP_KickTeamTip:OnDestroy()
  self:UnBindClickHandler()
end
function WBP_KickTeamTip:OnShow(PlayerInfo)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.PlayerInfo = PlayerInfo
  self.Txt_Name:SetText(PlayerInfo.nickname)
end
function WBP_KickTeamTip:BindOnConfirmButtonClicked()
  LogicTeam.RequestKickTeamMemberToServer(self.PlayerInfo.roleid, self.CheckBox_Prohibt:IsChecked())
  UIMgr:Hide(ViewID.UI_KickTeamTip)
end
function WBP_KickTeamTip:BindOnCancelButtonClicked()
  UIMgr:Hide(ViewID.UI_KickTeamTip)
end
function WBP_KickTeamTip:OnHide()
  self.PlayerInfo = nil
end
return WBP_KickTeamTip
