local DrawCardData = {
  CardPoolInfo = {}
}

function DrawCardData:UpdateCardPoolInfo(CardPoolInfo)
  DrawCardData.CardPoolInfo = CardPoolInfo
end

function DrawCardData:SetCardPoolOpenCount(CardPoolId, OpenCount)
  if not DrawCardData.CardPoolInfo[CardPoolId] then
    DrawCardData.CardPoolInfo[CardPoolId] = {}
  end
  DrawCardData.CardPoolInfo[CardPoolId].OpenCount = OpenCount
end

function DrawCardData:GetCardPoolOpenCountById(CardPoolId)
  if not DrawCardData.CardPoolInfo[CardPoolId] then
    return nil
  end
  return DrawCardData.CardPoolInfo[CardPoolId].OpenCount
end

function DrawCardData:SetCardPoolGuarantList(CardPoolId, GuarantList)
  if not DrawCardData.CardPoolInfo[CardPoolId] then
    DrawCardData.CardPoolInfo[CardPoolId] = {}
  end
  DrawCardData.CardPoolInfo[CardPoolId].GuarantList = GuarantList
end

function DrawCardData:GetCardPoolGuarantListById(CardPoolId)
  if not DrawCardData.CardPoolInfo[CardPoolId] then
    return nil
  end
  return DrawCardData.CardPoolInfo[CardPoolId].GuarantList
end

function DrawCardData:GetDecomposeInfoById(ResourceId)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TotalResourceTable[ResourceId] or 0 == #TotalResourceTable[ResourceId].DecomposeResources then
    return nil, nil
  end
  local DecomposeResource = TotalResourceTable[ResourceId].DecomposeResources[1]
  return DecomposeResource.key, DecomposeResource.value
end

return DrawCardData
