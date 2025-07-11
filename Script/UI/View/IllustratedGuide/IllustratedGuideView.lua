local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local IllustratedGuideView = Class(ViewBase)
function IllustratedGuideView:BindClickHandler()
end
function IllustratedGuideView:UnBindClickHandler()
end
function IllustratedGuideView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function IllustratedGuideView:OnDestroy()
  self:UnBindClickHandler()
end
function IllustratedGuideView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.WBP_IGuide_GenericModify:OnEnter(2)
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    IllustratedGuideView.BindCloseSelf
  })
end
function IllustratedGuideView:BindCloseSelf()
  UIMgr:Hide(ViewID.UI_IllustratedGuide)
end
function IllustratedGuideView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
end
function IllustratedGuideView:Construct()
  self:BlueprintBeginPlay()
end
function IllustratedGuideView:AddBtnEvent()
  self.Btn_GenericModify.Btn.OnClicked:Add(self, function()
    self:BindSelectGenericModifyTab()
  end)
end
function IllustratedGuideView:BlueprintBeginPlay()
  self:AddBtnEvent()
  self:BindSelectGenericModifyTab()
end
function IllustratedGuideView:BindSelectGenericModifyTab()
  self.Btn_GenericModify:ChangeStyle(BtbStyle.Select)
  self.ContentSwitcher:SetActiveWidgetIndex(0)
  self.WBP_IGuide_GenericModify:InitGenericModify()
end
return IllustratedGuideView
