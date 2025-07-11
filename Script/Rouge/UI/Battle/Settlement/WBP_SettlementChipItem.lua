local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_SettlementChipItem = UnLua.Class()
function WBP_SettlementChipItem:Construct()
  self.Overridden.Construct(self)
end
function WBP_SettlementChipItem:Destruct()
end
function WBP_SettlementChipItem:InitSettlementChipItem(Id, Num, bShowName, HoveredFunc, UnHoveredFunc, bIncrease, DropType)
  UpdateVisibility(self, true)
  self.WBP_Item:InitItem(Id, Num)
  self.WBP_Item:BindOnMainButtonHovered(HoveredFunc)
  self.WBP_Item:BindOnMainButtonUnHovered(UnHoveredFunc)
  UpdateVisibility(self.CanvasPanelIncrease, bIncrease)
  UpdateVisibility(self.CanvasPanelBenefit, DropType == UE.EItemDropType.BenefitDrop)
end
return WBP_SettlementChipItem
