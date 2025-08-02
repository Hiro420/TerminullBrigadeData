local rapidjson = require("rapidjson")
local MailData = require("Modules.Mail.MailData")
local MailHandler = {}
local ProtocolInterval = 2.0
local MailExpiredErrorCode = 16004

function MailHandler:RequestCheckToServer()
  HttpCommunication.Request("mail/check", {}, {
    GameInstance,
    function()
      print("Check Mail Success!")
      MailHandler:RequestGetMailListToServer()
    end
  }, {
    GameInstance,
    function()
      print("Check Mail fail!")
    end
  })
end

function MailHandler:RequestDeleteToServer(MailIdList)
  if MailHandler.LastRequestDeleteTime and GetCurrentUTCTimestamp() - MailHandler.LastRequestDeleteTime < ProtocolInterval then
    print("MailHandler:RequestDeleteToServer \229\164\132\228\186\142\229\143\145\233\128\129\229\141\143\232\174\174\233\151\180\233\154\148\228\184\173")
    return
  end
  MailHandler.LastRequestDeleteTime = GetCurrentUTCTimestamp()
  HttpCommunication.Request("mail/delete", {id = MailIdList}, {
    GameInstance,
    function()
      print("Delete Mail Success!")
      MailHandler:RequestGetMailListToServer()
    end
  }, {
    GameInstance,
    function()
      print("Delete Mail Fail!")
    end
  })
end

function MailHandler:RequestGetContentToServer(MailId)
  local Path = "mail/getcontent?id=" .. MailId
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      print("GetContent Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      MailData:SetMailContentInfoList(JsonTable)
      EventSystem.Invoke(EventDef.Mail.OnMailContentInfoChanged, MailId)
    end
  }, {
    GameInstance,
    function(Target, HttpError)
      print("GetContent fail!", HttpError.ErrorCode)
      if HttpError.ErrorCode == MailExpiredErrorCode then
        MailData:RemoveMailInfoByMailId(MailId)
        EventSystem.Invoke(EventDef.Mail.OnUpdateAllMailListInfo)
      end
    end
  })
end

function MailHandler:RequestGetMailListToServer(MailType, ReadType)
  MailType = MailType or 0
  ReadType = ReadType or 0
  local Path = "mail/list?mailType=" .. MailType .. "&readType=" .. ReadType .. "&pageNum=0&pageSize=0&currId=0"
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      print("GetMailList Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      MailData:SetAllMailInfoList(JsonTable.mails)
      EventSystem.Invoke(EventDef.Mail.OnUpdateAllMailListInfo)
    end
  }, {
    GameInstance,
    function()
      print("GetMailList fail!")
    end
  })
end

function MailHandler:RequestMarkReadToServer(MailIdList)
  if MailHandler.LastRequestMarkReadTime and GetCurrentUTCTimestamp() - MailHandler.LastRequestMarkReadTime < ProtocolInterval then
    print("MailHandler:RequestMarkReadToServer \229\164\132\228\186\142\229\143\145\233\128\129\229\141\143\232\174\174\233\151\180\233\154\148\228\184\173")
    return
  end
  MailHandler.LastRequestMarkReadTime = GetCurrentUTCTimestamp()
  HttpCommunication.Request("mail/markread", {id = MailIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("Mark Mail Read Success!")
      MailData:MarkMailReaded(MailIdList)
    end
  }, {
    GameInstance,
    function()
      print("Mark Mail Read Fail!")
    end
  })
end

function MailHandler:RequestReceiveAttachmentToServer(MailIdList)
  if MailHandler.LastRequestReceiveAttachmentTime and GetCurrentUTCTimestamp() - MailHandler.LastRequestReceiveAttachmentTime < ProtocolInterval then
    print("MailHandler:RequestReceiveAttachmentToServer \229\164\132\228\186\142\229\143\145\233\128\129\229\141\143\232\174\174\233\151\180\233\154\148\228\184\173")
    return
  end
  MailHandler.LastRequestReceiveAttachmentTime = GetCurrentUTCTimestamp()
  local OnConfirmClick = function(optionalGiftInfos)
    if optionalGiftInfos then
      if self.OptionalGiftInfos == nil then
        self.OptionalGiftInfos = {}
      end
      for index, GiftInfo in ipairs(optionalGiftInfos) do
        table.insert(self.OptionalGiftInfos, GiftInfo)
      end
    end
    if self.OptionalGiftInfos ~= nil and 0 == #self.OptionalGiftInfos then
      self.OptionalGiftInfos = nil
    end
    HttpCommunication.Request("mail/recvattachment", {
      id = MailIdList,
      optionalGiftInfos = self.OptionalGiftInfos
    }, {
      GameInstance,
      function(Target, JsonResponse)
        print("Mail Receive Attachment Success!")
        self.OptionalGiftInfos = {}
        MailData:MarkMailReceived(MailIdList)
      end
    })
  end
  
  local function ShowOptionalGiftQueueWindow(optionalGiftInfos)
    if optionalGiftInfos then
      if self.OptionalGiftInfos == nil then
        self.OptionalGiftInfos = {}
      end
      for index, GiftInfo in ipairs(optionalGiftInfos) do
        table.insert(self.OptionalGiftInfos, GiftInfo)
      end
    end
    for key, value in pairs(self.OptionalGiftIdTable) do
      local Table = {}
      Table[key] = value
      if table.count(self.OptionalGiftIdTable) > 1 then
        ShowOptionalGiftWindow(Table, nil, _G.EOptionalGiftType.Mail, ShowOptionalGiftQueueWindow)
      else
        ShowOptionalGiftWindow(Table, nil, _G.EOptionalGiftType.Mail, OnConfirmClick)
      end
      self.OptionalGiftIdTable[key] = nil
      break
    end
  end
  
  self.OptionalGiftIdTable = {}
  local SelectNum = 0
  for index, value in ipairs(MailIdList) do
    local MailInfo = MailData.AllMailInfoList[value]
    if MailInfo then
      for index, ItemInfo in ipairs(MailInfo.attachment) do
        if self:IsOptional(tonumber(ItemInfo.itemId)) then
          SelectNum = SelectNum + ItemInfo.itemNum
          if self.OptionalGiftIdTable[tonumber(ItemInfo.itemId)] then
            self.OptionalGiftIdTable[tonumber(ItemInfo.itemId)] = self.OptionalGiftIdTable[tonumber(ItemInfo.itemId)] + ItemInfo.itemNum
          else
            self.OptionalGiftIdTable[tonumber(ItemInfo.itemId)] = ItemInfo.itemNum
          end
        end
      end
    end
  end
  if table.count(self.OptionalGiftIdTable) > 0 then
    ShowOptionalGiftQueueWindow()
  else
    OnConfirmClick()
  end
end

function MailHandler:IsOptional(ItemId)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TBGeneral[ItemId] then
    return TBGeneral[ItemId].Type == TableEnums.ENUMResourceType.OptionalGift
  end
  return false
end

return MailHandler
