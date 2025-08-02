local GloriaTypeId = 1040
local WBP_GloriaRobotInfo_C = UnLua.Class()

function WBP_GloriaRobotInfo_C:Construct()
  self.Overridden.Construct(self)
end

function WBP_GloriaRobotInfo_C:Destruct()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character.CoreComponent
  if not CoreComp then
    return
  end
  CoreComp:UnBindAttributeChanged(self.AttackTurretPlaceNum, {
    self,
    self.BindOnAttackTurretPlaceNumAttributeChanged
  })
  CoreComp:UnBindAttributeChanged(self.AttackTurretPlaceMaxNum, {
    self,
    self.BindOnAttackTurretPlaceNumAttributeChanged
  })
  CoreComp:UnBindAttributeChanged(self.TreatTurretPlaceNum, {
    self,
    self.BindOnTreatTurretPlaceNumAttributeChanged
  })
  CoreComp:UnBindAttributeChanged(self.TreatTurretPlaceMaxNum, {
    self,
    self.BindOnTreatTurretPlaceNumAttributeChanged
  })
  self.Overridden.Destruct(self)
end

function WBP_GloriaRobotInfo_C:Init()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  if Character:GetTypeID() ~= GloriaTypeId then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true)
  local CoreComp = Character.CoreComponent
  if not CoreComp then
    return
  end
  CoreComp:BindAttributeChanged(self.AttackTurretPlaceNum, {
    self,
    self.BindOnAttackTurretPlaceNumAttributeChanged
  })
  CoreComp:BindAttributeChanged(self.AttackTurretPlaceMaxNum, {
    self,
    self.BindOnAttackTurretPlaceNumAttributeChanged
  })
  CoreComp:BindAttributeChanged(self.TreatTurretPlaceNum, {
    self,
    self.BindOnTreatTurretPlaceNumAttributeChanged
  })
  CoreComp:BindAttributeChanged(self.TreatTurretPlaceMaxNum, {
    self,
    self.BindOnTreatTurretPlaceNumAttributeChanged
  })
  self:InitNum()
end

function WBP_GloriaRobotInfo_C:InitNum()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character.CoreComponent
  if not CoreComp then
    return
  end
  local AttackTurretPlaceNumTemp = CoreComp:GetCurrentAttributeValue(self.AttackTurretPlaceNum)
  local AttackTurretPlaceMaxNumTemp = CoreComp:GetCurrentAttributeValue(self.AttackTurretPlaceMaxNum)
  self.WBP_GloriaAttackRobotItem:Init(self.AttackTurretIcon, AttackTurretPlaceNumTemp, AttackTurretPlaceMaxNumTemp)
  local TreatTurretPlaceNumTemp = CoreComp:GetCurrentAttributeValue(self.TreatTurretPlaceNum)
  local TreatTurretPlaceMaxNumTemp = CoreComp:GetCurrentAttributeValue(self.TreatTurretPlaceMaxNum)
  self.WBP_GloriaTreatRobotItem:Init(self.TreatTurretIcon, TreatTurretPlaceNumTemp, TreatTurretPlaceMaxNumTemp)
end

function WBP_GloriaRobotInfo_C:BindOnAttackTurretPlaceNumAttributeChanged(NewValue, OldValue)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  local AttackTurretPlaceNumTemp = CoreComp:GetCurrentAttributeValue(self.AttackTurretPlaceNum)
  local AttackTurretPlaceMaxNumTemp = CoreComp:GetCurrentAttributeValue(self.AttackTurretPlaceMaxNum)
  self.WBP_GloriaAttackRobotItem:Init(self.AttackTurretIcon, AttackTurretPlaceNumTemp, AttackTurretPlaceMaxNumTemp)
  self:UpdateInteractTipVis()
end

function WBP_GloriaRobotInfo_C:BindOnTreatTurretPlaceNumAttributeChanged(NewValue, OldValue)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  local TreatTurretPlaceNumTemp = CoreComp:GetCurrentAttributeValue(self.TreatTurretPlaceNum)
  local TreatTurretPlaceMaxNumTemp = CoreComp:GetCurrentAttributeValue(self.TreatTurretPlaceMaxNum)
  self.WBP_GloriaTreatRobotItem:Init(self.TreatTurretIcon, TreatTurretPlaceNumTemp, TreatTurretPlaceMaxNumTemp)
  self:UpdateInteractTipVis()
end

function WBP_GloriaRobotInfo_C:UpdateInteractTipVis()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  local AttackTurretPlaceNumTemp = CoreComp:GetCurrentAttributeValue(self.AttackTurretPlaceNum)
  local TreatTurretPlaceNumTemp = CoreComp:GetCurrentAttributeValue(self.TreatTurretPlaceNum)
  if 0 == AttackTurretPlaceNumTemp and 0 == TreatTurretPlaceNumTemp then
    UpdateVisibility(self.InteractTip, false)
  else
    UpdateVisibility(self.InteractTip, true)
  end
end

return WBP_GloriaRobotInfo_C
