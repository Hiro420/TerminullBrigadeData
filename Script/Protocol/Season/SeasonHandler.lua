local UnLua = _G.UnLua
local rapidjson = require("rapidjson")
local ChipData = require("Modules.Chip.ChipData")
local tbChip = LuaTableMgr.GetLuaTableByName(TableNames.TBResChip)
local SeasonHandler = {}

function SeasonHandler.RequestSelectedPastGrowthSeasonID(SeasonID)
  local param = {seasonID = SeasonID}
  local path = "playerservice/selectedpastgrowthseasonid"
  HttpCommunication.Request(path, param, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestSelectedPastGrowthSeasonID", JsonResponse.Content)
      DataMgr.SetCurSelectPastSeasonID(SeasonID)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

function SeasonHandler.RequestGetHeroInfoBySeasonID(SeasonID)
  local path = string.format("hero/getheroinfobyseasonid?seasonID=%d", SeasonID)
  HttpCommunication.RequestByGet(path, {
    GameInstance,
    function(Target, JsonResponse)
      print("RequestGetHeroInfoBySeasonID" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

function SeasonHandler.GetPuzzlePackageBySeasonID(SeasonID)
  local path = string.format("hero/getpuzzlepackagebyseasonid?seasonID=%d", SeasonID)
  HttpCommunication.RequestByGet(path, {
    GameInstance,
    function(Target, JsonResponse)
      print("GetPuzzlePackageBySeasonID" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

function SeasonHandler:GetGemPackageBySeasonID(SeasonID)
  local path = string.format("hero/getgempackagebyseasonid?seasonID=%d", SeasonID)
  HttpCommunication.RequestByGet(path, {
    GameInstance,
    function(Target, JsonResponse)
      print("GetGemPackageBySeasonID" .. JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
    end
  }, {
    GameInstance,
    function()
    end
  }, false, true)
end

return SeasonHandler
