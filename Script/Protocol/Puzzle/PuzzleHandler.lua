local PuzzleHandler = {}
local rapidjson = require("rapidjson")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local GemData = require("Modules.Gem.GemData")
local PuzzleInfoConfig = require("GameConfig.Puzzle.PuzzleInfoConfig")

function PuzzleHandler:RequestEquipPuzzleToServer(PuzzleId, HeroId, SlotIdList)
  local JsonParams = {
    heroID = HeroId,
    positions = {slotIDs = SlotIdList},
    uniqueID = PuzzleId
  }
  HttpCommunication.Request("hero/equippuzzle", JsonParams, {
    GameInstance,
    function()
      print("PuzzleHandler:RequestEquipPuzzleToServer Success!")
      local OldSlotIdList = PuzzleData:GetSlotListByPuzzleId(PuzzleId)
      if OldSlotIdList then
        for i, SingleSlotId in ipairs(OldSlotIdList) do
          PuzzleData:RefreshSlotStatus(SingleSlotId, EPuzzleSlotStatus.Empty)
        end
      end
      for index, SingleSlotId in ipairs(SlotIdList) do
        PuzzleData:RefreshSlotStatus(SingleSlotId, PuzzleId)
      end
      local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
      PuzzleData:RemoveEquipPuzzleId(PackageInfo.equipHeroID, PuzzleId)
      PuzzleData:SetSlotEquipId(PuzzleId, SlotIdList)
      PuzzleData:SetPuzzleEquipHeroId(PuzzleId, HeroId)
      PuzzleData:AddEquipPuzzleId(HeroId, PuzzleId)
      EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, {PuzzleId})
      EventSystem.Invoke(EventDef.Puzzle.OnEquipPuzzleSuccess, PuzzleId)
    end
  })
end

function PuzzleHandler:RequestGetAllPuzzleDetailToServer()
  HttpCommunication.Request("hero/getallpuzzledetail", {}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestGetAllPuzzleDetailToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, SinglePuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, SinglePuzzleDetailInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo)
    end
  })
end

function PuzzleHandler:RequestGetPuzzleDetailToServer(PuzzleIdList)
  local JsonParams = {puzzleIDs = PuzzleIdList}
  HttpCommunication.Request("hero/getpuzzledetail", JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestGetPuzzleDetailToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, SinglePuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, SinglePuzzleDetailInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestLockPuzzleToServer(PuzzleId)
  local JsonParams = {uniqueID = PuzzleId}
  HttpCommunication.Request("hero/lockpuzzle", JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestLockPuzzleToServer Success!")
      PuzzleData:SetPuzzleState(PuzzleId, EPuzzleStatus.Lock)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, {PuzzleId})
    end
  })
end

function PuzzleHandler:RequestPuzzlepackageToServer()
  HttpCommunication.RequestByGet("hero/puzzlepackage", {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestPuzzlepackageToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for i, SinglePuzzleInfo in ipairs(JsonTable.puzzles) do
        PuzzleData:SetPuzzlePackageInfo(SinglePuzzleInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo)
    end
  })
end

function PuzzleHandler:RequestGetPuzzleSlotUnlockInfo()
  HttpCommunication.RequestByGet("hero/puzzleslotunlockinfo", {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestGetPuzzleSlotUnlockInfo Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      PuzzleData:SetPuzzleUnlockSlotList(JsonTable.slotIDs)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleSlotUnlockInfo)
    end
  })
end

function PuzzleHandler:RequestUnEquipPuzzleToServer(PuzzleId, HeroId)
  local JsonParams = {heroID = HeroId, uniqueID = PuzzleId}
  HttpCommunication.Request("hero/unequippuzzle", JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestUnEquipPuzzleToServer Success!", JsonResponse.Content)
      local OldSlotIdList = PuzzleData:GetSlotListByPuzzleId(PuzzleId)
      if OldSlotIdList then
        for i, SingleSlotId in ipairs(OldSlotIdList) do
          PuzzleData:RefreshSlotStatus(SingleSlotId, EPuzzleSlotStatus.Empty)
        end
      end
      PuzzleData:SetSlotEquipId(PuzzleId, nil)
      PuzzleData:SetPuzzleEquipHeroId(PuzzleId, 0)
      PuzzleData:RemoveEquipPuzzleId(HeroId, PuzzleId)
      EventSystem.Invoke(EventDef.Puzzle.RefreshPuzzleboardItemStatus)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, {PuzzleId})
      EventSystem.Invoke(EventDef.Puzzle.OnUnEquipPuzzleSuccess, PuzzleId)
    end
  })
end

function PuzzleHandler:RequestUnEquipHeroAllPuzzleToServer(HeroId)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  for PuzzleId, PuzzlePackageInfo in pairs(AllPackageInfo) do
    if PuzzlePackageInfo.equipHeroID == HeroId then
      self:RequestUnEquipPuzzleToServer(PuzzleId, HeroId)
    end
  end
end

function PuzzleHandler:RequestUpgradePuzzleToServer(PuzzleId, TargetLevel)
end

function PuzzleHandler:RequestResetPuzzleToServer(PuzzleId)
  HttpCommunication.Request("hero/resetpuzzle", {uniqueID = PuzzleId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestResetPuzzleToServer Success!")
      local PuzzleDetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleId)
      local TargetPuzzleDetailInfo = {
        MainAttrGrowth = {},
        SubAttrGrowth = {},
        SubAttrInitV2 = PuzzleDetailInfo.SubAttrInitV2,
        GemSlotInfo = PuzzleDetailInfo.GemSlotInfo,
        GodSubAttrIDs = PuzzleDetailInfo.GodSubAttrIDs
      }
      PuzzleData:SetPuzzleLevel(PuzzleId, 0)
      PuzzleData:SetPuzzleDetailInfo(PuzzleId, TargetPuzzleDetailInfo)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, {PuzzleId})
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, {PuzzleId})
    end
  })
end

function PuzzleHandler:RequestDecomposePuzzleToServer(PuzzleIdList)
  HttpCommunication.Request("hero/decomposepuzzle", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestDecomposePuzzleToServer Success!")
      for i, SinglePuzzleId in ipairs(PuzzleIdList) do
        PuzzleData:RemovePuzzlePackageInfo(SinglePuzzleId)
        PuzzleData:SetPuzzleDetailInfo(SinglePuzzleId, nil)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnDecomposePuzzleSuccess, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestDiscardPuzzleToServer(PuzzleId)
  HttpCommunication.Request("hero/discardpuzzle", {uniqueID = PuzzleId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestDiscardPuzzleToServer Success!")
      PuzzleData:SetPuzzleState(PuzzleId, EPuzzleStatus.Discard)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, {PuzzleId})
    end
  })
end

function PuzzleHandler:RequestCancelLockOrDiscardPuzzle(PuzzleId)
  HttpCommunication.Request("hero/cancellockordiscardpuzzle", {uniqueID = PuzzleId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestCancelLockOrDiscardPuzzle Success!")
      PuzzleData:SetPuzzleState(PuzzleId, EPuzzleStatus.Normal)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, {PuzzleId})
    end
  })
end

function PuzzleHandler:RequestWashPuzzleFirstSubAttrToServer(PuzzleIdList)
  HttpCommunication.Request("hero/washpuzzlefirstsubattr", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestWashPuzzleFirstSubAttrToServer Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, PuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, PuzzleDetailInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestWashPuzzleLastSubAttrToServer(PuzzleIdList)
  HttpCommunication.Request("hero/washpuzzlelastsubattr", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestWashPuzzleLastSubAttrToServer Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, PuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, PuzzleDetailInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestWashPuzzleSubAttrToServer(PuzzleIdList)
  HttpCommunication.Request("hero/washpuzzlesubattr", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestWashPuzzleSubAttrToServer Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, PuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, PuzzleDetailInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestWashPuzzleSubAttrValueToServer(PuzzleIdList)
  HttpCommunication.Request("hero/washpuzzlesubattrvalue", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestWashPuzzleSubAttrValueToServer Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, PuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, PuzzleDetailInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestWashPuzzleInscriptionToServer(PuzzleIdList)
  HttpCommunication.Request("hero/washpuzzleinscription", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestWashPuzzleInscriptionToServer Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, PuzzlePackageInfo in pairs(JsonTable.puzzles) do
        PuzzleData:SetPuzzlePackageInfo(PuzzlePackageInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestWashPuzzleShapeToServer(PuzzleIdList)
  HttpCommunication.Request("hero/washpuzzleshape", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestWashPuzzleShapeToServer Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, PuzzlePackageInfo in pairs(JsonTable.puzzles) do
        PuzzleData:SetPuzzlePackageInfo(PuzzlePackageInfo)
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, PuzzleIdList)
    end
  })
end

function PuzzleHandler:RequestWashPuzzleSlotAmountToServer(PuzzleIdList)
  HttpCommunication.Request("hero/washpuzzleslotamount", {uniqueIDs = PuzzleIdList}, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestWashPuzzleSlotAmount Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      local ChangedGemIdList = {}
      for PuzzleId, PuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        local OldGemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(PuzzleId)
        local CurEquipGemIdList = {}
        for SlotIndex, GemId in pairs(PuzzleDetailInfo.GemSlotInfo) do
          if "0" ~= GemId then
            CurEquipGemIdList[GemId] = 1
          end
        end
        for SlotIndex, GemId in pairs(OldGemSlotInfo) do
          if "0" ~= GemId and not CurEquipGemIdList[GemId] then
            table.insert(ChangedGemIdList, GemId)
            GemData:SetGemEquipPuzzleId(GemId, "0")
          end
        end
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, PuzzleDetailInfo)
      end
      table.Print(JsonTable.puzzlesdetail)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, PuzzleIdList)
      EventSystem.Invoke(EventDef.Puzzle.OnWashPuzzleSlotAmountSuccess, PuzzleIdList)
      if next(ChangedGemIdList) ~= nil then
        EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo)
      end
    end
  })
end

function PuzzleHandler:RequestPuzzleMutationToServer(PuzzleIdList, IsSeniorMutation)
  local JsonParams = {uniqueIDs = PuzzleIdList, isSeniorMutation = IsSeniorMutation}
  HttpCommunication.Request("hero/puzzlemutation", JsonParams, {
    GameInstance,
    function(Target, JsonResponse)
      print("PuzzleHandler:RequestPuzzleMutationToServer Success!")
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for PuzzleId, PuzzlePackageInfo in pairs(JsonTable.puzzles) do
        PuzzleData:SetPuzzlePackageInfo(PuzzlePackageInfo)
      end
      local PuzzleDetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleIdList[1])
      local OldMutationAttrInfo
      for i, SingleAttrInfo in ipairs(PuzzleDetailInfo.SubAttrInitV2) do
        if SingleAttrInfo.mutationType ~= EMutationType.Normal then
          OldMutationAttrInfo = SingleAttrInfo
          break
        end
      end
      local MutationResultTipId = 0
      local MutationResult = EMutationType.Normal
      for PuzzleId, PuzzleDetailInfo in pairs(JsonTable.puzzlesdetail) do
        PuzzleData:SetPuzzleDetailInfo(PuzzleId, PuzzleDetailInfo)
        local NewMutationAttrInfo
        for i, SingleAttrInfo in ipairs(PuzzleDetailInfo.SubAttrInitV2) do
          if SingleAttrInfo.mutationType ~= EMutationType.Normal then
            NewMutationAttrInfo = SingleAttrInfo
            break
          end
        end
        if not OldMutationAttrInfo then
          if not NewMutationAttrInfo then
            MutationResultTipId = PuzzleInfoConfig.MutataionNotChangeTipId
          elseif NewMutationAttrInfo.mutationType == EMutationType.NegaMutation then
            MutationResultTipId = PuzzleInfoConfig.MutationFailTipId
          elseif NewMutationAttrInfo.mutationType == EMutationType.PosMutation then
            MutationResultTipId = PuzzleInfoConfig.MutationSuccessTipId
          end
        elseif OldMutationAttrInfo.mutationType == EMutationType.NegaMutation then
          MutationResultTipId = PuzzleInfoConfig.MutationSuccessTipId
        elseif OldMutationAttrInfo.attrID == NewMutationAttrInfo.attrID and OldMutationAttrInfo.value == NewMutationAttrInfo.value then
          MutationResultTipId = PuzzleInfoConfig.MutataionNotChangeTipId
        else
          MutationResultTipId = PuzzleInfoConfig.MutationSuccessTipId
        end
        if 0 ~= MutationResultTipId then
          ShowWaveWindow(MutationResultTipId)
        end
      end
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzlePackageInfo, PuzzleIdList)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, PuzzleIdList)
    end
  })
end

return PuzzleHandler
