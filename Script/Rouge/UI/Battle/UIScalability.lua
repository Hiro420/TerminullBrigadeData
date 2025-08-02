local UIQuality = {
  LOW = 0,
  MEDIUM = 1,
  HIGH = 2
}
local M = {
  Default = {},
  Survivor = {
    DamageNumber = UIQuality.MEDIUM,
    BossBarInfo = UIQuality.LOW,
    GridBar = UIQuality.LOW,
    AIInfo = UIQuality.LOW,
    RedWarning = UIQuality.LOW
  },
  Current = nil
}
_G.BattleUIScalability = _G.BattleUIScalability or M
_G.UIQuality = _G.UIQuality or UIQuality

function BattleUIScalability:GetScalabilityConfig()
  if UE.URGLevelLibrary.IsSurvivorMode() then
    return self.Survivor
  end
  return self.Default
end

function BattleUIScalability:GetDamageNumberScalability()
  return self:GetScalabilityConfig().DamageNumber or UIQuality.HIGH
end

function BattleUIScalability:GetBossBarInfoScalability()
  return self:GetScalabilityConfig().BossBarInfo or UIQuality.HIGH
end

function BattleUIScalability:GetGridBarScalability()
  return self:GetScalabilityConfig().GridBar or UIQuality.HIGH
end

function BattleUIScalability:GetAIInfoScalability()
  return self:GetScalabilityConfig().AIInfo or UIQuality.HIGH
end

function BattleUIScalability:GetRedWarningScalability()
  return self:GetScalabilityConfig().RedWarning or UIQuality.HIGH
end
