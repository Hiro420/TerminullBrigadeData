local SkinData = require("Modules.Appearance.Skin.SkinData")
local BP_LobbyRole_C = UnLua.Class()

function BP_LobbyRole_C:ReceiveBeginPlay()
  self:SetWeaponAnimBpInst()
end

function BP_LobbyRole_C:ActorBeginCursorOver()
  local ParentActor = self:GetParentActor()
  if not ParentActor then
    return
  end
  EventSystem.Invoke(EventDef.Lobby.LobbyHeroCursor, ParentActor.Index, true)
end

function BP_LobbyRole_C:ActorEndCursorOver()
  local ParentActor = self:GetParentActor()
  if not ParentActor then
    return
  end
  EventSystem.Invoke(EventDef.Lobby.LobbyHeroCursor, ParentActor.Index, false)
end

function BP_LobbyRole_C:ActorOnClicked(ButtonPressed)
  local ParentActor = self:GetParentActor()
  if not ParentActor then
    return
  end
  EventSystem.Invoke(EventDef.Lobby.LobbyHeroClicked, ParentActor.Index)
end

function BP_LobbyRole_C:ChangeWeaponSkin(WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
  local weaponSkinId = WeaponSkinId or "-1"
  self.ChildActor.ChildActor:InitPreChanged(self.ChildActor.ChildActor.CurrentSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
  self.ChildActor.ChildActor:LocalSetSkinId(weaponSkinId)
end

function BP_LobbyRole_C:ChangeRoleSkin(SkinId, SkinChangedCallback)
  if not (SkinId and tonumber(SkinId)) or tonumber(SkinId) < 0 then
    self:LocalSetSkinId(self.DefalutSkinId)
  else
    self:LocalSetSkinId(SkinId)
  end
  self.SkinChangedCallback = SkinChangedCallback
end

function BP_LobbyRole_C:GetDefaultRoleSkin()
  return self.DefalutSkinId and self.DefalutSkinId or -1
end

function BP_LobbyRole_C:OnSkinChanged(NewSkinId)
  self.Overridden.OnSkinChanged(self, NewSkinId)
  if self.bIsSucc ~= nil then
    self:UpdateAniInstBySkinId(NewSkinId, self.bIsSucc)
  else
    self:UpdateStandPos()
    self:SetRoleStatus(self.RoleStatus)
  end
  if self.SkinChangedCallback then
    self.SkinChangedCallback()
    self.SkinChangedCallback = nil
  end
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      LogicAudio.OnLobbyPlayHeroSound(tonumber(NewSkinId), self)
    end
  })
  self:RemoveHeroDithering(NewSkinId)
  local result, row = GetRowData(DT.DT_DisplaySkin, tostring(NewSkinId))
  if result then
    for i, v in iterator(row.SubSkins) do
      local subMesh = self:K2_GetSubMeshComponentFromRegistry(v.Skin.MeshComponentKey)
      if UE.RGUtil.IsUObjectValid(subMesh) then
        subMesh:SetLightingChannels(true, true, false)
      end
    end
  end
  self:SetVirtualLightON()
  EventSystem.Invoke(EventDef.Heirloom.MultiLayerCameraSkinChanged)
end

function BP_LobbyRole_C:SetVirtualLightON()
  self.Mesh:SetScalarParameterValueOnMaterials("VirtualLightON", 1)
end

function BP_LobbyRole_C:UpdateStandPos()
  local aniInst = self.Mesh:GetAnimInstance()
  if aniInst and aniInst:Cast(UE.URGLobbyRoleAnimInstance) then
    aniInst:SetStandPos(self.StandPos)
  end
end

function BP_LobbyRole_C:UpdateAniInstBySkinId(SkinId, bIsSucc)
  self.bIsSucc = bIsSucc
  local result, row = GetRowData(DT.DT_DisplaySkin, tostring(SkinId))
  if result then
    local majorMeshAniCls
    if bIsSucc then
      majorMeshAniCls = GetAssetBySoftObjectPtr(row.MajorSkin.AnimInstanceSettleSuccess, true)
    else
      majorMeshAniCls = GetAssetBySoftObjectPtr(row.MajorSkin.AnimInstanceSettleFailed, true)
    end
    if UE.RGUtil.IsUObjectValid(self.Mesh) and UE.RGUtil.IsUObjectValid(majorMeshAniCls) then
      self.Mesh:SetAnimClass(majorMeshAniCls)
    end
    for i, v in iterator(row.SubSkins) do
      local subMesh = self:K2_GetSubMeshComponentFromRegistry(v.Skin.MeshComponentKey)
      local aniCls
      if bIsSucc then
        aniCls = GetAssetBySoftObjectPtr(v.Skin.AnimInstanceSettleSuccess, true)
      else
        aniCls = GetAssetBySoftObjectPtr(v.Skin.AnimInstanceSettleFailed, true)
      end
      if UE.RGUtil.IsUObjectValid(subMesh) and UE.RGUtil.IsUObjectValid(aniCls) then
        subMesh:SetAnimClass(aniCls)
      end
    end
    self:UpdateStandPos()
    self:ResetRoleStatus()
  end
end

function BP_LobbyRole_C:RemoveHeroDithering(SkinId)
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

function BP_LobbyRole_C:UpdateMat(Mesh)
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

function BP_LobbyRole_C:ShowOrHideTargetChildren(bIsShow, Target)
  if not UE.RGUtil.IsUObjectValid(Target) then
    return
  end
  local compAry = UE.TArray(UE.USceneComponent)
  compAry = Target:GetChildrenComponents(false, nil)
  for i, v in pairs(compAry) do
    UE.URGBlueprintLibrary.SetSceneComVisible(v, bIsShow)
    if bIsShow then
      v:SetHiddenInGame(false)
    else
      v:SetHiddenInGame(true)
    end
  end
end

function BP_LobbyRole_C:ShowOrHideLightInActor(IsShow)
  self:HideSettlementLight()
  print("BP_LobbyRole_C:ShowOrHideLightInActor", IsShow)
  if UE.RGUtil.IsUObjectValid(self.Light_Default) then
    self.Light_Default:SetHiddenInGame(not IsShow)
    self:ShowOrHideTargetChildren(IsShow, self.Light_Default)
  end
end

function BP_LobbyRole_C:ShowLightBySettlementResult(SettleStatus)
  print("BP_LobbyRole_C:ShowLightBySettlementResult", SettleStatus)
  if UE.RGUtil.IsUObjectValid(self.Light_Default) then
    self.Light_Default:SetHiddenInGame(true)
    self:ShowOrHideTargetChildren(false, self.Light_Default)
  end
  if SettleStatus == SettlementStatus.Finish then
    if UE.RGUtil.IsUObjectValid(self.Light_Settlement_Victory) then
      print("BP_LobbyRole_C:ShowLightBySettlementResult Succ")
      self.Light_Settlement_Defeat:SetHiddenInGame(true)
      self.Light_Settlement_Victory:SetHiddenInGame(false)
      self:ShowOrHideTargetChildren(true, self.Light_Settlement_Victory)
      self:ShowOrHideTargetChildren(false, self.Light_Settlement_Defeat)
    end
  elseif UE.RGUtil.IsUObjectValid(self.Light_Settlement_Defeat) then
    print("BP_LobbyRole_C:ShowLightBySettlementResult Defeat")
    self.Light_Settlement_Defeat:SetHiddenInGame(false)
    self.Light_Settlement_Victory:SetHiddenInGame(true)
    self:ShowOrHideTargetChildren(false, self.Light_Settlement_Victory)
    self:ShowOrHideTargetChildren(true, self.Light_Settlement_Defeat)
  end
end

function BP_LobbyRole_C:HideSettlementLight()
  self:ShowOrHideTargetChildren(false, self.Light_Settlement_Victory)
  self:ShowOrHideTargetChildren(false, self.Light_Settlement_Defeat)
  if UE.RGUtil.IsUObjectValid(self.Light_Settlement_Victory) then
    self.Light_Settlement_Victory:SetHiddenInGame(true)
  end
  if UE.RGUtil.IsUObjectValid(self.Light_Settlement_Defeat) then
    self.Light_Settlement_Defeat:SetHiddenInGame(true)
  end
end

function BP_LobbyRole_C:HideDrawCardShowMatEffect()
  self:UpdateSkin()
  self:SetVirtualLightON()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:UpdateSkin()
  end
end

function BP_LobbyRole_C:ShowDrawCardShowMatEffect_LUA()
  self:ShowDrawCardShowMatEffect()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ShowDrawCardShowMatEffect()
  end
end

return BP_LobbyRole_C
