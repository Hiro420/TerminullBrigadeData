local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local RedDotData = require("Modules.RedDot.RedDotData")
local BundleItemView = Class(ViewBase)
function BundleItemView:BindClickHandler()
end
function BundleItemView:UnBindClickHandler()
end
function BundleItemView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function BundleItemView:OnDestroy()
  self:UnBindClickHandler()
end
function BundleItemView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function BundleItemView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function BundleItemView:BP_OnItemSelectionChanged(bIsSelected)
  if bIsSelected then
    self.WBP_RedDotView:SetNum(0)
  end
end
function BundleItemView:OnListItemObjectSet(ListItemObj)
  if ListItemObj then
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[ListItemObj.GoodsId] then
      local GoodsInfo = TBMall[ListItemObj.GoodsId]
      self.Text_Name:SetText(GoodsInfo.Name)
      self.WBP_RedDotView:ChangeRedDotIdByTag(ListItemObj.GoodsId)
      self.WBP_Price:SetPrice(GoodsInfo.DiscountPrice, GoodsInfo.ConsumeNum, GoodsInfo.ConsumeResources[1].x)
      self.Text_Discount:SetText(math.floor((GoodsInfo.DiscountPrice - GoodsInfo.ConsumeNum) / GoodsInfo.ConsumeNum * 100) .. "%")
      UpdateVisibility(self.CanvasPanel_0, GoodsInfo.DiscountPrice ~= GoodsInfo.ConsumeNum)
      if 0 ~= GoodsInfo.BuyLimitType then
        local Restrictions = NSLOCTEXT("BundleItemView", "Restrictions", "\233\153\144\232\180\173{0}/{1}")
        UpdateVisibility(self.Text_LimitPurchase, true)
        UpdateVisibility(self.Text_TimeLeft, true)
        self.Text_LimitPurchase:SetText(UE.FTextFormat(Restrictions(), ListItemObj.Amount, GoodsInfo.BuyLimit))
      else
        UpdateVisibility(self.Text_TimeLeft, false)
        UpdateVisibility(self.Text_LimitPurchase, false)
      end
      if 2 == GoodsInfo.ShelfsShowType then
        UpdateVisibility(self.RGList, true)
        self.GiftId = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[ListItemObj.GoodsId].GainResourcesID
        local TBRandomGift = LuaTableMgr.GetLuaTableByName(TableNames.TBGift)
        self.BundleInfo = TBRandomGift[self.GiftId]
        self.RGList:ClearListItems()
        if self.BundleInfo then
          for key, value in pairs(self.BundleInfo.Resources) do
            local ItemObj = self.RGList:GetOrCreateDataObj()
            ItemObj.ItemId = value.key
            ItemObj.Num = value.value
            ItemObj.ChildWidget = UE.UUserListEntryLibrary.GetOwningListView(self):GetParent():GetParent():GetChildAt(3)
            self.RGList:AddItem(ItemObj)
          end
        end
      else
        UpdateVisibility(self.RGList, false)
      end
      self.ResourcesID = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[ListItemObj.GoodsId].GainResourcesID
      local TBRandomGift = LuaTableMgr.GetLuaTableByName(TableNames.TBGift)
      self.Icon = TBRandomGift[self.ResourcesID].Icon
      SetImageBrushByPath(self.Image_Icon, self.Icon)
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
      self:SetQuality(GoodsInfo.Quality)
    end
  end
end
function BundleItemView:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, true)
end
function BundleItemView:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, false)
end
function BundleItemView:SetQuality(Quality)
  local Re, Info = GetRowData(DT.DT_ItemRarity, Quality)
  if Re then
    UpdateVisibility(self.URGImage_Quality, true, false)
    self.URGImage_Quality:SetColorAndOpacity(Info.SkinRareBgColor)
  end
end
return BundleItemView
