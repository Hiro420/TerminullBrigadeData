local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local IllustratedGuideMenuView = Class(ViewBase)
function IllustratedGuideMenuView:BindClickHandler()
end
function IllustratedGuideMenuView:UnBindClickHandler()
end
function IllustratedGuideMenuView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end
function IllustratedGuideMenuView:OnDestroy()
  self:UnBindClickHandler()
end
function IllustratedGuideMenuView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.GenericModify.OnClicked:Add(self, self.OpenGenericModify)
  self.SpecificModify.OnClicked:Add(self, self.OpenSpecificModify)
  self.Fragment.OnClicked:Add(self, self.OpenFragment)
  ChangeLobbyCamera(self, "IGuideMenu")
  LogicRole.ShowOrLoadLevel(-1)
  LogicLobby.ChangeLobbyMainModelVis(false)
  local FragmentProgress = IllustratedGuideData:GetPlotFragmentProgress()
  self.Txt_CurFragmentCount:SetText(FragmentProgress[1])
  self.Txt_TotalFragmentCount:SetText(FragmentProgress[2])
  self:StopAllAnimations()
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      self:PlayAnimationForward(self.Ani_in)
    end
  })
  LogicRole.ShowOrHideRoleMainHero(false)
end
function IllustratedGuideMenuView:OnRollback()
  ChangeLobbyCamera(self, "IGuideMenu")
  LogicRole.ShowOrLoadLevel(-1)
  LogicLobby.ChangeLobbyMainModelVis(false)
  self:StopAllAnimations()
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      self:PlayAnimationForward(self.Ani_in)
    end
  })
end
function IllustratedGuideMenuView:OpenGenericModify()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.QUAN_XIAN) then
    return
  end
  UIMgr:Show(ViewID.UI_IllustratedGuide, nil, 0)
end
function IllustratedGuideMenuView:OpenSpecificModify()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.QIAN_NENG_MI_YAO) then
    return
  end
  UIMgr:Show(ViewID.UI_IllustratedGuideSpecificModify, true)
end
function IllustratedGuideMenuView:OpenFragment()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.STORY_PIECES) then
    return
  end
  UIMgr:Show(ViewID.UI_IGuidePlotFragmentsWorldMenu, true)
end
function IllustratedGuideMenuView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  LogicLobby.ChangeLobbyMainModelVis(true)
  self:StopAllAnimations()
  self:PlayAnimationForward(self.Ani_out)
end
function IllustratedGuideMenuView:CanDirectSwitch(NextTabWidget)
  self:StopAllAnimations()
  self:PlayAnimationForward(self.Ani_out)
  return false
end
function IllustratedGuideMenuView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    self:BindOnOutAnimationFinished()
  end
end
function IllustratedGuideMenuView:BindOnOutAnimationFinished()
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
end
return IllustratedGuideMenuView
