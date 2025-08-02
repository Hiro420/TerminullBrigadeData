local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local rapidjson = require("rapidjson")
local UIUtil = require("Framework.UIMgr.UIUtil")
local RechargeView = Class(ViewBase)

function RechargeView:Construct()
  self:OnInit()
  Logic_Mall.PushRechargeInfo(true)
end

function RechargeView:BindClickHandler()
end

function RechargeView:UnBindClickHandler()
end

function RechargeView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function RechargeView:OnDestroy()
  self:UnBindClickHandler()
end

function RechargeView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self:PlayAnimation(self.Ani_in)
end

function RechargeView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function RechargeView:UpdataList(GoodsInfos)
end

function RechargeView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    self:BindOnOutAnimationFinished()
  end
end

function RechargeView:BindOnOutAnimationFinished()
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
end

function RechargeView:CanDirectSwitch(NextTabWidget)
  self:PlayAnimation(self.Ani_out)
  return false
end

return RechargeView
