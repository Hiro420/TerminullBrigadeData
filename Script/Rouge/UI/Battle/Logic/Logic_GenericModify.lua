local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
LogicGenericModify = LogicGenericModify or {IsInit = false}
GenericModifySlotDesc = {
  [0] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc0", "\232\162\171\229\138\168\230\157\131\233\153\144"),
  [1] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc1", "\229\176\132\229\135\187"),
  [2] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc2", "\230\141\162\229\188\185"),
  [3] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc3", "\233\151\170\233\129\191\230\138\128\232\131\189"),
  [4] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc4", "\230\172\161\232\166\129\230\138\128\232\131\189"),
  [5] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc5", "\228\184\187\232\166\129\230\138\128\232\131\189"),
  [6] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc6", "Q"),
  [7] = NSLOCTEXT("LogicGenericModify", "GenericModifySlotDesc7", "\230\177\130\230\143\180")
}
local ModifyToSkillType = {
  [1] = TableEnums.ENUMSkillType.Q,
  [2] = TableEnums.ENUMSkillType.E,
  [3] = TableEnums.ENUMSkillType.Alt
}
ModifyChooseType = {
  None = 0,
  GenericModify = 1,
  UpgradeModify = 3,
  SpecificModify = 4,
  BattleLagacy = 5,
  BattleLagacyReminder = 6,
  GenericModifySell = 7,
  DoubleGenericModify = 8,
  DoubleGenericModifyUpgrade = 9,
  RarityUpModify = 10,
  SpecificModifyReplace = 11,
  SurvivalAddModify = 12,
  SurvivalUpgradeModify = 13,
  SurvivalSpecificModify = 14
}
ELastPassiveSlotStatus = {
  bIsFromMod = 1,
  bIsFromGenericModify = 2,
  bIsChangeLevel = 3,
  bIsFromSpecific = 4
}
function LogicGenericModify.Init()
  if LogicGenericModify.IsInit then
    print("LogicGenericModify \229\183\178\229\136\157\229\167\139\229\140\150")
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    LogicGenericModify:BindDelegate(Character)
    return
  end
  LogicGenericModify.LastPassiveSlotStatus = ELastPassiveSlotStatus.bIsFromGenericModify
  LogicGenericModify.IsInit = true
  LogicGenericModify.ChoosPanelOpenTimes = {
    [ModifyChooseType.GenericModify] = 1,
    [ModifyChooseType.SpecificModify] = 1,
    [ModifyChooseType.UpgradeModify] = 1,
    [ModifyChooseType.DoubleGenericModify] = 1,
    [ModifyChooseType.SpecificModifyReplace] = 1,
    [ModifyChooseType.RarityUpModify] = 1,
    [ModifyChooseType.SurvivalSpecificModify] = 1,
    [ModifyChooseType.SurvivalUpgradeModify] = 1
  }
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  LogicGenericModify:BindDelegate(Character)
  EventSystem.AddListener(nil, EventDef.Battle.OnControlledPawnChanged, LogicGenericModify.BindOnControlledPawnChanged)
end
function LogicGenericModify.BindOnControlledPawnChanged(Character)
  LogicGenericModify:BindDelegate(Character)
end
function LogicGenericModify:BindDelegate(Character)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if InteractHandle then
    print("LogicGenericModify:BindDelegate")
    InteractHandle.OnBeginInteract:Add(GameInstance, LogicGenericModify.BindOnBeginInteract)
    InteractHandle.OnFinishInteract:Add(GameInstance, LogicGenericModify.BindOnFinishInteract)
    InteractHandle.OnCancelInteract:Add(GameInstance, LogicGenericModify.BindOnCancelInteract)
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if RGGenericModifyComponent then
    RGGenericModifyComponent.OnAddModify:Add(GameInstance, LogicGenericModify.OnAddModify)
    RGGenericModifyComponent.OnUpgradeModify:Add(GameInstance, LogicGenericModify.OnUpgradeModify)
    RGGenericModifyComponent.OnRemoveModify:Add(GameInstance, LogicGenericModify.OnRemoveModify)
    RGGenericModifyComponent.OnGenericModifyPushPreview:Add(GameInstance, LogicGenericModify.OnGenericModifyPushPreview)
  end
  local RGSpecificModifyComponent = Character:GetComponentByClass(UE.URGSpecificModifyComponent:StaticClass())
  if RGSpecificModifyComponent then
    RGSpecificModifyComponent.OnAddModify:Add(GameInstance, LogicGenericModify.OnSpecificAddModify)
    RGSpecificModifyComponent.OnRemoveModify:Add(GameInstance, LogicGenericModify.OnSpecificRemoveModify)
    RGSpecificModifyComponent.OnRefreshCountChange:Add(GameInstance, LogicGenericModify.OnSpecificRefreshCountChange)
  end
  local InscriptionComp = Character:GetComponentByClass(UE.URGInscriptionComponentV2:StaticClass())
  if InscriptionComp then
    InscriptionComp.OnInscriptionCooldown:Add(GameInstance, LogicGenericModify.BindOnClientUpdateInscriptionCD)
  end
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  SurvivalModeComp.PreviewModifyDataDelegate:Remove(GameInstance, self.OnSurvivalPreviewModifyData)
  SurvivalModeComp.PreviewModifyDataDelegate:Add(GameInstance, self.OnSurvivalPreviewModifyData)
  SurvivalModeComp.PreviewUpgradeModifyDataDelegate:Remove(GameInstance, self.OnSurvivalUpgradeModifyData)
  SurvivalModeComp.PreviewUpgradeModifyDataDelegate:Add(GameInstance, self.OnSurvivalUpgradeModifyData)
  SurvivalModeComp.PreviewSpecificModifyDataDelegate:Remove(GameInstance, self.OnSurvivalSpecificModifyData)
  SurvivalModeComp.PreviewSpecificModifyDataDelegate:Add(GameInstance, self.OnSurvivalSpecificModifyData)
  SurvivalModeComp.PreviewModifyCountDelegate:Remove(GameInstance, self.OnSurvivalPreviewModifyCount)
  SurvivalModeComp.PreviewModifyCountDelegate:Add(GameInstance, self.OnSurvivalPreviewModifyCount)
  SurvivalModeComp.SpecificModifyRefreshCountDelegate:Remove(GameInstance, self.OnSpecificModifyRefreshCount)
  SurvivalModeComp.SpecificModifyRefreshCountDelegate:Add(GameInstance, self.OnSpecificModifyRefreshCount)
end
function LogicGenericModify:TryUpgradeMOD(Pawn, ModId, ChooseType, MODLevel, ModType)
  local ModComponent = Pawn:GetComponentByClass(UE.UMODComponent.StaticClass())
  if ModComponent and LogicGenericModify.bCanOperator then
    LogicGenericModify.CurSelectModId = ModId
    ModComponent:TryUpgradeMOD(ModId, ChooseType, MODLevel, ModType)
    LogicGenericModify.bCanOperator = false
  end
end
function LogicGenericModify:BindOnBeginInteract(Target, Instigator)
  print("LogicGenericModify:BindOnBeginInteract", Target)
  LogicGenericModify.IsFinishChooseModify = false
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InteractNPCType = 0
  if Target then
    local InteractComp = Target:GetComponentByClass(UE.URGInteractComponent_GenericModify:StaticClass())
    if not InteractComp then
      InteractComp = Target:GetComponentByClass(UE.URGInteractComponent_UpgradeModify:StaticClass())
      local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
      if InteractComp then
        InteractNPCType = ModifyChooseType.UpgradeModify
        NotifyObjectMessage(nil, GMP.MSG_Level_Guide_BeginInteractNPC, InteractNPCType)
      end
      if InteractComp and RGGenericModifyComponent and not RGGenericModifyComponent:HasCandidateModifies() then
        local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
        if WaveWindowManager then
          local configId = InteractComp.ItemIfAllModifyReachMaxLevel.ConfigId
          local stack = InteractComp.ItemIfAllModifyReachMaxLevel.Stack
          PlaySound2DEffect(10035, "BindOnBeginInteract")
          WaveWindowManager:ShowWaveWindow(1110, {
            stack,
            "<img id=\"Coin\"/>"
          })
        end
        print("LogicGenericModify:BindOnBeginInteract not HasCandidateModifies", Target)
        return
      end
    else
      InteractNPCType = ModifyChooseType.GenericModify
      NotifyObjectMessage(nil, GMP.MSG_Level_Guide_BeginInteractNPC, InteractNPCType)
    end
    if not InteractComp then
      InteractComp = Target:GetComponentByClass(UE.URGInteractComponent_UpgradeRarityModify:StaticClass())
      if InteractComp then
        local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
        if RGGenericModifyComponent and not RGGenericModifyComponent:HasCandidateRarityUpModifies() then
          local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
          if WaveWindowManager then
            local configId = InteractComp.CompensateItem.ConfigId
            local stack = InteractComp.CompensateItem.Stack
            PlaySound2DEffect(10035, "BindOnBeginInteract")
            WaveWindowManager:ShowWaveWindow(1229, {
              stack,
              "<img id=\"Coin\"/>"
            })
          end
          print("LogicGenericModify:BindOnBeginInteract not HasCandidateModifies", Target)
          return
        end
        if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyWaitPanel_C.UIName) then
          print("LogicGenericModify:BindOnBeginInteract Show WaitPanel", Target)
          RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyWaitPanel_C.UIName)
          local WaitPanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyWaitPanel_C.UIName)
          if WaitPanel then
            WaitPanel:InitGenericModifyWaitPanel(InteractComp, Target)
          end
        end
        return
      end
    end
    if not InteractComp then
      InteractComp = Target:GetComponentByClass(UE.URGInteractComponent_SpecificModify:StaticClass())
      if InteractComp then
        if InteractComp.Type == UE.ERGSpecificModifyType.Add then
          InteractNPCType = ModifyChooseType.SpecificModify
        elseif InteractComp.Type == UE.ERGSpecificModifyType.Replace then
          InteractNPCType = ModifyChooseType.SpecificModifyReplace
          local curSpecificModify = LogicGenericModify:GetFirstSpecificModify()
          if not curSpecificModify then
            local RGGlobalSettings = UE.URGGlobalSettings.GetSettings()
            local num = 0
            if RGGlobalSettings then
              num = RGGlobalSettings.SpecificModifyReplace_CompensateItemCount
            end
            ShowWaveWindow(1218, {
              num,
              "<img id=\"Coin\"/>"
            })
            return
          end
        end
        NotifyObjectMessage(nil, GMP.MSG_Level_Guide_BeginInteractNPC, InteractNPCType)
      end
    end
    if InteractComp then
      print("LogicGenericModify:BindOnBeginInteract Check WaitPanel Open", Target)
      local InteractHandle = Instigator:GetComponentByClass(UE.URGInteractHandle:StaticClass())
      if InteractHandle and InteractHandle.InteractType > 0 then
        print("LogicGenericModify:BindOnBeginInteract UpgradeModify Secondary Interact", Instigator)
        PlaySound2DEffect(10035, "BindOnBeginInteract")
        return
      end
      if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyWaitPanel_C.UIName) then
        print("LogicGenericModify:BindOnBeginInteract Show WaitPanel", Target)
        RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyWaitPanel_C.UIName)
        local WaitPanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyWaitPanel_C.UIName)
        if WaitPanel then
          WaitPanel:InitGenericModifyWaitPanel(InteractComp, Target)
        end
      end
      return
    end
    InteractComp = InteractComp or Target:GetComponentByClass(UE.URGInteractComponent_GenericModifySell:StaticClass())
    if InteractComp then
      print("LogicGenericModify:BindOnBeginInteract Check WaitPanel Open", Target)
      if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyWaitPanel_C.UIName) then
        print("LogicGenericModify:BindOnBeginInteract Show WaitPanel", Target)
        RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyWaitPanel_C.UIName)
        local WaitPanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyWaitPanel_C.UIName)
        if WaitPanel then
          WaitPanel:InitGenericModifyWaitPanel(InteractComp, Target)
        end
      end
      return
    end
  end
end
function LogicGenericModify:BindOnCancelInteract(Target, Instigator)
  EventSystem.Invoke(EventDef.GenericModify.OnCancelInteract, Target, Instigator)
end
function LogicGenericModify:BindOnFinishInteract(Target, Instigator)
  EventSystem.Invoke(EventDef.GenericModify.OnFinishInteract, Target, Instigator)
end
function LogicGenericModify:OnAddModify(RGGenericModifyParam)
  EventSystem.Invoke(EventDef.GenericModify.OnAddModify, RGGenericModifyParam)
  LogicAudio.OnAddModify(RGGenericModifyParam)
end
function LogicGenericModify:OnRemoveModify(RGGenericModifyParam)
  EventSystem.Invoke(EventDef.GenericModify.OnRemoveModify, RGGenericModifyParam)
end
function LogicGenericModify:OnUpgradeModify(RGGenericModifyParam)
  EventSystem.Invoke(EventDef.GenericModify.OnUpgradeModify, RGGenericModifyParam)
end
function LogicGenericModify:OnGenericModifyPushPreview(PreviewModifyList)
  local PreviewModifyListTb = PreviewModifyList:ToTable()
  if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    LogicGenericModify.PushPreviewModifyList = nil
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName, true)
    RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName):InitGenericModifyChoosePanelByPushPreview(PreviewModifyListTb)
  else
    LogicGenericModify.PushPreviewModifyList = PreviewModifyListTb
  end
end
function LogicGenericModify:OnSpecificAddModify(RGSpecificModifyParam)
  EventSystem.Invoke(EventDef.SpecificModify.OnAddModify, RGSpecificModifyParam)
end
function LogicGenericModify:OnSpecificRemoveModify(RGSpecificModifyParam)
  EventSystem.Invoke(EventDef.SpecificModify.OnRemoveModify, RGSpecificModifyParam)
end
function LogicGenericModify:OnSpecificRefreshCountChange()
  EventSystem.Invoke(EventDef.SpecificModify.OnRefreshCountChange)
end
function LogicGenericModify:BindOnClientUpdateInscriptionCD(InscriptionId, RemainTime)
  local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandSubsystem then
    return
  end
  local DataAssest = GetLuaInscription(InscriptionId)
  if not DataAssest then
    return
  end
  if not DataAssest.InscriptionCDData.bIsShowCD then
    print(InscriptionId, "\228\184\141\230\152\190\231\164\186")
    return
  end
  if not LogicGenericModify.InscriptionCDDatas then
    LogicGenericModify.InscriptionCDDatas = {}
  end
  local InscriptionData = {}
  InscriptionData.RemainTime = RemainTime
  local GS = UE.UGameplayStatics.GetGameState(self)
  InscriptionData.StartTime = GS:GetServerWorldTimeSeconds()
  LogicGenericModify.InscriptionCDDatas[InscriptionId] = InscriptionData
  EventSystem.Invoke(EventDef.Inscription.OnTriggerCD, InscriptionId, RemainTime)
end
function LogicGenericModify:CheckIsPassiveModify(InModifyIdParam)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return false
  end
  local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(tostring(InModifyIdParam), nil)
  if ResultGenericModify then
    return GenericModifyRow.Slot == UE.ERGGenericModifySlot.None
  end
  return false
end
function LogicGenericModify:GetGroupIDByFirstModify(PreviewModifyList)
  local Modifyid = -1
  if PreviewModifyList.ModifyList:IsValidIndex(1) then
    Modifyid = PreviewModifyList.ModifyList:Get(1)
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(Modifyid, nil)
    if ResultGenericModify then
      return GenericModifyRow.GroupId
    end
  end
  return -1
end
function LogicGenericModify:GetSurvivalGroupIDByFirstModify(PreviewModifyList)
  local Modifyid = -1
  if PreviewModifyList:IsValidIndex(1) then
    Modifyid = PreviewModifyList:Get(1)
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if DTSubsystem then
    local ResultGenericModify, GenericModifyRow = DTSubsystem:GetGenericModifyDataByName(Modifyid, nil)
    if ResultGenericModify then
      return GenericModifyRow.GroupId
    end
  end
  return -1
end
function LogicGenericModify:GetGenericModifyData(InModifyIdParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return nil
  end
  local bIsFind, OutModify = RGGenericModifyComponent:TryGetModify(InModifyIdParam)
  if bIsFind then
    return OutModify
  end
  return nil
end
function LogicGenericModify:GetModifyBySlot(SlotParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return nil
  end
  local bIsFind, OutModify = RGGenericModifyComponent:TryGetModifyBySlot(SlotParam)
  if bIsFind then
    return OutModify
  end
  return nil
end
function LogicGenericModify:CloseGenericModifyChoosePanel(Target)
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    local GenericModifyChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if GenericModifyChoosePanel then
      if GenericModifyChoosePanel.ModifyChooseType == ModifyChooseType.SurvivalAddModify or GenericModifyChoosePanel.ModifyChooseType == ModifyChooseType.SurvivalUpgradeModify or GenericModifyChoosePanel.ModifyChooseType == ModifyChooseType.SurvivalSpecificModify then
        RGUIMgr:HideUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
      else
        RGUIMgr:CloseUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
      end
    else
      print("LogicGenericModify:CloseGenericModifyChoosePanel GenericModifyChoosePanel is nil")
    end
    EventSystem.Invoke(EventDef.GenericModify.OnChoosePanelHideByFinishInteract, LogicGenericModify.IsFinishChooseModify)
    LogicHUD:UpdateGenericModifyListShow(true)
    LogicGenericModify:CancelInteractGenericModify(Target)
  elseif RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChooseSell_C.UIName) then
    RGUIMgr:CloseUI(UIConfig.WBP_GenericModifyChooseSell_C.UIName)
    LogicHUD:UpdateGenericModifyListShow(true)
    LogicGenericModify:CancelInteractGenericModify(Target)
  end
end
function LogicGenericModify:CancelInteractGenericModify(Target)
  if not Target then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local RGInteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not RGInteractHandle then
    return
  end
  local RGInteractComponent_GenericModify = Target:GetComponentByClass(UE.URGInteractComponent_GenericModify:StaticClass())
  if RGInteractComponent_GenericModify then
    RGInteractComponent_GenericModify:CancelInteract(Target, RGInteractHandle)
  end
  local RGInteractComponent_UpgradeModify = Target:GetComponentByClass(UE.URGInteractComponent_UpgradeModify:StaticClass())
  if RGInteractComponent_UpgradeModify then
    RGInteractComponent_UpgradeModify:CancelInteract(Target, RGInteractHandle)
  end
  local RGInteractComponent_SpecificModify = Target:GetComponentByClass(UE.URGInteractComponent_SpecificModify:StaticClass())
  if RGInteractComponent_SpecificModify then
    RGInteractComponent_SpecificModify:CancelInteract(Target, RGInteractHandle)
  end
  local RGInteractComponent_UpgradeRarityModify = Target:GetComponentByClass(UE.URGInteractComponent_UpgradeRarityModify:StaticClass())
  if RGInteractComponent_UpgradeRarityModify then
    RGInteractComponent_UpgradeRarityModify:CancelInteract(Target, RGInteractHandle)
  end
end
function LogicGenericModify:FinishInteractGenericModify(Target)
  if LogicGenericModify.bCanFinish == false then
    return
  end
  if not Target then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local RGInteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if not RGInteractHandle then
    return
  end
  local RGInteractComponent_GenericModify = Target:GetComponentByClass(UE.URGInteractComponent_GenericModify:StaticClass())
  if RGInteractComponent_GenericModify then
    RGInteractComponent_GenericModify:FinishInteract(Target, RGInteractHandle)
    LogicGenericModify.bCanFinish = false
  end
  local RGInteractComponent_UpgradeRarityModify = Target:GetComponentByClass(UE.URGInteractComponent_UpgradeRarityModify:StaticClass())
  if RGInteractComponent_UpgradeRarityModify then
    RGInteractComponent_UpgradeRarityModify:FinishInteract(Target, RGInteractHandle)
    LogicGenericModify.bCanFinish = false
  end
  local RGInteractComponent_UpgradeModify = Target:GetComponentByClass(UE.URGInteractComponent_UpgradeModify:StaticClass())
  if RGInteractComponent_UpgradeModify then
    RGInteractComponent_UpgradeModify:FinishInteract(Target, RGInteractHandle)
    LogicGenericModify.bCanFinish = false
  end
  local RGInteractComponent_SpecificModify = Target:GetComponentByClass(UE.URGInteractComponent_SpecificModify:StaticClass())
  if RGInteractComponent_SpecificModify then
    RGInteractComponent_SpecificModify:FinishInteract(Target, RGInteractHandle)
    LogicGenericModify.bCanFinish = false
  end
end
function LogicGenericModify:AddGenericModify(PC, InModifyIdParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicGenericModify:AddGenericModify Character is Nil", InModifyIdParam)
    return nil
  end
  if LogicGenericModify.bCanOperator then
    print("LogicGenericModify:AddGenericModify", InModifyIdParam)
    if PC and PC.MiscHelper then
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
      PC.MiscHelper:AddGenericModify(ChoosePanel.InteractComp, InModifyIdParam)
    end
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:AddGenericModify LogicGenericModify.bCanOperator is false", InModifyIdParam)
  end
end
function LogicGenericModify:UpgradeModify(PC, InModifyIdParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicGenericModify:UpgradeModify Character is Nil", InModifyIdParam)
    return nil
  end
  if LogicGenericModify.bCanOperator then
    print("LogicGenericModify:UpgradeModify", InModifyIdParam)
    if PC and PC.MiscHelper then
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
      PC.MiscHelper:UpgradeModify(ChoosePanel.InteractComp, InModifyIdParam)
    end
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:UpgradeModify LogicGenericModify.bCanOperator is false", InModifyIdParam)
  end
end
function LogicGenericModify:AddSpecificModify(PC, InModifyIdParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicGenericModify:AddSpecificModify Character is Nil", InModifyIdParam)
    return nil
  end
  if LogicGenericModify.bCanOperator then
    print("LogicGenericModify:AddSpecificModify", InModifyIdParam)
    if PC and PC.MiscHelper then
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
      PC.MiscHelper:AddSpecificModify(ChoosePanel.InteractComp, InModifyIdParam)
    end
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:AddSpecificModify LogicGenericModify.bCanOperator is false", InModifyIdParam)
  end
end
function LogicGenericModify:ReplaceSpecificModify(PC, InModifyIdParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicGenericModify:ReplaceSpecificModify Character is Nil", InModifyIdParam)
    return nil
  end
  if LogicGenericModify.bCanOperator then
    print("LogicGenericModify:ReplaceSpecificModify", InModifyIdParam)
    if PC and PC.MiscHelper then
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
      PC.MiscHelper:ReplaceSpecificModify(ChoosePanel.InteractComp, InModifyIdParam)
    end
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:ReplaceSpecificModify LogicGenericModify.bCanOperator is false", InModifyIdParam)
  end
end
function LogicGenericModify:AbandonSpecificModify(PC, Interact_SpecificCom, Target)
  if LogicGenericModify.bCanOperator then
    if PC and PC.MiscHelper and UE.RGUtil.IsUObjectValid(Interact_SpecificCom) then
      PC.MiscHelper:AbandonSpecificModify(Interact_SpecificCom)
    end
    LogicGenericModify.bCanOperator = false
    if UE.RGUtil.IsUObjectValid(Target) then
      LogicGenericModify:FinishInteractGenericModify(Target)
    end
  else
    print("LogicGenericModify:AbandonSpecificModify LogicGenericModify.bCanOperator is false")
  end
end
function LogicGenericModify:AddBattleLagacyModify(Idx, InModifyIdParam)
  BattleLagacyModule:AddGenericModifyByBattleLagacy(Idx, InModifyIdParam)
end
function LogicGenericModify:RemoveGenericModify(InModifyIdParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return nil
  end
  RGGenericModifyComponent:RemoveModify(InModifyIdParam)
end
function LogicGenericModify:DoubleGenericModifyUpgrade(InModifyIdParam)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if not RGGenericModifyComponent then
    return nil
  end
  RGGenericModifyComponent:ServerInscriptionUpgradeModify_UpgradeModify(InModifyIdParam)
end
function LogicGenericModify:UpgradeGenericModifyRarity(PC, ModifyID)
  if LogicGenericModify.bCanOperator then
    if PC and PC.MiscHelper then
      local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
      PC.MiscHelper:UpgradeGenericModifyRarity(ChoosePanel.InteractComp, ModifyID)
    end
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:UpgradeGenericModifyRarity LogicGenericModify.bCanOperator is false")
  end
end
function LogicGenericModify:SurvivalAddModify(ModifyID)
  if LogicGenericModify.bCanOperator then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    if not Character then
      print("LogicGenericModify:AddGenericModifyPack Character is Nil")
      return nil
    end
    local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
    if not SurvivalModeComp then
      return
    end
    SurvivalModeComp:SurvivalAddModify(ModifyID)
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:UpgradeGenericModifyRarity LogicGenericModify.bCanOperator is false")
  end
end
function LogicGenericModify:OnSurvivalPreviewModifyData(PreviewModifyData)
  EventSystem.Invoke(EventDef.SurvivalModify.OnAddModify, PreviewModifyData)
  if 0 == #PreviewModifyData.PreviewModifyList:ToTable() then
    return
  end
  if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
  end
  local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
  if ChoosePanel then
    ChoosePanel:InitSurvivalModifyList(PreviewModifyData)
  end
end
function LogicGenericModify:OnSurvivalUpgradeModifyData(PreviewUpgradeModifyData)
  EventSystem.Invoke(EventDef.SurvivalModify.OnUpgradeModify, PreviewUpgradeModifyData)
  if 0 == #PreviewUpgradeModifyData.PreviewModifyList:ToTable() then
    return
  end
  if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
  end
  local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
  if ChoosePanel then
    ChoosePanel:InitSurvivalUpgradeModifyData(PreviewUpgradeModifyData)
  end
end
function LogicGenericModify:OnSurvivalSpecificModifyData(PreviewSpecificModifyData)
  EventSystem.Invoke(EventDef.SurvivalModify.OnSpecificModify, PreviewSpecificModifyData)
  if 0 == #PreviewSpecificModifyData.PreviewModifyList:ToTable() then
    return
  end
  if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
  end
  local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
  if ChoosePanel then
    ChoosePanel:InitSurvivalSpecificModifyData(PreviewSpecificModifyData)
  end
end
function LogicGenericModify:OnSurvivalPreviewModifyCount(Count)
  EventSystem.Invoke(EventDef.SurvivalModify.OnModifyCountChange, Count)
end
function LogicGenericModify:OnSpecificModifyRefreshCount(SpecificModifyRefreshCount)
  EventSystem.Invoke(EventDef.SurvivalModify.OnSpecificModifyRefreshCount, SpecificModifyRefreshCount)
end
function LogicGenericModify:AddGenericModifyPack(PC, IdxParam)
  local Idx = IdxParam - 1
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicGenericModify:AddGenericModifyPack Character is Nil", Idx)
    return nil
  end
  if LogicGenericModify.bCanOperator then
    print("LogicGenericModify:AddGenericModifyPack", Idx)
    Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass()):AddModifyPack(Idx)
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:AddGenericModifyPack LogicGenericModify.bCanOperator is false", Idx)
  end
end
function LogicGenericModify:GiveUpGenericPack()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicGenericModify:GiveUpGenericPack Character is Nil")
    return nil
  end
  if LogicGenericModify.bCanOperator then
    Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass()):GiveUpModifyPack()
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:GiveUpGenericPack LogicGenericModify.bCanOperator is false")
  end
end
function LogicGenericModify:RefreshGenericPack()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("LogicGenericModify:RefreshGenericPack Character is Nil")
    return nil
  end
  if LogicGenericModify.bCanOperator then
    Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass()):RefreshModifyPack()
    LogicGenericModify.bCanOperator = false
  else
    print("LogicGenericModify:GiveUpGenericPack LogicGenericModify.bCanOperator is false")
  end
end
function LogicGenericModify:UpdateLastPassiveSlotStatus(LastPassiveSlotStatusParam)
  LogicGenericModify.LastPassiveSlotStatus = LastPassiveSlotStatusParam
end
function LogicGenericModify.Clear()
  LogicGenericModify.InscriptionCDDatas = {}
  LogicGenericModify.ChoosPanelOpenTimes = {
    [ModifyChooseType.GenericModify] = 1,
    [ModifyChooseType.SpecificModify] = 1,
    [ModifyChooseType.UpgradeModify] = 1,
    [ModifyChooseType.DoubleGenericModify] = 1,
    [ModifyChooseType.SpecificModifyReplace] = 1,
    [ModifyChooseType.RarityUpModify] = 1,
    [ModifyChooseType.SurvivalSpecificModify] = 1
  }
  EventSystem.RemoveListener(EventDef.Battle.OnControlledPawnChanged, LogicGenericModify.BindOnControlledPawnChanged, nil)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
  if InteractHandle then
    print("LogicGenericModify:Clear")
    InteractHandle.OnBeginInteract:Remove(GameInstance, LogicGenericModify.BindOnBeginInteract)
    InteractHandle.OnFinishInteract:Remove(GameInstance, LogicGenericModify.BindOnFinishInteract)
    InteractHandle.OnCancelInteract:Remove(GameInstance, LogicGenericModify.BindOnCancelInteract)
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if RGGenericModifyComponent then
    RGGenericModifyComponent.OnAddModify:Remove(GameInstance, LogicGenericModify.OnAddModify)
    RGGenericModifyComponent.OnUpgradeModify:Remove(GameInstance, LogicGenericModify.OnUpgradeModify)
    RGGenericModifyComponent.OnRemoveModify:Remove(GameInstance, LogicGenericModify.OnRemoveModify)
    RGGenericModifyComponent.OnGenericModifyPushPreview:Remove(GameInstance, LogicGenericModify.OnGenericModifyPushPreview)
  end
  local RGSpecificModifyComponent = Character:GetComponentByClass(UE.URGSpecificModifyComponent:StaticClass())
  if RGSpecificModifyComponent then
    RGSpecificModifyComponent.OnAddModify:Remove(GameInstance, LogicGenericModify.OnSpecificAddModify)
    RGSpecificModifyComponent.OnRemoveModify:Remove(GameInstance, LogicGenericModify.OnSpecificRemoveModify)
    RGSpecificModifyComponent.OnRefreshCountChange:Remove(GameInstance, LogicGenericModify.OnSpecificRefreshCountChange)
  end
  local InscriptionComp = Character:GetComponentByClass(UE.URGInscriptionComponentV2:StaticClass())
  if InscriptionComp then
    InscriptionComp.OnInscriptionCooldown:Remove(GameInstance, LogicGenericModify.BindOnClientUpdateInscriptionCD)
  end
  LogicGenericModify.IsInit = false
  LogicGenericModify.PushPreviewModifyList = nil
end
function LogicGenericModify:CheckIsSkillType(Slot, SkillType)
  return ModifyToSkillType[Slot] == SkillType
end
function LogicGenericModify:CheckIsChangeModify(ModifyId, ModifyChooseTypeParam)
  if ModifyChooseTypeParam and ModifyChooseTypeParam == ModifyChooseType.RarityUpModify then
    return false
  end
  local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if not result then
    return false
  end
  local GenericModifyData = LogicGenericModify:GetGenericModifyData(ModifyId)
  if not GenericModifyData then
    GenericModifyData = LogicGenericModify:GetModifyBySlot(row.Slot)
    if GenericModifyData then
      return true
    end
  end
  return false
end
function LogicGenericModify:GetChangeModifyList(ModifyId)
  local result, row = GetRowData(DT.DT_GenericModify, tostring(ModifyId))
  if not result then
    return nil, nil
  end
  local GenericModifyData = LogicGenericModify:GetGenericModifyData(ModifyId)
  if not GenericModifyData then
    GenericModifyData = LogicGenericModify:GetModifyBySlot(row.Slot)
    if GenericModifyData then
      local newModifyData = {
        ModifyId = ModifyId,
        Level = GenericModifyData.Level
      }
      return GenericModifyData, newModifyData
    end
  end
  return nil, nil
end
function LogicGenericModify:GetLevelValue(GenericModifyLevelId, GenericModifyId, Level, ModifyLevelDescShowType)
  if ModifyLevelDescShowType == UE.EModifyLevelDesc.Addition then
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
    if not DTSubsystem then
      return ""
    end
    local ResultGenericModifyLevel, GenericModifyLevelRow = DTSubsystem:GetGenericModifyLevelDataByName(tostring(GenericModifyLevelId), nil)
    if not ResultGenericModifyLevel then
      return ""
    end
    local ResultGenericModify, GenericModifyRow = GetRowData(DT.DT_GenericModify, tostring(GenericModifyId))
    if not ResultGenericModify then
      return ""
    end
    local Level2DataMap
    local Unit = ""
    local Key
    if GenericModifyLevelRow.LevelDataAry:IsValidIndex(1) then
      Level2DataMap = GenericModifyLevelRow.LevelDataAry:GetRef(1).Level2DataMap
      Unit = GenericModifyLevelRow.LevelDataAry:GetRef(1).Unit
      Key = GenericModifyLevelRow.LevelDataAry:GetRef(1).Key
    end
    local GroupId = GenericModifyRow.GroupId
    local Slot = GenericModifyRow.Slot
    local HeroId = LogicRole.GetCurUseHeroId()
    local WeaponId = LogicRole:GetCurWeaponId()
    local RowName = string.format("%s_%s_%s_%s", tostring(GroupId), tostring(Slot), tostring(HeroId), tostring(WeaponId))
    local Ratio = 1
    local ResultGenericModifyLevelRatio, GenericModifyLevelRatioRow = GetRowData(DT.DT_GenericModifyLevelRatio, RowName)
    if ResultGenericModifyLevelRatio then
      Ratio = GenericModifyLevelRatioRow.FallbackRatio
      for i, v in pairs(GenericModifyLevelRatioRow.RatioDataArray) do
        if v.Key == Key then
          Ratio = v.Ratio
          break
        end
      end
    end
    local ParamPre
    if Level2DataMap then
      ParamPre = Level2DataMap:Find(Level)
    end
    if ParamPre then
      local PreValue = ParamPre.Param * Ratio
      if IsInterger(PreValue) then
        return math.floor(PreValue) .. Unit
      else
        local ValueStr = string.format("%.1f", PreValue)
        return ValueStr .. Unit
      end
    else
      return "0" .. Unit
    end
  elseif ModifyLevelDescShowType == UE.EModifyLevelDesc.FinalValue then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    local value = UE.URGGenericModifyComponent.GetGenericModifyBaseDamageFormActor(Character, GenericModifyId, Level)
    if IsInterger(value) then
      local valueInt = math.floor(value)
      return valueInt
    else
      local ValueStr = string.format("%.1f", value)
      return ValueStr
    end
  end
end
function LogicGenericModify:GetAllPassiveModifies()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return UE.TArray(UE.FRGGenericModify)
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  local AllPassiveModifies = RGGenericModifyComponent:GetAllPassiveModifies()
  local GS = UE.UGameplayStatics.GetGameState(GameInstance)
  if not GS then
    return AllPassiveModifies
  end
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamSubsystem:StaticClass())
  local userIds = RGTeamSubsystem:GetAllUserIds()
  local otherAllPassiveModifies = UE.TArray(UE.FRGGenericModify)
  for i, v in iterator(userIds) do
    if v ~= tonumber(DataMgr.UserId) then
      for idxPS, vPS in iterator(GS.PlayerArray) do
        local pawn = vPS:BP_GetPawn()
        if vPS:GetUserId() == v and pawn then
          local otherRGGenericModifyComponent = pawn:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
          if otherRGGenericModifyComponent then
            otherAllPassiveModifies:Append(otherRGGenericModifyComponent:GetAllPassiveModifies())
          else
            print("LogicGenericModify:GetAllPassiveModifies otherRGGenericModifyComponent is nil")
          end
        end
      end
    end
  end
  if 0 == otherAllPassiveModifies:Num() then
    return AllPassiveModifies
  end
  for i, v in iterator(otherAllPassiveModifies) do
    local modifyId = v.ModifyId
    local result, row = GetRowData(DT.DT_GenericModify, modifyId)
    if result and row.bTeamSpirit then
      AllPassiveModifies:Add(v)
    end
  end
  return AllPassiveModifies
end
function LogicGenericModify:GetModifyTypeByComp(InteractComp)
  if not UE.RGUtil.IsUObjectValid(InteractComp) then
    return ModifyChooseType.None
  end
  local ModifyChooseTypeTemp = ModifyChooseType.GenericModify
  if InteractComp:Cast(UE.URGInteractComponent_UpgradeModify:StaticClass()) then
    ModifyChooseTypeTemp = ModifyChooseType.UpgradeModify
  end
  if InteractComp:Cast(UE.URGInteractComponent_SpecificModify:StaticClass()) then
    if InteractComp.Type == UE.ERGSpecificModifyType.Replace then
      ModifyChooseTypeTemp = ModifyChooseType.SpecificModifyReplace
    elseif InteractComp.Type == UE.ERGSpecificModifyType.Add then
      ModifyChooseTypeTemp = ModifyChooseType.SpecificModify
    end
  end
  if InteractComp:Cast(UE.URGInteractComponent_GenericModifySell:StaticClass()) then
    ModifyChooseTypeTemp = ModifyChooseType.GenericModifySell
  end
  if InteractComp:Cast(UE.URGInteractComponent_UpgradeRarityModify:StaticClass()) then
    ModifyChooseTypeTemp = ModifyChooseType.RarityUpModify
  end
  return ModifyChooseTypeTemp
end
function LogicGenericModify:GetFirstSpecificModify()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local RGSpecificModifyComponent = Character:GetComponentByClass(UE.URGSpecificModifyComponent:StaticClass())
  local allSpecificModifies = RGSpecificModifyComponent:GetActivatedModifies()
  if allSpecificModifies:IsValidIndex(1) then
    return allSpecificModifies:Get(1)
  end
  return nil
end
function LogicGenericModify:GetModifyUpgradeLevelByModifyId(ModifyId)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return 0
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if RGGenericModifyComponent then
    local upgradeLv = LogicGenericModify:GetShopUpgradeModifyUpgradeLevel()
    local maxCanUpgradeLv = RGGenericModifyComponent:GetUpgradableLevel(ModifyId)
    return math.min(upgradeLv, maxCanUpgradeLv)
  end
  return 0
end
function LogicGenericModify:GetShopUpgradeModifyUpgradeLevel()
  return LogicShop.GetShopUpgradeModifyUpgradeLevel()
end
function LogicGenericModify:CheckMultiLvUpgrade()
  return LogicGenericModify:GetShopUpgradeModifyUpgradeLevel() > 1
end
function LogicGenericModify:GetRecommendGenericId(BuildId, WorldIdx, LevelIdx)
  local recommendedGenericModifyId = -1
  if table.IsEmpty(LogicGenericModify.RecommendGenericIdMap) then
    LogicGenericModify.RecommendGenericIdMap = {}
    local tableNames = GetAllRowNames(DT.DT_CustomizeGenericModifyBuild)
    for k, v in pairs(tableNames) do
      local result, row = GetRowData(DT.DT_CustomizeGenericModifyBuild, v)
      if result and row.ModifyBuildId == BuildId and row.WorldIndex and row.LevelIndex == LevelIdx and row.RecommendedGenericModifyId:IsValidIndex(1) then
        recommendedGenericModifyId = row.RecommendedGenericModifyId:Get(1)
      end
      if result then
        if not LogicGenericModify.RecommendGenericIdMap[row.ModifyBuildId] then
          LogicGenericModify.RecommendGenericIdMap[row.ModifyBuildId] = {}
        end
        local id = -1
        if row.RecommendedGenericModifyId:IsValidIndex(1) then
          id = row.RecommendedGenericModifyId:Get(1)
        end
        table.insert(LogicGenericModify.RecommendGenericIdMap[row.ModifyBuildId], {
          WorldIndex = row.WorldIndex,
          LevelIndex = row.LevelIndex,
          RecommendedGenericModifyId = id
        })
      end
    end
  elseif LogicGenericModify.RecommendGenericIdMap[BuildId] then
    for k, v in ipairs(LogicGenericModify.RecommendGenericIdMap[BuildId]) do
      if v.WorldIndex == WorldIdx and v.LevelIndex == LevelIdx then
        recommendedGenericModifyId = v.RecommendedGenericModifyId
        break
      end
    end
  end
  return recommendedGenericModifyId
end
function LogicGenericModify:GetGenericPackData()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local GenericPackComp = Character:GetComponentByClass(UE.URGHeroGenericModifyPackComponent:StaticClass())
  if not GenericPackComp then
    return nil
  end
  return GenericPackComp.PreviewModifyData
end
function LogicGenericModify:CloseGenericPackChoosePanel()
  if RGUIMgr:IsShown(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName) then
    RGUIMgr:CloseUI(UIConfig.WBP_GenericModify_Pack_Choose_C.UIName)
    EventSystem.Invoke(EventDef.GenericModify.OnChoosePanelHideByFinishInteract, LogicGenericModify.IsFinishChooseModify)
    LogicHUD:UpdateGenericModifyListShow(true)
  end
end
function LogicGenericModify:GetSurvivalPreviewModifyData()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  return SurvivalModeComp.PreviewModifyData
end
function LogicGenericModify:GetSurvivalPreviewUpgradeModifyData()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  return SurvivalModeComp.PreviewUpgradeModifyData
end
function LogicGenericModify:GetSurvivalPreviewSpecificModifyData()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return nil
  end
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  return SurvivalModeComp.PreviewSpecificModifyData
end
function LogicGenericModify:SurvivalUpgradeModify(ModifyId)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  if RGGenericModifyComponent and not RGGenericModifyComponent:HasCandidateModifies() then
    return
  end
  SurvivalModeComp:SurvivalUpgradeModify(ModifyId)
end
function LogicGenericModify:SurvivalAddSpecificModify(ModifyId)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    return
  end
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  SurvivalModeComp:SurvivalAddSpecificModify(ModifyId)
end
function LogicGenericModify:GetSurvivalModifyCount()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return 0
  end
  local Count = SurvivalModeComp.Count
  return Count
end
function LogicGenericModify:GetSurvivalSpecificModifyRefreshCount()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return 0
  end
  local SpecificModifyRefreshCount = SurvivalModeComp.SpecificModifyRefreshCount
  return SpecificModifyRefreshCount
end
function LogicGenericModify:GetSurvivalUpgradeModifyCount()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local BagComp = PC:GetComponentByClass(UE.URGBagComponent.StaticClass())
  local Count = 0
  if BagComp then
    Count = BagComp:GetItemByConfigId(9999900).Stack
    local PreviewUpgradeModifyData = self:GetSurvivalPreviewUpgradeModifyData()
    local ModifyNum = PreviewUpgradeModifyData.PreviewModifyList:Length()
    if ModifyNum > 0 then
      Count = Count + 1
    end
  end
  return Count
end
function LogicGenericModify:GetSurvivalSpecificModifyCount()
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
  local Count = 0
  if BagComp then
    Count = BagComp:GetItemByConfigId(9999901).Stack
    local PreviewSpecificModifyData = self:GetSurvivalPreviewSpecificModifyData()
    local ModifyNum = PreviewSpecificModifyData.PreviewModifyList:Length()
    if ModifyNum > 0 then
      Count = Count + 1
    end
  end
  return Count
end
function LogicGenericModify:SurvivalRequestGenericModify()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  SurvivalModeComp:SurvivalRequestGenericModify()
end
function LogicGenericModify:SurvivalModify()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if not SurvivalModeComp then
    return
  end
  local Count = self:GetSurvivalModifyCount()
  if Count <= 0 then
    return
  end
  local PreviewModifyData = self:GetSurvivalPreviewModifyData()
  if 0 ~= PreviewModifyData.Status then
    if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    end
    local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if ChoosePanel then
      ChoosePanel:InitSurvivalModifyList(PreviewModifyData)
    end
  else
    self:SurvivalRequestGenericModify()
  end
end
function LogicGenericModify:SurvivalRequestUpgradeModify()
  local PreviewUpgradeModifyData = self:GetSurvivalPreviewUpgradeModifyData()
  if 0 ~= PreviewUpgradeModifyData.Status then
    if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    end
    local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if ChoosePanel then
      ChoosePanel:InitSurvivalUpgradeModifyData(PreviewUpgradeModifyData)
    end
  else
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
    if SurvivalModeComp then
      SurvivalModeComp:SurvivalRequestUpgradeModify()
    end
  end
end
function LogicGenericModify:SurvivalRequestSpecificModify()
  local PreviewSpecificModifyData = self:GetSurvivalPreviewSpecificModifyData()
  if 0 ~= PreviewSpecificModifyData.Status then
    if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
      RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    end
    local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if ChoosePanel then
      ChoosePanel:InitSurvivalSpecificModifyData(PreviewSpecificModifyData)
    end
  else
    local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
    local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
    if SurvivalModeComp then
      LogicGenericModify:SurvivalRequestSpecificModifyEx(false)
    end
  end
end
function LogicGenericModify:SurvivalRequestSpecificModifyEx(Refresh)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local SurvivalModeComp = Character:GetComponentByClass(UE.URGSurvivalModeComponent:StaticClass())
  if SurvivalModeComp then
    SurvivalModeComp:SurvivalRequestSpecificModify(Refresh)
  end
end
