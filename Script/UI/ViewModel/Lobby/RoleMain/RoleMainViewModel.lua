local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local RoleMainViewModel = CreateDefaultViewModel()
RoleMainViewModel.propertyBindings = {
  BasicInfo = {}
}
RoleMainViewModel.subViewModels = {}

function RoleMainViewModel:OnInit()
  self.Super.OnInit(self)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateHeroTalentInfo, self.BindOnHeroTalentInfoUpdate)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateCommonTalentInfo, self.BindOnUpdateCommonTalentInfo)
  EventSystem.AddListener(self, EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged)
  EventSystem.AddListener(self, EventDef.Lobby.WeaponSlotSelected, self.BindOnWeaponSlotSelected)
  EventSystem.AddListener(self, EventDef.Lobby.WeaponListChanged, self.BindOnWeaponListChanged)
  EventSystem.AddListener(self, EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, self.BindOnLobbyWeaponSlotHoverStatusChanged)
end

function RoleMainViewModel:RegisterPropertyChanged(BindingTable, View)
  self.Super.RegisterPropertyChanged(self, BindingTable, View)
end

function RoleMainViewModel:UnRegisterPropertyChanged(BindingTable, View)
  self.Super.UnRegisterPropertyChanged(self, BindingTable, View)
end

function RoleMainViewModel:BindOnHeroTalentInfoUpdate(HeroId)
  if self:GetFirstView() then
    self:GetFirstView():BindOnHeroTalentInfoUpdate(HeroId)
  end
end

function RoleMainViewModel:BindOnUpdateCommonTalentInfo()
  if self:GetFirstView() then
  end
end

function RoleMainViewModel:BindOnEquippedWeaponInfoChanged(HeroId)
  if self:GetFirstView() then
    self:GetFirstView():BindOnEquippedWeaponInfoChanged(HeroId)
  end
end

function RoleMainViewModel:BindOnWeaponSlotSelected(IsSelect, SlotId)
  if self:GetFirstView() then
    self:GetFirstView():BindOnWeaponSlotSelected(IsSelect, SlotId)
  end
end

function RoleMainViewModel:BindOnWeaponListChanged()
  local IsShow = UIMgr:IsShow(ViewID.UI_RoleMain)
  if self:GetFirstView() and IsShow then
    self:GetFirstView():BindOnWeaponListChanged()
  end
end

function RoleMainViewModel:BindOnLobbyWeaponSlotHoverStatusChanged(IsHover, WeaponInfo)
  if self:GetFirstView() then
    self:GetFirstView():BindOnLobbyWeaponSlotHoverStatusChanged(IsHover, WeaponInfo)
  end
end

function RoleMainViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateHeroTalentInfo, self.BindOnHeroTalentInfoUpdate, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateCommonTalentInfo, self.BindOnUpdateCommonTalentInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponSlotSelected, self.BindOnWeaponSlotSelected, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponListChanged, self.BindOnWeaponListChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, self.BindOnLobbyWeaponSlotHoverStatusChanged, self)
end

return RoleMainViewModel
