local GemHandler = {}
local rapidjson = require("rapidjson")
local GemData = require("Modules.Gem.GemData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local PuzzleInfoConfig = require("GameConfig.Puzzle.PuzzleInfoConfig")
function GemHandler:RequestCancelLockOrDiscardGemToServer(GemId)
  HttpCommunication.Request("hero/cancellockordiscardgem", {uniqueID = GemId}, {
    GameInstance,
    function(Target, JsonResponse)
      print("GemHandler:RequestCancelLockOrDiscardGemToServer Success!")
      GemData:SetGemState(GemId, EGemStatus.Normal)
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo, GemId)
    end
  })
end
function GemHandler:RequestDecomposeGemsToServer(IdList)
  HttpCommunication.Request("hero/decomposegems", {gemUniqueIDs = IdList}, {
    GameInstance,
    function()
      print("GemHandler:RequestDecomposeGemsToServer Success!")
      for index, SingleGemId in ipairs(IdList) do
        GemData:RemoveGemPackageInfo(SingleGemId)
      end
      EventSystem.Invoke(EventDef.Gem.OnGemDecomposeSuccess)
    end
  })
end
function GemHandler:RequestDiscardGemToServer(Id)
  HttpCommunication.Request("hero/discardgem", {uniqueID = Id}, {
    GameInstance,
    function()
      print("GemHandler:RequestDiscardGemToServer Success!")
      GemData:SetGemState(Id, EGemStatus.Discard)
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo, Id)
    end
  })
end
function GemHandler:RequestEquipGemToServer(PuzzleId, SlotId, GemId)
  local GemPackageInfo = GemData:GetGemPackageInfoByUId(GemId)
  local OldEquipPuzzleId = GemPackageInfo.pzUniqueID
  local JsonParam = {
    pzUniqueID = PuzzleId,
    slotID = SlotId,
    uniqueID = GemId,
    oldPzUniqueID = OldEquipPuzzleId
  }
  HttpCommunication.Request("hero/equipgem", JsonParam, {
    GameInstance,
    function()
      print("GemHandler:RequestEquipGemToServer Success!")
      local GemPackageInfo = GemData:GetGemPackageInfoByUId(GemId)
      local OldEquipPuzzleId = GemPackageInfo.pzUniqueID
      if "0" ~= OldEquipPuzzleId then
        local PuzzleGemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(OldEquipPuzzleId)
        for SlotIndex, SingleGemId in pairs(PuzzleGemSlotInfo) do
          if SingleGemId == GemId then
            PuzzleGemSlotInfo[SlotIndex] = "0"
            break
          end
        end
      end
      local PuzzleGemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(PuzzleId)
      for SlotIndex, SingleGemId in pairs(PuzzleGemSlotInfo) do
        if SlotIndex == tostring(SlotId) then
          local OldGemPackageInfo = GemData:GetGemPackageInfoByUId(SingleGemId)
          if OldGemPackageInfo then
            OldGemPackageInfo.pzUniqueID = "0"
          end
          break
        end
      end
      PuzzleGemSlotInfo[tostring(SlotId)] = GemId
      GemPackageInfo.pzUniqueID = PuzzleId
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo)
      EventSystem.Invoke(EventDef.Gem.OnRefreshGemStatus)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, {PuzzleId})
      EventSystem.Invoke(EventDef.Gem.OnGemEquipSuccess, PuzzleId, SlotId)
    end
  })
end
function GemHandler:RequestGetGemPackageInfoToServer(...)
  HttpCommunication.RequestByGet("hero/getgempackage", {
    GameInstance,
    function(Target, JsonResponse)
      print("GemHandler:RequestGetGemPackageInfoToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for i, SingleGemInfo in ipairs(JsonTable.gems) do
        GemData:SetGemPackageInfo(SingleGemInfo.uniqueID, SingleGemInfo)
      end
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo)
    end
  })
end
function GemHandler:RequestLockGemToServer(Id)
  HttpCommunication.Request("hero/lockgem", {uniqueID = Id}, {
    GameInstance,
    function()
      print("GemHandler:RequestLockGemToServer Success!")
      GemData:SetGemState(Id, EGemStatus.Lock)
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo, Id)
    end
  })
end
function GemHandler:RequestUnEquipGemToServer(PuzzleId, SlotId)
  local JsonParam = {
    slotID = tonumber(SlotId),
    pzUniqueID = PuzzleId
  }
  HttpCommunication.Request("hero/unequipgem", JsonParam, {
    GameInstance,
    function()
      print("GemHandler:RequestUnEquipGemToServer Success!")
      local PuzzleGemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(PuzzleId)
      local TargetGemId = PuzzleGemSlotInfo[tostring(SlotId)]
      PuzzleGemSlotInfo[tostring(SlotId)] = "0"
      local GemPackageInfo = GemData:GetGemPackageInfoByUId(TargetGemId)
      GemPackageInfo.pzUniqueID = "0"
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo, TargetGemId)
      EventSystem.Invoke(EventDef.Gem.OnRefreshGemStatus)
      EventSystem.Invoke(EventDef.Puzzle.OnUpdatePuzzleDetailInfo, {PuzzleId})
      EventSystem.Invoke(EventDef.Gem.OnGemUnEquipSuccess, TargetGemId, SlotId)
    end
  })
end
function GemHandler:RequestUpgradeGemToServer(GemId, Level)
  local JsonParam = {uniqueID = GemId, targetLevel = Level}
  HttpCommunication.Request("hero/upgradegem", JsonParam, {
    GameInstance,
    function()
      print("GemHandler:RequestUpgradeGemToServer Success!")
      local GemPackageInfo = GemData:GetGemPackageInfoByUId(GemId)
      if GemPackageInfo then
        GemPackageInfo.level = Level
        EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo, GemId)
      end
      EventSystem.Invoke(EventDef.Gem.OnGemUpgradeSuccess, GemId)
    end
  })
end
function GemHandler:RequestGemMutationToServer(GemIdList, IsSeniorMutation)
  local JsonParam = {uniqueIDs = GemIdList, isSeniorMutation = IsSeniorMutation}
  HttpCommunication.Request("hero/gemmutation", JsonParam, {
    GameInstance,
    function(Target, JsonResponse)
      print("GemHandler:RequestGemMutationToServer Success!", JsonResponse.Content)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for SingleGemId, GemInfo in pairs(JsonTable.gems) do
        local GemPackageInfo = GemData:GetGemPackageInfoByUId(SingleGemId)
        local OldMutationAttrInfo = GemPackageInfo.mutation and GemPackageInfo.mutationAttr[1] or nil
        local MutationResultTipId = 0
        local NewMutationAttrInfo = GemInfo.mutation and GemInfo.mutationAttr[1] or nil
        if not OldMutationAttrInfo then
          if not NewMutationAttrInfo then
            MutationResultTipId = PuzzleInfoConfig.MutataionNotChangeTipId
          elseif NewMutationAttrInfo.MutationType == EMutationType.NegaMutation then
            MutationResultTipId = PuzzleInfoConfig.MutationFailTipId
          elseif NewMutationAttrInfo.MutationType == EMutationType.PosMutation then
            MutationResultTipId = PuzzleInfoConfig.MutationSuccessTipId
          end
        elseif OldMutationAttrInfo.MutationType == EMutationType.NegaMutation then
          MutationResultTipId = PuzzleInfoConfig.MutationSuccessTipId
        elseif OldMutationAttrInfo.AttrID == NewMutationAttrInfo.AttrID and OldMutationAttrInfo.MutationValue == NewMutationAttrInfo.MutationValue then
          MutationResultTipId = PuzzleInfoConfig.MutataionNotChangeTipId
        else
          MutationResultTipId = PuzzleInfoConfig.MutationSuccessTipId
        end
        if 0 ~= MutationResultTipId then
          ShowWaveWindow(MutationResultTipId)
        end
        GemData:SetGemPackageInfo(SingleGemId, GemInfo)
      end
      EventSystem.Invoke(EventDef.Gem.OnUpdateGemPackageInfo, GemIdList[1])
      EventSystem.Invoke(EventDef.Gem.OnGemMutationSuccess)
    end
  })
end
return GemHandler
