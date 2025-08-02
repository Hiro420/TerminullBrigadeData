local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BundleContentItemView = Class(ViewBase)

function BundleContentItemView:BindClickHandler()
end

function BundleContentItemView:UnBindClickHandler()
end

function BundleContentItemView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function BundleContentItemView:OnDestroy()
  self:UnBindClickHandler()
end

function BundleContentItemView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function BundleContentItemView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function BundleContentItemView:OnListItemObjectSet(ListItemObj)
  UpdateVisibility(self.Overlay_Select, false)
  if ListItemObj then
    self.ItemId = ListItemObj.ItemId
    UpdateVisibility(self.Overlay_Have, ListItemObj.bHave)
    self.WBP_Item:InitItem(ListItemObj.ItemId, ListItemObj.Num)
    if ListItemObj.ChildWidget then
      self.ChildWidget = ListItemObj.ChildWidget
      if self.ChildWidget.InitCommonItemDetail then
        self.ChildWidget:InitCommonItemDetail(ListItemObj.ItemId)
      end
    end
  end
end

function BundleContentItemView:BP_OnItemSelectionChanged(bSel)
  UpdateVisibility(self.Overlay_Select, bSel)
end

function BundleContentItemView:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, true)
  if self.ChildWidget then
    self.ChildWidget:InitCommonItemDetail(self.ItemId)
    UpdateVisibility(self.ChildWidget, true)
    ShowCommonTips(nil, self, self.ChildWidget)
    if self.ChildWidget.Slot then
      self.ChildWidget.Slot:SetAutoSize(true)
    end
  end
end

function BundleContentItemView:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, false)
  if self.ChildWidget then
    UpdateVisibility(self.ChildWidget, false)
  end
end

return BundleContentItemView
