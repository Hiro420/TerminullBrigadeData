local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local LoginHandler = require("Protocol.LoginHandler")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local ProficiencyViewModel = CreateDefaultViewModel()
ProficiencyViewModel.propertyBindings = {}
ProficiencyViewModel.subViewModels = {}

function ProficiencyViewModel:OnInit()
  self.Super.OnInit(self)
  ProficiencyData:DealWithTable()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo)
end

function ProficiencyViewModel:OnShutdown()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo, self)
  self.Super.OnShutdown(self)
end

function ProficiencyViewModel:UpdateCurHeroId(...)
  local tbParam = {
    ...
  }
  local CurHeroId = tbParam[1]
  self.CurHeroId = CurHeroId
end

function ProficiencyViewModel:GetCurHeroId()
  return self.CurHeroId
end

function ProficiencyViewModel:GetMaxUnlockProfyLevel()
  return ProficiencyData:GetMaxUnlockProfyLevel(self.CurHeroId)
end

function ProficiencyViewModel:GetEquippedSkinIdByHeroId(HeroId)
  return SkinData.GetEquipedSkinIdByHeroId(HeroId)
end

function ProficiencyViewModel:BindOnUpdateMyHeroInfo()
  if self:GetFirstView() then
    self:GetFirstView():RefreshLevelAndExpInfo()
  end
end

function ProficiencyViewModel:ResetData()
  self.CurSelectGearLv = nil
  self.CurHeroId = nil
end

return ProficiencyViewModel
