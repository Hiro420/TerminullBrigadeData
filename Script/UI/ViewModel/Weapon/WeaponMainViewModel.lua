local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local LoginHandler = require("Protocol.LoginHandler")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local WeaponMainViewModel = CreateDefaultViewModel()
WeaponMainViewModel.propertyBindings = {WeaponStatus = true, EquipWeaonInfo = nil}
WeaponMainViewModel.subViewModels = {}

function WeaponMainViewModel:OnInit()
  self.Super.OnInit(self)
end

function WeaponMainViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

function WeaponMainViewModel:UpdateCurHeroId(...)
  local tbParam = {
    ...
  }
  local CurHeroId = tbParam[1]
  self.CurHeroId = CurHeroId
  local WeaponSubViewModel = UIModelMgr:Get("WeaponSubViewModel")
  WeaponSubViewModel:EmptySelectWeaponId()
  WeaponSubViewModel:UpdateCurHeroId(CurHeroId)
  self:Switch(true)
end

function WeaponMainViewModel:SetCloseCallback(CloseCallback)
  local WeaponSubViewModel = UIModelMgr:Get("WeaponSubViewModel")
  WeaponSubViewModel:SetCloseCallback(CloseCallback)
end

function WeaponMainViewModel:Switch(WeaponStatusParam, SlotIdx, weaponResId, playAni)
  local WeaponSubViewModel = UIModelMgr:Get("WeaponSubViewModel")
  if UIMgr:IsShow(ViewID.UI_WeaponSub) then
    local weaponSub = UIMgr:GetLuaFromActiveView(ViewID.UI_WeaponSub)
    if weaponSub then
      weaponSub:Refresh()
    end
  else
    UIMgr:Show(ViewID.UI_WeaponSub)
  end
  WeaponSubViewModel:SwitchWeaponInfo(true, weaponResId, playAni)
end

return WeaponMainViewModel
