local PuzzleData = {
  AllHeroPuzzleboardList = {},
  AllSlotStatus = {},
  PuzzleUnlockSlotList = {},
  PendingEquipSlotList = {},
  PendingCanNotEquipSlotList = {},
  AllHeroPuzzleEquipList = {},
  PendingDragSlotList = {},
  AllPuzzleDetailInfo = {},
  AllPuzzlePackageInfo = {},
  PuzzleSlotUnLockList = {},
  IsShowDetailPuzzleList = false,
  AllEquipPuzzleIdList = {}
}
local EPuzzleSlotStatus = {
  PendingCanNotEquip = -4,
  PendingDrag = -3,
  PendingEquip = -2,
  Lock = -1,
  Empty = 0
}
_G.EPuzzleSlotStatus = EPuzzleSlotStatus
local EPuzzleGemDevelopId = {
  PuzzleStrengthen = 1,
  PuzzleDecompose = 2,
  GemUpgrade = 3,
  GemDecompose = 4
}
_G.EPuzzleGemDevelopId = EPuzzleGemDevelopId
local EPuzzleStatus = {
  Normal = 0,
  Lock = 1,
  Discard = 2
}
_G.EPuzzleStatus = EPuzzleStatus
local EPuzzleSortRule = {
  QualityDesc = 1,
  QualityAsc = 2,
  TimeDesc = 3,
  TimeAsc = 4,
  LevelDesc = 5,
  LevelAsc = 6
}
_G.EPuzzleSortRule = EPuzzleSortRule
local EPuzzleFilterType = {
  World = 0,
  Quality = 1,
  SubAttr = 2,
  Lock = 3,
  Discard = 4
}
_G.EPuzzleFilterType = EPuzzleFilterType
local EPuzzleRefactorType = {
  WashShape = 99026,
  InscriptionRefresh = 99027,
  WashSubAttrValue = 99028,
  WashSlotNum = 99029,
  WashRandomOneSubAttr = 99030,
  WashFirstOneSubAttr = 99031,
  WashLastOneSubAttr = 99032,
  Mutation = 99033,
  SeniorMutation = 99036
}
_G.EPuzzleRefactorType = EPuzzleRefactorType
local EMutationType = {
  Normal = 0,
  PosMutation = 1,
  NegaMutation = 2
}
_G.EMutationType = EMutationType
local PuzzleInfoConfig = require("GameConfig.Puzzle.PuzzleInfoConfig")
local GemData = require("Modules.Gem.GemData")
function PuzzleData:DealWithTable(...)
  local PuzzleSlotTable = LuaTableMgr.GetLuaTableByName(TableNames.TBPuzzleSlots)
  if not PuzzleSlotTable then
    return
  end
  for SingleSlotId, SingleSlotInfo in pairs(PuzzleSlotTable) do
    if not PuzzleData.AllHeroPuzzleboardList[SingleSlotInfo.heroID] then
      PuzzleData.AllHeroPuzzleboardList[SingleSlotInfo.heroID] = {}
    end
    if not PuzzleData.AllHeroPuzzleboardList[SingleSlotInfo.heroID][SingleSlotInfo.position.key] then
      PuzzleData.AllHeroPuzzleboardList[SingleSlotInfo.heroID][SingleSlotInfo.position.key] = {}
    end
    if not PuzzleData.AllHeroPuzzleboardList[SingleSlotInfo.heroID][SingleSlotInfo.position.key][SingleSlotInfo.position.value] then
      PuzzleData.AllHeroPuzzleboardList[SingleSlotInfo.heroID][SingleSlotInfo.position.key][SingleSlotInfo.position.value] = {}
    end
    PuzzleData.AllHeroPuzzleboardList[SingleSlotInfo.heroID][SingleSlotInfo.position.key][SingleSlotInfo.position.value] = SingleSlotId
    if 0 == SingleSlotInfo.unlock then
      PuzzleData.AllSlotStatus[SingleSlotId] = EPuzzleSlotStatus.Empty
    else
      PuzzleData.AllSlotStatus[SingleSlotId] = EPuzzleSlotStatus.Lock
    end
  end
end
function PuzzleData:AddEquipPuzzleId(InHeroId, InPuzzleId)
  if not PuzzleData.AllEquipPuzzleIdList[InHeroId] then
    PuzzleData.AllEquipPuzzleIdList[InHeroId] = {}
  end
  table.insert(PuzzleData.AllEquipPuzzleIdList[InHeroId], InPuzzleId)
end
function PuzzleData:RemoveEquipPuzzleId(InHeroId, InPuzzleId)
  if PuzzleData.AllEquipPuzzleIdList[InHeroId] then
    table.RemoveItem(PuzzleData.AllEquipPuzzleIdList[InHeroId], InPuzzleId)
  end
end
function PuzzleData:ClearEquipPuzzleIdList()
  PuzzleData.AllEquipPuzzleIdList = {}
end
function PuzzleData:GetEquipPuzzleIdListByHeroId(InHeroId)
  return PuzzleData.AllEquipPuzzleIdList[InHeroId] or {}
end
function PuzzleData:RemoveEquipPuzzleIdListByHeroId(InHeroId)
  PuzzleData.AllEquipPuzzleIdList[InHeroId] = nil
end
function PuzzleData:SetPuzzleUnlockSlotList(InPuzzleUnlockSlotInfo)
  PuzzleData.PuzzleUnlockSlotList = InPuzzleUnlockSlotInfo
  for i, SingleSlotId in ipairs(PuzzleData.PuzzleUnlockSlotList) do
    if PuzzleData.AllSlotStatus[SingleSlotId] == EPuzzleSlotStatus.Lock then
      PuzzleData:RefreshSlotStatus(SingleSlotId, EPuzzleSlotStatus.Empty)
    end
  end
end
function PuzzleData:GetPuzzleSlotIdByCoordinate(HeroId, Coordinate)
  if PuzzleData.AllHeroPuzzleboardList[HeroId] and PuzzleData.AllHeroPuzzleboardList[HeroId][Coordinate.key] then
    return PuzzleData.AllHeroPuzzleboardList[HeroId][Coordinate.key][Coordinate.value]
  end
  return nil
end
function PuzzleData:GetPuzzleboardCoordinateByHeroId(HeroId)
  return PuzzleData.AllHeroPuzzleboardList[HeroId]
end
function PuzzleData:GetSlotIdListByHeroId(HeroId)
  local SlotIdList = {}
  if not PuzzleData.AllHeroPuzzleboardList[HeroId] then
    return SlotIdList
  end
  for CoordinateX, SingleSlotInfo in pairs(PuzzleData.AllHeroPuzzleboardList[HeroId]) do
    for CoordinateY, SingleSlotId in pairs(SingleSlotInfo) do
      table.insert(SlotIdList, SingleSlotId)
    end
  end
  return SlotIdList
end
function PuzzleData:RefreshSlotStatus(SlotId, Status)
  if PuzzleData.AllSlotStatus[SlotId] then
    PuzzleData.AllSlotStatus[SlotId] = Status
  end
end
function PuzzleData:GetSlotStatus(SlotId)
  if table.Contain(PuzzleData.PendingCanNotEquipSlotList, SlotId) then
    return EPuzzleSlotStatus.PendingCanNotEquip
  end
  if table.Contain(PuzzleData.PendingEquipSlotList, SlotId) then
    return EPuzzleSlotStatus.PendingEquip
  end
  if table.Contain(PuzzleData.PendingDragSlotList, SlotId) then
    return EPuzzleSlotStatus.PendingDrag
  end
  return PuzzleData.AllSlotStatus[SlotId]
end
function PuzzleData:GetSlotEquipPuzzleId(SlotId)
  return PuzzleData.AllSlotStatus[SlotId]
end
function PuzzleData:IsSlotEquipped(SlotId)
  local Status = PuzzleData.AllSlotStatus[SlotId]
  return type(Status) ~= "number"
end
function PuzzleData:IsPendingDrag(SlotId)
  return table.Contain(PuzzleData.PendingDragSlotList, SlotId)
end
function PuzzleData:SetSlotEquipId(PuzzleId, SlotIdList)
  PuzzleData.AllHeroPuzzleEquipList[PuzzleId] = SlotIdList
end
function PuzzleData:GetSlotListByPuzzleId(PuzzleId)
  return PuzzleData.AllHeroPuzzleEquipList[PuzzleId]
end
function PuzzleData:SetPendingEquipSlot(InPendingEquipSlot)
  PuzzleData.PendingEquipSlotList = InPendingEquipSlot
end
function PuzzleData:SetPendingCanNotEquipSlot(InPendingCanNotEquipSlot)
  PuzzleData.PendingCanNotEquipSlotList = InPendingCanNotEquipSlot
end
function PuzzleData:SetPendingDragSlotList(InPendingDragSlotList)
  PuzzleData.PendingDragSlotList = InPendingDragSlotList
end
function PuzzleData:GetPendingDragSlotList()
  return PuzzleData.PendingDragSlotList
end
function PuzzleData:GetPuzzleResourceIdByUid(InUid)
  local PackageInfo = PuzzleData:GetPuzzlePackageInfo(InUid)
  return tonumber(PackageInfo.resourceID)
end
function PuzzleData:SetPuzzleDetailInfo(PuzzleId, InDetailInfo)
  PuzzleData.AllPuzzleDetailInfo[PuzzleId] = InDetailInfo
end
function PuzzleData:GetPuzzleDetailInfo(InPuzzleId)
  return PuzzleData.AllPuzzleDetailInfo[InPuzzleId]
end
function PuzzleData:SetPuzzlePackageInfo(InPuzzlePackageInfo)
  PuzzleData.AllPuzzlePackageInfo[InPuzzlePackageInfo.uniqueID] = InPuzzlePackageInfo
end
function PuzzleData:RemovePuzzlePackageInfo(PuzzleId)
  PuzzleData.AllPuzzlePackageInfo[PuzzleId] = nil
end
function PuzzleData:SetPuzzleState(InPuzzleId, State)
  local PuzzlePackageInfo = PuzzleData:GetPuzzlePackageInfo(InPuzzleId)
  if not PuzzlePackageInfo then
    return
  end
  PuzzlePackageInfo.state = State
end
function PuzzleData:SetPuzzleEquipHeroId(InPuzzleId, HeroId)
  local PuzzlePackageInfo = PuzzleData:GetPuzzlePackageInfo(InPuzzleId)
  if not PuzzlePackageInfo then
    return
  end
  PuzzlePackageInfo.equipHeroID = HeroId
end
function PuzzleData:SetPuzzleLevel(InPuzzleId, InLevel)
  local PuzzlePackageInfo = PuzzleData:GetPuzzlePackageInfo(InPuzzleId)
  if not PuzzlePackageInfo then
    return
  end
  PuzzlePackageInfo.level = InLevel
end
function PuzzleData:GetPuzzlePackageInfo(InPuzzleId)
  if not InPuzzleId then
    return nil
  end
  return PuzzleData.AllPuzzlePackageInfo[InPuzzleId]
end
function PuzzleData:GetAllPuzzlePackageInfo(...)
  return PuzzleData.AllPuzzlePackageInfo
end
function PuzzleData:GetAllPuzzlePackageIdList()
  local IdList = {}
  for PuzzleId, PuzzlePackageInfo in pairs(PuzzleData.AllPuzzlePackageInfo) do
    table.insert(IdList, PuzzleId)
  end
  return IdList
end
function PuzzleData:CreatePuzzlePackageInfo(ResId, bindheroID, equipHeroID, Inscription)
  local PuzzlePackageInfo = {}
  PuzzlePackageInfo.bindHeroID = bindheroID
  PuzzlePackageInfo.equipHeroID = equipHeroID
  PuzzlePackageInfo.exp = 0
  PuzzlePackageInfo.inscription = Inscription
  PuzzlePackageInfo.level = 0
  PuzzlePackageInfo.resourceID = ResId
  PuzzlePackageInfo.shapeID = 0
  PuzzlePackageInfo.state = 0
  PuzzlePackageInfo.uniqueID = -1
  PuzzlePackageInfo.Mutation = false
  return PuzzlePackageInfo
end
function PuzzleData:CreatePuzzleDetailInfo(SubAttr)
  local PuzzleDetailInfo = {}
  PuzzleDetailInfo.MainAttrGrowth = {}
  PuzzleDetailInfo.SubAttrGrowth = {}
  PuzzleDetailInfo.SubAttrInitV2 = SubAttr
  return PuzzleDetailInfo
end
function PuzzleData:GetAttrDisplayValue(AttrId, AttrValue)
  local result, row = GetRowData(DT.DT_AttributeModifyOp, tonumber(AttrId))
  if result then
    return AttrValue * row.RateDisplayInUI
  end
  return AttrValue
end
function PuzzleData:GetHeroPuzzleInfoByHeroId(HeroId)
  local PuzzleInfo = {}
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  for PuzzleId, PuzzlePackageInfo in pairs(AllPackageInfo) do
    if PuzzlePackageInfo.equipHeroID == HeroId then
      local SlotIdList = PuzzleData:GetSlotListByPuzzleId(PuzzleId)
      table.insert(PuzzleInfo, {
        Id = PuzzlePackageInfo.resourceID,
        SlotIdList = SlotIdList,
        Level = PuzzlePackageInfo.level
      })
    end
  end
  local PuzzleInfoStr = ""
  for i, SinglePuzzleInfo in ipairs(PuzzleInfo) do
    PuzzleInfoStr = PuzzleInfoStr .. SinglePuzzleInfo.Id .. "|" .. SinglePuzzleInfo.Level .. "|"
    for j, SingleSlotId in ipairs(SinglePuzzleInfo.SlotIdList) do
      PuzzleInfoStr = PuzzleInfoStr .. SingleSlotId .. ","
    end
    PuzzleInfoStr = string.sub(PuzzleInfoStr, 1, -2)
    PuzzleInfoStr = PuzzleInfoStr .. ";"
  end
  return PuzzleInfoStr
end
function PuzzleData:GetUnEquipPuzzleUidByResIdAndLevel(ResId, Level)
  local AllPackageInfo = PuzzleData:GetAllPuzzlePackageInfo()
  for PuzzleId, PuzzlePackageInfo in pairs(AllPackageInfo) do
    if 0 == PuzzlePackageInfo.equipHeroID and PuzzlePackageInfo.resourceID == tostring(ResId) and Level >= PuzzlePackageInfo.level then
      return PuzzleId
    end
  end
  return nil
end
function PuzzleData:GetAllEquipAttrAndInscription(HeroId)
  local HeroSlotIdList = PuzzleData:GetSlotIdListByHeroId(HeroId)
  local EquipPuzzleIdList = {}
  for i, SingleSlotId in ipairs(HeroSlotIdList) do
    local PuzzleId = PuzzleData:GetSlotEquipPuzzleId(SingleSlotId)
    if PuzzleData:IsSlotEquipped(SingleSlotId) and not table.Contain(EquipPuzzleIdList, PuzzleId) then
      table.insert(EquipPuzzleIdList, PuzzleId)
    end
  end
  if next(EquipPuzzleIdList) == nil then
    return {}, {}
  else
    local AttrList = {}
    local InscriptionIdList = {}
    for i, PuzzleId in ipairs(EquipPuzzleIdList) do
      local DetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleId)
      local PackageInfo = PuzzleData:GetPuzzlePackageInfo(PuzzleId)
      if PackageInfo and DetailInfo then
        local Result, PuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, PuzzleData:GetPuzzleResourceIdByUid(PuzzleId))
        if 0 ~= PackageInfo.inscription then
          table.insert(InscriptionIdList, PackageInfo.inscription)
        end
        for i, SingleCoreAttributeInfo in ipairs(PuzzleResRowInfo.MainAttr) do
          if not AttrList[tostring(SingleCoreAttributeInfo.key)] then
            AttrList[tostring(SingleCoreAttributeInfo.key)] = SingleCoreAttributeInfo.value
          else
            AttrList[tostring(SingleCoreAttributeInfo.key)] = AttrList[tostring(SingleCoreAttributeInfo.key)] + SingleCoreAttributeInfo.value
          end
        end
        for AttrId, AttrValue in pairs(DetailInfo.MainAttrGrowth) do
          if not AttrList[AttrId] then
            AttrList[AttrId] = AttrValue
          else
            AttrList[AttrId] = AttrList[AttrId] + AttrValue
          end
        end
        for AttrId, AttrValue in pairs(DetailInfo.SubAttrGrowth) do
          if not AttrList[AttrId] then
            AttrList[AttrId] = AttrValue
          else
            AttrList[AttrId] = AttrList[AttrId] + AttrValue
          end
        end
        for i, SingleAttrInfo in ipairs(DetailInfo.SubAttrInitV2) do
          local AttrId = SingleAttrInfo.attrID
          local AttrValue = SingleAttrInfo.value
          if SingleAttrInfo.mutationType ~= EMutationType.NegaMutation then
            if not AttrList[AttrId] then
              AttrList[AttrId] = AttrValue
            else
              AttrList[AttrId] = AttrList[AttrId] + AttrValue
            end
          end
        end
        local GemSlotInfo = PuzzleData:GetPuzzleGemSlotInfo(PuzzleId)
        for SlotIndex, GemId in pairs(GemSlotInfo) do
          if GemData:IsEquippedInPuzzle(GemId) then
            local MainAttrValueList = GemData:GetMainAttrValueList(GemId)
            local GemPackageInfo = GemData:GetGemPackageInfoByUId(GemId)
            local MutationInfo = GemPackageInfo.mutation and GemPackageInfo.mutationAttr[1]
            for AttrId, AttrValue in pairs(MainAttrValueList) do
              if MutationInfo and MutationInfo.MutationType == EMutationType.NegaMutation then
                AttrValue = AttrValue * MutationInfo.MutationValue
              end
              if not AttrList[tostring(AttrId)] then
                AttrList[tostring(AttrId)] = AttrValue
              else
                AttrList[tostring(AttrId)] = AttrList[tostring(AttrId)] + AttrValue
              end
            end
            if MutationInfo and MutationInfo.MutationType == EMutationType.PosMutation then
              if not AttrList[tostring(MutationInfo.AttrID)] then
                AttrList[tostring(MutationInfo.AttrID)] = MutationInfo.MutationValue
              else
                AttrList[tostring(MutationInfo.AttrID)] = AttrList[tostring(MutationInfo.AttrID)] + MutationInfo.MutationValue
              end
            end
          end
        end
      end
    end
    return AttrList, InscriptionIdList
  end
end
function PuzzleData:GetPuzzleGemSlotInfo(PuzzleId)
  local PuzzleDetailInfo = PuzzleData:GetPuzzleDetailInfo(PuzzleId)
  if not PuzzleDetailInfo then
    return {}
  end
  return PuzzleDetailInfo.GemSlotInfo
end
function PuzzleData:IsGodSubAttr(PuzzleId, PuzzleDetailInfo, AttrId)
  PuzzleDetailInfo = PuzzleDetailInfo or PuzzleData:GetPuzzleDetailInfo(PuzzleId)
  if not PuzzleDetailInfo then
    return false
  end
  for i, AttrInfo in ipairs(PuzzleDetailInfo.SubAttrInitV2) do
    if AttrInfo.attrID == tonumber(AttrId) then
      return AttrInfo.godAttr ~= nil and (AttrInfo.godAttr or AttrInfo.godattr) or false
    end
  end
  return false
end
function PuzzleData:IsPuzzleMutation(PuzzleId, PuzzlePackageInfo)
  PuzzlePackageInfo = PuzzlePackageInfo or PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  if not PuzzlePackageInfo then
    return false
  end
  return PuzzlePackageInfo.Mutation
end
function PuzzleData:GetPuzzleShapeRowInfo(PuzzleId, PuzzlePackageInfo)
  local PackageInfo = PuzzlePackageInfo or PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  if not PackageInfo then
    return false, nil
  end
  local ResourceId = PackageInfo.resourceID and tonumber(PackageInfo.resourceID) or tonumber(PackageInfo.resourceid)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  local ShapeId = PackageInfo.shapeID
  if 0 == ShapeId then
    ShapeId = RowInfo.shapeID
  end
  local Result, ShapeRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleShape, ShapeId)
  return Result, ShapeRowInfo
end
function PuzzleData:GetPuzzleName(PuzzleId, PuzzlePackageInfo, PuzzleDetailInfo)
  local PackageInfo = PuzzlePackageInfo or PuzzleData:GetPuzzlePackageInfo(PuzzleId)
  local DetailInfo = PuzzleDetailInfo or PuzzleData:GetPuzzleDetailInfo(PuzzleId)
  if not PackageInfo or not DetailInfo then
    return ""
  end
  local ResourceId = PackageInfo.resourceID and tonumber(PackageInfo.resourceID) or tonumber(PackageInfo.resourceid)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return ""
  end
  local Result, PuzzleResRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBResPuzzle, ResourceId)
  if not Result then
    return ""
  end
  local MainAttrId = ""
  local MainAttrInfo = DeepCopy(PuzzleResRowInfo.MainAttr)
  table.sort(MainAttrInfo, function(a, b)
    return a.key < b.key
  end)
  for i, SingleCoreAttributeInfo in ipairs(MainAttrInfo) do
    if "" == MainAttrId then
      MainAttrId = SingleCoreAttributeInfo.key
    elseif SingleCoreAttributeInfo.key then
      MainAttrId = string.format("%s_%d", tostring(MainAttrId), SingleCoreAttributeInfo.key)
    end
  end
  local MainAttrText = ""
  local Result, MainAttrNameRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleAttrName, MainAttrId)
  if Result then
    MainAttrText = MainAttrNameRowInfo.Name
  end
  local InscriptionText = ""
  local PowerfulInscriptionText = ""
  if 0 ~= PackageInfo.inscription then
    local InscriptionId = PackageInfo.inscription or PackageInfo.Inscription
    local Result, InscriptionRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleInscriptionName, InscriptionId)
    if Result then
      InscriptionText = InscriptionRowInfo.Name
    end
    local Result, InscriptionGroupRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleInscriptionGroup, InscriptionId)
    if Result and InscriptionGroupRowInfo.EffectType == TableEnums.ENUMInscriptionType.Powerful then
      PowerfulInscriptionText = PuzzleInfoConfig.PowerfulInscriptionText
    end
  end
  local ShapeText = ""
  local Result, ShapeRowInfo = PuzzleData:GetPuzzleShapeRowInfo(PuzzleId, PackageInfo)
  if Result then
    local Result, ShapeNameRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBPuzzleShapeName, ShapeRowInfo.shapeID)
    if Result then
      ShapeText = ShapeNameRowInfo.Name
    end
  end
  local GodAttrText = ""
  for i, SingleAttrInfo in ipairs(DetailInfo.SubAttrInitV2) do
    if SingleAttrInfo.godAttr and PuzzleInfoConfig.GodAttrText then
      GodAttrText = string.format("%s%s", GodAttrText, PuzzleInfoConfig.GodAttrText)
    end
  end
  local MutationText = ""
  if PackageInfo.Mutation or PackageInfo.mutation then
    MutationText = PuzzleInfoConfig.MutationName
  end
  local NameFmt = PuzzleInfoConfig.NameFmt
  local Name = UE.FTextFormat(NameFmt, MutationText, MainAttrText, InscriptionText, ShapeText, GodAttrText, PowerfulInscriptionText)
  return Name
end
function PuzzleData:ClearData(...)
  PuzzleData.AllSlotStatus = {}
  PuzzleData.PuzzleUnlockSlotList = {}
  PuzzleData.PendingEquipSlotList = {}
  PuzzleData.PendingCanNotEquipSlotList = {}
  PuzzleData.AllHeroPuzzleEquipList = {}
  PuzzleData.PendingDragSlotList = {}
  PuzzleData.AllPuzzleDetailInfo = {}
  PuzzleData.AllPuzzlePackageInfo = {}
  PuzzleData.PuzzleSlotUnLockList = {}
  PuzzleData.IsShowDetailPuzzleList = false
  PuzzleData.AllEquipPuzzleIdList = {}
end
function PuzzleData:ConvertV2Struct(SubattrV2)
  local SubAttrInitV2 = {}
  for i, SingleAttrInfo in ipairs(SubattrV2) do
    local SubAttrInfo = {}
    SubAttrInfo.attrID = SingleAttrInfo.AttrID
    SubAttrInfo.godAttr = SingleAttrInfo.godattr
    SubAttrInfo.mutationType = SingleAttrInfo.MutationType
    SubAttrInfo.value = SingleAttrInfo.Value
    for k, v in pairs(SubattrV2) do
      if "AttrID" ~= k and "godattr" ~= k and "MutationType" ~= k and "Value" ~= k then
        SubAttrInfo[k] = v
      end
    end
    table.insert(SubAttrInitV2, SubAttrInfo)
  end
  return SubAttrInitV2
end
return PuzzleData
