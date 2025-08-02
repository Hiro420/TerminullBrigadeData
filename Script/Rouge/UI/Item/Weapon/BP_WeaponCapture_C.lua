local BP_WeaponCapture_C = UnLua.Class()

function BP_WeaponCapture_C:LeftMouseButtonPressed()
  if not self.RotateByAccessory then
    self.InConfigTransform = false
    self:ChangeTransformByWeapon(true, true)
    self:ClearEquipSlotChoose()
    PlaySound2DEffect(30010, "")
  end
end

function BP_WeaponCapture_C:LeftMouseButtonReleased()
  if not self.RotateByAccessory then
    self.InConfigTransform = true
    self.ManualRotate = false
    self:ChangeTransformByWeapon(true, false)
    EventSystem.Invoke(EventDef.GamePokey.OnWeaponMeshReleased)
    self.RecordX = 0
    self.RecordY = 0
  end
end

function BP_WeaponCapture_C:CheckWeaponMeshRotation(RecordX, RecordY)
  if not self.ManualRotate and (RecordX ~= self.RecordX or RecordY ~= self.RecordY) then
    self.ManualRotate = true
    EventSystem.Invoke(EventDef.GamePokey.OnWeaponMeshPressed)
  end
end

return BP_WeaponCapture_C
