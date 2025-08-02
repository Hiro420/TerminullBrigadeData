local rapidjson = require("rapidjson")
local WBP_WeaponWorldItem_C = UnLua.Class()

function WBP_WeaponWorldItem_C:Construct()
end

function WBP_WeaponWorldItem_C:Destruct()
end

function WBP_WeaponWorldItem_C:Show(WorldName, WorldSpriteIcon, WorldId)
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(WorldSpriteIcon)
  self.URGImageUnSelectIcon.Brush.ResourceObject = IconObj
  self.URGImageSelectIcon.Brush.ResourceObject = IconObj
  self.RGTextUnSelectName:SetText(WorldName)
  self.RGTextSelectName:SetText(WorldName)
  self.WorldId = WorldId
end

return WBP_WeaponWorldItem_C
