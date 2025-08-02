local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local PropsItemView = Class(ViewBase)

function PropsItemView:BindClickHandler()
end

function PropsItemView:UnBindClickHandler()
end

function PropsItemView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function PropsItemView:OnDestroy()
  self:UnBindClickHandler()
end

function PropsItemView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function PropsItemView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function PropsItemView:OnListItemObjectSet(ListItemObj)
  self.ItemObj = ListItemObj
  local LimitPurchaseForever = NSLOCTEXT("PropsItemView", "LimitPurchaseForever", "\230\176\184\228\185\133\233\153\144\232\180\173{0}/{1}")
  local LimitPurchaseSeason = NSLOCTEXT("PropsItemView", "LimitPurchaseSeason", "\232\181\155\229\173\163\233\153\144\232\180\173{0}/{1}")
  local LimitPurchaseMonth = NSLOCTEXT("PropsItemView", "LimitPurchaseMonth", "\230\156\172\230\156\136\233\153\144\232\180\173{0}/{1}")
  local LimitPurchaseDay = NSLOCTEXT("PropsItemView", "LimitPurchaseDay", "\230\175\143\230\151\165\233\153\144\232\180\173{0}/{1}")
  local LimitPurchaseWeekly = NSLOCTEXT("PropsItemView", "LimitPurchaseWeekly", "\230\175\143\229\145\168\233\153\144\232\180\173{0}/{1}")
  if ListItemObj then
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[ListItemObj.GoodsId] then
      local GoodsInfo = TBMall[ListItemObj.GoodsId]
      self.RGTextName:SetText(GoodsInfo.Name)
      self.WBP_Price_1:SetPrice(GoodsInfo.ConsumeResources[1].z, GoodsInfo.ConsumeResources[1].y, GoodsInfo.ConsumeResources[1].x)
      UpdateVisibility(self.WBP_Price_2, GoodsInfo.ConsumeResources[2] ~= nil)
      if GoodsInfo.ConsumeResources[2] then
        self.WBP_Price_2:SetPrice(GoodsInfo.ConsumeResources[2].y, GoodsInfo.ConsumeResources[2].z, GoodsInfo.ConsumeResources[2].x)
      end
      self.WBP_RedDotView:ChangeRedDotIdByTag(ListItemObj.GoodsId)
      UpdateVisibility(self.CanvasPanel_2, GoodsInfo.ConsumeResources[1].z ~= GoodsInfo.ConsumeResources[1].y)
      self.Text_Discount:SetText(math.floor((GoodsInfo.DiscountPrice - GoodsInfo.ConsumeNum) / GoodsInfo.ConsumeNum * 100) .. "%")
      if 5 == GoodsInfo.BuyLimitType then
        UpdateVisibility(self.Text_LimitPurchase, true)
        UpdateVisibility(self.Text_TimeLeft, true)
        self.Text_TimeLeft:SetCountdownInfo(os.time() + CalcTartUnixTimeStamp(5))
        self.Text_LimitPurchase:SetText(UE.FTextFormat(LimitPurchaseDay(), ListItemObj.Amount, GoodsInfo.BuyLimit))
      elseif 4 == GoodsInfo.BuyLimitType then
        UpdateVisibility(self.Text_LimitPurchase, true)
        UpdateVisibility(self.Text_TimeLeft, true)
        self.Text_TimeLeft:SetCountdownInfo(os.time() + GetNextWeeklyRefreshTimeStamp(5, 1))
        self.Text_LimitPurchase:SetText(UE.FTextFormat(LimitPurchaseWeekly(), ListItemObj.Amount, GoodsInfo.BuyLimit))
      elseif 3 == GoodsInfo.BuyLimitType then
        UpdateVisibility(self.Text_LimitPurchase, true)
        UpdateVisibility(self.Text_TimeLeft, true)
        self.Text_TimeLeft:SetCountdownInfo(os.time() + GetNextMonthRefreshTimeStamp(5))
        self.Text_LimitPurchase:SetText(UE.FTextFormat(LimitPurchaseMonth(), ListItemObj.Amount, GoodsInfo.BuyLimit))
      elseif 2 == GoodsInfo.BuyLimitType then
        UpdateVisibility(self.Text_LimitPurchase, true)
        UpdateVisibility(self.Text_TimeLeft, true)
        self.Text_LimitPurchase:SetText(UE.FTextFormat(LimitPurchaseSeason(), ListItemObj.Amount, GoodsInfo.BuyLimit))
      elseif 1 == GoodsInfo.BuyLimitType then
        UpdateVisibility(self.Text_LimitPurchase, true)
        UpdateVisibility(self.Text_TimeLeft, false)
        self.Text_LimitPurchase:SetText(UE.FTextFormat(LimitPurchaseForever(), ListItemObj.Amount, GoodsInfo.BuyLimit))
      else
        UpdateVisibility(self.Text_TimeLeft, false)
        UpdateVisibility(self.Text_LimitPurchase, false)
      end
      local SaleStatus = Logic_Mall.GetGoodsSalesStatus(ListItemObj)
      UpdateVisibility(self.Overlay_Have, SaleStatus == EnumSalesStatus.AlreadyOwned)
      UpdateVisibility(self.Overlay_SoldOut, SaleStatus == EnumSalesStatus.SoldOut)
      if SaleStatus == EnumSalesStatus.LimitedTimeOnSale then
        UpdateVisibility(self.WBP_ItemCountdown, true)
        self.WBP_ItemCountdown:SetCountdownInfo(ListItemObj.EndTime)
      else
        UpdateVisibility(self.WBP_ItemCountdown, false)
      end
      UpdateVisibility(self.Overlay_NotOnSale, SaleStatus == EnumSalesStatus.NotOnSale)
      if SaleStatus == EnumSalesStatus.NotOnSale then
        local current_date = os.date("*t", ListItemObj.StartTime)
        self.WBP_LimitedTime.TextBlock:SetText(string.format("%d-%02d-%02d", current_date.year, current_date.month, current_date.day) .. "\229\188\128\229\148\174")
      end
      UpdateVisibility(self.Overlay_OffShelf, SaleStatus == EnumSalesStatus.OffShelf)
      local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      if TBGeneral[GoodsInfo.GainResourcesID] then
        SetImageBrushByPath(self.URGImageIcon, TBGeneral[GoodsInfo.GainResourcesID].Icon)
        local Re, Info = GetRowData(DT.DT_ItemRarity, TBGeneral[GoodsInfo.GainResourcesID].Rare)
        if Re then
          self.Image_Quality01:SetColorAndOpacity(Info.SkinRareBgColor)
        end
      end
      self.WBP_Item:InitItem(GoodsInfo.GainResourcesID)
    end
  end
end

function PropsItemView:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, true)
  local Offset = UE.FVector2D(-100, 0)
  self.HoverTips = ShowCommonTips(nil, self, nil, nil, nil, nil, Offset)
  if self.ItemObj then
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMall, self.ItemObj.GoodsId)
    if result then
      local itemID = row.GainResourcesID
      self.HoverTips:ShowTipsByItemID(itemID)
    end
  end
end

function PropsItemView:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, false)
  UpdateVisibility(self.HoverTips, false)
end

function PropsItemView:BP_OnItemSelectionChanged(bSelected)
  if bSelected then
    self.WBP_RedDotView:SetNum(0)
  end
end

return PropsItemView
