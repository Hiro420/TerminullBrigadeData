local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local rapidjson = require("rapidjson")
local RechargeItemView = Class(ViewBase)
function RechargeItemView:BindClickHandler()
  self.Btn.OnClicked:Add(self, function()
    self:Recharge()
  end)
end
function RechargeItemView:UnBindClickHandler()
end
function RechargeItemView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function RechargeItemView:OnDestroy()
  self:UnBindClickHandler()
end
function RechargeItemView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function RechargeItemView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end
function RechargeItemView:Construct()
  self:OnInit()
  EventSystem.AddListenerNew(EventDef.Mall.OnGetRechargeInfo, self, self.Refresh)
end
function RechargeItemView:OnMouseEnter(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, true)
end
function RechargeItemView:OnMouseLeave(MyGeometry, MouseEvent)
  UpdateVisibility(self.Overlay_Hovered, false)
end
function RechargeItemView:Refresh(GoodsInfo)
  local MallInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[self.GoodsId]
  if nil == MallInfo then
    print("RechargeItemView , GoodsId is nil")
    return
  end
  for key, value in pairs(GoodsInfo) do
    if value.GoodsID == self.GoodsId then
      self.Info = value
      self.TextAmountNum:SetText(MallInfo.GainNum)
      self.Text_Amount:SetText(self.RMB)
      self.TextBlock_Num:SetText(MallInfo.GainNum)
    end
  end
end
function RechargeItemView:Recharge()
  HttpCommunication.Request("mallservice/buy", {
    amount = 1,
    goodsID = self.GoodsId,
    shelfID = 4
  }, {
    self,
    function(self, JsonResponse)
      print("\229\133\133\229\128\188\230\136\144\229\138\159")
      Logic_Mall.PushRechargeInfo(false)
      local MallInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[self.GoodsId]
      if nil == MallInfo then
        print("RechargeItemView , GoodsId is nil")
        return
      end
    end
  }, {
    self,
    function(self, JsonResponse)
      print("\232\180\173\228\185\176\229\164\177\232\180\165")
    end
  })
end
return RechargeItemView
