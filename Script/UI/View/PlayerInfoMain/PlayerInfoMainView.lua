local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local EscName = "PauseGame"
local SubViewId = {
  ViewID.UI_PlayerInfo,
  ViewID.UI_History,
  ViewID.UI_Achievement
}
local CurrentToggleIndex = 1
local PlayerInfoMainView = Class(ViewBase)

function PlayerInfoMainView:OnBindUIInput()
  self.WBP_InteractTipWidgetMenuPrev:BindInteractAndClickEvent(self, self.BindOnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:BindInteractAndClickEvent(self, self.BindOnSelectNextMenu)
end

function PlayerInfoMainView:OnUnBindUIInput()
  self.WBP_InteractTipWidgetMenuPrev:UnBindInteractAndClickEvent(self, self.BindOnSelectPrevMenu)
  self.WBP_InteractTipWidgetMenuNext:UnBindInteractAndClickEvent(self, self.BindOnSelectNextMenu)
end

function PlayerInfoMainView:BindClickHandler()
  self.RGToggleGroupFirst.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
end

function PlayerInfoMainView:UnBindClickHandler()
  self.RGToggleGroupFirst.OnCheckStateChanged:Remove(self, self.OnFirstGroupCheckStateChanged)
end

function PlayerInfoMainView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("PlayerInfoMainViewModel")
  self:BindClickHandler()
end

function PlayerInfoMainView:OnDestroy()
  self:UnBindClickHandler()
end

function PlayerInfoMainView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  local param = {
    ...
  }
  local roleID = param[1]
  self.viewModel:UpdateRoleID(roleID)
  local bIsOwnerInfo = roleID == DataMgr.GetUserId()
  UpdateVisibility(self.Canvas_ToggleAchievement, bIsOwnerInfo)
  self.RGToggleGroupFirst:SelectId(EPlayerInfoMainToggleStatus.PlayerInfo)
  self.bIsAppearanceViewIsShow = false
end

function PlayerInfoMainView:BindOnSelectPrevMenu()
  CurrentToggleIndex = CurrentToggleIndex - 1
  if CurrentToggleIndex < 1 then
    CurrentToggleIndex = #SubViewId
  end
  self.RGToggleGroupFirst:SelectId(CurrentToggleIndex)
end

function PlayerInfoMainView:BindOnSelectNextMenu()
  CurrentToggleIndex = CurrentToggleIndex + 1
  if CurrentToggleIndex > #SubViewId then
    CurrentToggleIndex = 1
  end
  self.RGToggleGroupFirst:SelectId(CurrentToggleIndex)
end

function PlayerInfoMainView:OnShowLink(LinkParams)
  local firstToggleIdx = 1
  if LinkParams:IsValidIndex(1) then
    firstToggleIdx = LinkParams:GetRef(1).IntParam
  end
  self.RGToggleGroupFirst:SelectId(firstToggleIdx)
  self.viewModel:SwitchLink(firstToggleIdx, LinkParams)
end

function PlayerInfoMainView:OnHide()
  self.viewModel:ResetData()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end

function PlayerInfoMainView:ListenForEscInputAction(withoutAnimation)
  for i, v in ipairs(SubViewId) do
    local luaInst = UIMgr:GetLuaFromActiveView(v)
    if luaInst and UE.RGUtil.IsUObjectValid(luaInst) then
      UpdateVisibility(luaInst, true)
    end
    UIMgr:Hide(v, false, false, withoutAnimation)
  end
  UIMgr:Hide(ViewID.UI_PlayerInfoMain, true, false, withoutAnimation)
end

function PlayerInfoMainView:UpdateUIColor(UIColor)
  self.RGTextTitle:SetColorAndOpacity(UIColor)
  self.RGTextRoleName:SetColorAndOpacity(UIColor)
end

function PlayerInfoMainView:OnFirstGroupCheckStateChanged(SelectId)
  print("PlayerInfoMainView:OnFirstGroupCheckStateChanged", SelectId)
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr then
    if SelectId == EPlayerInfoMainToggleStatus.Achievement then
      if not SystemOpenMgr:IsSystemOpen(SystemOpenID.ACHIEVEMENT) then
        return
      end
    elseif SelectId == EPlayerInfoMainToggleStatus.History and not SystemOpenMgr:IsSystemOpen(SystemOpenID.HISTORY) then
      return
    end
  end
  self.viewModel:Switch(SelectId)
  CurrentToggleIndex = SelectId
end

return PlayerInfoMainView
