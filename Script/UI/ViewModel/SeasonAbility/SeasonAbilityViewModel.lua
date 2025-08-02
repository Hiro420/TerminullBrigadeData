local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local StringExt = require("Utils.StringExt")
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local SeasonAbilityViewModel = CreateDefaultViewModel()
SeasonAbilityViewModel.propertyBindings = {}
SeasonAbilityViewModel.subViewModels = {}

function SeasonAbilityViewModel:OnInit()
  self.Super.OnInit(self)
  SeasonAbilityData:DealWithTable()
  self:DealWithTable()
end

function SeasonAbilityViewModel:DealWithTable()
  self.HeroSeasonAbilityTableInfo = {}
  local HeroSeasonAbilityTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroSeasonAbility)
  for k, SingleRowInfo in pairs(HeroSeasonAbilityTable) do
    self.HeroSeasonAbilityTableInfo[SingleRowInfo.HeroID] = SingleRowInfo
  end
end

function SeasonAbilityViewModel:GetHeroSeasonAbilityRowInfo(HeroId)
  return self.HeroSeasonAbilityTableInfo[HeroId]
end

function SeasonAbilityViewModel:GetCurHeroId()
  return self.CurHeroId
end

function SeasonAbilityViewModel:SetCurHeroId(InHeroId)
  self.CurHeroId = InHeroId
end

function SeasonAbilityViewModel:OnShutdown()
  self.Super.OnShutdown(self)
end

return SeasonAbilityViewModel
