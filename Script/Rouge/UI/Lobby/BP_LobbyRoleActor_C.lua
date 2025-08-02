local SkinData = require("Modules.Appearance.Skin.SkinData")
local BP_LobbyRoleActor_C = UnLua.Class()

function BP_LobbyRoleActor_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  local skinSys = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.URGSkinSystem:StaticClass())
  if skinSys then
    skinSys.OnDynamicSkinChange:Add(self, self.SkinChanged)
  end
  self:ForceRefreshBodyMesh()
end

function BP_LobbyRoleActor_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  local skinSys = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.URGSkinSystem:StaticClass())
  if skinSys then
    skinSys.OnDynamicSkinChange:Remove(self, self.SkinChanged)
  end
end

function BP_LobbyRoleActor_C:SkinChanged(TargetActor, Success, SkinId)
  if TargetActor == self.ChildActor.ChildActor then
    if self.bShowGlitchMatEffect then
      TargetActor:ShowGlitchMatEffect()
      self:MaterialAni()
      self.bShowGlitchMatEffect = false
    end
    if self.bShowDrawCardShowMatEffect then
      UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        self,
        function(self)
          TargetActor:ShowDrawCardShowMatEffect()
          self:MaterialAni()
        end
      }, self.DrawCardShowMaterialAniDelayTime, false)
      self.bShowDrawCardShowMatEffect = false
    end
  end
end

function BP_LobbyRoleActor_C:GlitchAniEnd()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:UpdateSkin()
    self.ChildActor.ChildActor:SetVirtualLightON()
  end
end

function BP_LobbyRoleActor_C:ForceRefreshBodyMesh()
  local RowInfo = LogicRole.GetCharacterTableRow(self.CurEquipHeroId)
  if not RowInfo then
    return
  end
  local SkinId = self.CurEquipSkinId or SkinData.GetEquipedSkinIdByHeroId(self.CurEquipHeroId)
  local tbSkinRowName = GetTbSkinRowNameBySkinID(SkinId)
  local ActorCls
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, tbSkinRowName)
  if result then
    ActorCls = GetAssetByPath(row.ActorPath, true)
  end
  if ActorCls and not UE.UKismetMathLibrary.EqualEqual_ClassClass(self.ChildActor.ChildActorClass, ActorCls) then
    self.ChildActor:SetChildActorClass(ActorCls)
  elseif self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ResetAnimation()
  end
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ShowOrHideLightInActor(self.IsShowLightInActor)
  end
  if self.ChildActor.ChildActor and UE.RGUtil.IsUObjectValid(self.ChildActor.ChildActor) and self.ChildActor.ChildActor.ChangeRoleSkin then
    self.ChildActor.ChildActor:ChangeRoleSkin(SkinId)
    self.CurSkinId = SkinId
  end
  self:ChangeWeaponMesh(self.CurEquipHeroId)
end

function BP_LobbyRoleActor_C:ChangeBodyMesh(HeroId, SkinId, SkinChangedCallback, IsNotShowEquipSkinMap, bShowGlitchMatEffect, IsShowHeroEffect, bShowDrawCardShowMatEffect, bForceInit)
  if nil == bShowGlitchMatEffect then
    bShowGlitchMatEffect = false
  end
  if nil == bShowDrawCardShowMatEffect then
    bShowDrawCardShowMatEffect = false
  end
  self.bShowGlitchMatEffect = false
  self.bShowDrawCardShowMatEffect = false
  self.CurEquipHeroId = HeroId
  self.CurEquipSkinId = SkinId
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if not RowInfo then
    return
  end
  local skinId = SkinId or SkinData.GetEquipedSkinIdByHeroId(HeroId)
  if -1 == skinId then
    skinId = SkinData.GetDefaultSkinIdByHeroId(HeroId)
  end
  if self.CurSkinId ~= skinId or bForceInit then
    local tbSkinRowName = GetTbSkinRowNameBySkinID(skinId)
    local ActorCls
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, tbSkinRowName)
    if result then
      ActorCls = GetAssetByPath(row.ActorPath, true)
    end
    LogicAudio.OnLobbyPlayHeroSound(skinId, self)
    if ActorCls and not UE.UKismetMathLibrary.EqualEqual_ClassClass(self.ChildActor.ChildActorClass, ActorCls) then
      self.ChildActor:SetChildActorClass(ActorCls)
      if UE.RGUtil.IsUObjectValid(self.Representative) then
        self.ChildActor.ChildActor:SetRepresentative(self.Representative)
      else
        self.ChildActor.ChildActor:SetRepresentative(self)
      end
    elseif self.ChildActor.ChildActor then
      self.ChildActor.ChildActor:ResetAnimation()
    end
  end
  if (self.CurSkinId ~= skinId or bForceInit) and self.ChildActor.ChildActor and UE.RGUtil.IsUObjectValid(self.ChildActor.ChildActor) and self.ChildActor.ChildActor.ChangeRoleSkin then
    if tonumber(skinId) < 0 and self.ChildActor.ChildActor.GetDefaultRoleSkin then
      skinId = self.ChildActor.ChildActor:GetDefaultRoleSkin()
    end
    local cbFunc = function()
      if SkinChangedCallback then
        SkinChangedCallback()
      end
      if self and self.ChildActor.ChildActor and UE.RGUtil.IsUObjectValid(self.ChildActor.ChildActor) then
        self.ChildActor.ChildActor:SetHiddenInGame(false)
      end
    end
    if self and self.ChildActor.ChildActor and UE.RGUtil.IsUObjectValid(self.ChildActor.ChildActor) then
      self.ChildActor.ChildActor:SetHiddenInGame(true)
    end
    self.ChildActor.ChildActor:ChangeRoleSkin(skinId, cbFunc)
    self.CurSkinId = skinId
    self.bShowGlitchMatEffect = bShowGlitchMatEffect
    self.bShowDrawCardShowMatEffect = bShowDrawCardShowMatEffect
  end
  if not self.IsShowLightInActor and not IsNotShowEquipSkinMap then
    LogicRole.ShowSkinLightMap(self.CurSkinId)
  end
  if self.bShowGlitchMatEffect ~= bShowGlitchMatEffect then
    self.ChildActor.ChildActor:ShowGlitchMatEffect()
    self:MaterialAni()
  end
  if self.bShowDrawCardShowMatEffect ~= bShowDrawCardShowMatEffect then
    UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      function(self)
        self:ShowDrawCardShowMatEffect()
        self:MaterialAni()
      end
    }, self.DrawCardShowMaterialAniDelayTime, false)
  end
  self:ChangeWeaponMesh(HeroId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ShowOrHideLightInActor(self.IsShowLightInActor)
    self.ChildActor.ChildActor:RoleUpdateStandPos(self.StandPos)
    LogicRole.SetEffectState(self.ChildActor.ChildActor, skinId, HeroId, IsShowHeroEffect)
  end
end

function BP_LobbyRoleActor_C:LobbyRoleActorToggleSkipEnter(bSkipEnterParam)
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ToggleSkipEnter(bSkipEnterParam)
  end
end

function BP_LobbyRoleActor_C:LobbyRoleActorResetAnimation()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ResetAnimation()
  end
end

function BP_LobbyRoleActor_C:GetDefaultRoleSkinId(...)
  return self.ChildActor.ChildActor:GetDefaultRoleSkin()
end

function BP_LobbyRoleActor_C:ClearChildActor()
  if not self.ChildActor.ChildActor or self.ChildActor.ChildActor:IsValid() then
  end
end

function BP_LobbyRoleActor_C:ResetChildActorAnimation()
  if not self.ChildActor.ChildActor then
    return
  end
  self.ChildActor.ChildActor:SetRoleStatus(UE.ERGLobbyRoleStatus.RelaxIdle)
  self.ChildActor.ChildActor:ResetAnimation()
end

function BP_LobbyRoleActor_C:ChangeWeaponMesh(HeroId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
  local WeaponId, WeaponSkinId
  if not DataMgr.IsOwnHero(HeroId) then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, HeroId)
    if not Result then
      print("BP_LobbyRoleActor_C:ChangeWeaponMesh not OwnHero not found Hero RowInfo!", HeroId)
      return
    end
    WeaponId = RowInfo.WeaponID
    local BResult, WeaponRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, WeaponId)
    if not BResult then
      print("BP_LobbyRoleActor_C:ChangeWeaponMesh not OwnHero not found Weapon RowInfo!", WeaponId)
      return
    end
    WeaponSkinId = WeaponRowInfo.SkinID
  else
    local EquippedWeaponList = DataMgr.GetEquippedWeaponList(HeroId)
    if not EquippedWeaponList then
      return
    end
    local TargetWeaponInfo = EquippedWeaponList[1]
    if not TargetWeaponInfo then
      return
    end
    WeaponId = tonumber(TargetWeaponInfo.resourceId)
    WeaponSkinId = EquippedWeaponList[1].skin
  end
  if not WeaponId or not WeaponSkinId then
    return
  end
  if self.ChildActor.ChildActor and self.ChildActor.ChildActor.ChangeWeaponSkin then
    self.ChildActor.ChildActor:ChangeWeaponSkin(WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
    self.CurWeaponSkinId = WeaponSkinId
  end
end

function BP_LobbyRoleActor_C:ChangeWeaponMeshBySkinId(WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ChangeWeaponSkin(WeaponSkinId, bShowGlitchMatEffect, bShowDrawCardShowMatEffect)
  end
  self.CurWeaponSkinId = WeaponSkinId
end

function BP_LobbyRoleActor_C:ChangeWeaponMeshById(WeaponId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local WeaponRowInfo = DTSubsystem:GetWeaponTableRowByID(WeaponId, nil)
  if self.ChildActor.ChildActor then
    local Mesh = GetAssetBySoftObjectPtr(WeaponRowInfo.SkeletalMesh, true)
    if Mesh then
    end
  end
end

function BP_LobbyRoleActor_C:ChangeChildActorDefaultRotation(HeroId)
  local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
  if not CharacterRow then
    return
  end
  local TargetRotator = UE.FRotator()
  TargetRotator.Pitch = self.DefaultRelativeRotator.Pitch
  TargetRotator.Roll = self.DefaultRelativeRotator.Roll
  TargetRotator.Yaw = CharacterRow.RoleModeRotator
  self.ChildActor:K2_SetRelativeRotation(TargetRotator, false, nil, false)
  self.InitRelativeRotation = self.ChildActor.RelativeRotation
end

function BP_LobbyRoleActor_C:UpdateAniInstBySkinId(SkinId, bIsSucc)
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:UpdateAniInstBySkinId(SkinId, bIsSucc)
  end
end

function BP_LobbyRoleActor_C:ShowLightBySettlementResult(SettleStatus)
  if self.ChildActor.ChildActor then
    print("BP_LobbyRoleActor_C:ShowLightBySettlementResult", SettleStatus)
    self.ChildActor.ChildActor:ShowLightBySettlementResult(SettleStatus)
  end
end

function BP_LobbyRoleActor_C:ShowDrawCardShowMatEffect()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ShowDrawCardShowMatEffect_LUA()
  end
end

function BP_LobbyRoleActor_C:HideDrawCardShowMatEffect()
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:HideDrawCardShowMatEffect()
  end
end

return BP_LobbyRoleActor_C
