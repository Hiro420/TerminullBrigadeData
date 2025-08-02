local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local MailData = require("Modules.Mail.MailData")
local MailViewModel = CreateDefaultViewModel()
MailViewModel.propertyBindings = {}
MailViewModel.subViewModels = {}

function MailViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListener(self, EventDef.Mail.OnUpdateAllMailListInfo, self.BindOnUpdateAllMailListInfo)
  EventSystem.AddListener(self, EventDef.Mail.OnChangeMailItemSelected, self.BindOnChangeMailItemSelected)
end

function MailViewModel:BindOnUpdateAllMailListInfo()
  self:RefreshMailItemList()
end

function MailViewModel:BindOnChangeMailItemSelected(DataObj)
  local View = self:GetFirstView()
  if not View then
    return
  end
  View.MailItemListView:BP_SetSelectedItem(DataObj)
end

function MailViewModel:RefreshMailItemList()
  local View = self:GetFirstView()
  if not View then
    return
  end
  View:RefreshAllReceiveButtonStatus()
  local AllMailInfoList = MailData:GetAllMailInfoList()
  local CurSelectedItem
  local CurSelectedItemId = View.MailItemListView:BP_GetSelectedItem() and View.MailItemListView:BP_GetSelectedItem().Id or -1
  View.MailItemListView:RecyleAllData()
  local AllMailIdList = {}
  for MailId, value in pairs(AllMailInfoList) do
    table.insert(AllMailIdList, MailId)
  end
  local ReadStatusSortType = {
    [EMailReadStatus.UnRead] = 0,
    [EMailReadStatus.Readed] = 1
  }
  table.sort(AllMailIdList, function(A, B)
    local AMailInfo = MailData:GetMailInfoById(A)
    local BMailInfo = MailData:GetMailInfoById(B)
    if AMailInfo.readStatus == BMailInfo.readStatus then
      if AMailInfo.IsHaveAttachment == BMailInfo.IsHaveAttachment then
        return AMailInfo.sendTime > BMailInfo.sendTime
      end
      return AMailInfo.IsHaveAttachment and not BMailInfo.IsHaveAttachment
    end
    return ReadStatusSortType[AMailInfo.readStatus] < ReadStatusSortType[BMailInfo.readStatus]
  end)
  local DataObjList = {}
  for i, MailId in ipairs(AllMailIdList) do
    local SingleDataObj = View.MailItemListView:GetOrCreateDataObj()
    SingleDataObj.Id = MailId
    table.insert(DataObjList, SingleDataObj)
    if MailId == CurSelectedItemId then
      CurSelectedItem = SingleDataObj
    end
  end
  View.MailItemListView:SetRGListItems(DataObjList, false, true)
  CurSelectedItem = CurSelectedItem or DataObjList[1]
  if CurSelectedItem then
    local MailInfo = MailData:GetMailInfoById(CurSelectedItem.Id)
    if not MailInfo then
      CurSelectedItem = nil
    end
  end
  if not CurSelectedItem then
    if View.ShowEmptyPanel then
      View:ShowEmptyPanel()
    end
  else
    if View.ShowNotEmptyPanel then
      View:ShowNotEmptyPanel()
    end
    View.MailItemListView:BP_SetSelectedItem(CurSelectedItem)
  end
  View.Txt_Num:SetText(string.format("%d/%d", table.count(MailData:GetAllMailInfoList()), View.MaxMailNum))
end

function MailViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  MailData:ClearAllMailInfoList()
  EventSystem.RemoveListener(EventDef.Mail.OnUpdateAllMailListInfo, self.BindOnUpdateAllMailListInfo, self)
  EventSystem.RemoveListener(EventDef.Mail.OnChangeMailItemSelected, self.BindOnChangeMailItemSelected, self)
end

return MailViewModel
