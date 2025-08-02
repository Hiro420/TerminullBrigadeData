local MailAwardItemView = UnLua.Class()

function MailAwardItemView:OnListItemObjectSet(DataObj)
  self.DataObj = DataObj
  self.WBP_Item:InitItem(tonumber(DataObj.AttachmentInfo.itemId), DataObj.AttachmentInfo.itemNum)
  self.WBP_Item:ShowSpecialTag(DataObj.AttachmentInfo.itemId)
  self:SetReceiveStatus(DataObj.IsReceiveAttachment)
end

function MailAwardItemView:SetReceiveStatus(IsReceive)
  if IsReceive then
    self.SelectedPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_Item:SetRenderOpacity(self.ReceivedOpacity)
  else
    self.SelectedPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.WBP_Item:SetRenderOpacity(self.NotReceiveOpacity)
  end
end

function MailAwardItemView:GetToolTipWidget()
  if not self.ItemToolTipWidget or not self.ItemToolTipWidget:IsValid() then
    self.ItemToolTipWidget = GetItemDetailWidget(tonumber(self.DataObj.AttachmentInfo.itemId))
  end
  self.ItemToolTipWidget:InitCommonItemDetail(tonumber(self.DataObj.AttachmentInfo.itemId))
  return self.ItemToolTipWidget
end

function MailAwardItemView:BP_OnEntryReleased()
end

return MailAwardItemView
