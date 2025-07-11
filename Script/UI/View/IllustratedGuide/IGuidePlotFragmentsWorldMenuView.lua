local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local IGuidePlotFragmentsWorldMenuView = Class(ViewBase)
function IGuidePlotFragmentsWorldMenuView:BindClickHandler()
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Add(self, self.BindOnEscAction)
end
function IGuidePlotFragmentsWorldMenuView:UnBindClickHandler()
  self.WBP_InteractTipWidgetEsc.Btn_Main.OnClicked:Remove(self, self.BindOnEscAction)
end
function IGuidePlotFragmentsWorldMenuView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function IGuidePlotFragmentsWorldMenuView:OnDestroy()
  self:UnBindClickHandler()
end
function IGuidePlotFragmentsWorldMenuView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if not IsListeningForInputAction(self, "PauseGame") then
    ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscAction
    })
  end
  self:InitInfo()
  self:PlayAnimationForward(self.Ani_in)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, self.BindOnPlotFragmentsWorldChange)
end
function IGuidePlotFragmentsWorldMenuView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if IsListeningForInputAction(self, "PauseGame") then
    StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  end
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnPlotFragmentsWorldChange, self.BindOnPlotFragmentsWorldChange, self)
end
function IGuidePlotFragmentsWorldMenuView:InitInfo()
  local WorldIdList = IllustratedGuideData:GetPlotFragmentWorldIdList()
  table.insert(WorldIdList, -1)
  for Index, WorldId in ipairs(WorldIdList) do
    local item = GetOrCreateItem(self.SclBox_WorldList, Index, self.WBP_IGuide_PlotFragmentsWorldMenuItem:GetClass())
    UpdateVisibility(item, false, false, true)
    GlobalTimer.DelayCallback(0.05 * Index, function()
      UpdateVisibility(item, true)
      item:InitInfoFromWorldMenu(WorldId)
    end)
  end
  HideOtherItem(self.SclBox_WorldList, #WorldIdList + 1)
end
function IGuidePlotFragmentsWorldMenuView:BindOnEscAction()
  self:PlayAnimationForward(self.Ani_out)
end
function IGuidePlotFragmentsWorldMenuView:BindOnPlotFragmentsWorldChange(WorldId)
  if self:IsVisible() then
    IllustratedGuideData.CurrentWorldId = WorldId
    UIMgr:Show(ViewID.UI_IllustratedGuidePlotFragments, true)
  end
end
function IGuidePlotFragmentsWorldMenuView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UIMgr:Hide(ViewID.UI_IGuidePlotFragmentsWorldMenu, true)
  end
end
return IGuidePlotFragmentsWorldMenuView
