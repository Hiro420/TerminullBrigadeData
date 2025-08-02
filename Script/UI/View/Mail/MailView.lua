local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local MailHandler = require("Protocol.Mail.MailHandler")
local MailData = require("Modules.Mail.MailData")
local EscKeyName = "PauseGame"
local MailView = Class(ViewBase)

function MailView:OnBindUIInput()
  if not IsListeningForInputAction(self, EscKeyName) then
    ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
  self.WBP_InteractTipWidgetDeleteAll:BindInteractAndClickEvent(self, self.BindOnDeleteReadButtonClicked)
  self.WBP_InteractTipWidgetReadAll:BindInteractAndClickEvent(self, self.BindOnAllReadButtonClicked)
  self.WBP_InteractTipWidgetReceiveAll:BindInteractAndClickEvent(self, self.BindOnAllReceiveButtonClicked)
  self.WBP_InteractTipWidgetDone:BindInteractAndClickEvent(self, self.BindOnReceiveOrDeleteButtonClicked)
end

function MailView:OnUnBindUIInput()
  if IsListeningForInputAction(self, EscKeyName) then
    StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidgetDeleteAll:UnBindInteractAndClickEvent(self, self.BindOnDeleteReadButtonClicked)
  self.WBP_InteractTipWidgetReadAll:UnBindInteractAndClickEvent(self, self.BindOnAllReadButtonClicked)
  self.WBP_InteractTipWidgetReceiveAll:UnBindInteractAndClickEvent(self, self.BindOnAllReceiveButtonClicked)
  self.WBP_InteractTipWidgetDone:UnBindInteractAndClickEvent(self, self.BindOnReceiveOrDeleteButtonClicked)
end

function MailView:BindClickHandler()
  self.MailItemListView.BP_OnItemSelectionChanged:Add(self, self.BindOnMailItemListItemSelectionChanged)
  if self.Btn_SendMail then
    self.Btn_SendMail.OnClicked:Add(self, self.BindOnSendMailButtonClicked)
  end
  self.Btn_AllRead.OnClicked:Add(self, self.BindOnAllReadButtonClicked)
  self.Btn_AllRead.OnHovered:Add(self, self.BindOnAllReadButtonHovered)
  self.Btn_AllRead.OnUnhovered:Add(self, self.BindOnAllReadButtonUnhovered)
  self.Btn_AllReceive.OnClicked:Add(self, self.BindOnAllReceiveButtonClicked)
  self.Btn_AllReceive.OnHovered:Add(self, self.BintOnAllReceiveButtonHovered)
  self.Btn_AllReceive.OnUnhovered:Add(self, self.BindOnAllReceiveButtonUnhovered)
  self.Btn_DeleteRead.OnClicked:Add(self, self.BindOnDeleteReadButtonClicked)
  self.Btn_DeleteRead.OnHovered:Add(self, self.BindOnDeleteReadButtonHovered)
  self.Btn_DeleteRead.OnUnhovered:Add(self, self.BindOnDeleteReadButtonUnhovered)
  self.Btn_ReceiveOrDelete.OnClicked:Add(self, self.BindOnReceiveOrDeleteButtonClicked)
  self.Btn_ReceiveOrDelete.OnHovered:Add(self, self.BindOnReceiveOrDeleteButtonHovered)
  self.Btn_ReceiveOrDelete.OnUnhovered:Add(self, self.BindOnReceiveOrDeleteButtonUnhovered)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, self.BindOnEscKeyPressed)
end

function MailView:BindOnSendMailButtonClicked()
  local Params = {
    request = {
      Detail = {
        content = "this is a test mail!",
        title = "Mail title" .. tostring(table.count(MailData:GetAllMailInfoList()))
      },
      attach = {
        {itemId = "300001", itemNum = 200}
      },
      mailType = "SYSTEM"
    },
    roleId = {
      DataMgr.GetUserId()
    }
  }
  HttpCommunication.Request("dbg/mail/send", Params, {
    self,
    function()
      print("SendMailSuccess!")
    end
  }, {
    self,
    function()
      print("SendMailFail!")
    end
  })
end

function MailView:UnBindClickHandler()
  self.MailItemListView.BP_OnItemSelectionChanged:Remove(self, self.BindOnMailItemListItemSelectionChanged)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.BindOnEscKeyPressed)
end

function MailView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("MailViewModel")
  self:BindClickHandler()
end

function MailView:OnDestroy()
  self:UnBindClickHandler()
end

function MailView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:PlayAnimation(self.Ani_in)
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Add(self, self.BindOnInputMethodChanged)
    local CurrentInputType = CommonInputSubsystem:GetCurrentInputType()
    self:BindOnInputMethodChanged(CurrentInputType)
  end
  EventSystem.AddListener(self, EventDef.Mail.OnMailContentInfoChanged, self.BindOnMailContentInfoChanged)
  EventSystem.AddListener(self, EventDef.Mail.OnUpdateMailReadStatus, self.BindOnUpdateMailReadStatus)
  EventSystem.AddListener(self, EventDef.Mail.OnUpdateMailReceiveAttachmentStatus, self.BindOnUpdateMailReceiveAttachmentStatus)
  MailHandler:RequestGetMailListToServer()
  self.ViewModel:RefreshMailItemList()
  self.AllReadHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.AllReceiveHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.DeleteReadHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ReceiveOrDeleteHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self:PlayAnimation(self.Ani_in)
  LogicRole.ShowOrHideRoleMainHero(false)
end

function MailView:BindOnInputMethodChanged(InputType)
  if InputType == UE.ECommonInputType.Gamepad then
    self.Icon_Receive:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Icon_ReadAll:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Icon_DeleteAll:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Image_ReceiveAll:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.Icon_Receive:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Icon_ReadAll:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Icon_DeleteAll:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_ReceiveAll:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
end

function MailView:ShowEmptyPanel()
  self.MailItemListView:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.NotEmptyListPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.EmptyListPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.OperateButtonPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.DetailInfoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.EmptyDetailInfoPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function MailView:ShowNotEmptyPanel()
  self.NotEmptyListPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.EmptyListPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.MailItemListView:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.OperateButtonPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.DetailInfoPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.EmptyDetailInfoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function MailView:BindOnEscKeyPressed()
  UIMgr:Hide(ViewID.UI_Mail, true)
end

function MailView:BindOnMailItemListItemSelectionChanged(DataObj, IsSelected)
  if not IsSelected then
    return
  end
  local MailInfo = MailData:GetMailInfoById(DataObj.Id)
  if MailInfo.readStatus == EMailReadStatus.UnRead then
    MailHandler:RequestMarkReadToServer({
      DataObj.Id
    })
  end
  local MailContentInfo = MailData:GetMailContentInfoById(DataObj.Id)
  if not MailContentInfo then
    MailHandler:RequestGetContentToServer(DataObj.Id)
    self.DetailInfoPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self:UpdateMailDetailInfoPanel(DataObj.Id)
  end
end

function MailView:UpdateMailDetailInfoPanel(MailId)
  local MailInfo = MailData:GetMailInfoById(MailId)
  local MailContentInfo = MailData:GetMailContentInfoById(MailId)
  self.DetailInfoPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Title:SetText(MailInfo.title)
  self.Txt_Content:SetText(MailContentInfo.content)
  self:UpdateReceiveOrDeleteButtonText()
  self:UpdateMailAttachmentList()
  local RemainTimeSecond = MailInfo.invalidTime - MailInfo.sendTime
  local RemainTimeDay = math.floor(RemainTimeSecond / 86400)
  local DayText = NSLOCTEXT("MailView", "DayText", "{0}\229\164\169")
  self.Txt_RemainTime:SetText(UE.FTextFormat(DayText, RemainTimeDay))
end

function MailView:UpdateMailAttachmentList()
  local CurSelectedItem = self.MailItemListView:BP_GetSelectedItem()
  local MailInfo = MailData:GetMailInfoById(CurSelectedItem.Id)
  if not MailInfo.IsHaveAttachment then
    self.AttachmentList:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.AttachmentList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local AllAttachment = MailInfo.attachment
    local DataObjList = {}
    self.AttachmentList:RecyleAllData()
    for i, SingleAttachmentInfo in ipairs(AllAttachment) do
      local SingleDataObj = self.AttachmentList:GetOrCreateDataObj()
      SingleDataObj.AttachmentInfo = SingleAttachmentInfo
      SingleDataObj.IsReceiveAttachment = MailInfo.IsReceiveAttachment
      table.insert(DataObjList, SingleDataObj)
    end
    self.AttachmentList:SetRGListItems(DataObjList, false, true)
    self:UpdateAttacmentReceiveStatus()
  end
end

function MailView:UpdateAttacmentReceiveStatus()
  local CurSelectedItem = self.MailItemListView:BP_GetSelectedItem()
  local MailInfo = MailData:GetMailInfoById(CurSelectedItem.Id)
  local AllDisplayedEntryWidgets = self.AttachmentList:GetDisplayedEntryWidgets()
  for key, SingleItem in pairs(AllDisplayedEntryWidgets) do
    if SingleItem.SetReceiveStatus then
      SingleItem:SetReceiveStatus(MailInfo.IsReceiveAttachment)
    end
  end
end

function MailView:UpdateReceiveOrDeleteButtonText()
  local CurSelectedItem = self.MailItemListView:BP_GetSelectedItem()
  local MailInfo = MailData:GetMailInfoById(CurSelectedItem.Id)
  UpdateVisibility(self.CanvasPanel_Receive, MailInfo.IsHaveAttachment and not MailInfo.IsReceiveAttachment)
  UpdateVisibility(self.CanvasPanel_Delete, not MailInfo.IsHaveAttachment or not not MailInfo.IsReceiveAttachment)
end

function MailView:BindOnMailContentInfoChanged(MailId)
  local CurSelectedItem = self.MailItemListView:BP_GetSelectedItem()
  if not CurSelectedItem or CurSelectedItem.Id ~= MailId then
    return
  end
  self:UpdateMailDetailInfoPanel(MailId)
end

function MailView:BindOnUpdateMailReadStatus()
  local AllDisplayedEntryWidgets = self.MailItemListView:GetDisplayedEntryWidgets()
  for key, SingleItem in pairs(AllDisplayedEntryWidgets) do
    SingleItem:UpdateReadStatus()
  end
end

function MailView:BindOnUpdateMailReceiveAttachmentStatus()
  local AllDisplayedEntryWidgets = self.MailItemListView:GetDisplayedEntryWidgets()
  for key, SingleItem in pairs(AllDisplayedEntryWidgets) do
    SingleItem:UpdateReceiveAttachmentStatus()
  end
  self:UpdateReceiveOrDeleteButtonText()
  self:UpdateAttacmentReceiveStatus()
  self:RefreshAllReceiveButtonStatus()
end

function MailView:RefreshAllReceiveButtonStatus(...)
  local AllMailInfoList = MailData:GetAllMailInfoList()
  local TargetNotReceiveList = {}
  for MailId, MailInfo in pairs(AllMailInfoList) do
    if MailInfo.IsHaveAttachment and not MailInfo.IsReceiveAttachment then
      table.insert(TargetNotReceiveList, MailId)
    end
  end
  if next(TargetNotReceiveList) == nil then
    self.RGStateController_AllReceiveBtn:ChangeStatus("CanNotReceive")
  else
    self.RGStateController_AllReceiveBtn:ChangeStatus("CanReceive")
  end
end

function MailView:BindOnAllReadButtonClicked()
  local AllMailInfoList = MailData:GetAllMailInfoList()
  local TargetNotReadList = {}
  for MailId, MailInfo in pairs(AllMailInfoList) do
    if MailInfo.readStatus == EMailReadStatus.UnRead then
      table.insert(TargetNotReadList, MailId)
    end
  end
  if next(TargetNotReadList) == nil then
    print("MailView:BindOnAllReadButtonClicked not found UnRead Mails!")
    ShowWaveWindow(self.NotCanMarkReadWaveId)
  else
    MailHandler:RequestMarkReadToServer(TargetNotReadList)
  end
end

function MailView:BindOnAllReadButtonHovered()
  self.AllReadHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function MailView:BindOnAllReadButtonUnhovered()
  self.AllReadHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function MailView:BindOnAllReceiveButtonClicked()
  local AllMailInfoList = MailData:GetAllMailInfoList()
  local TargetNotReceiveList = {}
  local TargetNotReadList = {}
  for MailId, MailInfo in pairs(AllMailInfoList) do
    if MailInfo.IsHaveAttachment and not MailInfo.IsReceiveAttachment then
      table.insert(TargetNotReceiveList, MailId)
      if MailInfo.readStatus == EMailReadStatus.UnRead then
        table.insert(TargetNotReadList, MailId)
      end
    end
  end
  if next(TargetNotReceiveList) == nil then
    print("MailView:BindOnAllReceiveButtonClicked not found UnReceive Mails!")
    ShowWaveWindow(self.NotCanReceiveWaveId)
  else
    MailHandler:RequestReceiveAttachmentToServer(TargetNotReceiveList)
  end
  if next(TargetNotReadList) ~= nil then
    MailHandler:RequestMarkReadToServer(TargetNotReadList)
  end
end

function MailView:BintOnAllReceiveButtonHovered()
  self.AllReceiveHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function MailView:BindOnAllReceiveButtonUnhovered()
  self.AllReceiveHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function MailView:BindOnDeleteReadButtonClicked()
  local AllMailInfoList = MailData:GetAllMailInfoList()
  local TargetDeleteList = {}
  for MailId, MailInfo in pairs(AllMailInfoList) do
    if MailInfo.readStatus == EMailReadStatus.Readed and (not MailInfo.IsHaveAttachment or MailInfo.IsReceiveAttachment) then
      table.insert(TargetDeleteList, MailId)
    end
  end
  if next(TargetDeleteList) == nil then
    print("MailView:BindOnDeleteReadButtonClicked not found Read Mails!")
  elseif 0 == self.ConfirmDeleteAllReadMsgId then
    MailHandler:RequestDeleteToServer(TargetDeleteList)
  else
    local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if WaveWindowManager then
      WaveWindowManager:ShowWaveWindowWithDelegate(self.ConfirmDeleteAllReadMsgId, {}, nil, {
        self,
        function()
          MailHandler:RequestDeleteToServer(TargetDeleteList)
        end
      })
    end
  end
end

function MailView:BindOnDeleteReadButtonHovered()
  self.DeleteReadHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function MailView:BindOnDeleteReadButtonUnhovered()
  self.DeleteReadHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function MailView:BindOnReceiveOrDeleteButtonClicked()
  local CurSelectedItem = self.MailItemListView:BP_GetSelectedItem()
  local MailInfo = MailData:GetMailInfoById(CurSelectedItem.Id)
  if MailInfo.IsHaveAttachment and not MailInfo.IsReceiveAttachment then
    local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
    if UserClickStatisticsMgr then
      UserClickStatisticsMgr:AddClickStatistics("MailReceive")
    end
    MailHandler:RequestReceiveAttachmentToServer({
      CurSelectedItem.Id
    })
  else
    MailHandler:RequestDeleteToServer({
      CurSelectedItem.Id
    })
  end
end

function MailView:BindOnReceiveOrDeleteButtonHovered()
  self.ReceiveOrDeleteHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function MailView:BindOnReceiveOrDeleteButtonUnhovered()
  self.ReceiveOrDeleteHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function MailView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  MailData:ClearAllMailInfoList()
  self.MailItemListView:BP_ClearSelection()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local CommonInputSubsystem = UE.USubsystemBlueprintLibrary.GetLocalPlayerSubsystem(PC, UE.UCommonInputSubsystem:StaticClass())
  if CommonInputSubsystem then
    CommonInputSubsystem.OnInputMethodChanged:Remove(self, self.BindOnInputMethodChanged)
  end
  EventSystem.RemoveListener(EventDef.Mail.OnMailContentInfoChanged, self.BindOnMailContentInfoChanged, self)
  EventSystem.RemoveListener(EventDef.Mail.OnUpdateMailReadStatus, self.BindOnUpdateMailReadStatus, self)
  EventSystem.RemoveListener(EventDef.Mail.OnUpdateMailReceiveAttachmentStatus, self.BindOnUpdateMailReceiveAttachmentStatus, self)
end

return MailView
