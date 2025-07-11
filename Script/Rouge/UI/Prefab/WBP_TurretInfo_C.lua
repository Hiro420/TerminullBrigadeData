local ViewBase = require("Rouge.UI.Prefab.WBP_AIInfo_C")
local WBP_TurretInfo_C = UnLua.Class(ViewBase)
WBP_TurretInfo_C.bNeedOverrideHideFunc = true
function WBP_TurretInfo_C:Construct()
  self.bIsShowPanel = false
  self.Super.Construct(self)
  self.ShowLeftTime = 0
  local CoreCom = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreCom then
    CoreCom:BindAttributeChanged(self.HealthAttribute, {
      self,
      self.BindOnHealthAttributeChanged
    })
    CoreCom:BindAttributeChanged(self.MaxShieldAttribute, {
      self,
      self.BindOnMaxShieldAttributeChanged
    })
  end
end
function WBP_TurretInfo_C:Destruct()
  self.Super.Destruct(self)
  local CoreCom = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if CoreCom then
    CoreCom:UnBindAttributeChanged(self.HealthAttribute, {
      self,
      self.BindOnHealthAttributeChanged
    })
    CoreCom:UnBindAttributeChanged(self.MaxShieldAttribute, {
      self,
      self.BindOnMaxShieldAttributeChanged
    })
  end
end
function WBP_TurretInfo_C:BindOnHealthAttributeChanged(NewValue, OldValue)
  if NewValue < OldValue then
    self.ShowLeftTime = 3
  end
end
function WBP_TurretInfo_C:BindOnMaxShieldAttributeChanged(NewValue, OldValue)
  self:UpdateShieldBarVisibility()
end
function WBP_TurretInfo_C:ShowPanel()
  UpdateVisibility(self.HealthBar, true)
  self.bIsShowPanel = true
  self:UpdateShieldBarVisibility()
end
function WBP_TurretInfo_C:HidePanel()
  UpdateVisibility(self.HealthBar, false)
  self.bIsShowPanel = false
  self:UpdateShieldBarVisibility()
end
function WBP_TurretInfo_C:UpdateShieldBarVisibility()
  local MaxSheild = 0
  if self.OwningActor then
    local CoreCom = self.OwningActor:GetComponentByClass(UE.URGCoreComponent:StaticClass())
    if CoreCom then
      MaxSheild = CoreCom:GetAttributeValue(self.MaxShieldAttribute)
    end
  end
  UpdateVisibility(self.ShieldBar, MaxSheild > 0 and self.bIsShowPanel)
end
function WBP_TurretInfo_C:InitWidgetInfo(OwningActor)
  self.Super.InitWidgetInfo(self, OwningActor)
  if nil == OwningActor then
    return
  end
  local OwnerCharacter = OwningActor:GetInstigator()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if OwnerCharacter and Character then
    print("WBP_TurretInfo_C InitWidgetInfo", Character:GetUserId(), OwnerCharacter:GetUserId())
    if OwnerCharacter ~= Character then
      UpdateVisibility(self, false)
    else
      UpdateVisibility(self, true)
    end
  end
end
function WBP_TurretInfo_C:LuaTick(InDeltaTime)
  if self.ShowLeftTime > 0 then
    self.ShowLeftTime = self.ShowLeftTime - InDeltaTime
    UpdateVisibility(self.HealthBar, true)
    UpdateVisibility(self.HorizontalBox_68, true)
  end
  if self.ShowLeftTime <= 0 then
    UpdateVisibility(self.HealthBar, false)
    UpdateVisibility(self.HorizontalBox_68, false)
  end
end
return WBP_TurretInfo_C
