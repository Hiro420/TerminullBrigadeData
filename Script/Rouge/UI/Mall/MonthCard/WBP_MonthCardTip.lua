local WBP_MonthCardTip = UnLua.Class()
local MonthCardData = require("Modules.MonthCard.MonthCardData")
local PrivilegeData = require("Modules.Privilege.PrivilegeData")
local PandoraHandler = require("Protocol.Pandora.PandoraHandler")

function WBP_MonthCardTip:Show(RoleId, ParentView)
  self.Btn_MonthCard.OnMainButtonClicked:Add(self, self.OnClickBtnMonthCard)
  self.Btn_Privilege.OnMainButtonClicked:Add(self, self.OnClickBtnPrivilege)
  self.ParentView = ParentView
  local TargetRoleId = RoleId or DataMgr.GetUserId()
  local MonthCardInfo = MonthCardData:GetMonthCardInfoByRoleId(TargetRoleId)
  local PrivilegeInfos = PrivilegeData:GetRolePrivilegeInfo(TargetRoleId)
  local CurTime = GetLocalTimestamp()
  local Index = 1
  if MonthCardInfo then
    for MonthCardId, EndTime in pairs(MonthCardInfo) do
      if CurTime < tonumber(EndTime) then
        local Item = GetOrCreateItem(self.Vertical_MonthCardDesc, Index, self.WBP_MonthCardTipItem:StaticClass())
        Item:Show(MonthCardId, EndTime - CurTime)
        Index = Index + 1
      end
    end
  end
  UpdateVisibility(self.Vertical_MonthCardDesc, Index > 1)
  UpdateVisibility(self.Txt_MonthCard, 1 == Index)
  HideOtherItem(self.Vertical_MonthCardDesc, Index)
  local Index = 1
  local PrivilegeResIdList = {}
  if PrivilegeInfos then
    for PrivilegeId, PrivilegeInfo in pairs(PrivilegeInfos) do
      local PrivilegeResId = PrivilegeData:GetResIdByPrivilegeId(PrivilegeId)
      if table.Contain(PrivilegeResIdList, PrivilegeResId) then
      else
        table.insert(PrivilegeResIdList, PrivilegeResId)
        if CurTime < tonumber(PrivilegeInfo.expireTime) and PrivilegeData:GetPrivilegeIsShow(tonumber(PrivilegeId)) then
          local Item = GetOrCreateItem(self.Vertical_PrivilegeDesc, Index, self.WBP_PrivilegeTipItem:StaticClass())
          Item:Show(PrivilegeId, PrivilegeInfo.expireTime - CurTime, true)
          Index = Index + 1
        end
      end
    end
  end
  UpdateVisibility(self.Txt_Privilege, 1 == Index)
  UpdateVisibility(self.Vertical_PrivilegeDesc, Index > 1)
  HideOtherItem(self.Vertical_PrivilegeDesc, Index)
  self.WBP_CommonTips:ShowTips(self.WBP_CommonTips.TxtTitle)
end

function WBP_MonthCardTip:OnClickBtnMonthCard()
  local LobbyPanelTagName = LogicLobby.GetLabelTagNameByUIName("UI_MonthCardPanel")
  LogicLobby.ChangeLobbyPanelLabelSelected(LobbyPanelTagName)
  if self.ParentView then
    self.ParentView.BindOnMainButtonClicked(self.ParentView)
  end
end

function WBP_MonthCardTip:OnClickBtnPrivilege()
  PandoraHandler.GoPandoraActivity(self.JumpId, "\230\181\139\232\175\149\232\183\179\232\189\172")
  if self.ParentView then
    self.ParentView.BindOnMainButtonClicked(self.ParentView)
  end
end

function WBP_MonthCardTip:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_MonthCardTip
