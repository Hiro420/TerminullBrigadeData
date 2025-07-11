local SkinData = require("Modules.Appearance.Skin.SkinData")
local BP_LobbyDisplayRoleActor_C = UnLua.Class()
function BP_LobbyDisplayRoleActor_C:ReceiveTick(DeltaSeconds)
  self.Overridden.ReceiveTick(self, DeltaSeconds)
end
function BP_LobbyDisplayRoleActor_C:ReceiveBeginPlay()
  self.ChildActor:SetChildActorClass(nil)
  self.ShowRelaxAnimation = false
  self.ShowDissoveEffector = false
  self.OnAnimNotify_RelaxShow_Finish:Add(self, BP_LobbyDisplayRoleActor_C.OnRelaxShow_Finish)
  self.OnCharacterDissolveEffectFinish:Add(self, BP_LobbyDisplayRoleActor_C.OnCharacterDissolveEffectFinishCB)
  print("BP_LobbyDisplayRoleActor_C", self.Index)
  if 1 == self.Index then
    print("BP_LobbyDisplayRoleActor_C:StartBindUpdateMyHeroInfo")
    EventSystem.AddListener(self, EventDef.Lobby.EnterLobbyPanel, BP_LobbyDisplayRoleActor_C.RestoreLobbyCharacterMesh)
    EventSystem.AddListener(self, EventDef.Lobby.EquippedWeaponInfoChanged, BP_LobbyDisplayRoleActor_C.BindOnEquippedWeaponInfoChanged)
    EventSystem.AddListenerNew(EventDef.Lobby.WeaponListChanged, self, self.OnWeaponInfoChanged)
    EventSystem.AddListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.BindOnUpdateMyHeroInfo)
    local GameInst = UE.UGameplayStatics.GetGameInstance(self)
    GameInst.BP_Delegate_OnLobbyEffToWhiteFinish:Add(self, BP_LobbyDisplayRoleActor_C.OnLobbyEffToWhiteFinish)
    if not UE.URGBlueprintLibrary.RGIsInPIEWorld(self) then
      self:SetActorHiddenInGame(true)
    end
  end
  local skinSys = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.URGSkinSystem:StaticClass())
  if skinSys then
    skinSys.OnDynamicSkinChange:Add(self, self.SkinChanged)
  end
end
function BP_LobbyDisplayRoleActor_C:OnRelaxShow_Finish()
  self.ShowRelaxAnimation = true
end
function BP_LobbyDisplayRoleActor_C:OnLobbyEffToWhiteFinish()
  self:SetHiddenInGame(false)
end
function BP_LobbyDisplayRoleActor_C:ShowActor(HeroId, WeaponResourceId, SkinId, WeaponSkinId)
  self:SetActorHiddenInGame(false)
  self:ChangeBodyMesh(HeroId, SkinId)
  self:ChangeEquipWeaponMesh(WeaponResourceId, WeaponSkinId)
  if self.heroId == HeroId or not self.ShowDissoveEffector then
  end
end
function BP_LobbyDisplayRoleActor_C:HideActor()
  self:SetHiddenInGame(true)
end
function BP_LobbyDisplayRoleActor_C:RestoreLobbyCharacterMesh()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  if nil ~= HeroInfo then
    local EquippedWeaponList = DataMgr.GetEquippedWeaponList(HeroInfo.equipHero)
    if not EquippedWeaponList then
      return
    end
    local TargetWeaponInfo = EquippedWeaponList[1]
    if not TargetWeaponInfo then
      return
    end
    self:ChangeBodyMesh(HeroInfo.equipHero)
    self:ChangeEquipWeaponMesh(TargetWeaponInfo.resourceId)
  end
end
function BP_LobbyDisplayRoleActor_C:BindOnEquippedWeaponInfoChanged(HeroId)
  local HeroInfo = DataMgr.GetMyHeroInfo()
  if not HeroInfo then
    return
  end
  if HeroId ~= HeroInfo.equipHero then
    return
  end
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(HeroInfo.equipHero)
  if not EquippedWeaponList then
    return
  end
  local TargetWeaponInfo = EquippedWeaponList[1]
  if not TargetWeaponInfo then
    return
  end
  self:ChangeEquipWeaponMesh(tonumber(TargetWeaponInfo.resourceId))
end
function BP_LobbyDisplayRoleActor_C:OnWeaponInfoChanged()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  if not HeroInfo then
    return
  end
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(HeroInfo.equipHero)
  if not EquippedWeaponList then
    return
  end
  local TargetWeaponInfo = EquippedWeaponList[1]
  if not TargetWeaponInfo then
    return
  end
  self:ChangeEquipWeaponMesh(tonumber(TargetWeaponInfo.resourceId))
end
function BP_LobbyDisplayRoleActor_C:ChangeEquipWeaponMesh(WeaponResourceId, WeaponSkinId, bShowGlitchMatEffect)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local WeaponRowInfo = DTSubsystem:GetWeaponTableRowByID(tonumber(WeaponResourceId), nil)
  if self.ChildActor.ChildActor and self.ChildActor.ChildActor.ChangeWeaponSkin then
    local skinId = WeaponSkinId or SkinData.GetEquipedWeaponSkinIdByWeaponResId(tonumber(WeaponResourceId))
    if not self.CurWeaponSkinId or self.CurWeaponSkinId ~= skinId then
      self.ChildActor.ChildActor:ChangeWeaponSkin(skinId, bShowGlitchMatEffect)
      self.CurWeaponSkinId = skinId
    end
  end
end
function BP_LobbyDisplayRoleActor_C:ForceChangeEquipWeaponMesh(WeaponSkinId, bShowGlitchMatEffect)
  if self.ChildActor.ChildActor and self.ChildActor.ChildActor.ChangeWeaponSkin then
    self.ChildActor.ChildActor:ChangeWeaponSkin(WeaponSkinId, bShowGlitchMatEffect)
    self.CurWeaponSkinId = WeaponSkinId
  end
end
function BP_LobbyDisplayRoleActor_C:BindOnUpdateMyHeroInfo()
  print("BP_LobbyDisplayRoleActor_C:BindOnUpdateMyHeroInfo")
  local HeroInfo = DataMgr.GetMyHeroInfo()
  if nil ~= HeroInfo then
    print("BP_LobbyDisplayRoleActor_C:BindOnUpdateMyHeroInfo1", HeroInfo.equipHero)
    self:ChangeBodyMesh(HeroInfo.equipHero)
    local EquippedWeaponList = DataMgr.GetEquippedWeaponList(HeroInfo.equipHero)
    if not EquippedWeaponList then
      return
    end
    local TargetWeaponInfo = EquippedWeaponList[1]
    if not TargetWeaponInfo then
      return
    end
    self:ChangeEquipWeaponMesh(TargetWeaponInfo.resourceId)
  end
end
function BP_LobbyDisplayRoleActor_C:PlayDissoveEffect(bReverse)
  if self.ChildActor.ChildActor ~= nil then
    self.ChildActor.ChildActor:PlayDissoveEffect(bReverse, 0)
  end
end
function BP_LobbyDisplayRoleActor_C:OnCharacterDissolveEffectFinishCB()
  self.ShowDissoveEffector = true
end
function BP_LobbyDisplayRoleActor_C:ChangeBodyMesh(HeroId, SkinId, IsShowHeroEffect)
  local skinId = SkinId or SkinData.GetEquipedSkinIdByHeroId(HeroId)
  if skinId < 0 then
    print("BP_LobbyDisplayRoleActor_C ChangeBodyMesh skinId is", skinId, HeroId, SkinId)
    return
  end
  local tbSkinRowName = GetTbSkinRowNameBySkinID(skinId)
  local ActorCls
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, tbSkinRowName)
  if result then
    ActorCls = GetAssetByPath(row.ActorPath, true)
  end
  if self.heroId ~= HeroId then
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if not DTSubsystem then
      print("DTSubsystem is null.  BP_LobbyDisplayRoleActor_C")
      return
    end
    local Result, LobbyNameSlotRow = DTSubsystem:GetLobbyNameSlotTableRow(HeroId, nil)
    if Result then
      self.NickNameLocation:K2_SetRelativeLocation(LobbyNameSlotRow.SlotLocation, false, nil, false)
    end
    local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
    if not RowInfo then
      return
    end
    self.ChildActor:SetWorldScale3D(UE.FVector(RowInfo.LobbyDisplayRoleModelScale))
    self.heroId = HeroId
  end
  if not ActorCls then
    error("BP_LobbyDisplayRoleActor_C:ChangeBodyMesh ActorCls is nil. skinId is ", skinId)
  end
  if ActorCls and not UE.UKismetMathLibrary.EqualEqual_ClassClass(self.ChildActor.ChildActorClass, ActorCls) then
    self.ChildActor:SetChildActorClass(ActorCls)
  elseif self.ChildActor.ChildActor then
  end
  self:RoleChangeStandPos(self.StandPos)
  self:RoleAdjustHeight()
  print("BP_LobbyDisplayRoleActor_C:ChangeBodyMesh SkinNew", HeroId, skinId)
  print("BP_LobbyDisplayRoleActor_C:ChangeBodyMesh SkinOld", HeroId, self.CurSkinId)
  if self.CurSkinId ~= skinId then
    self.ChildActor.ChildActor:ChangeRoleSkin(skinId)
    self.CurSkinId = skinId
    if self.CurWeaponSkinId and self.CurWeaponSkinId > 0 then
      self:ForceChangeEquipWeaponMesh(self.CurWeaponSkinId)
    end
  end
  if self.ChildActor.ChildActor then
    self.ChildActor.ChildActor:ShowOrHideLightInActor(self.IsShowLightInActor)
    LogicRole.SetEffectState(self.ChildActor.ChildActor, skinId, HeroId, IsShowHeroEffect)
  end
end
function BP_LobbyDisplayRoleActor_C:ChangeBodyMesh11(HeroId, SkinId)
  if self.heroId ~= HeroId then
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if not DTSubsystem then
      print("DTSubsystem is null.  BP_LobbyDisplayRoleActor_C")
      return
    end
    local Result, LobbyNameSlotRow = DTSubsystem:GetLobbyNameSlotTableRow(HeroId, nil)
    if Result then
      self.NickNameLocation:K2_SetRelativeLocation(LobbyNameSlotRow.SlotLocation, false, nil, false)
    end
    local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
    if not RowInfo then
      return
    end
    self.ChildActor:SetWorldScale3D(UE.FVector(RowInfo.LobbyDisplayRoleModelScale))
    local Class = GetAssetByPath(RowInfo.ActorPath, true)
    if Class and not UE.UKismetMathLibrary.EqualEqual_ClassClass(self.ChildActor.ChildActorClass, Class) then
      self.ChildActor:SetChildActorClass(Class)
    else
      self.ChildActor.ChildActor:ResetAnimation()
    end
    if self.ChildActor.ChildActor then
      self.ChildActor.ChildActor:ShowOrHideLightInActor(self.IsShowLightInActor)
    end
    self.heroId = HeroId
    self:RoleChangeStandPos(self.StandPos)
    self:RoleAdjustHeight()
  end
  local skinId = SkinId or SkinData.GetEquipedSkinIdByHeroId(HeroId)
  print("BP_LobbyDisplayRoleActor_C:ChangeBodyMesh SkinNew", HeroId, skinId)
  print("BP_LobbyDisplayRoleActor_C:ChangeBodyMesh SkinOld", HeroId, self.CurSkinId)
  if self.CurSkinId ~= skinId then
    self.ChildActor.ChildActor:ChangeRoleSkin(skinId)
    self.CurSkinId = skinId
  end
end
function BP_LobbyDisplayRoleActor_C:ResetChildActorAnimation()
  if not self.ChildActor.ChildActor then
    return
  end
  self.ChildActor.ChildActor:SetRoleStatus(UE.ERGLobbyRoleStatus.RelaxIdle)
  self.ChildActor.ChildActor:ResetAnimation()
end
function BP_LobbyDisplayRoleActor_C:SkinChanged(TargetActor, Success, SkinId)
  if TargetActor == self.ChildActor.ChildActor then
  end
end
function BP_LobbyDisplayRoleActor_C:GlitchAniEnd()
  self.ChildActor.ChildActor:UpdateSkin()
end
function BP_LobbyDisplayRoleActor_C:ReceiveEndPlay()
  self.OnAnimNotify_RelaxShow_Finish:Remove(self, BP_LobbyDisplayRoleActor_C.OnRelaxShow_Finish)
  if 1 == self.Index then
    EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, BP_LobbyDisplayRoleActor_C.BindOnUpdateMyHeroInfo)
    EventSystem.RemoveListener(EventDef.Lobby.EnterLobbyPanel, BP_LobbyDisplayRoleActor_C.RestoreLobbyCharacterMesh)
    EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, BP_LobbyDisplayRoleActor_C.BindOnEquippedWeaponInfoChanged)
    EventSystem.RemoveListenerNew(EventDef.Lobby.WeaponListChanged, self, self.OnWeaponInfoChanged)
    EventSystem.RemoveListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.BindOnUpdateMyHeroInfo)
    self.OnCharacterDissolveEffectFinish:Remove(self, BP_LobbyDisplayRoleActor_C.OnCharacterDissolveEffectFinishCB)
    local GameInst = UE.UGameplayStatics.GetGameInstance(self)
    GameInst.BP_Delegate_OnLobbyEffToWhiteFinish:Remove(self, BP_LobbyDisplayRoleActor_C.OnLobbyEffToWhiteFinish)
  end
  local skinSys = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.URGSkinSystem:StaticClass())
  if skinSys then
    skinSys.OnDynamicSkinChange:Remove(self, self.SkinChanged)
  end
end
return BP_LobbyDisplayRoleActor_C
