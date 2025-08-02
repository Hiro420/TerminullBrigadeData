LogicOutsidePackback = LogicOutsidePackback or {}
local rapidjson = require("rapidjson")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local ChipData = require("Modules.Chip.ChipData")
local PuzzleData = require("Modules.Puzzle.PuzzleData")
local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local specificmodifyconfig = require("GameConfig.SpecificModify.SpecificModifyConfig")
local GemData = require("Modules.Gem.GemData")
local MonthCradHandler = require("Protocol.MonthCard.MonthCardHandler")
local PrivilegeHandler = require("Protocol.Privilege.PrivilegeHandler")
local PlayerInfoHandler = require("Protocol.PlayerInfo.PlayerInfoHandler")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")

function LogicOutsidePackback.Init()
  EventSystem.AddListener(nil, EventDef.WSMessage.ResourceUpdate, LogicOutsidePackback.BindOnResourceUpdate)
end

function LogicOutsidePackback.BindOnResourceUpdate(JsonStr)
  local JsonTable = rapidjson.decode(JsonStr)
  if JsonTable.wallet then
    local CurrencyList = {}
    for i, SingleCurrencyInfo in ipairs(JsonTable.wallet) do
      local CurrencyListTable = {
        currencyId = SingleCurrencyInfo.cid,
        number = SingleCurrencyInfo.amount,
        expireAt = SingleCurrencyInfo.expireAt
      }
      table.insert(CurrencyList, CurrencyListTable)
    end
    DataMgr.SetOutsideCurrencyList(CurrencyList)
  end
  if JsonTable.proppack then
    local PackJson = rapidjson.decode(JsonTable.proppack)
    local PackbackList = {}
    for i, SinglePackBackInfo in ipairs(PackJson) do
      if type(SinglePackBackInfo) ~= "function" then
        if PackbackList[SinglePackBackInfo.id] then
          table.insert(PackbackList[SinglePackBackInfo.id], SinglePackBackInfo)
        else
          local List = {}
          table.insert(List, SinglePackBackInfo)
          PackbackList[SinglePackBackInfo.id] = List
        end
      end
    end
    DataMgr.SetOutsidePackbackList(PackbackList)
  end
  if JsonTable.resources then
    local GeneralTB = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    for i, v in ipairs(JsonTable.resources) do
      local ResourceId = tonumber(v.id)
      local ResourceInfo = LogicOutsidePackback.GetResourceInfoById(ResourceId)
      if ResourceInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
        local CharacterSkinTB = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
        local SkinId = CharacterSkinTB[ResourceId].SkinID
        local HeroId = CharacterSkinTB[ResourceId].CharacterID
        for i, v in ipairs(SkinData.HeroSkinMap[HeroId].SkinDataList) do
          if v.HeroSkinTb.SkinID == SkinId then
            v.bUnlocked = true
          end
        end
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.Weapon then
        local HeroId = LogicOutsideWeapon.GetHeroIdByWeaponId(ResourceId)
        LogicOutsideWeapon.RequestEquippedWeaponInfo(HeroId)
        LogicOutsideWeapon.RequestGetWeaponList()
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.HERO then
        LogicOutsideWeapon.RequestGetWeaponList()
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.ChipUpgradeMaterial then
        if ChipData.ChipUpgradeMatList[ResourceId] then
          ChipData.ChipUpgradeMatList[ResourceId].amount = ChipData.ChipUpgradeMatList[ResourceId].amount + v.amount
        else
          ChipData.ChipUpgradeMatList:Add(ResourceId, {
            id = ResourceId,
            amount = v.amount
          })
        end
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.Puzzle then
        local PuzzleInfoTable = rapidjson.decode(v.extra)
        for PuzzleId, PuzzleInfo in pairs(PuzzleInfoTable) do
          PuzzleData:SetPuzzlePackageInfo(PuzzleInfo.base)
          PuzzleData:SetPuzzleDetailInfo(PuzzleId, PuzzleInfo.detail)
        end
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.Gem then
        local GemInfoTable = rapidjson.decode(v.extra)
        for GemId, GemInfo in pairs(GemInfoTable) do
          GemData:SetGemPackageInfo(GemId, GemInfo)
        end
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.InfiniteProp then
        local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBInfiniteProp, ResourceId)
        if result and row.unlockTaskId > 0 then
          local inscriptionData = GetLuaInscription(ResourceId)
          if inscriptionData then
            IllustratedGuideData:AddSpecificUnlockAniMap(ResourceId)
          end
          local curScene = GetCurSceneStatus()
          if curScene == UE.ESceneStatus.EBattle or curScene == UE.ESceneStatus.ESettlement then
            local TaskId = row.unlockTaskId
            local specificData = {}
            specificData.TaskID = TaskId
            specificData.SpecificId = ResourceId
            IllustratedGuideData:AddNewUnlockSpecificData(specificData)
          end
        end
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.MonthCard then
        MonthCradHandler:RequestRolesMonthCardInfoToServer({
          DataMgr.GetUserId()
        })
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.Privilege then
        PrivilegeHandler:RequestRolesPrivilegeInfoToServer({
          DataMgr.GetUserId()
        })
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.Portrait then
        PlayerInfoHandler.RequestGetPortraits()
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.Banner then
        PlayerInfoHandler.RequestGetBanners()
      elseif ResourceInfo.Type == TableEnums.ENUMResourceType.HeroProfyExp then
        local Result, HeroProfyExpRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroProfyExp, tonumber(v.id))
        if Result then
          local HeroId = HeroProfyExpRowInfo.heroID
          local CurProfyLevel = ProficiencyData:GetMaxUnlockProfyLevel(HeroId)
          LogicRole.RequestMyHeroInfoToServer(function()
            local ProfyUnlockLevel = ProficiencyData:GetMaxUnlockProfyLevel(HeroId)
            if ProfyUnlockLevel > CurProfyLevel then
              local ViewData = {
                ViewID = ViewID.UI_ProfyUpgradeAnimPanel,
                Params = {HeroId}
              }
              LobbyModule = ModuleManager:Get("LobbyModule")
              LobbyModule:UpdateViewData(ViewData)
            end
          end)
        end
      end
    end
  end
  EventSystem.Invoke(EventDef.Lobby.UpdateResourceInfo)
end

function LogicOutsidePackback.GetHeroIdBySkinId(Id)
  local IdStr = tostring(Id)
  return tonumber(string.sub(IdStr, 1, 4))
end

function LogicOutsidePackback.GetResourceInfoById(Id)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if ResourceTable then
    return ResourceTable[Id]
  end
  return nil
end

function LogicOutsidePackback.GetResourceNumById(ResourceId)
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(ResourceId)
  if not CurrencyInfo then
    print("not found CurrencyId", ResourceId)
    return 0
  end
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY or CurrencyInfo.Type == TableEnums.ENUMResourceType.PaymentCurrency then
    return DataMgr.GetOutsideCurrencyNumById(ResourceId)
  else
    return DataMgr.GetPackbackNumById(ResourceId)
  end
end

function LogicOutsidePackback.Clear()
  EventSystem.RemoveListener(EventDef.WSMessage.ResourceUpdate, LogicOutsidePackback.BindOnResourceUpdate)
end
