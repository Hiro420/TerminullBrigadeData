local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local PlayerInfoMainData = require("Modules.PlayerInfoMain.PlayerInfoMainData")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local PlayerInfoMainViewModel = CreateDefaultViewModel()
local PlayerInfoMainTypeToWidgetNameReflaction = {
  [EPlayerInfoMainToggleStatus.PlayerInfo] = ViewID.UI_PlayerInfo,
  [EPlayerInfoMainToggleStatus.History] = ViewID.UI_History,
  [EPlayerInfoMainToggleStatus.Achievement] = ViewID.UI_Achievement
}
PlayerInfoMainViewModel.propertyBindings = {}
PlayerInfoMainViewModel.subViewModels = {}
function PlayerInfoMainViewModel:OnInit()
  self.Super.OnInit(self)
end
function PlayerInfoMainViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end
function PlayerInfoMainViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
end
function PlayerInfoMainViewModel:UpdateRoleID(RoleID)
  self.CurRoleID = RoleID
end
function PlayerInfoMainViewModel:GetCurRoleID()
  return self.CurRoleID
end
function PlayerInfoMainViewModel:Switch(PlayerInfoMainToggleTypeParam)
  if self.CurShowWidgetName then
    local Widget = UIMgr:GetFromActiveView(self.CurShowWidgetName)
    if Widget then
      UIMgr:Hide(self.CurShowWidgetName, nil, false)
    end
  end
  local TargetWidgetName = PlayerInfoMainTypeToWidgetNameReflaction[PlayerInfoMainToggleTypeParam]
  if TargetWidgetName then
    UIMgr:Show(TargetWidgetName)
    self.CurShowWidgetName = TargetWidgetName
  end
end
function PlayerInfoMainViewModel:SelectToggleId(ToggleIdx)
  if self:GetFirstView() then
    self:GetFirstView().RGToggleGroupFirst:SelectId(ToggleIdx)
  end
end
function PlayerInfoMainViewModel:SwitchLink(PlayerInfoMainToggleTypeParam, LinkParams)
  if self.CurShowWidgetName then
    local Widget = UIMgr:GetFromActiveView(self.CurShowWidgetName)
    if Widget then
      UIMgr:Hide(self.CurShowWidgetName, nil, false)
    end
  end
  local TargetWidgetName = PlayerInfoMainTypeToWidgetNameReflaction[PlayerInfoMainToggleTypeParam]
  if TargetWidgetName then
    UIMgr:ShowLink(TargetWidgetName, nil, LinkParams)
    self.CurShowWidgetName = TargetWidgetName
  end
end
function PlayerInfoMainViewModel:HidePlayerMainView(withoutAnimation)
  if self:GetFirstView() then
    self:GetFirstView():ListenForEscInputAction(withoutAnimation)
  end
end
function PlayerInfoMainViewModel:UpdateHeroSkinDetailsView(skinId)
  if self:GetFirstView() then
    local result, row = GetRowData(DT.DT_DisplaySkinUIColor, skinId)
    if not result then
      result, row = GetRowData(DT.DT_DisplaySkinUIColor, "Default")
    end
    if result then
      self:GetFirstView():UpdateUIColor(row.UIColor)
    end
  end
end
function PlayerInfoMainViewModel:ResetData()
  local playerInfoVM = UIModelMgr:Get("PlayerInfoViewModel")
  playerInfoVM:ResetData()
  local battleHistoryViewModel = UIModelMgr:Get("BattleHistoryViewModel")
  battleHistoryViewModel:ResetData()
end
function PlayerInfoMainViewModel:CheckIsOwnerInfo(roleID)
  return roleID == DataMgr.GetUserId()
end
return PlayerInfoMainViewModel
