local rapidjson = require("rapidjson")
local WBP_SoulCoreSkillTag_C = UnLua.Class()
function WBP_SoulCoreSkillTag_C:Construct()
end
function WBP_SoulCoreSkillTag_C:Destruct()
end
function WBP_SoulCoreSkillTag_C:Show(SkillTagName)
  self.RGTextTagName:SetText(SkillTagName)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_SoulCoreSkillTag_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_SoulCoreSkillTag_C
