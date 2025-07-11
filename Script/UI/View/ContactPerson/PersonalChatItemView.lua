local PersonalChatItemView = UnLua.Class()
local ContactPersonData = require("Modules.ContactPerson.ContactPersonData")
function PersonalChatItemView:Construct()
  self.Btn_Close.OnClicked:Add(self, self.BindOnCloseButtonClicked)
end
function PersonalChatItemView:BindOnCloseButtonClicked()
  self:PlayAnimationForward(self.Ani_Friend_Out)
end
function PersonalChatItemView:OnAnimationFinished(InAnimation)
  if InAnimation == self.Ani_Friend_Out then
    EventSystem.Invoke(EventDef.ContactPerson.OnRemovePersonalChatInfo, self.DataObj.Info.PlayerInfo.roleid)
  end
end
function PersonalChatItemView:OnListItemObjectSet(DataObj)
  self.DataObj = DataObj
  self:PlayAnimationForward(self.Ani_Friend_In)
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(self.DataObj.Info.PlayerInfo.roleid))
  local NameText = self.DataObj.Info.PlayerInfo.nickname
  local FriendInfo = ContactPersonData:GetFriendInfoById(self.DataObj.Info.PlayerInfo.roleid)
  if FriendInfo and not UE.UKismetStringLibrary.IsEmpty(FriendInfo.remarkName) then
    NameText = NameText .. "(" .. FriendInfo.remarkName .. ")"
  end
  self.Txt_Name:SetText(NameText)
  self.WBP_PlayerInfoHeadIconItem:InitPlayerInfoHeadIconItem(self.DataObj.Info.PlayerInfo.portrait)
  self.HoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.SelectedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:RefreshChatMsg()
  EventSystem.AddListener(self, EventDef.ContactPerson.OnPersonalChatInfoUpdate, self.BindOnPersonalChatInfoUpdate)
end
function PersonalChatItemView:BindOnPersonalChatInfoUpdate(RoleId)
  if self.DataObj.Info.PlayerInfo.roleid ~= RoleId then
    return
  end
  self:RefreshChatMsg()
  if self.IsSelected then
    self.WBP_RedDotView:SetNum(0)
  end
end
function PersonalChatItemView:RefreshChatMsg()
  local LastChatInfo
  for index, SingleChatInfo in ipairs(self.DataObj.Info.ChatInfo) do
    LastChatInfo = SingleChatInfo
  end
  if LastChatInfo and next(LastChatInfo) ~= nil then
    self.Txt_ChatMsg:SetText(LastChatInfo.Msg)
  else
    self.Txt_ChatMsg:SetText("")
  end
end
function PersonalChatItemView:OnMouseEnter()
  self.HoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function PersonalChatItemView:OnMouseLeave()
  self.HoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function PersonalChatItemView:BP_OnItemSelectionChanged(IsSelected)
  self.IsSelected = IsSelected
  if IsSelected then
    self.SelectedPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_RedDotView:SetNum(0)
  else
    self.SelectedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function PersonalChatItemView:BP_OnEntryReleased()
  self.DataObj = nil
  self.IsSelected = false
  EventSystem.RemoveListener(EventDef.ContactPerson.OnPersonalChatInfoUpdate, self.BindOnPersonalChatInfoUpdate, self)
end
return PersonalChatItemView
