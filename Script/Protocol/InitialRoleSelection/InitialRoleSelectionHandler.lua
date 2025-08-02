local URGHttpHelper = UE.URGHttpHelper
local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local InitialRoleSelectionHandler = {}

function InitialRoleSelectionHandler.RequestSelectHero(HeroId)
  HttpCommunication.Request("hero/selecthero", {
    heroId = tonumber(HeroId)
  }, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      print("InitialRoleSelectionHandler.RequestSelectHero OnSelectHeroSucc!")
      DataMgr.SetMyHeroInfo(JsonTable)
      EventSystem.Invoke(EventDef.InitialRoleSelection.OnSelectRoleSucc, JsonTable)
      EventSystem.Invoke(EventDef.Lobby.UpdateMyHeroInfo)
      LogicOutsideWeapon.RequestEquippedWeaponInfo(HeroId)
      SkinHandler.SendGetHeroSkinList()
    end
  }, {
    GameInstance,
    function()
      print("InitialRoleSelectionHandler.RequestLoginDevToServer OnLoginFail!")
    end
  })
end

return InitialRoleSelectionHandler
