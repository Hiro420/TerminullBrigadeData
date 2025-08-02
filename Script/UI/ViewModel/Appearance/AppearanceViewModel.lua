local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local AppearanceData = require("Modules.Appearance.AppearanceData")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local AppearanceViewModel = CreateDefaultViewModel()
AppearanceViewModel.propertyBindings = {
  AppearanceToggleType = EAppearanceToggleStatus.Skin
}
AppearanceViewModel.subViewModels = {}

function AppearanceViewModel:OnInit()
  self.Super.OnInit(self)
end

function AppearanceViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

local AppearanceTypeToWidgetNameReflaction = {
  [EAppearanceToggleStatus.Skin] = ViewID.UI_Skin,
  [EAppearanceToggleStatus.Heirloom] = ViewID.UI_Heirloom,
  [EAppearanceToggleStatus.Communication] = ViewID.UI_Communication
}

function AppearanceViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
  EventSystem.Invoke(EventDef.Lobby.WeaponListChanged)
end

function AppearanceViewModel:Switch(AppearanceToggleTypeParam)
  if self.CurShowWidgetName then
    local Widget = UIMgr:GetFromActiveView(self.CurShowWidgetName)
    if Widget then
      UIMgr:Hide(self.CurShowWidgetName, nil, false)
    end
  end
  local TargetWidgetName = AppearanceTypeToWidgetNameReflaction[AppearanceToggleTypeParam]
  if TargetWidgetName then
    UIMgr:Show(TargetWidgetName)
    self.CurShowWidgetName = TargetWidgetName
  end
end

function AppearanceViewModel:SwitchLink(AppearanceToggleTypeParam, LinkParams)
  if self.CurShowWidgetName then
    local Widget = UIMgr:GetFromActiveView(self.CurShowWidgetName)
    if Widget then
      UIMgr:Hide(self.CurShowWidgetName, nil, false)
    end
  end
  local TargetWidgetName = AppearanceTypeToWidgetNameReflaction[AppearanceToggleTypeParam]
  if TargetWidgetName then
    UIMgr:ShowLink(TargetWidgetName, nil, LinkParams)
    self.CurShowWidgetName = TargetWidgetName
  end
end

function AppearanceViewModel:UpdateCurHeroId(...)
  self:Switch(true)
  local tbParam = {
    ...
  }
  local CurHeroId = tbParam[1]
  local SkinViewModel = UIModelMgr:Get("SkinViewModel")
  local CommunicationViewModel = UIModelMgr:Get("CommunicationViewModel")
  SkinViewModel:UpdateCurHeroId(CurHeroId)
  CommunicationViewModel:UpdateCurHeroId(CurHeroId)
  AppearanceData:SetCurHeroId(CurHeroId)
end

function AppearanceViewModel:UpdateHeroSkinDetailsView(skinId)
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

function AppearanceViewModel:UpdateUIColor(Color)
  if self:GetFirstView() then
    self:GetFirstView():UpdateUIColor(Color)
  end
end

return AppearanceViewModel
