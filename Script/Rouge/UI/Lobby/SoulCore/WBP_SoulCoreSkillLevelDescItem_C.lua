local rapidjson = require("rapidjson")
local WBP_SoulCoreSkillLevelDescItem_C = UnLua.Class()
function WBP_SoulCoreSkillLevelDescItem_C:Construct()
end
function WBP_SoulCoreSkillLevelDescItem_C:Destruct()
end
function WBP_SoulCoreSkillLevelDescItem_C:Show(SkillInfo, CharacterStar)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local DescStr = string.format("LV:%d %s", SkillInfo.Star, SkillInfo.SimpleDesc)
  self.RGTextBlockDesc:SetText(DescStr)
  self:SetIsEnabled(CharacterStar >= SkillInfo.Star)
end
function WBP_SoulCoreSkillLevelDescItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_SoulCoreSkillLevelDescItem_C
