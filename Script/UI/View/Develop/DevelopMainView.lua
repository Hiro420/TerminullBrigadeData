local ViewBase = require("Framework.UIMgr.ViewBase")
local DevelopMainView = Class(ViewBase)
local ToggleIdToView = {
  [1] = {
    ViewID = "UI_WeaponMain",
    ToggleName = NSLOCTEXT("", "B26128334496CAB75BE7DC9E14429681", "\230\173\166\229\153\168"),
    ClickStatistics = "ReadinessWeapon"
  },
  [3] = {
    ViewID = "UI_ProficiencyView",
    ToggleName = NSLOCTEXT("", "AFCB50CA4C2A6CAEEDF09DB565E8DD09", "\231\134\159\231\187\131\229\186\166"),
    ClickStatistics = "ReadinessProficiency"
  },
  [4] = {
    ViewID = "UI_Puzzle",
    ToggleName = NSLOCTEXT("", "2122264B4499706A3EBBBDAA6343B165", "\230\136\152\230\150\151\231\159\169\233\152\181"),
    ClickStatistics = "ReadinessChip",
    SystemId = 3
  }
}

function DevelopMainView:BindClickHandler()
end

function DevelopMainView:UnBindClickHandler()
end

function DevelopMainView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function DevelopMainView:OnDestroy()
  self:UnBindClickHandler()
end

function DevelopMainView:OnShow(...)
  local param = {
    ...
  }
  local viewIdx = param[1] or 1
  table.remove(param, 1)
  self.WBP_ViewSet:OnShowViewSet(self, viewIdx, table.unpack(param))
  EventSystem.AddListenerNew(EventDef.Develop.UpdateViewSetVisible, self, self.OnUpdateViewSetVisible)
  self.bCanChangeHero = self.WBP_ViewSet.bCanChangeHero
  LogicRole.ShowOrLoadLevel(-1)
end

function DevelopMainView:OnShowLink(LinkParams, ...)
  local viewIdx = 1
  if LinkParams:IsValidIndex(1) then
    viewIdx = LinkParams:GetRef(1).IntParam
  end
  self.WBP_ViewSet:OnShowLink(viewIdx, ...)
end

function DevelopMainView:OnHide()
  self.WBP_ViewSet:OnHideViewSet()
  EventSystem.RemoveListenerNew(EventDef.Develop.UpdateViewSetVisible, self, self.OnUpdateViewSetVisible)
  self:HideFilterTips()
end

function DevelopMainView:HideFilterTips()
  if self.RGAutoLoadPanelFilterTips.ChildWidget then
    self.RGAutoLoadPanelFilterTips.ChildWidget:Hide(true)
  else
    UpdateVisibility(self.RGAutoLoadPanelFilterTips, false)
  end
end

function DevelopMainView:OnUpdateViewSetVisible(bIsShow, bShowOperator)
  if bShowOperator then
    UpdateVisibility(self.WBP_ViewSet.CanvasPanelRoot, bIsShow)
    UpdateVisibility(self.WBP_ViewSet.Hor_Operator, true)
  else
    UpdateVisibility(self.WBP_ViewSet, bIsShow)
    self.bCanChangeHero = bIsShow
  end
end

function DevelopMainView:GetShowParamsByViewId(ViewId)
  if ViewId == ViewID.UI_WeaponMain then
    return {
      self.WBP_ViewSet:GetCurShowHeroId(),
      true,
      0
    }
  elseif ViewId == ViewID.UI_Chip then
    return {
      self.WBP_ViewSet:GetCurShowHeroId(),
      self
    }
  elseif ViewId == ViewID.UI_Puzzle then
    return {
      self.WBP_ViewSet:GetCurShowHeroId()
    }
  elseif ViewId == ViewID.UI_ProficiencyView then
    return {
      self.WBP_ViewSet:GetCurShowHeroId()
    }
  end
end

function DevelopMainView:PreShowSubView(ViewId)
  if ViewId == ViewID.UI_WeaponMain then
    local curHeroId = self.WBP_ViewSet:GetCurShowHeroId()
    local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(curHeroId)
    if EquippedWeaponInfo and EquippedWeaponInfo[1] then
    else
      LogicOutsideWeapon.RequestEquippedWeaponInfo(curHeroId)
    end
    EventSystem.Invoke(EventDef.Lobby.WeaponListChanged)
  elseif ViewId == ViewID.UI_Chip then
  elseif ViewId == ViewID.UI_Puzzle then
  elseif ViewId == ViewID.UI_ProficiencyView then
  end
end

function DevelopMainView:HideUI(bIsShow)
  UpdateVisibility(self.CanvasPanelRoot, bIsShow)
end

function DevelopMainView:GetCanChangeHero()
  return self.bCanChangeHero
end

function DevelopMainView:GetToggleIdToView()
  return DeepCopy(ToggleIdToView)
end

return DevelopMainView
