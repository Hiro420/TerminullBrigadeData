local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local LoginHandler = require("Protocol.LoginHandler")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local LoginRewardsViewModel = CreateDefaultViewModel()
LoginRewardsViewModel.propertyBindings = {}
LoginRewardsViewModel.subViewModels = {}

function LoginRewardsViewModel:OnInit()
  self.Super.OnInit(self)
  self.bFirstShow = true
  EventSystem.AddListener(self, EventDef.Lobby.OnUpdateAllowMultiPlayerTeam, self.RequesRewards)
end

function LoginRewardsViewModel:OnShutdown()
  self.Super.OnShutdown(self)
  EventSystem.RemoveListener(EventDef.Lobby.OnUpdateAllowMultiPlayerTeam, self.RequesRewards, self)
end

function LoginRewardsViewModel:RequesRewards()
  local Path = "playergrowth/sevendaylogin/info"
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local VM = UIModelMgr:Get("LoginRewardsViewModel")
      if VM then
        VM.Rewards = JsonTable.rewards
        EventSystem.Invoke(EventDef.Lobby.OnUpdateLoginRewards)
        if not VM.bFirstShow then
          return
        end
        if table.count(VM.Rewards) < 7 then
          local LobbyModule = ModuleManager:Get("LobbyModule")
          local viewData = {
            ViewID = ViewID.UI_LoginRewards,
            Params = {}
          }
          VM.bFirstShow = false
          LobbyModule:PushView(viewData)
        end
      end
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

function LoginRewardsViewModel:HaveRewards()
  local ServerOpenTime = DataMgr:GetServerOpenTime()
  local LocalTime = tonumber(os.time())
  local Days = math.floor((LocalTime - ServerOpenTime) / 86400 + 1)
  if Days > 7 then
    Days = 7
  end
  return Days > table.count(self.Rewards)
end

return LoginRewardsViewModel
