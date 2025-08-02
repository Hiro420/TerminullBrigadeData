local ChipStrengthLvItem = UnLua.Class()

function ChipStrengthLvItem:Construct()
end

function ChipStrengthLvItem:Destruct()
end

function ChipStrengthLvItem:InitChipStrengthLvItem(Lv, bActived)
  UpdateVisibility(self, true)
  local str = string.format("+%d", Lv)
  self.RGTextLv:SetText(str)
  self:SetIsEnabled(bActived)
end

function ChipStrengthLvItem:Hide()
  UpdateVisibility(self, false)
end

return ChipStrengthLvItem
