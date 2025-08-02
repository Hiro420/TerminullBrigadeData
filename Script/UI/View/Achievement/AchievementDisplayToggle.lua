local AchievementDisplayToggle = UnLua.Class()

function AchievementDisplayToggle:Construct()
end

function AchievementDisplayToggle:Destruct()
end

function AchievementDisplayToggle:InitAchievementDisplayToggle(str)
  self.RGTextUnSelect:SetText(str)
  self.RGTextSelect:SetText(str)
end

function AchievementDisplayToggle:OnMouseEnter()
  self.RGStateControllerHover:ChangeStatus(EHover.Hover)
end

function AchievementDisplayToggle:OnMouseLeave()
  self.RGStateControllerHover:ChangeStatus(EHover.UnHover)
end

return AchievementDisplayToggle
