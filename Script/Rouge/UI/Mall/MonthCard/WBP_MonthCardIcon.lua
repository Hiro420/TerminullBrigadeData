local WBP_MonthCardIcon = UnLua.Class()
local MonthCardData = require("Modules.MonthCard.MonthCardData")
local MonthCardHandler = require("Protocol.MonthCard.MonthCardHandler")
local PrivilegeData = require("Modules.Privilege.PrivilegeData")
local PrivilegeHandler = require("Protocol.Privilege.PrivilegeHandler")

function WBP_MonthCardIcon:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  self.IsShowTips = false
  EventSystem.AddListener(self, EventDef.MonthCard.OnUpdateRolesRivilegeInfo, self.OnUpdateRolesRivilegeInfo)
  EventSystem.AddListener(self, EventDef.Lobby.CloseMonthCardTip, self.CloseCardTips)
end

function WBP_MonthCardIcon:Show(RoleId, IsNeedButtonLogic, IsNeedButtonHoverLogic)
  self.RoleId = RoleId or DataMgr.GetUserId()
  self.IsNeedButtonLogic = IsNeedButtonLogic
  self.IsNeedButtonHoverLogic = IsNeedButtonHoverLogic
  UpdateVisibility(self, true)
  local MonthCardInfo = MonthCardData:GetMonthCardInfoByRoleId(RoleId)
  local HasValidMonthCard = false
  if MonthCardInfo then
    local ValidMonthCardNum = 0
    for MonthCardID, EndTime in pairs(MonthCardInfo) do
      if not MonthCardData:IsMonthCardExpired(self.RoleId, MonthCardID) then
        HasValidMonthCard = true
        ValidMonthCardNum = ValidMonthCardNum + 1
      end
    end
    if ValidMonthCardNum >= MonthCardData:GetMaxMonthCardNum() then
      self.Btn_Main:SetStyle(self.FullUseStyle)
    elseif 0 == ValidMonthCardNum then
      self.Btn_Main:SetStyle(self.EmptyStyle)
      self:StopAnimation(self.Anim_LOOP)
    else
      self.Btn_Main:SetStyle(self.PartUseStyle)
    end
  end
  if not MonthCardData:HasValidMonthCardInfo(self.RoleId) then
    MonthCardHandler:RequestRolesMonthCardInfoToServer({
      self.RoleId
    })
    PrivilegeHandler:RequestRolesPrivilegeInfoToServer({
      self.RoleId
    })
  end
  if not self.IsListen then
    EventSystem.AddListenerNew(EventDef.MonthCard.OnUpdateRolesMonthCardInfo, self, self.BindOnUpdateRolesMonthCardInfo)
    self.IsListen = true
  end
  if PrivilegeData.PrivilegeRoleInfo[RoleId] then
    self:SetPrivilegeAni(RoleId)
  end
end

function WBP_MonthCardIcon:BindOnUpdateRolesMonthCardInfo(RoleIdList)
  if not self.RoleId or not table.Contain(RoleIdList, self.RoleId) then
    return
  end
  self:Show(self.RoleId, self.IsNeedButtonLogic, self.IsNeedButtonHoverLogic)
end

function WBP_MonthCardIcon:BindOnMainButtonClicked(...)
  if not self.IsNeedButtonLogic then
    return
  end
  local HoverTips = self.MonthCardIconTip
  if self.IsShowTips then
    UpdateVisibility(HoverTips, false)
    if self.ParentView and self.ParentView.ClickBG then
      UpdateVisibility(self.ParentView.ClickBG, false)
    end
  else
    self.MonthCardIconTip = ShowCommonTips(nil, self, HoverTips, "/Game/Rouge/UI/Mall/MonthCard/WBP_MonthCardTip.WBP_MonthCardTip", nil, false, self.Offset)
    UpdateVisibility(self.MonthCardIconTip, true)
    self.MonthCardIconTip:Show(self.RoleId, self)
    EventSystem.Invoke(EventDef.Lobby.OpenMonthCardTip)
  end
  self.IsShowTips = not self.IsShowTips
end

function WBP_MonthCardIcon:OnUpdateRolesRivilegeInfo()
  self:Show(self.RoleId, self.IsNeedButtonLogic, self.IsNeedButtonHoverLogic)
end

function WBP_MonthCardIcon:CloseCardTips()
  UpdateVisibility(self.MonthCardIconTip, false)
  self.IsShowTips = false
end

function WBP_MonthCardIcon:BindOnMainButtonHovered(...)
  if not self.IsNeedButtonLogic and not self.IsNeedButtonHoverLogic then
    return
  end
  self.RGStateController_Hover:ChangeStatus("Hover")
end

function WBP_MonthCardIcon:BindOnMainButtonUnhovered(...)
  if not self.IsNeedButtonLogic and not self.IsNeedButtonHoverLogic then
    return
  end
  self.RGStateController_Hover:ChangeStatus("Unhover")
end

function WBP_MonthCardIcon:SetPrivilegeAni(UserId)
  local PrivilegeMaxQuality = PrivilegeData:GetMaxPrivilegeQuality(UserId)
  local AniName = "Anim_Quality_"
  print("WBP_MonthCardIcon  " .. AniName .. PrivilegeMaxQuality)
  self:PlayAnimation(self[AniName .. PrivilegeMaxQuality])
end

function WBP_MonthCardIcon:Hide(...)
  self.RoleId = nil
  UpdateVisibility(self, false)
  EventSystem.RemoveListenerNew(EventDef.MonthCard.OnUpdateRolesMonthCardInfo, self, self.BindOnUpdateRolesMonthCardInfo)
  self.IsListen = false
end

function WBP_MonthCardIcon:Destruct(...)
  self.Btn_Main.OnClicked:Remove(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Remove(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.BindOnMainButtonUnhovered)
  EventSystem.RemoveListener(self, EventDef.MonthCard.OnUpdateRolesRivilegeInfo, self.SetPrivilegeAni)
  EventSystem.RemoveListener(self, EventDef.Lobby.CloseMonthCardTip, self.CloseCardTips)
  self:Hide()
end

return WBP_MonthCardIcon
