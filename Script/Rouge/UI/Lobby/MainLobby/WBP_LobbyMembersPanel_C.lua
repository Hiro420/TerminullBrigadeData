local WBP_LobbyMembersPanel_C = UnLua.Class()

function WBP_LobbyMembersPanel_C:Construct()
  local AllChildren = self.HorizontalBox_MemberSlot:GetAllChildren()
  for key, SingleWidget in pairs(AllChildren) do
    SingleWidget:Hide()
  end
end

function WBP_LobbyMembersPanel_C:Show()
  if self.IsShow then
    return
  end
  self.IsShow = true
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateRoomMembersInfo)
end

function WBP_LobbyMembersPanel_C:Hide()
  if self.IsShow ~= nil and not self.IsShow then
    return
  end
  self.IsShow = false
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateRoomMembersInfo, self.BindOnUpdateRoomMembersInfo)
end

function WBP_LobbyMembersPanel_C:UpdateSingleMemberState()
end

function WBP_LobbyMembersPanel_C:UpdateRoomMemberState()
end

function WBP_LobbyMembersPanel_C:BindOnUpdateRoomMembersInfo(PlayerInfoList)
  local Widget
  local WidgetClass = self.MemberSlotTemplate:StaticClass()
  local Margin = UE.FMargin()
  Margin.Right = 5
  local slot
  local Index = 0
  for i, SinglePlayerInfo in ipairs(PlayerInfoList) do
    if SinglePlayerInfo.roleid ~= DataMgr.GetUserId() then
      Widget = self.HorizontalBox_MemberSlot:GetChildAt(Index)
      if not Widget then
        Widget = UE.UWidgetBlueprintLibrary.Create(self, WidgetClass, self:GetOwningPlayer())
        if Widget then
          slot = self.HorizontalBox_MemberSlot:AddChild(Widget)
          slot:SetPadding(Margin)
        end
      end
      Widget:Show(SinglePlayerInfo)
      Index = Index + 1
    end
  end
  local Length = table.count(PlayerInfoList) - 1
  local AllChildren = self.HorizontalBox_MemberSlot:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    if i > Length then
      SingleItem:Hide()
    end
  end
end

function WBP_LobbyMembersPanel_C:ClearAllMemberIcon(ClearIcon)
  for key, value in iterator(self.HorizontalBox_MemberSlot:GetAllChildren()) do
    value:ShowMemberIcon(false)
    if ClearIcon then
      value.IconObj = nil
    end
  end
end

return WBP_LobbyMembersPanel_C
