local SkinData = require("Modules.Appearance.Skin.SkinData")
LogicAudio = LogicAudio or {}

function LogicAudio.OnSkillLack(SkillID)
  PlaySound2DEffect(10028, SkillID)
end

function LogicAudio.OnSkillActivation(SkillID)
  PlaySound2DEffect(10029, SkillID)
end

function LogicAudio.OnSkillHit(DamageParams, TargetActor, SourceActor)
  local SkillID = UE.URGDamageStatics.GetSkillID(DamageParams)
  local DamageType = UE.URGDamageStatics.GetDamageType(DamageParams)
  local IsWeak = UE.URGDamageStatics.IsWeakHit(DamageParams)
  if IsWeak then
    UE.UAudioManager.SetEmitterRTPC("HitEnemy_Type", 1, TargetActor)
  else
    UE.UAudioManager.SetEmitterRTPC("HitEnemy_Type", 0, TargetActor)
  end
  if DamageType == UE.ERGDamageType.WeaponDamage and 0 == SkillID then
    PlayHeroNormalHitSound3D(SourceActor, TargetActor, UE.URGDamageStatics.IsKill(DamageParams))
  else
    PlayHeroSkillHitSound3D(SkillID, DamageType, SourceActor, TargetActor, UE.URGDamageStatics.IsKill(DamageParams))
  end
end

function LogicAudio.OnSkillNorHit(TargetActor, SourceActor)
end

function LogicAudio.OnPortalDisappear()
  PlaySound2DEffect(10036, "OnPortalDisappear")
end

function LogicAudio.OnPortalAppear()
  PlaySound2DEffect(10037, "OnPortalAppear")
end

function LogicAudio.OnPortalTransfer()
  PlaySound2DEffect(10038, "OnPortalTransfer")
end

function LogicAudio.OnFunJumpGather()
  PlaySound2DEffect(10104, "OnFunJumpGather")
end

function LogicAudio.OnFunJumpStart()
  PlaySound2DEffect(10105, "OnFunJumpStart")
end

function LogicAudio.OnFunJumpHammerDown()
  PlaySound2DEffect(10038, "OnFunJumpHammerDown")
end

function LogicAudio.OnFunJumpHammerBroken()
  PlaySound2DEffect(10038, "OnFunJumpHammerBroken")
end

function LogicAudio.OnFunJumpWaveStart()
  PlaySound2DEffect(10038, "OnFunJumpWaveStart")
end

function LogicAudio.OnFunJumpSuccess()
  PlaySound2DEffect(10106, "OnFunJumpSuccess")
end

function LogicAudio.OnFunJumpFail()
  PlaySound2DEffect(10107, "OnFunJumpFail")
end

function LogicAudio.OnTreasureBoxOpenCharge()
  PlaySound2DEffect(10030, "OnTreasureBoxOpenCharge")
end

function LogicAudio.OnTreasureBoxStopCharge()
  StopSound2DEffect(10030)
end

function LogicAudio.OnTreasureBoxOpen()
  PlaySound2DEffect(10031, "OnTreasureBoxOpenCharge")
end

function LogicAudio.OnPickupCentaur()
  PlaySound2DEffect(10035, "OnPickupCentaur")
end

function LogicAudio.OnGunShotDry()
  PlaySound2DEffect(10032, "OnGunShotDry")
end

function LogicAudio.OnPickupReel()
  PlaySound2DEffect(10033, "OnPickupReel")
end

function LogicAudio.OnDropReel()
  PlaySound2DEffect(10034, "OnDropReel")
end

function LogicAudio.OnNegative()
  PlaySound2DEffect(5, "OnNegative")
end

function LogicAudio.OnThreeToOneOpen()
  PlaySound2DEffect(10201, "OnThreeToOneOpen")
end

function LogicAudio.OnThreeToOneChoose()
  PlaySound2DEffect(10203, "OnThreeToOneChoose")
end

function LogicAudio.OnThreeToOneClose()
  PlaySound2DEffect(10204, "OnThreeToOneClose")
end

function LogicAudio.OnThreeToOnePick()
  PlaySound2DEffect(10202, "OnThreeToOnePick")
end

function LogicAudio.OnTalentPick()
  PlaySound2DEffect(2, "OnTalentPick")
end

function LogicAudio.OnTalentClick()
  PlaySound2DEffect(8, "OnTalentClick")
end

function LogicAudio.OnTalentUnClick()
  PlaySound2DEffect(5, "OnTalentUnClick")
end

function LogicAudio.OnLevelUpAppear()
  PlaySound2DEffect(94004, "OnLevelUp")
end

function LogicAudio.OnLevelUpDisappear()
  PlaySound2DEffect(94006, "OnLevelUp")
end

function LogicAudio.OnLevelUp()
  PlaySound2DEffect(94005, "OnLevelUp")
end

function LogicAudio.OnPageOpen()
  PlaySound2DEffect(6, "OnPageOpen")
end

function LogicAudio.OnPageClose()
  PlaySound2DEffect(7, "OnPageClose")
end

function LogicAudio.OnMovieTipAppear()
  PlaySound2DEffect(9, "OnMovieTipAppear")
end

function LogicAudio.OnMovieTipDisappear()
  PlaySound2DEffect(10, "OnMovieTipDisappear")
end

function LogicAudio.OnOperateTipAppear()
  PlaySound2DEffect(9, "OnOperateTipAppear")
end

function LogicAudio.OnLobbyPlayHeroSound(SkinId, TargetActor, From, Force)
  UE.UAudioManager.StopWwiseEventByName(LogicAudio.LastAkEventName)
  if SkinId <= 0 then
    return
  end
  if not TargetActor then
    return
  end
  local bRecentlyRendered = TargetActor:WasRecentlyRendered(0.01)
  if false == bRecentlyRendered and TargetActor.ChildActor and TargetActor.ChildActor.WasRecentlyRendered then
    bRecentlyRendered = TargetActor.ChildActor:WasRecentlyRendered(0.01)
  end
  if false == bRecentlyRendered and TargetActor.ChildActor.ChildActor and TargetActor.ChildActor.ChildActor.WasRecentlyRendered then
    bRecentlyRendered = TargetActor.ChildActor.ChildActor:WasRecentlyRendered(0.01)
  end
  if bRecentlyRendered or Force then
    if LogicAudio.bIsPlayingMovie then
      return
    end
    if LogicAudio.bSkipEnter then
      return
    end
    local result, row = GetRowData(DT.DT_DisplaySkin, SkinId)
    if result then
      local AkEventName = row.SkinSound.AppearanceSound
      if "War" == From then
        AkEventName = row.SkinSound.WarSound
      end
      UE.UAudioManager.PlaySound2DByName(AkEventName, "OnLobbyChangeHero OnLobbyPlayHeroSound")
      LogicAudio.LastAkEventName = AkEventName
    end
  end
end

function LogicAudio.PickHero(HeroId)
  local SkinId = SkinData.GetEquipedSkinIdByHeroId(HeroId)
  print("LogicAudio.PickHero", HeroId, SkinId)
  UE.UAudioManager.StopWwiseEventByName(LogicAudio.LastAkEventName)
  if SkinId <= 0 then
    return
  end
  if LogicAudio.bIsPlayingMovie then
    return
  end
  local result, row = GetRowData(DT.DT_DisplaySkin, SkinId)
  if result then
    local AkEventName = row.SkinSound.WarSound
    print("LogicAudio.PickHero", AkEventName)
    UE.UAudioManager.PlaySound2DByName(AkEventName, "OnLobbyChangeHero  PickHero")
    LogicAudio.LastAkEventName = AkEventName
  end
end

function LogicAudio.OnActiveSet_Voice(Pawn, Level)
  if not Pawn then
    return
  end
  print("OnActiveSet_Voice", Level)
  local RowName = "Voice.OnActiveSet." .. tostring(Level)
  if 1 == Level then
    RowName = "Voice.OnActiveSet.1"
  end
  PlayVoice(RowName, Pawn)
end

function LogicAudio.OnAddModify(Modify)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if RGGenericModifyComponent and RGGenericModifyComponent:ShouldDiscardNotify() then
    return
  end
  if not Modify then
    return
  end
  local ModifyId = Modify.ModifyId
  if not ModifyId then
    return
  end
  local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if not result then
    return
  end
  if row.Rarity == UE.ERGItemRarity.EIR_Legend then
    PlayVoice("Voice.OnAddModify.Legend", UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0))
  end
end

function LogicAudio.StartAddExp()
  PlaySound2DEffect(19, "\231\187\147\231\174\151 - \231\134\159\231\187\131\229\186\166\231\187\143\233\170\140\229\188\128\229\167\139")
end

function LogicAudio.EndAddExp()
  StopSound2DEffect(19)
end

function LogicAudio.StartPowerUpReward()
  PlaySound2DEffect(18, "\231\187\147\231\174\151 - \232\147\132\229\138\155\229\165\150\229\138\177\229\188\128\229\167\139")
end

function LogicAudio.EndPowerUpReward()
  StopSound2DEffect(18)
end

function LogicAudio.BattleLevelUp()
  PlaySound2DByName("UI_Battle_Survivor_LevelUp", "BattleLevelUp")
end
