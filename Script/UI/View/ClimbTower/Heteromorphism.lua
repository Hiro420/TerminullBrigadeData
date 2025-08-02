local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local Heteromorphism = UnLua.Class()

function Heteromorphism:InitHeteromorphism(Floor)
  ClimbTowerData:GameFloorPassData()
  local HeteromorphismTable = ClimbTowerData:GetHeteromorphism(Floor)
  local Index = 1
  for index, value in ipairs(HeteromorphismTable) do
    local Item = GetOrCreateItem(self.ScrollList, Index, self.WBP_Heteromorphism_Item:GetClass())
    UpdateVisibility(Item, true)
    Item:SetHeteromorphismInfo(value)
    Index = Index + 1
  end
  HideOtherItem(self.ScrollList, Index, true)
end

return Heteromorphism
