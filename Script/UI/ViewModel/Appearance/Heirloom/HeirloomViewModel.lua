local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local AppearanceData = require("Modules.Appearance.AppearanceData")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local AppearanceData = require("Modules.Appearance.AppearanceData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local HeirloomHandler = require("Protocol.Appearance.Heirloom.HeirloomHandler")
local HeirloomViewModel = CreateDefaultViewModel()
HeirloomViewModel.propertyBindings = {}
HeirloomViewModel.subViewModels = {}
function HeirloomViewModel:OnInit()
  self.Super.OnInit(self)
  HeirloomData:DealWithHeirloomTable()
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomUpgradeSuccess, self.BindOnHeirloomUpgradeSuccess)
end
function HeirloomViewModel:BindOnHeirloomUpgradeSuccess(HeirloomId, Level)
  UIMgr:Show(ViewID.UI_HeirloomUpgradeSuccess, nil, HeirloomId, Level, self:GetCurOperateHeroId())
end
function HeirloomViewModel:GetCurOperateHeroId()
  return AppearanceData.CurHeroId
end
function HeirloomViewModel:GetAllHeirloomByCurOperateHeroId()
  local HeirloomList = HeirloomData:GetAllHeirloomByHeroId(AppearanceData.CurHeroId)
  return HeirloomList
end
function HeirloomViewModel:GetEquipedWeaponSkinIdByWeaponResId(WeaponResId)
  return SkinData.GetEquipedWeaponSkinIdByWeaponResId(WeaponResId)
end
function HeirloomViewModel:RequestGetFamilyTreasureToServer()
  HeirloomHandler:RequestGetFamilytreasureToServer()
end
function HeirloomViewModel:RequestUpgradeFamilyTreasureToServer(Id)
  HeirloomHandler:RequestUpgradeFamilyTreasure(Id)
end
function HeirloomViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  EventSystem.RemoveListener(EventDef.Heirloom.OnHeirloomUpgradeSuccess, self.BindOnHeirloomUpgradeSuccess, self)
end
return HeirloomViewModel
