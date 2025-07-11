local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local rapidjson = require("rapidjson")
local UIUtil = require("Framework.UIMgr.UIUtil")
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local PurchaseConfirm = Class(ViewBase)
function PurchaseConfirm:OnBindUIInput()
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    self.CloseWindow
  })
  self.WBP_InteractTipWidgetBuy:BindInteractAndClickEvent(self, self.OnSingleBuyBtnClicked)
  self.WBP_InteractTipWidgetBuyLeft:BindInteractAndClickEvent(self, self.OnSingleBuyBtnLeftClicked)
  self.WBP_InteractTipWidgetBuyRight:BindInteractAndClickEvent(self, self.OnSingleBuyBtnRightClicked)
end
function PurchaseConfirm:OnUnBindUIInput()
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidgetBuy:UnBindInteractAndClickEvent(self, self.OnSingleBuyBtnClicked)
  self.WBP_InteractTipWidgetBuyLeft:UnBindInteractAndClickEvent(self, self.OnSingleBuyBtnLeftClicked)
  self.WBP_InteractTipWidgetBuyRight:UnBindInteractAndClickEvent(self, self.OnSingleBuyBtnRightClicked)
end
function PurchaseConfirm:BindClickHandler()
  self.Btn1.OnClicked:Add(self, self.OnSingleBuyBtnClicked)
  self.Btn2.OnClicked:Add(self, self.OnSingleBuyBtnLeftClicked)
  self.Btn3.OnClicked:Add(self, self.OnSingleBuyBtnRightClicked)
end
function PurchaseConfirm:UnBindClickHandler()
end
function PurchaseConfirm:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("PurchaseConfirmViewModel")
  self:BindClickHandler()
end
function PurchaseConfirm:OnDestroy()
  self:UnBindClickHandler()
end
function PurchaseConfirm:OnShow(GoodsId, shelfID, CurAmount, InitAmount)
  if nil == CurAmount then
    CurAmount = 0
  end
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.GoodsId = GoodsId
  self.shelfID = shelfID
  UpdateVisibility(self.WBP_CommonItem.Img_Bg_1, false)
  local TemplateId = 0
  local TBShelf = LuaTableMgr.GetLuaTableByName(TableNames.TBMallShelf)
  if TBShelf and TBShelf[self.shelfID] then
    TemplateId = TBShelf[self.shelfID].TemplateId
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if TBMall[GoodsId] then
    local GoodsInfo = TBMall[GoodsId]
    self.WBP_CommonItem:InitCommonItem(GoodsInfo.GainResourcesID, 0, true)
    UpdateVisibility(self.WBP_SliderInput, GoodsInfo.BuyLimitType ~= TableEnums.ENUMBuyLimitType.FOREVER)
    if GoodsInfo.BuyLimitType == TableEnums.ENUMBuyLimitType.NONE then
      self.WBP_SliderInput:InitSliderInput(1, 1, 100, function(Num)
        self:OnSelNumChange(Num)
      end)
    elseif GoodsInfo.BuyLimitType ~= TableEnums.ENUMBuyLimitType.FOREVER then
      self.WBP_SliderInput:InitSliderInput(1, 1, GoodsInfo.BuyLimit - CurAmount, function(Num)
        self:OnSelNumChange(Num)
      end)
    end
    self.Switcher:SetActiveWidgetIndex(#GoodsInfo.ConsumeResources - 1)
    local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    local ItemInfo = TotalResourceTable[GoodsInfo.GainResourcesID]
    if ItemInfo then
      self.GetText:SetText(string.format(GetStringById(16), ItemInfo.Name))
      self.Desc:SetText(ItemInfo.Desc)
    end
  end
  self.WBP_SliderInput:SetInitAmount(InitAmount)
  if nil == InitAmount then
    InitAmount = 1
  end
  self:OnSelNumChange(InitAmount)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.CloseWindow)
end
function PurchaseConfirm:CloseWindow()
  UIMgr:Hide(ViewID.UI_Mall_PurchaseConfirm, true)
end
function PurchaseConfirm:IsOptional(ResourcesID)
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TBGeneral[ResourcesID] then
    return TBGeneral[ResourcesID].Type == TableEnums.ENUMResourceType.OptionalGift
  end
  return false
end
function PurchaseConfirm:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.CloseWindow)
end
function PurchaseConfirm:Buy()
  local bConsume, ConsumeNum = self:CheckGoodsType()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResourceExchange, self.resourceID)
  if not bConsume and not Result then
    ShowWaveWindow(1010)
    return
  end
  if not bConsume then
    UIMgr:Hide(ViewID.UI_Mall_PurchaseConfirm, true)
    self.Widget = ShowWaveWindowWithDelegate(-10, {}, {
      GameInstance,
      function()
        return not self.Widget.bClose
      end
    }, {
      GameInstance,
      function()
      end
    })
    if self.Widget then
      self.Widget:InitExchangeWindow(self.resourceID, ConsumeNum)
    end
    return
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  local GoodsInfo = TBMall[self.GoodsId]
  local _, _, y, m, d, _hour, _min, _sec = string.find(GoodsInfo.SaleStartTime, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
  local ShowStartTimestamp = os.time({
    year = y,
    month = m,
    day = d,
    hour = _hour,
    min = _min,
    sec = _sec
  })
  _, _, y, m, d, _hour, _min, _sec = string.find(GoodsInfo.SaleEndTime, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
  local ShowEndTimestamp = os.time({
    year = y,
    month = m,
    day = d,
    hour = _hour,
    min = _min,
    sec = _sec
  })
  if not self:OnBuyTime(ShowStartTimestamp, ShowEndTimestamp) then
    ShowWaveWindow(103002)
    print("\228\184\141\229\156\168\232\180\173\228\185\176\230\151\182\233\151\180\232\140\131\229\155\180\229\134\133")
    return
  end
  local optionalGiftInfos = {}
  local OnConfirmClick = function(optionalGiftInfos)
    if 0 == optionalGiftInfos or 0 == #optionalGiftInfos then
      optionalGiftInfos = nil
    end
    HttpCommunication.Request("mallservice/buybyresource", {
      amount = self.SelectNum,
      goodsID = self.GoodsId,
      optionalGiftInfos = optionalGiftInfos,
      resourceID = self.resourceID,
      shelfID = self.shelfID
    }, {
      self,
      function(self, JsonResponse)
        SkinHandler.SendGetHeroSkinList()
        SkinHandler.SendGetWeaponSkinList()
        Logic_Mall.RecordData(self.SelectNum, self.GoodsId, self.shelfID)
        Logic_Mall.PushExteriorInfo(false)
        Logic_Mall.PushBundleInfo(false)
        Logic_Mall.PushPropsInfo(false)
      end
    }, {
      GameInstance,
      function(self, JsonResponse)
        print("\232\180\173\228\185\176\229\164\177\232\180\165")
      end
    })
    UIMgr:Hide(ViewID.UI_Mall_PurchaseConfirm, true)
  end
  if self:IsOptional(GoodsInfo.GainResourcesID) then
    local OptionalGiftIdTable = {}
    OptionalGiftIdTable[GoodsInfo.GainResourcesID] = self.SelectNum
    ShowOptionalGiftWindow(OptionalGiftIdTable, nil, _G.EOptionalGiftType.Mall, OnConfirmClick)
  else
    OnConfirmClick({nil})
  end
end
function PurchaseConfirm:CheckGoodsType()
  local ConsumeNum = self.resourceNum * self.SelectNum
  local GoddsId = tonumber(self.GoodsId)
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(self.resourceID)
  if not CurrencyInfo then
    print("not found CurrencyId", self.resourceID)
    return false, ConsumeNum
  end
  local CurNum = 0
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
    CurNum = DataMgr.GetOutsideCurrencyNumById(self.resourceID)
  else
    CurNum = DataMgr.GetPackbackNumById(self.resourceID)
  end
  return ConsumeNum <= CurNum, ConsumeNum - CurNum
end
function PurchaseConfirm:OnBuyTime(StartTime, EndTime)
  local CurTimeTemp = os.time()
  return tonumber(StartTime) <= tonumber(CurTimeTemp) and tonumber(CurTimeTemp) <= tonumber(EndTime)
end
function PurchaseConfirm:OnSingleBuyBtnClicked()
  if 0 ~= self.Switcher:GetActiveWidgetIndex() then
    return
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if TBMall[self.GoodsId] then
    local GoodsInfo = TBMall[self.GoodsId]
    self.resourceID = GoodsInfo.ConsumeResources[1].x
    self.resourceNum = GoodsInfo.ConsumeResources[1].z
    self:Buy()
  end
end
function PurchaseConfirm:OnSingleBuyBtnLeftClicked()
  if 1 ~= self.Switcher:GetActiveWidgetIndex() then
    return
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if TBMall[self.GoodsId] then
    local GoodsInfo = TBMall[self.GoodsId]
    self.resourceID = GoodsInfo.ConsumeResources[1].x
    self.resourceNum = GoodsInfo.ConsumeResources[1].z
    self:Buy()
  end
end
function PurchaseConfirm:OnSingleBuyBtnRightClicked()
  if 1 ~= self.Switcher:GetActiveWidgetIndex() then
    return
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if TBMall[self.GoodsId] then
    local GoodsInfo = TBMall[self.GoodsId]
    self.resourceID = GoodsInfo.ConsumeResources[2].x
    self.resourceNum = GoodsInfo.ConsumeResources[2].z
    self:Buy()
  end
end
function PurchaseConfirm:OnSelNumChange(Num)
  self.SelectNum = Num
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if TBMall[self.GoodsId] then
    local GoodsInfo = TBMall[self.GoodsId]
    if 1 == #GoodsInfo.ConsumeResources then
      self.WBP_Price:SetPrice(GoodsInfo.ConsumeResources[1].z * Num, GoodsInfo.ConsumeResources[1].y * Num, GoodsInfo.ConsumeResources[1].x)
    elseif 2 == #GoodsInfo.ConsumeResources then
      self.WBP_Price2:SetPrice(GoodsInfo.ConsumeResources[1].y * Num, GoodsInfo.ConsumeResources[1].z * Num, GoodsInfo.ConsumeResources[1].x)
      self.WBP_Price3:SetPrice(GoodsInfo.ConsumeResources[2].y * Num, GoodsInfo.ConsumeResources[2].z * Num, GoodsInfo.ConsumeResources[2].x)
    end
  end
end
return PurchaseConfirm
