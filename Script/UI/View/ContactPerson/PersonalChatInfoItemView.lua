local PersonalChatInfoItemView = UnLua.Class()
function PersonalChatInfoItemView:OnListItemObjectSet(DataObj)
  self.DataObj = DataObj
  if self.DataObj.Info.IsTime then
    self.WBP_PersonalChatTime:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.ChatMsgPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.WBP_PersonalChatTime:Show(self.DataObj.Info.ReceiveTime)
  else
    self.WBP_PersonalChatTime:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ChatMsgPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if self.DataObj.Info.IsReceive then
      self.SelfPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.ChatPartnerPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Txt_PartnerChatInfo:SetText(self.DataObj.Info.Msg)
      self.ChatPartnerHeadItem:InitPlayerInfoHeadIconItem(self.DataObj.PlayerInfo.portrait)
    else
      self.ChatPartnerPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.SelfPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.Txt_SelfChatInfo:SetText(self.DataObj.Info.Msg)
      self.WBP_PlayerInfoHeadIconItem:InitPlayerInfoHeadIconItem(self.DataObj.PlayerInfo.portrait)
    end
  end
end
function PersonalChatInfoItemView:BP_OnEntryReleased()
  self.DataObj = nil
end
function PersonalChatInfoItemView:OnMouseButtonDown(MyGeometry, MouseEvent)
  local MousePosition = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
  UIMgr:Show(ViewID.UI_ContactPersonOperateButtonPanel, nil, MousePosition, self.DataObj.PlayerInfo, EOperateButtonPanelSourceFromType.PrivateChat, self.DataObj.Info.Msg)
  return UE.UWidgetBlueprintLibrary.Handled()
end
return PersonalChatInfoItemView
