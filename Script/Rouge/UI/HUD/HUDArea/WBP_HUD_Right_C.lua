local WBP_HUD_Right_C = UnLua.Class()
local PunishTime = NSLOCTEXT("WBP_HUD_Right_C", "PunishTime", "+{0}\229\136\134\233\146\159")
local PerfectTime = NSLOCTEXT("WBP_HUD_Right_C", "PerfectTime", "\229\174\140\231\190\142\233\128\154\229\133\179\239\188\154{0}:{1}.00")
function WBP_HUD_Right_C:Construct()
  self.Overridden.Construct(self)
  EventSystem.AddListener(self, EventDef.HUD.UpdateSkillPanelPosXByWeaponVSkill, self.BindOnUpdateSkillPanelPosXByWeaponVSkill)
  EventSystem.AddListener(self, EventDef.Battle.OnControlledPawnChanged, self.BindOnControlledPawnChanged)
  ListenObjectMessage(nil, GMP.MSG_Hero_Dying, self, self.OnHeroDying)
  ListenObjectMessage(nil, GMP.MSG_Hero_NotifyRescue, self, self.OnHeroRescue)
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem.StaticClass())
  if GameLevelSystem then
    GameLevelSystem.OnNotifyWorldInfo:Add(self, self.BindOnNotifyWorldInfo)
  end
  self:BindOnNotifyWorldInfo()
  self:BindOnPunshTimeDel()
  local PerfectTimeSecondText = string.format("%02d", UE.URGLevelLibrary:GetPerfectTime() % 60)
  local PerfectTimeMinText = math.ceil(UE.URGLevelLibrary:GetPerfectTime() / 60)
  local PerfectTimeText = UE.FTextFormat(PerfectTime(), PerfectTimeMinText, PerfectTimeSecondText)
  self.TXT_PerfectTime:SetText(PerfectTimeText)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CheckPerfectTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CheckPerfectTimer)
  end
  self.CheckPerfectTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.CheckIsPerfectTime
  }, 1, true)
  local GS = UE.UGameplayStatics.GetGameState(self)
  if not GS then
    return nil
  end
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  if LevelSubSystem then
    UpdateVisibility(self.TXT_PerfectTime, LevelSubSystem:GetMatchGameMode() == TableEnums.ENUMGameMode.NORMAL or LevelSubSystem:GetMatchGameMode() == TableEnums.ENUMGameMode.SEASONNORMAL)
  end
  local GameLevelComponent = GS:GetComponentByClass(UE.URGGameLevelComponent:StaticClass())
  if GameLevelComponent and GameLevelComponent.BattleTimeData.PenaltyTime > 0 then
    local PunishTimeText = string.format("%.1f", GameLevelComponent.BattleTimeData.PenaltyTime / 60000)
    self.TXT_PunishTime:SetText(UE.FTextFormat(PunishTime(), PunishTimeText))
    self:PlayAnimation(self.Ani_PunishTime_in, self.Ani_PunishTime_in:GetEndTime())
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  self:BindCharacterDelegate(Character)
end
function WBP_HUD_Right_C:BindOnUpdateSkillPanelPosXByWeaponVSkill(IsHasWeaponVSkill)
  local SkillPanelSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.SkillListPanel)
  if not SkillPanelSlot then
    return
  end
  local Position = SkillPanelSlot:GetPosition()
  if IsHasWeaponVSkill then
    Position.X = self.HasWeaponVSkillPanelPosX
  else
    Position.X = self.NotHasWeaponVSkillPanelPosX
  end
  SkillPanelSlot:SetPosition(Position)
end
function WBP_HUD_Right_C:BindOnNotifyWorldInfo()
  self:SetLevelName()
end
function WBP_HUD_Right_C:BindOnPunshTimeDel()
  local GS = UE.UGameplayStatics.GetGameState(self)
  local GameLevelComponent = GS:GetComponentByClass(UE.URGGameLevelComponent:StaticClass())
  if GameLevelComponent then
    GameLevelComponent.BattleTimeChangeDelegate:Add(self, self.OnPunishTimeChange)
  end
end
function WBP_HUD_Right_C:SetLevelName()
  local name = UE.URGGameplayLibrary.RGGetLevelNameTxt(self)
  UpdateVisibility(self.TextBlock_LevelName, true)
  self.TextBlock_LevelName:SetText(name)
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem.StaticClass())
  if GameLevelSystem then
    local worldIdx = GameLevelSystem.WorldInfo.CurrentWorldIndex + 1
    local levelIdx = GameLevelSystem.WorldInfo.CurrentLevelIndex
    local worldMode = LogicTeam.GetWorldId()
    local worldModeName = ""
    local result, row = GetRowData(DT.DT_GameMode, tostring(worldMode))
    if result then
      worldModeName = row.Name
    end
    local bShowLevelInfo = true
    local TutorialLevelSubSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTutorialLevelSystem:StaticClass())
    if TutorialLevelSubSystem and TutorialLevelSubSystem:IsFreshPlayer() then
      bShowLevelInfo = false
    end
    UpdateVisibility(self.HorizontalBoxInfo, bShowLevelInfo)
    local bIsClimbTowner = false
    local bIsSurvivor = false
    local resultWorldMode, rowWorldMode = GetRowData(DT.DT_GameMode, tostring(worldMode))
    if resultWorldMode then
      bIsClimbTowner = rowWorldMode.ModeType == UE.EGameModeType.TowerClimb
      bIsSurvivor = rowWorldMode.ModeType == UE.EGameModeType.Survivor
    end
    if bIsClimbTowner then
      UpdateVisibility(self.HorizontalBoxNormal, false)
      UpdateVisibility(self.HorizontalBoxClimbTowner, true)
      UpdateVisibility(self.HorizontalBoxBossRush, false)
      UpdateVisibility(self.HorizontalBoxSurvival, false)
      self.RichTxt_Diff:SetText(UE.FTextFormat(self.ClimbDiffFmt, LogicTeam.GetFloor()))
      self.RichTxt_Idx:SetText(UE.FTextFormat(self.ClimbLevelIdxFmt, levelIdx + 1))
    elseif resultWorldMode and rowWorldMode.ModeType == UE.EGameModeType.BossRush then
      UpdateVisibility(self.HorizontalBoxNormal, false)
      UpdateVisibility(self.HorizontalBoxClimbTowner, false)
      UpdateVisibility(self.HorizontalBoxBossRush, true)
      UpdateVisibility(self.HorizontalBoxSurvival, false)
      self.TextBlock_Theme_BossRush:SetText(worldModeName)
    elseif bIsSurvivor then
      UpdateVisibility(self.HorizontalBoxNormal, false)
      UpdateVisibility(self.HorizontalBoxClimbTowner, false)
      UpdateVisibility(self.HorizontalBoxBossRush, false)
      UpdateVisibility(self.HorizontalBoxSurvival, true)
      UpdateVisibility(self.TextBlock_LevelName, false)
      UpdateVisibility(self.TextBlock_Theme, not GameLevelSystem:IsReadyLevel())
      UpdateVisibility(self.Text_LevelDetail, false)
      self.TextBlock_Theme_Survival:SetText(worldModeName)
    else
      UpdateVisibility(self.HorizontalBoxNormal, true)
      UpdateVisibility(self.HorizontalBoxClimbTowner, false)
      UpdateVisibility(self.HorizontalBoxBossRush, false)
      UpdateVisibility(self.HorizontalBoxSurvival, false)
      UpdateVisibility(self.TextBlock_Theme, not GameLevelSystem:IsReadyLevel())
      UpdateVisibility(self.Text_LevelDetail, not GameLevelSystem:IsReadyLevel())
      if GameLevelSystem:IsLastLevelOfAll() then
        self.TextBlock_Theme:SetText(UE.FTextFormat(self.FinalLevelFmt, worldModeName))
        UpdateVisibility(self.Text_LevelDetail, false)
      else
        self.TextBlock_Theme:SetText(worldModeName)
        self.Text_LevelDetail:SetText(UE.FTextFormat("{0}-{1}", worldIdx, levelIdx))
      end
      self.TextBlock_Diff:SetText(LogicTeam.GetFloor())
    end
  end
end
function WBP_HUD_Right_C:OnPunishTimeChange(OldTime, NewTime)
  if 0 == math.ceil(OldTime) then
    self:PlayAnimation(self.Ani_PunishTime_in)
  else
    self:PlayAnimation(self.Ani_PunishTime_Add)
  end
  local PunishTimeText = string.format("%.1f", NewTime / 60)
  self.TXT_PunishTime:SetText(UE.FTextFormat(PunishTime(), PunishTimeText))
end
function WBP_HUD_Right_C:OnHeroDying(Target)
  if Target ~= UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    return
  end
  UpdateVisibility(self.SkillLinePanel, false)
  UpdateVisibility(self.SkillListPanel, false)
end
function WBP_HUD_Right_C:OnHeroRescue(Target)
  if Target ~= UE.UGameplayStatics.GetPlayerCharacter(self, 0) then
    return
  end
  UpdateVisibility(self.SkillLinePanel, true)
  UpdateVisibility(self.SkillListPanel, true)
end
function WBP_HUD_Right_C:CheckIsPerfectTime()
  if not UE.URGLevelLibrary:IsInPerfectTime() then
    self.TXT_PerfectTime:SetColorAndOpacity(self.EnableColor)
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CheckPerfectTimer)
  end
end
function WBP_HUD_Right_C:Destruct()
  EventSystem.RemoveListener(EventDef.HUD.UpdateSkillPanelPosXByWeaponVSkill, self.BindOnUpdateSkillPanelPosXByWeaponVSkill, self)
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, self.BindOnControlledPawnChanged, self)
  UnListenObjectMessage(GMP.MSG_Hero_Dying, self)
  UnListenObjectMessage(GMP.MSG_Hero_Rescue, self)
  if self.ControlledPawn and self.ControlledPawn:IsValid() then
    local EquipmentComp = self.ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if EquipmentComp then
      EquipmentComp.OnEquipmentChanged:Remove(self, self.BindOnEquipmentChanged)
    end
    local EquipmentComp = self.ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
    if EquipmentComp then
      EquipmentComp.OnCurrentWeaponChanged:Remove(self, self.BindOnCurrentWeaponChanaged)
    end
  end
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGGameLevelSystem.StaticClass())
  if GameLevelSystem then
    GameLevelSystem.OnNotifyWorldInfo:Remove(self, self.BindOnNotifyWorldInfo)
  end
  local GS = UE.UGameplayStatics.GetGameState(self)
  local GameLevelComponent = GS:GetComponentByClass(UE.URGGameLevelComponent:StaticClass())
  if GameLevelComponent then
    GameLevelComponent.BattleTimeChangeDelegate:Remove(self, self.OnPunishTimeChange)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.CheckPerfectTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.CheckPerfectTimer)
  end
end
function WBP_HUD_Right_C:InitGloriaRobotInfo()
  self.WBP_GloriaRobotInfo:Init()
end
function WBP_HUD_Right_C:BindOnControlledPawnChanged(ControlledPawn)
  self:BindCharacterDelegate(ControlledPawn)
end
function WBP_HUD_Right_C:BindCharacterDelegate(ControlledPawn)
  self.ControlledPawn = ControlledPawn
  if not ControlledPawn then
    return
  end
  local EquipmentComp = ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if EquipmentComp then
    EquipmentComp.OnEquipmentChanged:Add(self, self.BindOnEquipmentChanged)
    self:BindOnEquipmentChanged()
  end
  local EquipmentComp = ControlledPawn:GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if EquipmentComp then
    EquipmentComp.OnCurrentWeaponChanged:Add(self, self.BindOnCurrentWeaponChanaged)
  end
end
function WBP_HUD_Right_C:BindOnEquipmentChanged()
  print("WBP_HUD_Right_C:BindOnEquipmentChanged")
  self:BindOnCurrentWeaponChanaged()
end
function WBP_HUD_Right_C:BindOnCurrentWeaponChanaged(OldWeapon, NewWeapon)
  print("WBP_WeaponList_C:BindOnCurrentWeaponChanaged")
  local EquipmentComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGEquipmentComponent.StaticClass())
  if not EquipmentComp then
    return
  end
  local CurWeapon = EquipmentComp:GetCurrentWeapon()
  if not CurWeapon then
    print("WBP_WeaponList_C:BindOnCurrentWeaponChanaged Invalid CurWeapon")
    return
  end
  local Result, RowInfo = GetRowData(DT.DT_Weapon, CurWeapon:GetItemId())
  if not Result then
    return
  end
  local AbilityClass = RowInfo.AbilityConfig.AbilityClasses:Find(self.WeaponSkillCoolDown.SkillType)
  if not UE.UKismetSystemLibrary.IsValidClass(AbilityClass) then
    self.WeaponSkillCoolDown:SetSkillIcon(RowInfo.UnSkillDefaultIcon)
  end
  self.WeaponSkillCoolDown:RefreshInfo(AbilityClass)
  local VAbilityClass = RowInfo.AbilityConfig.AbilityClasses:Find(self.WeaponVSkillCoolDown.SkillType)
  if not UE.UKismetSystemLibrary.IsValidClass(VAbilityClass) then
    self.VSkillPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.VSkillPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WeaponVSkillCoolDown:RefreshInfo(VAbilityClass)
  end
  EventSystem.Invoke(EventDef.HUD.UpdateSkillPanelPosXByWeaponVSkill, UE.UKismetSystemLibrary.IsValidClass(VAbilityClass))
end
return WBP_HUD_Right_C
