local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local SkinHandler = {}
function SkinHandler.SendEquipHeroSkinReq(HeroId, skinId)
  local url = "hero/equipheroskin"
  HttpCommunication.Request(url, {heroID = HeroId, skinID = skinId}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Skin.OnEquipHeroSkin, JsonTable, HeroId, skinId)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function SkinHandler.SendGetHeroSkinList()
  local url = "hero/getheroskinlist"
  HttpCommunication.RequestByGet(url, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for k, vSkinData in pairs(SkinData.HeroSkinMap) do
        for iHeroSkinData, vHeroSkinData in ipairs(vSkinData.SkinDataList) do
          vHeroSkinData.bUnlocked = false
          vHeroSkinData.expireAt = nil
          for i, v in ipairs(JsonTable.heroSkinInfos) do
            if vHeroSkinData.HeroSkinTb.SkinID == v.skinID then
              vHeroSkinData.bUnlocked = true
              vHeroSkinData.expireAt = v.expireAt
              print("SkinHandler.SendGetHeroSkinList", vHeroSkinData.HeroSkinTb.SkinID, v.expireAt)
            end
          end
        end
      end
      EventSystem.Invoke(EventDef.Skin.OnGetHeroSkinList, JsonTable.heroSkinInfos)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function SkinHandler.SendEquipWeaponSkinReq(SkinId, WeaponId)
  local url = "hero/equipweaponskin"
  HttpCommunication.Request(url, {skinID = SkinId, weaponID = WeaponId}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      EventSystem.Invoke(EventDef.Skin.OnEquipWeaponSkin, JsonTable, SkinId, WeaponId)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function SkinHandler.SendGetWeaponSkinList()
  local url = "hero/getweaponskinlist"
  HttpCommunication.RequestByGet(url, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if JsonTable.weaponSkinList then
        for i, v in ipairs(JsonTable.weaponSkinInfos) do
          for k, vSkinData in pairs(SkinData.WeaponSkinMap) do
            for iWeaponSkinData, vWeaponSkinData in ipairs(vSkinData.SkinDataList) do
              if vWeaponSkinData.WeaponSkinTb.SkinID == v.skinID then
                vWeaponSkinData.bUnlocked = true
                vWeaponSkinData.expireAt = v.expireAt
              end
            end
          end
        end
      end
      EventSystem.Invoke(EventDef.Skin.OnGetWeaponSkinList, JsonTable.weaponSkinList)
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function SkinHandler.SendBuyHeroSkin(SkinId)
  local url = "hero/buyheroskin"
  HttpCommunication.Request(url, {skinID = SkinId}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      SkinHandler.SendGetHeroSkinList()
      LogicRole.RequestMyHeroInfoToServer()
    end
  }, {
    GameInstance,
    function()
    end
  })
end
function SkinHandler.SendSetHeroSkinEffectState(EffectState, SkinId)
  local url = "hero/setheroskineffectstate"
  HttpCommunication.Request(url, {effectState = EffectState, skinID = SkinId}, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      LogicRole.RequestMyHeroInfoToServer()
    end
  }, {
    GameInstance,
    function()
    end
  })
end
return SkinHandler
