local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local rapidjson = require("rapidjson")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BundleView = Class(ViewBase)
function BundleView:BindClickHandler()
  self.List.BP_OnItemClicked:Add(self, BundleView.BP_OnItemClicked)
  EventSystem.AddListener(self, EventDef.Mall.OnGetBundleInfo, BundleView.UpDateList)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, self.OpenSetting)
  ListenForInputAction("OpenSettings", UE.EInputEvent.IE_Pressed, true, {
    self,
    self.OpenSetting
  })
end
function BundleView:UnBindClickHandler()
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Remove(self, self.OpenSetting)
  StopListeningForInputAction(self, "OpenSettings", UE.EInputEvent.IE_Pressed)
end
function BundleView:OpenSetting()
  LogicGameSetting.ShowGameSettingPanel()
end
function BundleView:OnShowLink(LinkParams)
  self.IsShowLink = true
  SetLobbyPanelCurrencyList(true, {300005})
  UpdateVisibility(self.WBP_InteractTipWidgetSetting, true)
  UpdateVisibility(self.WBP_InteractTipWidgetEsc, true)
end
function BundleView:ReturnLobby()
  local LobbyDefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
  LogicLobby.ChangeLobbyPanelLabelSelected(LobbyDefaultLabelName)
end
function BundleView:OnInit()
  self.DataBindTable = {
    {
      Source = "UpDateList",
      Callback = BundleView.UpDateList
    }
  }
  self.ViewModel = UIModelMgr:Get("BundleViewModel")
  self:BindClickHandler()
end
function BundleView:OnDestroy()
  self:UnBindClickHandler()
end
function BundleView:OnShow(...)
  UpdateVisibility(self.WBP_InteractTipWidgetSetting, false)
  UpdateVisibility(self.WBP_InteractTipWidgetEsc, false)
  SetLobbyPanelCurrencyList(true, {300005})
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.ShelfIndex = LogicLobby.UINameToShelfIndex[self.ViewID]
  Logic_Mall.PushBundleInfo(true, self.ShelfIndex)
  self:PlayAnimation(self.Ani_in)
  LogicLobby.ChangeLobbyMainModelVis(false)
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.ReturnLobby)
end
function BundleView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  LogicLobby.ChangeLobbyMainModelVis(true)
  self.IsShowLink = false
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.ReturnLobby)
  SetLobbyPanelCurrencyList(false)
end
function BundleView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    self:BindOnOutAnimationFinished()
  end
end
function BundleView:BindOnOutAnimationFinished()
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
end
function BundleView:CanDirectSwitch(NextTabWidget)
  self:PlayAnimation(self.Ani_out)
  return false
end
function BundleView:UpDateList(goodsInfos)
  self.List:ClearListItems()
  if nil == goodsInfos or nil == goodsInfos[self.ShelfIndex] then
    return
  end
  goodsInfos = goodsInfos[self.ShelfIndex]
  table.sort(goodsInfos, function(a, b)
    local InfoA = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[a.GoodsID]
    local InfoB = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[b.GoodsID]
    local bSoldOutA = false
    local bSoldOutB = false
    if 0 ~= InfoA.BuyLimitType then
      bSoldOutA = a.Amount >= InfoA.BuyLimit
    end
    if 0 ~= InfoB.BuyLimitType then
      bSoldOutB = b.Amount >= InfoB.BuyLimit
    end
    if bSoldOutA == bSoldOutB then
      return InfoA.Sort > InfoB.Sort
    end
    return not bSoldOutA
  end)
  for key, value in pairs(goodsInfos) do
    local DataObj = self.List:GetOrCreateDataObj()
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
      self.List:AddItem(DataObj)
    end
  end
end
function BundleView:BP_OnItemClicked(Item)
  local BundleViewContentModel = UIModelMgr:Get("BundleViewContentModel")
  if BundleViewContentModel then
    local GainResourcesID = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[Item.GoodsId].GainResourcesID
    local GoodsInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[Item.GoodsId]
    if 2 == GoodsInfo.ShelfsShowType then
      if Item.SoldOut then
        print("\229\148\174\231\189\132")
        return
      end
      UIMgr:Show(ViewID.UI_Mall_PurchaseConfirm, true, Item.GoodsId, 1)
      return
    end
    BundleViewContentModel:ShowBundleContent(GainResourcesID, Item.GoodsId, Item)
  end
end
function BundleView:BindOnResourceUpdate(json)
  local JsonTable = rapidjson.decode(json)
  if JsonTable.proppack == nil then
    return
  end
  if self.ViewModel then
    self.ViewModel:GetMallInfo()
  end
end
function BundleView:OnShowTime(ShowStartTime, ShowEndTime)
  local CurTimeTemp = os.time()
  return tonumber(ShowStartTime) <= tonumber(CurTimeTemp) and tonumber(CurTimeTemp) <= tonumber(ShowEndTime)
end
return BundleView
