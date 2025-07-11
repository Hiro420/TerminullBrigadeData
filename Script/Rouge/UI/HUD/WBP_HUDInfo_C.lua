local WBP_HUDInfo_C = UnLua.Class()
local LowHelalthValue = 60
local NaxTypeId = 1030
local CheckIsAlone = function()
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return false
  end
  return 1 == TeamSubsystem.TeamInfo.AllPlayerInfos:Num()
end
function WBP_HUDInfo_C:Construct()
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    self.InitListInfo
  })
  self:BindHealthAndShieldAttributeModifyText(true)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.InitRevivalInfo
  }, 1)
  ListenObjectMessage(nil, GMP.MSG_Level_OnTeamChange, self, self.BindOnTeamCaptainChanged)
  local Character = self:GetOwningPlayerPawn()
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if not CoreComp then
    return
  end
  self:UpdateArmor()
  self:InitTeamIndexInfo()
  self:UpdateTeamCaptainVis()
  self.LastShield = CoreComp:GetShield()
  CoreComp:BindAttributeChanged(self.HealthAttribute, {
    self,
    self.BindOnHealthAttributeChanged
  })
  CoreComp:BindAttributeChanged(self.MaxHealthAttribute, {
    self,
    self.BindOnMaxHealthAttributeChanged
  })
  CoreComp:BindAttributeChanged(self.ShieldAttribute, {
    self,
    self.BindOnShieldAttributeChanged
  })
  CoreComp:BindAttributeChanged(self.ShieldList.SpecialAttribute, {
    self,
    self.BindOnExtraShieldAttributeChanged
  })
  CoreComp.ClientShieldChanged:Add(self, self.BindOnShieleAttributeChanged)
  CoreComp.ClientMaxShieldChanged:Add(self, self.BindOnShieleAttributeChanged)
  if CoreComp.ClientArmorChanged then
    CoreComp.ClientArmorChanged:Add(self, self.BindOnArmorAttributeChanged)
  end
  if CoreComp.ClientMaxArmorChanged then
    CoreComp.ClientMaxArmorChanged:Add(self, self.BindOnArmorAttributeChanged)
  end
  if self.IsLowHealth then
    self.IsLowHealth = false
    EventSystem.Invoke(EventDef.HUD.PlayScreenEdgeEffect, "HPLow", UE.EUMGSequencePlayMode.Reverse)
    if -1 ~= self.LowHealthMaterialIndex then
      local PostProcessManager = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.UPostProcessManager:StaticClass())
      if PostProcessManager then
        PostProcessManager:UpdatePostMaterialWeightByMID(self.LowHealthMaterialIndex, 0)
      end
    end
  end
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      GVoice.RoomMemberVoiceStatusDelegate:Add(self, self.UpdateSpeakingTag)
    end
  end
  local TypeId = Character:GetTypeID()
  if TypeId == NaxTypeId then
    UpdateVisibility(self.NaxHealthSlot, true)
    self.WBP_NaxHealthBar:Show()
  else
    UpdateVisibility(self.NaxHealthSlot, false)
  end
  ListenObjectMessage(nil, GMP.MSG_Damage_OnHealthLock_HealBegin, self, self.BindOnHealthLockHealBegin)
  ListenObjectMessage(nil, GMP.MSG_Damage_OnHealthLock_HealEnd, self, self.BindOnHealthLockHealEnd)
  ListenObjectMessage(nil, GMP.MSG_Game_PlayerRevivalSuccess, self, self.Bind_MSG_Game_PlayerRevivalSuccess)
end
function WBP_HUDInfo_C:InitListInfo()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  self:InitRevivalInfo()
  local ShieldSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.ShieldList)
  local ShieldSize = ShieldSlot:GetSize()
  self.ShieldList:InitInfo(Character)
  self.ShieldList:UpdateBarGrid(ShieldSize.X, ShieldSize.Y)
  local HealthSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.HealthList)
  local HealthSize = HealthSlot:GetSize()
  function self.HealthList.CanPlayReduceAnim(OldPercent, NewPercent)
    return OldPercent - NewPercent >= self.BigDamageHealthPercent
  end
  self.HealthList:InitInfo(Character)
  self.HealthList:UpdateBarGrid(HealthSize.X, HealthSize.Y)
  self:UpdateHealthText()
  self:UpdateShieldText()
  local HeroId = DataMgr.GetMyHeroInfo().equipHero
  local Result, RowData = GetRowData(DT.DT_Hero, tostring(HeroId))
  if Result then
    SetImageBrushBySoftObject(self.Icon_Head, RowData.HUDRoleIcon)
  end
end
function WBP_HUDInfo_C:InitTeamIndexInfo()
  print("InitTeamIndexInfo")
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  if not Character.PlayerState then
    print("Init Team Index Info not found PlayerState")
    return
  end
  if CheckIsAlone() then
    UpdateVisibility(self.Img_TeamIndex, false)
    UpdateVisibility(self.Txt_TeamIndex, false)
  else
    UpdateVisibility(self.Img_TeamIndex, true)
    UpdateVisibility(self.Txt_TeamIndex, true)
    local selfTeamIndex = self:GetSelfTeamIndex()
    self.Txt_TeamIndex:SetText(self:GetSelfTeamIndex())
    if LogicHUD.TeamIndexColor[Character.PlayerState:GetTeamIndex()] then
      self.Img_TeamIndex:SetColorAndOpacity(LogicHUD.TeamIndexColor[Character.PlayerState:GetTeamIndex()])
    else
      self.Img_TeamIndex:SetColorAndOpacity(LogicHUD.TeamIndexColor[1])
    end
  end
end
function WBP_HUDInfo_C:InitRevivalInfo()
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    print("WBP_DyingRevival: GameState is Null")
    return
  end
  local PlayerRevivalManager = GS:GetComponentByClass(UE.URGPlayerRevivalManager:StaticClass())
  local TeamRevivalInfo = PlayerRevivalManager.TeamRevivalInfo
  if TeamRevivalInfo.PlayerRevivalInfos:Num() > 1 and UE.URGLevelLibrary.IsTeamRevivalMode(self) then
    UpdateVisibility(self.Overlay_Revival, false)
  else
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    UpdateVisibility(self.Overlay_Revival, true)
    local SelfRevivalInfo = PlayerRevivalManager:GetPlayerInfo(Character:GetUserId())
    self.Txt_RevivalCount:SetText(SelfRevivalInfo.RevivalCount)
    local StatusStr = 0 == SelfRevivalInfo.RevivalCount and "Zero" or "NoZero"
    self.RGStateController_EqualToZero:ChangeStatus(StatusStr)
  end
end
function WBP_HUDInfo_C:GetSelfTeamIndex()
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return 1
  end
  for i, v in pairs(TeamSubsystem.TeamInfo.AllPlayerInfos) do
    if v.roleid == Character:GetUserId() then
      return i
    end
  end
  return 1
end
function WBP_HUDInfo_C:UpdateTeamCaptainVis()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local TeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  if not TeamSubsystem then
    return
  end
  if CheckIsAlone() then
    UpdateVisibility(self.Image_Leader, false)
  elseif tonumber(DataMgr.UserId) == TeamSubsystem:GetCaptain() then
    self.Image_Leader:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Image_Leader:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_HUDInfo_C:BindOnHealthAttributeChanged(NewValue, OldValue)
  self:UpdateHealthText()
  self:PlayLowHealthEffect(NewValue, OldValue)
  EventSystem.Invoke(EventDef.Battle.OnHealthChanged, NewValue, LogicHUD.OldValue)
  LogicHUD.OldValue = NewValue
  if NewValue < OldValue then
    self:PlayAnimation(self.ShieldFlareRed, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
  elseif OldValue < NewValue then
    self:PlayAnimation(self.ShieldFlareGreen, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
  end
end
function WBP_HUDInfo_C:BindOnMaxHealthAttributeChanged(NewValue, OldValue)
  self:UpdateHealthText()
  self:PlayLowHealthEffect(NewValue, OldValue)
end
function WBP_HUDInfo_C:BindOnShieldAttributeChanged(NewValue, OldValue)
  if NewValue <= 0 then
    self:PlayAnimation(self.ShieldExplo, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
  end
end
function WBP_HUDInfo_C:BindOnExtraShieldAttributeChanged(NewValue, OldValue)
  if NewValue <= 0 then
    self:PlayAnimation(self.ShieldExplo_2, 0.0, 1, UE.EUMGSequencePlayMode.Forward)
  end
end
function WBP_HUDInfo_C:BindOnShieleAttributeChanged(NewValue, OldValue)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  if 0 ~= self.LastShield and CoreComp:GetShield() <= 0 then
    self.LastShield = 0
    PlaySound2DEffect(10002, "WBP_HUDInfo_C:BindOnAttributeChange")
    EventSystem.Invoke(EventDef.HUD.PlayScreenEdgeEffect, "ShieldBreak", UE.EUMGSequencePlayMode.Forward)
  end
  self.LastShield = CoreComp:GetShield()
  self:UpdateShieldText()
end
function WBP_HUDInfo_C:BindOnArmorAttributeChanged(NewValue, OldValue)
  self:UpdateArmor()
end
function WBP_HUDInfo_C:PlayLowHealthEffect(NewValue, OldValue)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local CoreComp = Character.CoreComponent
  if not CoreComp then
    return
  end
  local PostProcessManager = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.UPostProcessManager:StaticClass())
  if not PostProcessManager then
    return
  end
  if self:CheckIsLowHelath(CoreComp) then
    if not self.IsLowHealth then
      if NewValue < OldValue and (LogicHUD.OldValue == OldValue and 0 ~= LogicHUD.OldValue or -1 == LogicHUD.OldValue) then
        PlaySound2DEffect(10001, "WBP_HUDInfo_C:BindOnAttributeChange")
      end
      self.IsLowHealth = true
      EventSystem.Invoke(EventDef.HUD.PlayScreenEdgeEffect, "HPLow", UE.EUMGSequencePlayMode.Forward)
      if -1 == self.LowHealthMaterialIndex and self.LowHealthMaterialSoftObjectPath then
        self.LowHealthMaterialIndex = PostProcessManager:AddPostProcessMID(self.LowHealthMaterialSoftObjectPath)
      end
      if -1 ~= self.LowHealthMaterialIndex then
        PostProcessManager:UpdatePostMaterialWeightByMID(self.LowHealthMaterialIndex, 1)
      end
    end
  elseif self.IsLowHealth then
    PlaySound2DEffect(10007, "WBP_HUDInfo_C:BindOnAttributeChange")
    self.IsLowHealth = false
    EventSystem.Invoke(EventDef.HUD.PlayScreenEdgeEffect, "HPLow", UE.EUMGSequencePlayMode.Reverse)
    if -1 ~= self.LowHealthMaterialIndex then
      PostProcessManager:UpdatePostMaterialWeightByMID(self.LowHealthMaterialIndex, 0)
    end
  end
end
function WBP_HUDInfo_C:InitRevival()
end
function WBP_HUDInfo_C:CheckIsLowHelath(CoreComp)
  if CoreComp:GetMaxHealth() < LowHelalthValue then
    return false
  end
  if CoreComp:GetHealth() >= LowHelalthValue then
    return false
  end
  local Percent = CoreComp:GetHealth() / CoreComp:GetMaxHealth()
  if Percent >= self.LowHealthPercent then
    return false
  end
  return true
end
function WBP_HUDInfo_C:BindOnTeamCaptainChanged()
  self:UpdateTeamCaptainVis()
end
function WBP_HUDInfo_C:GetAttributeValue(Attribute)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return 0
  end
  local AttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, Attribute, nil)
  return AttributeValue
end
function WBP_HUDInfo_C:UpdateSpeakingTag(RoomName, OpenId, MemberId, Status)
  if not LogicTeam.CheckIsOwnerVoiceRoom(RoomName) then
    return
  end
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
    if bIsMute then
      self:UpdateSpeakingStatus(false)
    elseif Status == UE.EVoiceRoomMemberStatus.SayingFromSilence or Status == UE.EVoiceRoomMemberStatus.ContinueSaying then
      local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(DataMgr.GetUserId())
      if SelfMemberId == MemberId then
        self:UpdateSpeakingStatus(true)
      end
    elseif Status == UE.EVoiceRoomMemberStatus.SilenceFromSaying then
      local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(DataMgr.GetUserId())
      if SelfMemberId == MemberId then
        self:UpdateSpeakingStatus(false)
      end
    end
  end
end
function WBP_HUDInfo_C:UpdateSpeakingStatus(bIsShow)
  if CheckIsAlone() then
    UpdateVisibility(self.Image_Voice, false)
  else
    UpdateVisibility(self.Image_Voice, bIsShow)
    if bIsShow then
      math.randomseed(os.time())
      local Amplitude = math.random() * 0.5
      local Mat = self.Image_Voice:GetDynamicMaterial()
      if Mat then
        Mat:SetScalarParameterValue("amplitude", Amplitude)
      end
    end
  end
end
function WBP_HUDInfo_C:UpdateArmor()
  local ArmorValue = self:GetAttributeValue(self.ArmorAttribute)
  local MaxArmorValue = self:GetAttributeValue(self.MaxArmorAttribute)
  if ArmorValue <= 0 then
    self:HideArmor()
  else
    self.Img_ArmorBar:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    if not self.IsPlayingArmorAnim then
      EventSystem.Invoke(EventDef.HUD.PlayScreenEdgeShieldEffect, self.ArmorShowAnim)
      self.IsPlayingArmorAnim = true
    end
    EventSystem.Invoke(EventDef.HUD.UpdateScreenEdgeShieldMat, ArmorValue / MaxArmorValue)
    self:UpdateHealthText()
    self.Img_ArmorBar:SetClippingValue(ArmorValue / MaxArmorValue)
  end
end
function WBP_HUDInfo_C:HideArmor()
  self.Img_ArmorBar:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.IsPlayingArmorAnim then
    self.IsPlayingArmorAnim = false
    EventSystem.Invoke(EventDef.HUD.PlayScreenEdgeShieldEffect, self.ArmorHideAnim)
  end
end
function WBP_HUDInfo_C:PlayHeartModifyAnim()
  self.ShieldFX:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.HealthFX:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationForward(self.ShieldFXAnim)
  self:PlayAnimationForward(self.HealthFXAnim)
end
function WBP_HUDInfo_C:BindOnHealthLockHealBegin(...)
  print("WBP_HUDInfo_C:BindOnHealthLockHealBegin")
  self:PlayAnimation(self.Ani_DeathProtection_in)
  self.WBP_HeartModifyScreenEffect_second:PlayAnimation(self.WBP_HeartModifyScreenEffect_second.Ani_DeathProtection_in)
end
function WBP_HUDInfo_C:BindOnHealthLockHealEnd(...)
  print("WBP_HUDInfo_C:BindOnHealthLockHealEnd")
  self:PlayAnimation(self.Ani_DeathProtection_out)
  self.WBP_HeartModifyScreenEffect_second:PlayAnimation(self.WBP_HeartModifyScreenEffect_second.Ani_DeathProtection_out)
end
function WBP_HUDInfo_C:Bind_MSG_Game_PlayerRevivalSuccess(UserId, RevivalCount, RevivalCoinNum)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  if UserId == Character:GetUserId() then
    self.Txt_RevivalCount:SetText(RevivalCount)
    local StatusStr = 0 == RevivalCount and "Zero" or "NoZero"
    self.RGStateController_EqualToZero:ChangeStatus(StatusStr)
  end
end
function WBP_HUDInfo_C:Destruct()
  self:BindHealthAndShieldAttributeModifyText(false)
  local Character = self:GetOwningPlayerPawn()
  if Character then
    local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
    if CoreComp then
      CoreComp:UnBindAttributeChanged(self.HealthAttribute, {
        self,
        self.BindOnHealthAttributeChanged
      })
      CoreComp:UnBindAttributeChanged(self.MaxHealthAttribute, {
        self,
        self.BindOnMaxHealthAttributeChanged
      })
      CoreComp:UnBindAttributeChanged(self.ShieldAttribute, {
        self,
        self.BindOnShieldAttributeChanged
      })
      CoreComp:UnBindAttributeChanged(self.ShieldList.SpecialAttribute, {
        self,
        self.BindOnExtraShieldAttributeChanged
      })
      CoreComp.ClientShieldChanged:Remove(self, self.BindOnShieleAttributeChanged)
      CoreComp.ClientMaxShieldChanged:Remove(self, self.BindOnShieleAttributeChanged)
      if CoreComp.ClientArmorChanged then
        CoreComp.ClientArmorChanged:Remove(self, self.BindOnArmorAttributeChanged)
      end
      if CoreComp.ClientMaxArmorChanged then
        CoreComp.ClientMaxArmorChanged:Remove(self, self.BindOnArmorAttributeChanged)
      end
    end
  end
  UnListenObjectMessage(GMP.MSG_Level_OnTeamChange, self)
  UnListenObjectMessage(GMP.MSG_Damage_OnHealthLock_HealBegin, self)
  UnListenObjectMessage(GMP.MSG_Damage_OnHealthLock_HealEnd, self)
  UnListenObjectMessage(GMP.MSG_Game_PlayerRevivalSuccess, self)
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      GVoice.RoomMemberVoiceStatusDelegate:Remove(self, self.UpdateSpeakingTag)
    end
  end
  if -1 ~= self.LowHealthMaterialIndex then
    local PostProcessManager = UE.USubsystemBlueprintLibrary.GetWorldSubsystem(self, UE.UPostProcessManager:StaticClass())
    if PostProcessManager then
      PostProcessManager:DeletePostProcessMID(self.LowHealthMaterialIndex)
    end
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.ShieldBreakAndBigDamageTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.ShieldBreakAndBigDamageTimer)
  end
  self.WBP_HeartModifyScreenEffect_second:StopAllAnimations()
end
return WBP_HUDInfo_C
