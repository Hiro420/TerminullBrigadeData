local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local rapidjson = require("rapidjson")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local PropsView = Class(ViewBase)
function PropsView:Construct()
  self:OnInit()
end
function PropsView:BindClickHandler()
  self.PropsList.BP_OnItemClicked:Add(self, PropsView.BP_OnItemClicked)
  EventSystem.AddListener(self, EventDef.WSMessage.ResourceUpdate, PropsView.BindOnResourceUpdate)
  EventSystem.AddListener(self, EventDef.Mall.OnGetPropsInfo, PropsView.UpDateList)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.ReturnLobby)
end
function PropsView:UnBindClickHandler()
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Remove(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.ReturnLobby)
end
function PropsView:OpenSetting()
  LogicGameSetting.ShowGameSettingPanel()
end
function PropsView:ReturnLobby()
  local LobbyDefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
  local CurShowLabelName = LogicLobby.GetCurSelectedLabelName()
  if CurShowLabelName == LobbyDefaultLabelName then
    EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, not self.IsShowLobbyMenuPanel)
  else
    LogicLobby.ChangeLobbyPanelLabelSelected(LobbyDefaultLabelName)
  end
end
function PropsView:OnInit()
  self.DataBindTable = {
    {
      Source = "UpDateList",
      Callback = PropsView.UpDateList
    }
  }
  self.ViewModel = UIModelMgr:Get("PropsViewModel")
  self:BindClickHandler()
end
function PropsView:OnDestroy()
  self:UnBindClickHandler()
end
function PropsView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.ShelfIndex = LogicLobby.UINameToShelfIndex[self.ViewID]
  Logic_Mall.PushPropsInfo(true, self.ShelfIndex)
  self:PlayAnimation(self.Ani_in)
  LogicLobby.ChangeLobbyMainModelVis(false)
  self.ShowLink = false
  ListenForInputAction("OpenSettings", UE.EInputEvent.IE_Pressed, true, {
    self,
    self.OpenSetting
  })
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    self.ReturnLobby
  })
end
function PropsView:OnShowLink()
  self.ShowLink = true
end
function PropsView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    self:BindOnOutAnimationFinished()
  end
end
function PropsView:BindOnOutAnimationFinished()
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
end
function PropsView:CanDirectSwitch(NextTabWidget)
  self:PlayAnimation(self.Ani_out)
  return false
end
function PropsView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  LogicLobby.ChangeLobbyMainModelVis(true)
  StopListeningForInputAction(self, "OpenSettings", UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
end
function PropsView:UpDateList(goodsInfos)
  self.PropsList:ClearListItems()
  if not goodsInfos or not goodsInfos[self.ShelfIndex] then
    return
  end
  goodsInfos = goodsInfos[self.ShelfIndex]
  for key, value in pairs(goodsInfos) do
    local DataObj = NewObject(self.DataObjClass, GameInstance, nil)
    DataObj.GoodsId = value.GoodsID
    DataObj.Amount = value.Amount
    DataObj.StartTime = value.startTime
    DataObj.EndTime = value.endTime
    DataObj.BuyLimitForAlreadyOwned = value.buyLimitForAlreadyOwned
    DataObj.ShowStartTime = value.showStartTime
    DataObj.ShowEndTime = value.showEndTime
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if 0 ~= TBMall[DataObj.GoodsId].BuyLimitType then
      DataObj.SoldOut = value.Amount >= TBMall[DataObj.GoodsId].BuyLimit
    end
    if self:OnShowTime(DataObj.ShowStartTime, DataObj.ShowEndTime) then
      self.PropsList:AddItem(DataObj)
    end
  end
end
function PropsView:CheckGoodsType(GoodsId, Amount)
  local ConsumeNum = 0
  local MailInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if MailInfo[GoodsId] then
    self.CurrencyId = MailInfo[GoodsId].ConsumeResourcesID
    ConsumeNum = MailInfo[GoodsId].DiscountPrice * Amount
  end
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not CurrencyInfo then
    print("not found CurrencyId", self.CurrencyId)
    return false
  end
  local CurNum = 0
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
    CurNum = DataMgr.GetOutsideCurrencyNumById(self.CurrencyId)
  else
    CurNum = DataMgr.GetPackbackNumById(self.CurrencyId)
  end
  return ConsumeNum <= CurNum, ConsumeNum - CurNum
end
function PropsView:BP_OnItemClicked(Item)
  local SaleStatus = Logic_Mall.GetGoodsSalesStatus(Item)
  if SaleStatus == EnumSalesStatus.OnSale or SaleStatus == EnumSalesStatus.LimitedTimeOnSale then
    UIMgr:Show(ViewID.UI_Mall_PurchaseConfirm, true, Item.GoodsId, 3, 1)
  end
end
function PropsView:BindOnResourceUpdate(json)
  local JsonTable = rapidjson.decode(json)
  if JsonTable.proppack == nil then
    return
  end
  Logic_Mall.PushPropsInfo(false)
end
function PropsView:OnShowTime(ShowStartTime, ShowEndTime)
  local CurTimeTemp = os.time()
  print(tonumber(ShowStartTime), tonumber(CurTimeTemp), tonumber(ShowEndTime))
  return tonumber(ShowStartTime) <= tonumber(CurTimeTemp) and tonumber(CurTimeTemp) <= tonumber(ShowEndTime)
end
return PropsView
