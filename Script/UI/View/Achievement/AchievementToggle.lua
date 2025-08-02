local AchievementToggle = UnLua.Class()

function AchievementToggle:Construct()
end

function AchievementToggle:Destruct()
end

function AchievementToggle:InitAchievementToggle(AchievementTbData)
  SetImageBrushByPath(self.URGImageIconUnSelect, AchievementTbData.Icon)
  SetImageBrushByPath(self.URGImageIconSelect, AchievementTbData.Icon)
  self.WBP_RedDotView:ChangeRedDotIdByTag(AchievementTbData.type)
end

function AchievementToggle:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(tostring(2))
end

function AchievementToggle:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(tostring(1))
end

return AchievementToggle
