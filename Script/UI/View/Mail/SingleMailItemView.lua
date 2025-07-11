local SingleMailItemView = UnLua.Class()
local MailData = require("Modules.Mail.MailData")
function SingleMailItemView:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
end
function SingleMailItemView:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Mail.OnChangeMailItemSelected, self.DataObj)
end
function SingleMailItemView:BindOnMainButtonHovered()
  self.HoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function SingleMailItemView:BindOnMainButtonUnhovered()
  self.HoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function SingleMailItemView:OnListItemObjectSet(DataObj)
  self.MailId = DataObj.Id
  self.DataObj = DataObj
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.MailId)
  self:UpdateReadStatus()
  self:UpdateReceiveAttachmentStatus()
  self.Txt_Title:SetText(MailInfo.title)
  if MailInfo.IsHaveAttachment then
    self.Img_Gift:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Gift:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self:BP_OnItemSelectionChanged(false)
  local DateTimeStr = os.date("%Y-%m-%d", MailInfo.sendTime)
  self.Txt_SendTime:SetText(DateTimeStr)
end
function SingleMailItemView:UpdateReadStatus()
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  local IconSoftObj
  if MailInfo.readStatus == EMailReadStatus.Readed then
    IconSoftObj = self.ReadedIconBrush
    UpdateVisibility(self.CanvasPanel_UnReadFlag, false)
    if not MailInfo.IsHaveAttachment then
      self.WBP_RedDotView:ChangeNum(-1)
    end
  elseif MailInfo.readStatus == EMailReadStatus.UnRead then
    IconSoftObj = self.UnReadIconBrush
    UpdateVisibility(self.CanvasPanel_UnReadFlag, true)
  end
  SetImageBrushBySoftObject(self.Img_ReadStatus, IconSoftObj, self.ReadIconSize)
  self:RefreshBottomColorAndOpacity()
  self:RefreshTitleAndSendTimeColorAndOpacity()
  self:RefreshFrameImgVis()
end
function SingleMailItemView:UpdateReceiveAttachmentStatus()
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  if MailInfo.IsHaveAttachment and MailInfo.IsReceiveAttachment then
    self.WBP_RedDotView:ChangeNum(-1)
  end
  self:RefreshBottomColorAndOpacity()
  self:RefreshGitColorAndOpacity()
  self:RefreshReadStatusColorAndOpacity()
  self:RefreshTitleAndSendTimeColorAndOpacity()
  self:RefreshFrameImgVis()
end
function SingleMailItemView:RefreshGitColorAndOpacity(...)
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  if MailInfo.IsHaveAttachment then
    if MailInfo.IsReceiveAttachment then
      self.Img_Gift:SetColorAndOpacity(self.ReceivedGiftColor)
    elseif self.IsSelected then
      self.Img_Gift:SetColorAndOpacity(self.SelectedGiftColor)
    else
      self.Img_Gift:SetColorAndOpacity(self.UnSelectedGiftColor)
    end
  end
end
function SingleMailItemView:RefreshReadStatusColorAndOpacity(...)
  self.Img_ReadStatus:SetColorAndOpacity(self.NormalReadStatusColor)
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  if MailInfo.IsHaveAttachment and MailInfo.IsReceiveAttachment and not self.IsSelected then
    self.Img_ReadStatus:SetColorAndOpacity(self.ReceivedReadStatusColor)
  end
end
function SingleMailItemView:RefreshTitleAndSendTimeColorAndOpacity(...)
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  if self.IsSelected then
    self.Txt_Title:SetColorAndOpacity(self.SelectedTitleColor)
    self.Txt_SendTime:SetColorAndOpacity(self.SelectedTimeColor)
  elseif MailInfo.IsHaveAttachment then
    if MailInfo.IsReceiveAttachment then
      self.Txt_Title:SetColorAndOpacity(self.ReceivedTitleColor)
      self.Txt_SendTime:SetColorAndOpacity(self.ReceivedTimeColor)
    else
      self.Txt_Title:SetColorAndOpacity(self.UnSelectedTitleColor)
      self.Txt_SendTime:SetColorAndOpacity(self.UnSelectedTimeColor)
    end
  elseif MailInfo.readStatus == EMailReadStatus.Readed then
    self.Txt_Title:SetColorAndOpacity(self.ReceivedTitleColor)
    self.Txt_SendTime:SetColorAndOpacity(self.ReceivedTimeColor)
  else
    self.Txt_Title:SetColorAndOpacity(self.UnSelectedTitleColor)
    self.Txt_SendTime:SetColorAndOpacity(self.UnSelectedTimeColor)
  end
end
function SingleMailItemView:RefreshBottomColorAndOpacity(...)
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  if MailInfo.IsHaveAttachment then
    if MailInfo.IsReceiveAttachment then
      self.Img_Bottom:SetColorAndOpacity(self.ReceivedBottomColor)
    else
      self.Img_Bottom:SetColorAndOpacity(self.UnReceivedBottomColor)
    end
  elseif MailInfo.readStatus == EMailReadStatus.Readed then
    self.Img_Bottom:SetColorAndOpacity(self.ReceivedBottomColor)
  else
    self.Img_Bottom:SetColorAndOpacity(self.UnReceivedBottomColor)
  end
end
function SingleMailItemView:RefreshFrameImgVis(...)
  local MailInfo = MailData:GetMailInfoById(self.MailId)
  if self.IsSelected then
    UpdateVisibility(self.Img_kuang, false)
  elseif MailInfo.IsHaveAttachment and MailInfo.IsReceiveAttachment or not MailInfo.IsHaveAttachment and MailInfo.readStatus == EMailReadStatus.Readed then
    UpdateVisibility(self.Img_kuang, false)
  else
    UpdateVisibility(self.Img_kuang, true)
  end
end
function SingleMailItemView:BP_OnEntryReleased()
  self.MailId = ""
  self.DataObj = nil
end
function SingleMailItemView:BP_OnItemSelectionChanged(IsSelected)
  self.IsSelected = IsSelected
  self:RefreshGitColorAndOpacity()
  self:RefreshReadStatusColorAndOpacity()
  self:RefreshTitleAndSendTimeColorAndOpacity()
  self:RefreshFrameImgVis()
  if IsSelected then
    self.Img_Select:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_Select:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
return SingleMailItemView
