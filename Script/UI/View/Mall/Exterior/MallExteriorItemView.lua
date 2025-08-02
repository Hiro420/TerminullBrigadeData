local MallExteriorItemView = UnLua.Class()
local LimitPurchaseDay = NSLOCTEXT("MallExteriorItemView", "LimitPurchaseDay", "\230\156\172\230\151\165\233\153\144\232\180\173")
local OnSaleText = NSLOCTEXT("MallExteriorItemView", "OnSaleText", "\229\188\128\229\148\174")

function MallExteriorItemView:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    self.ListItemObj = ListItemObj
    self.TipsWidget = ListItemObj.TipsWidget
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[ListItemObj.GoodsId] then
      local GoodsInfo = TBMall[ListItemObj.GoodsId]
      self.Text_Name:SetText(GoodsInfo.Name)
      UpdateVisibility(self.WBP_Price, GoodsInfo.ConsumeResources[1] ~= nil)
      self.WBP_Price:SetPrice(GoodsInfo.ConsumeResources[1].z, GoodsInfo.ConsumeResources[1].y, GoodsInfo.ConsumeResources[1].x)
      UpdateVisibility(self.WBP_Price_2, GoodsInfo.ConsumeResources[2] ~= nil)
      if GoodsInfo.ConsumeResources[2] then
        self.WBP_Price_2:SetPrice(GoodsInfo.ConsumeResources[2].y, GoodsInfo.ConsumeResources[2].z, GoodsInfo.ConsumeResources[2].x)
      end
      self.WBP_RedDotView:ChangeRedDotIdByTag(ListItemObj.GoodsId)
      UpdateVisibility(self.CanvasPanel_Lijian, GoodsInfo.DiscountPrice ~= GoodsInfo.ConsumeNum)
      self.Text_Discount:SetText(math.floor((GoodsInfo.DiscountPrice - GoodsInfo.ConsumeNum) / GoodsInfo.ConsumeNum * 100) .. "%")
      if 5 == GoodsInfo.BuyLimitType then
        UpdateVisibility(self.Text_LimitPurchase, true)
        self.Text_LimitPurchase:SetText(LimitPurchaseDay() .. ListItemObj.Amount .. "/" .. GoodsInfo.BuyLimit)
      else
        UpdateVisibility(self.Text_LimitPurchase, false)
      end
      local CurTime = os.time()
      local TimeLeft = Format(ListItemObj.EndTime - CurTime, "dd\229\164\169hh\229\176\143\230\151\182mm\229\136\134ss\231\167\146")
      local SaleStatus = Logic_Mall.GetGoodsSalesStatus(ListItemObj)
      UpdateVisibility(self.Overlay_Have, SaleStatus == EnumSalesStatus.AlreadyOwned)
      UpdateVisibility(self.ScaleBox_0, SaleStatus ~= EnumSalesStatus.AlreadyOwned)
      UpdateVisibility(self.Overlay_SoldOut, SaleStatus == EnumSalesStatus.SoldOut)
      if SaleStatus == EnumSalesStatus.LimitedTimeOnSale then
        UpdateVisibility(self.ScaleBox_Countdown, true)
        self.WBP_ItemCountdown:SetCountdownInfo(ListItemObj.EndTime)
      else
        UpdateVisibility(self.ScaleBox_Countdown, false)
      end
      UpdateVisibility(self.Overlay_NotOnSale, SaleStatus == EnumSalesStatus.NotOnSale)
      if SaleStatus == EnumSalesStatus.NotOnSale then
        local current_date = os.date("*t", ListItemObj.StartTime)
        self.WBP_LimitedTime.TextBlock:SetText(string.format("%02d-%02d", current_date.month, current_date.day) .. OnSaleText())
      end
      UpdateVisibility(self.Overlay_OffShelf, SaleStatus == EnumSalesStatus.OffShelf)
      local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      if TBGeneral[GoodsInfo.GainResourcesID] then
        self:SetQuality(TBGeneral[GoodsInfo.GainResourcesID].Rare)
      end
      self.WBP_Item:InitItem(GoodsInfo.GainResourcesID)
    end
  end
  UpdateVisibility(self.Overlay_Sel, UE.UUserListEntryLibrary.IsListItemSelected(self))
end

function MallExteriorItemView:BP_OnItemSelectionChanged(bSelected)
  UpdateVisibility(self.Overlay_Sel, bSelected)
  if bSelected then
    self.WBP_RedDotView:SetNum(0)
  end
end

function MallExteriorItemView:SetQuality(Quality)
  local Re, Info = GetRowData(DT.DT_ItemRarity, Quality)
  if Re then
    UpdateVisibility(self.Image_Quality01, true, false)
    self.Image_Quality01:SetColorAndOpacity(Info.SkinRareBgColor)
  end
end

return MallExteriorItemView
