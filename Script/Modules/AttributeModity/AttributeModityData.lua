local AttributeModityData = {
  RequestingList = {},
  RefusedList = {}
}

function AttributeModityData:Reset()
  AttributeModityData.RequestingList = {}
  AttributeModityData.RefusedList = {}
end

function AttributeModityData:GetRequesing(UserId)
  return AttributeModityData.RequestingList[UserId]
end

function AttributeModityData:AddRequesing(UserId, AttributeModifyId)
  AttributeModityData.RequestingList[UserId] = AttributeModifyId
  print("AttributeModityData:AddRequesing, UserId:" .. UserId .. ", AttributeModifyId:" .. AttributeModifyId)
end

function AttributeModityData:RemoveRequesting(UserId)
  AttributeModityData.RequestingList[UserId] = nil
  print("AttributeModityData:RemoveRequesting, UserId:" .. UserId)
end

function AttributeModityData:GetRefused(UserId)
  return AttributeModityData.RefusedList[UserId]
end

function AttributeModityData:AddRefused(UserId, AttributeModifyId)
  AttributeModityData.RefusedList[UserId] = AttributeModifyId
  print("AttributeModityData:AddRefused, UserId:" .. UserId .. ", AttributeModifyId:" .. AttributeModifyId)
end

function AttributeModityData:RemoveRefused(UserId)
  AttributeModityData.RefusedList[UserId] = nil
  print("AttributeModityData:RemoveRefused, UserId:" .. UserId)
end

return AttributeModityData
