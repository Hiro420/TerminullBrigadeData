local SkinData = require("Modules.Appearance.Skin.SkinData")
local BP_DisplayWeapon_C = UnLua.Class()

function BP_DisplayWeapon_C:OnSkinChanged(NewSkinId)
  self.Overridden.OnSkinChanged(self, NewSkinId)
  self:RemoveHeroDithering(NewSkinId)
  local resultDisplayWeaponSkin, rowDisplayWeaponSkin = GetRowData(DT.DT_DisplayWeaponSkin, tostring(NewSkinId))
  if resultDisplayWeaponSkin and rowDisplayWeaponSkin.OffHandSkin.Skin.SkeletalMesh and rowDisplayWeaponSkin.OffHandSkin.Skin.SkeletalMesh:IsValid() then
    self:CreateOffHandWeaponMesh(rowDisplayWeaponSkin.OffHandSkin)
  end
  local weaponResId = SkinData.GetWeaponResIdBySkinId(NewSkinId)
  if weaponResId then
    local result, row = GetRowData(DT.DT_RoleWeaponDisplayConfig, weaponResId)
    if result then
      self.Mesh:K2_SetRelativeTransform(row.RoleWeaponTransform, false, nil, false)
    else
      local resultDefault, rowDefault = GetRowData(DT.DT_RoleWeaponDisplayConfig, "Defalut")
      if resultDefault then
        self.Mesh:K2_SetRelativeTransform(rowDefault.RoleWeaponTransform, false, nil, false)
      end
    end
  end
  if self.bShowGlitchMatEffect then
    self:ShowGlitchMatEffect()
    self:MaterialAni(false)
    self.bShowGlitchMatEffect = false
  end
  if self.bShowDrawCardShowMatEffect then
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function(self)
        self:ShowDrawCardShowMatEffect()
        self:MaterialAni(true)
      end
    }, self.DrawCardShowMaterialAniDelayTime, false)
    self.bShowDrawCardShowMatEffect = false
  end
end

function BP_DisplayWeapon_C:GlitchAniEnd()
  self:UpdateSkin()
end

function BP_DisplayWeapon_C:BP_GetCurWeaponResID()
  local weaponResID = SkinData.GetWeaponResIdBySkinId(self.CurrentSkinId)
  if weaponResID then
    return weaponResID
  end
  return -1
end

function BP_DisplayWeapon_C:RemoveHeroDithering(SkinId)
  self:UpdateMat(self.Mesh)
  local result, row = GetRowData(DT.DT_DisplaySkin, tostring(SkinId))
  if result then
    for i, v in iterator(row.SubSkins) do
      local subMesh = self:K2_GetSubMeshComponentFromRegistry(v.Skin.MeshComponentKey)
      if UE.RGUtil.IsUObjectValid(subMesh) then
        self:UpdateMat(subMesh)
      end
    end
  end
end

function BP_DisplayWeapon_C:UpdateMat(Mesh)
  if UE.RGUtil.IsUObjectValid(Mesh) then
    for i, v in iterator(Mesh.OverrideMaterials) do
      if UE.RGUtil.IsUObjectValid(v) and v:IsA(UE.UMaterialInstanceDynamic) then
        v:SetScalarParameterValue("MaxHeroDitheringDistance", 1)
        v:SetScalarParameterValue("DisableHairDithering", 0)
      else
        local dynamicInst = UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(self, v)
        dynamicInst:K2_CopyMaterialInstanceParameters(v, true)
        dynamicInst:SetScalarParameterValue("MaxHeroDitheringDistance", 1)
        dynamicInst:SetScalarParameterValue("DisableHairDithering", 0)
        UE.URGBlueprintLibrary.SetMeshMaterial(Mesh, i - 1, dynamicInst)
      end
    end
  end
end

function BP_DisplayWeapon_C:InitPreChanged(OldSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
  self.bShowGlitchMatEffect = bShowGlitchMatEffect
  self.bShowDrawCardShowMatEffect = bShowDrawCardShowMatEffect
  self.OldSkinId = OldSkinId
end

function BP_DisplayWeapon_C:HideDrawCardShowMatEffect()
  self:UpdateSkin()
end

return BP_DisplayWeapon_C
