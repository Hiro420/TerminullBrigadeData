local PlayerInfoGameModeDetailsInfoItem = Class()
function PlayerInfoGameModeDetailsInfoItem:Construct()
  self.Overridden.Construct(self)
end
function PlayerInfoGameModeDetailsInfoItem:InitPlayerInfoGameModeDetailsInfoItem(Txt1, Txt2)
  UpdateVisibility(self, true)
  self.RGTextInfoValue1:SetText(Txt1)
  self.RGTextInfoValue2:SetText(Txt2)
end
function PlayerInfoGameModeDetailsInfoItem:Hide()
  UpdateVisibility(self, false)
end
return PlayerInfoGameModeDetailsInfoItem
