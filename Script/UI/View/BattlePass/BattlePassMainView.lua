local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local battlepassdata = require("Modules.BattlePass.BattlePassData")
local BattlePassHandler = require("Protocol.BattlePass.BattlePassHandler")
local BattlePassMainView = Class(ViewBase)
local SubViewId = {
  ViewID.UI_BattlePassSubView
}
local EscName = "PauseGame"
function BattlePassMainView:BindClickHandler()
end
function BattlePassMainView:UnBindClickHandler()
end
function BattlePassMainView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("BattlePassMainViewModel")
  self:BindClickHandler()
end
function BattlePassMainView:OnDestroy()
end
function BattlePassMainView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.Btn_Link.OnMainButtonClicked:Add(self, self.LinkToShop)
  self.RGToggleGroupFirst.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
  self.RGToggleGroupFirst:SelectId(0)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.ListenForEscInputAction)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  LogicRole.ShowOrLoadLevel(-1)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0, 0)
  self:SetEnhancedInputActionBlocking(true)
end
function BattlePassMainView:OnShowLink(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self.RGToggleGroupFirst.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
  self.RGToggleGroupFirst:SelectId(0)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.ListenForEscInputAction)
  self:InitSubView(battlepassdata.CurBattlePassID)
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscInputAction
    })
  end
  LogicRole.ShowOrLoadLevel(-1)
  self:PlayAnimation(self.Ani_in)
  self:PlayAnimation(self.Ani_loop, 0, 0)
  self:SetEnhancedInputActionBlocking(true)
end
function BattlePassMainView:OnPreHide()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  self.RGToggleGroupFirst.OnCheckStateChanged:Remove(self, self.OnFirstGroupCheckStateChanged)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.ListenForEscInputAction)
  self:SetEnhancedInputActionBlocking(false)
end
function BattlePassMainView:OnHide()
  self:StopAllAnimations()
  self.WBP_BattlePassSubView:OnHide()
  self.WBP_BattlePassTaskView:OnHide()
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.ListenForEscInputAction)
  ChangeToLobbyAnimCamera()
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  self.Btn_Link.OnMainButtonClicked:Remove(self, self.LinkToShop)
end
function BattlePassMainView:LinkToShop()
  self:ListenForEscInputAction()
  ComLink(1036)
end
function BattlePassMainView:OnFirstGroupCheckStateChanged(SelectId)
  self.viewModel:Switch(SelectId)
  self.Switcher:SetActiveWidgetIndex(SelectId)
  local Widget = self.Switcher:GetActiveWidget()
  if Widget.OnActivated then
    Widget:OnActivated()
  end
end
function BattlePassMainView:InitSubView(BattlePassID)
  self.BattlePassID = BattlePassID
  self.WBP_BattlePassSubView:OnShow(BattlePassID)
  self.WBP_BattlePassTaskView:OnShow(BattlePassID)
end
function BattlePassMainView:ListenForEscInputAction()
  BattlePassHandler:SendBattlePassData(self.BattlePassID)
  UIMgr:Hide(ViewID.UI_BattlePassMainView, true)
end
return BattlePassMainView
