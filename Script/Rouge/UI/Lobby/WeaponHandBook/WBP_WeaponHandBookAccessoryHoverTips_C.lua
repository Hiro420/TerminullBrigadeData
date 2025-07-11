local WBP_WeaponHandBookAccessoryHoverTips_C = UnLua.Class()
function WBP_WeaponHandBookAccessoryHoverTips_C:Construct()
end
function WBP_WeaponHandBookAccessoryHoverTips_C:Destruct()
end
function WBP_WeaponHandBookAccessoryHoverTips_C:InitInfo(AccessoryId, Rare)
  local Item = LogicWeaponHandBook:GetItemDataByRowName(tostring(AccessoryId))
  if Item then
    self.RGTextName:SetText(Item.Name)
  end
  local Result, AccessoryData = LogicWeaponHandBook:GetAccessoryById(AccessoryId)
  if AccessoryData then
    local Result, WorldInfo = LogicWeaponHandBook:GetWorldInfoByWorldId(AccessoryData.WorldId)
    if WorldInfo then
      self.RGTextWorldName:SetText(WorldInfo.WorldDisplayName)
    end
  end
  self.WBP_WeaponHandBookParts:Init(AccessoryId, Rare)
end
return WBP_WeaponHandBookAccessoryHoverTips_C
