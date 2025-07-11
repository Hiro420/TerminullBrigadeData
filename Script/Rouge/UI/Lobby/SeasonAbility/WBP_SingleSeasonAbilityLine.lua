local WBP_SingleSeasonAbilityLine = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityModule = require("Modules.SeasonAbility.SeasonAbilityModule")
function WBP_SingleSeasonAbilityLine:Show(AbilityId, Type, CurHeroId)
  if 0 == AbilityId then
    self:Hide()
    return
  end
  UpdateVisibility(self, true)
  UpdateVisibility(self.CanvasPanel_LeftLine_Glow, 1 == self.LineType)
  UpdateVisibility(self.CanvasPanel_MiddleLine_Glow, 2 == self.LineType)
  UpdateVisibility(self.CanvasPanel_RightLine_Glow, 3 == self.LineType)
  self.AbilityId = AbilityId
  self.Type = Type
  self.CurHeroId = CurHeroId
  self:BindOnSeasonAbilityInfoUpdated()
  if not self.IsBind then
    EventSystem.AddListener(self, EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated, self.BindOnSeasonAbilityInfoUpdated)
    self.IsBind = true
  end
end
function WBP_SingleSeasonAbilityLine:BindOnSeasonAbilityInfoUpdated(...)
  local PreLevel = SeasonAbilityData:GetPreAbilityLevel(self.AbilityId, self.CurHeroId)
  local MaxLevel = SeasonAbilityData:GetAbilityMaxLevel(self.AbilityId)
  local Type = -1
  if PreLevel >= MaxLevel then
    Type = self.Type
  else
    self.CanPlayBrightenAnim = true
  end
  if PreLevel >= MaxLevel and self.CanPlayBrightenAnim then
    self:PlayAnimationForward(self.Ani_Brighten)
    self.CanPlayBrightenAnim = false
  end
  local TargetColor = SeasonAbilityModule:GetLineColorByType(Type)
  self.Img_Line:SetColorAndOpacity(TargetColor)
  local TargetAnimLineColor = SeasonAbilityModule:GetAnimLineColorByType(Type)
  self.Img_RightAnimLine:SetColorAndOpacity(TargetAnimLineColor)
  self.Img_LeftAnimLine:SetColorAndOpacity(TargetAnimLineColor)
  self.Img_MiddleAnimLine:SetColorAndOpacity(TargetAnimLineColor)
end
function WBP_SingleSeasonAbilityLine:Hide(...)
  UpdateVisibility(self, false)
  self:StopAllAnimations()
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnSeasonAbilityInfoUpdated, self.BindOnSeasonAbilityInfoUpdated, self)
  self.IsBind = false
end
function WBP_SingleSeasonAbilityLine:Destruct(...)
  self:Hide()
end
return WBP_SingleSeasonAbilityLine
