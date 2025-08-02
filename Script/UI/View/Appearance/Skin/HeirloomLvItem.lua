local HeirloomLvItem = UnLua.Class()

function HeirloomLvItem:Construct()
end

function HeirloomLvItem:InitHeirloomLvItem(HeirloomLv, bIsUnlock)
  UpdateVisibility(self, true, true)
  self.RGTextUnSelectLvLock:SetText(NumToRoman(HeirloomLv))
  self.RGTextUnSelectLvUnLock:SetText(NumToRoman(HeirloomLv))
  self.RGTextSelectLvLock:SetText(NumToRoman(HeirloomLv))
  self.RGTextSelectLvUnLock:SetText(NumToRoman(HeirloomLv))
  UpdateVisibility(self.CanvasPanelUnSelectLock, not bIsUnlock)
  UpdateVisibility(self.CanvasPanelUnSelectUnLock, bIsUnlock)
  UpdateVisibility(self.CanvasPanelSelectLock, not bIsUnlock)
  UpdateVisibility(self.CanvasPanelSelectUnLock, bIsUnlock)
end

function HeirloomLvItem:OnMouseEnter(MyGeometry, MouseEvent)
end

function HeirloomLvItem:OnMouseLeave(MyGeometry, MouseEvent)
end

function HeirloomLvItem:Hide()
  UpdateVisibility(self, false)
end

return HeirloomLvItem
