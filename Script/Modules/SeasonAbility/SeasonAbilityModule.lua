local SeasonAbilityModule = ModuleManager and ModuleManager:Get("SeasonAbilityModule") or LuaClass()

function SeasonAbilityModule:Ctor(...)
end

function SeasonAbilityModule:OnInit(...)
  SeasonAbilityModule.IsAutoExchangeAbilityPoint = false
end

function SeasonAbilityModule:InitItemStyle(InAbilityItemStyle)
  SeasonAbilityModule.AbilityItemStyle = InAbilityItemStyle
end

function SeasonAbilityModule:GetItemStyleByType(Type)
  return SeasonAbilityModule.AbilityItemStyle[Type] and SeasonAbilityModule.AbilityItemStyle[Type] or SeasonAbilityModule.AbilityItemStyle[TableEnums.ENUMAbilityType.Weapon]
end

function SeasonAbilityModule:InitLineColorList(InLineColorList)
  SeasonAbilityModule.LineColorList = InLineColorList
end

function SeasonAbilityModule:GetLineColorByType(Type)
  return SeasonAbilityModule.LineColorList[Type] and SeasonAbilityModule.LineColorList[Type] or SeasonAbilityModule.LineColorList[TableEnums.ENUMAbilityType.Weapon]
end

function SeasonAbilityModule:InitAnimLineColorList(InAnimLineColorList)
  SeasonAbilityModule.AnimLineColorList = InAnimLineColorList
end

function SeasonAbilityModule:GetAnimLineColorByType(Type)
  return SeasonAbilityModule.AnimLineColorList[Type] and SeasonAbilityModule.AnimLineColorList[Type] or SeasonAbilityModule.AnimLineColorList[TableEnums.ENUMAbilityType.Weapon]
end

function SeasonAbilityModule:SetIsAutoExchangeAbilityPoint(InIsAuto)
  SeasonAbilityModule.IsAutoExchangeAbilityPoint = InIsAuto
end

function SeasonAbilityModule:GetIsAutoExchangeAbilityPoint(...)
  return SeasonAbilityModule.IsAutoExchangeAbilityPoint
end

function SeasonAbilityModule:OnShutdown(...)
end

return SeasonAbilityModule
