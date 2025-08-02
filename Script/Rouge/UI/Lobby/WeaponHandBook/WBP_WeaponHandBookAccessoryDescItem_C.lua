local rapidjson = require("rapidjson")
local WBP_WeaponHandBookAccessoryDescItem_C = UnLua.Class()

function WBP_WeaponHandBookAccessoryDescItem_C:Construct()
end

function WBP_WeaponHandBookAccessoryDescItem_C:Destruct()
end

function WBP_WeaponHandBookAccessoryDescItem_C:Init(Desc)
  self.RGTextDesc:SetText(Desc)
end

return WBP_WeaponHandBookAccessoryDescItem_C
