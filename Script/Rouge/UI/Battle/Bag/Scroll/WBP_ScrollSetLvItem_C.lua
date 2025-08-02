local WBP_ScrollSetLvItem_C = UnLua.Class()

function WBP_ScrollSetLvItem_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_ScrollSetLvItem_C:InitSetLvItem(CurLevel, selfLevel, bIsNextTag)
  UpdateVisibility(self, true)
  UpdateVisibility(self.CanvasPanelArrow, bIsNextTag)
  UpdateVisibility(self.CanvasPanelTag, not bIsNextTag)
  UpdateVisibility(self.URGImageTagActived, selfLevel <= CurLevel)
  UpdateVisibility(self.URGImageTag, CurLevel < selfLevel)
end

function WBP_ScrollSetLvItem_C:Hide()
  UpdateVisibility(self, false)
end

function WBP_ScrollSetLvItem_C:Destruct()
end

return WBP_ScrollSetLvItem_C
