local EMailType = {
  Invalid = "INVALID",
  System = "SYSTEM",
  Notice = "NOTICE"
}
_G.EMailType = EMailType
local EMailReadStatus = {
  Invalid = "INVALID",
  UnRead = "UNREAD",
  Readed = "READED"
}
_G.EMailReadStatus = EMailReadStatus
local MailData = {
  AllMailInfoList = {},
  MailContentInfoList = {}
}

function MailData:SetAllMailInfoList(InMailInfoList)
  MailData.AllMailInfoList = {}
  local Result, RowInfo = false
  for index, SingleMailInfo in ipairs(InMailInfoList) do
    if SingleMailInfo.templateID > 0 then
      Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemMail, SingleMailInfo.templateID)
      if not Result then
        print("MailData:SetAllMailInfoList Invalid Mail Template!", SingleMailInfo.templateID)
      else
        SingleMailInfo.title = RowInfo.Title
        local AttachmentList = {}
        for index, SingleAttachInfo in ipairs(RowInfo.Attachlist) do
          local TempValue = {
            itemId = SingleAttachInfo.key,
            itemNum = SingleAttachInfo.value
          }
          table.insert(AttachmentList, TempValue)
        end
        for index, SingleAttachInfo in ipairs(SingleMailInfo.attachment) do
          local TempValue = {
            itemId = SingleAttachInfo.itemId,
            itemNum = SingleAttachInfo.itemNum
          }
          table.insert(AttachmentList, TempValue)
        end
        SingleMailInfo.attachment = AttachmentList
        local MailContentInfo = {
          attachment = AttachmentList,
          content = RowInfo.Content,
          id = SingleMailInfo.id
        }
        MailData:SetMailContentInfoList(MailContentInfo)
      end
    end
    SingleMailInfo.IsReceiveAttachment = tonumber(SingleMailInfo.recvTime) > 0
    SingleMailInfo.IsHaveAttachment = table.count(SingleMailInfo.attachment) > 0
    MailData.AllMailInfoList[SingleMailInfo.id] = SingleMailInfo
  end
end

function MailData:GetAllMailInfoList()
  return MailData.AllMailInfoList
end

function MailData:ClearAllMailInfoList()
  MailData.AllMailInfoList = {}
end

function MailData:GetMailInfoById(MailId)
  return MailData.AllMailInfoList[MailId]
end

function MailData:RemoveMailInfoByMailId(MailId)
  MailData.AllMailInfoList[MailId] = nil
  MailData.MailContentInfoList[MailId] = nil
end

function MailData:MarkMailReaded(MailIdList)
  local MailInfo
  for key, SingleMailId in ipairs(MailIdList) do
    MailInfo = MailData.AllMailInfoList[SingleMailId]
    if MailInfo then
      MailInfo.readStatus = EMailReadStatus.Readed
    end
  end
  EventSystem.Invoke(EventDef.Mail.OnUpdateMailReadStatus)
end

function MailData:MarkMailReceived(MailIdList)
  local MailInfo
  for key, SingleMailId in ipairs(MailIdList) do
    MailInfo = MailData.AllMailInfoList[SingleMailId]
    if MailInfo then
      MailInfo.IsReceiveAttachment = true
    end
  end
  EventSystem.Invoke(EventDef.Mail.OnUpdateMailReceiveAttachmentStatus)
end

function MailData:SetMailContentInfoList(InMailContentInfo)
  MailData.MailContentInfoList[InMailContentInfo.id] = InMailContentInfo
end

function MailData:GetMailContentInfoById(MailId)
  return MailData.MailContentInfoList[MailId]
end

return MailData
