local BP_AvatarRole_C = UnLua.Class()
function BP_AvatarRole_C:ReceiveBeginPlay()
  self.OtherSkeletalMesh = {
    [UE.EAvatarPartType.MainBody] = self.Mesh,
    [UE.EAvatarPartType.Face] = self.Head,
    [UE.EAvatarPartType.Hair] = self.Hair
  }
end
function BP_AvatarRole_C:RefreshSkeletalMesh(Type, Id)
  local Result, AvatarItemRowInfo = GetDataLibraryObj().GetAvatarItemRowInfo(Id)
  local TargetSkeletalMeshComp = self.OtherSkeletalMesh[Type]
  if not Result or Type ~= AvatarItemRowInfo.Type then
    if TargetSkeletalMeshComp then
      TargetSkeletalMeshComp:SetSkeletalMesh(nil)
      TargetSkeletalMeshComp:SetAnimClass(nil)
    end
    return
  end
  if AvatarItemRowInfo.ConfigType == UE.EConfigType.Mesh then
    if AvatarItemRowInfo.Type == UE.EAvatarPartType.MainBody then
      LogicAvatar.SetCurGender(AvatarItemRowInfo.Gender)
      if AvatarItemRowInfo.Gender == UE.EGender.Female then
        self.Hair:K2_AttachToComponent(self.Mesh, "neck_01")
      else
        self.Hair:K2_AttachToComponent(self.Mesh, "None")
      end
      self.TargetMeshDataByGender = AvatarItemRowInfo.BodyMeshData
    else
      self.TargetMeshDataByGender = AvatarItemRowInfo.MeshData:Find(LogicAvatar.GetCurGender())
    end
    if not self.TargetMeshDataByGender then
      print("BP_AvatarRole_C:RefreshSkeletalMesh, \230\178\161\230\137\190\229\136\176\232\175\165\230\128\167\229\136\171\229\175\185\229\186\148\231\154\132mesh\228\191\161\230\129\175", Id)
      return
    end
    if not TargetSkeletalMeshComp then
      TargetSkeletalMeshComp = self:AddSkeletalMeshComp()
      self.OtherSkeletalMesh[AvatarItemRowInfo.Type] = TargetSkeletalMeshComp
    end
    if UE.UKismetSystemLibrary.IsValidSoftObjectReference(self.TargetMeshDataByGender.Mesh) then
      local MeshObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(self.TargetMeshDataByGender.Mesh)
      UE.URGBlueprintLibrary.EmptyOverrideMaterials(TargetSkeletalMeshComp)
      TargetSkeletalMeshComp:SetSkeletalMesh(MeshObj, true)
      TargetSkeletalMeshComp:SetAnimationMode(self.TargetMeshDataByGender.AnimationMode)
      if self.TargetMeshDataByGender.AnimationMode == UE.EAnimationMode.AnimationBlueprint then
        local AnimClass = UE.UKismetSystemLibrary.LoadClassAsset_Blocking(self.TargetMeshDataByGender.AnimBlueprintClass)
        TargetSkeletalMeshComp:SetAnimClass(AnimClass)
      elseif self.TargetMeshDataByGender.AnimationMode == UE.EAnimationMode.AnimationSingleNode then
        self.TargetMeshDataByGender.AnimationData = self.TargetMeshDataByGender.AnimData
      end
      if self.TargetMeshDataByGender.IsUseMorph then
        TargetSkeletalMeshComp:ClearMorphTargets()
        for key, SingleMorphParam in pairs(self.TargetMeshDataByGender.MorphParams) do
          TargetSkeletalMeshComp:SetMorphTarget(SingleMorphParam.MorphTargetName, SingleMorphParam.Value, true)
        end
      end
    else
      TargetSkeletalMeshComp:SetSkeletalMesh(nil)
      TargetSkeletalMeshComp:SetAnimClass(nil)
    end
    if not (AvatarItemRowInfo.IsUseMasterPose and self.OtherSkeletalMesh[UE.EAvatarPartType.MainBody]) or self.OtherSkeletalMesh[UE.EAvatarPartType.MainBody].SkeletalMesh then
    end
    self.TargetMeshDataByGender = UE.FMeshData()
  elseif AvatarItemRowInfo.ConfigType == UE.EConfigType.Material then
    local TargetSkeletalMesh = self.OtherSkeletalMesh[AvatarItemRowInfo.TargetPartType]
    if not TargetSkeletalMesh then
      print("not found TargetSkeletalMesh, please check config, RowId:" .. AvatarItemRowInfo.Id .. "TargetPartType" .. AvatarItemRowInfo.TargetPartType)
      return
    end
    local TargetMaterialDataByGender = AvatarItemRowInfo.MaterialData:Find(LogicAvatar.GetCurGender())
    if TargetMaterialDataByGender then
      for key, SingleMaterialConfig in pairs(TargetMaterialDataByGender.MaterialConfigs) do
        if SingleMaterialConfig.IsUseOtherPartType then
          TargetSkeletalMesh = self.OtherSkeletalMesh[SingleMaterialConfig.TargetPartType]
        else
          TargetSkeletalMesh = self.OtherSkeletalMesh[AvatarItemRowInfo.TargetPartType]
        end
        if not TargetSkeletalMesh then
          print("not found TargetSkeletalMesh, please check config, RowId:" .. AvatarItemRowInfo.Id .. "TargetPartType" .. AvatarItemRowInfo.TargetPartType)
        elseif TargetSkeletalMesh:IsMaterialSlotNameValid(SingleMaterialConfig.MaterialSlotName) then
          local MaterialObj = self:LoadMaterialSoftObject(SingleMaterialConfig.MaterialInstance)
          TargetSkeletalMesh:SetMaterialByName(SingleMaterialConfig.MaterialSlotName, MaterialObj)
        end
      end
    end
  elseif AvatarItemRowInfo.ConfigType == UE.EConfigType.MaterialParam then
    local TargetSkeletalMesh = self.OtherSkeletalMesh[AvatarItemRowInfo.TargetPartType]
    if not TargetSkeletalMesh then
      print("not found TargetSkeletalMesh, please check config, RowId:" .. AvatarItemRowInfo.Id .. "TargetPartType" .. AvatarItemRowInfo.TargetPartType)
      return
    end
    local TargetMaterialParamDataByGender = AvatarItemRowInfo.MaterialParamData:Find(LogicAvatar.GetCurGender())
    local TargetSkeletalMesh = self.OtherSkeletalMesh[AvatarItemRowInfo.TargetPartType]
    for i, SingleParamData in pairs(TargetMaterialParamDataByGender.ParamData) do
      if SingleParamData.IsUseOtherPartType then
        TargetSkeletalMesh = self.OtherSkeletalMesh[SingleParamData.TargetPartType]
      else
        TargetSkeletalMesh = self.OtherSkeletalMesh[AvatarItemRowInfo.TargetPartType]
      end
      if not TargetSkeletalMesh then
        print("not found TargetSkeletalMesh, please check config, RowId:" .. AvatarItemRowInfo.Id .. "TargetPartType" .. AvatarItemRowInfo.TargetPartType)
      elseif TargetMaterialParamDataByGender and TargetSkeletalMesh:IsMaterialSlotNameValid(TargetMaterialParamDataByGender.MaterialSlotName) then
        local MaterialIndex = TargetSkeletalMesh:GetMaterialIndex(TargetMaterialParamDataByGender.MaterialSlotName)
        local MaterialObj = TargetSkeletalMesh:GetMaterial(MaterialIndex)
        if MaterialObj then
          local MaterialInstance = TargetSkeletalMesh:CreateDynamicMaterialInstance(MaterialIndex, MaterialObj)
          if SingleParamData.ParamType == UE.EMaterialParamType.Scalar then
            MaterialInstance:SetScalarParameterValue(SingleParamData.ParamName, SingleParamData.ScalarValue)
          elseif SingleParamData.ParamType == UE.EMaterialParamType.Texture then
            local TextureObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SingleParamData.TextureValue)
            MaterialInstance:SetTextureParameterValue(SingleParamData.ParamName, TextureObj)
          elseif SingleParamData.ParamType == UE.EMaterialParamType.Vector then
            MaterialInstance:SetVectorParameterValue(SingleParamData.ParamName, SingleParamData.VectorValue)
          end
        end
      end
    end
  end
end
return BP_AvatarRole_C
