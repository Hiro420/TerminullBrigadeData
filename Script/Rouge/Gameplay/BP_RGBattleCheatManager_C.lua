local rapidjson = require("rapidjson")
local BP_RGBattleCheatManager_C = UnLua.Class()
local BattleLagacyHandler = require("Protocol.BattleLagacy.BattleLagacyHandler")
local BatchCheatCfg = require("GameConfig.Cheat.BatchCheatConfig")
function BP_RGBattleCheatManager_C:DebugInteractAllActorLog(bIsLog)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local WaveWindow = WaveWindowManager:ShowWaveWindow(1124, nil, nil)
end
function BP_RGBattleCheatManager_C:Debug3DUIHoverWidget(bIsDebug)
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if not WaveWindowManager then
    return
  end
  local WaveWindow = WaveWindowManager:ShowWaveWindow(1124, nil, nil)
end
function BP_RGBattleCheatManager_C:CheatSetBattleLagacyList(Id1, Id2, Id3)
  BattleLagacyHandler:Setbattlelagacylist(Id1, Id2, Id3)
end
function BP_RGBattleCheatManager_C:CheatSetBattleLagacy(Id)
  BattleLagacyHandler:Setbattlelagacy(Id)
end
function BP_RGBattleCheatManager_C:CheatOpenLagacyModifyChoosePanel(Id1, Id2, Id3)
  local BattleLagacyList = {
    tonumber(Id1),
    tonumber(Id2),
    tonumber(Id3)
  }
  print("WBP_SettlementInComeView_C:ShowBattleLagacyModifyChoosePanel", BattleLagacyList)
  if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyChoosePanel_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    local genericModifyPanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyChoosePanel_C.UIName)
    if genericModifyPanel then
      genericModifyPanel:InitGenericModifyChoosePanelByBattleLagacy(BattleLagacyList)
    end
  end
end
function BP_RGBattleCheatManager_C:CheatShowInscriptionBattleLagacy(Id)
  RGUIMgr:OpenUI(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName)
  local battleLagacyModifyRewardReminder_C = RGUIMgr:GetUI(UIConfig.WBP_BattleLagacyInscriptionRewardReminder_C.UIName)
  if battleLagacyModifyRewardReminder_C then
    battleLagacyModifyRewardReminder_C:InitBattleLagacyInscriptionRewardReminder({
      BattleLagacyType = EBattleLagacyType.Inscription,
      BattleLagacyId = tostring(Id)
    }, false)
  end
end
function BP_RGBattleCheatManager_C:CheatShowModifyBattleLagacy(Id)
  RGUIMgr:OpenUI(UIConfig.WBP_BattleLagacyModifyRewardReminder_C.UIName)
  local battleLagacyModifyRewardReminder_C = RGUIMgr:GetUI(UIConfig.WBP_BattleLagacyModifyRewardReminder_C.UIName)
  if battleLagacyModifyRewardReminder_C then
    battleLagacyModifyRewardReminder_C:InitBattleLagacyModifyRewardReminder({
      BattleLagacyType = EBattleLagacyType.GeneircModify,
      BattleLagacyId = tostring(Id)
    }, false)
  end
end
function BP_RGBattleCheatManager_C:SetVoiceLanguage(NewCulture)
  UE.UAudioManager.SetVoiceLanguage(NewCulture)
end
function BP_RGBattleCheatManager_C:PrintServerTime()
  local url = "dbg/hotfix/getservertime"
  HttpCommunication.Request(url, {}, {
    self,
    function(Target, JsonResponse)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      if JsonTable and JsonTable.timestamp then
        print("\229\189\147\229\137\141\230\156\141\229\138\161\229\153\168\230\151\182\233\151\180(" .. tostring(Timezone()) .. ")\239\188\154", TimestampToDateTimeText(tonumber(JsonTable.timestamp)), "\230\151\182\233\151\180\230\136\179\239\188\154", JsonTable.timestamp)
        UE4.UKismetSystemLibrary.PrintString(self, "\229\189\147\229\137\141\230\156\141\229\138\161\229\153\168\230\151\182\233\151\180(" .. tostring(Timezone()) .. ")\239\188\154" .. "     " .. TimestampToDateTimeText(tonumber(JsonTable.timestamp)))
        ShowWaveWindow(100001, {
          TimestampToDateTimeText(tonumber(JsonTable.timestamp))
        })
      end
    end
  }, {
    GameInstance,
    function()
      print("\232\175\183\230\177\130\229\164\177\232\180\165")
    end
  })
end
function BP_RGBattleCheatManager_C:PrintHPAndSheild()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if not Character then
    print("\230\178\161\230\156\137\230\137\190\229\136\176\232\167\146\232\137\178")
    return
  end
  local CoreComp = Character:GetComponentByClass(UE.URGCoreComponent:StaticClass())
  local ExtraShieldComp = Character:GetComponentByClass(UE.URGExtraShieldComponent:StaticClass())
  if ExtraShieldComp then
    local maxShield = UE.UKismetMathLibrary.Round(tonumber(CoreComp:GetMaxShield()))
    local curShield = 0
    if ExtraShieldComp:GetExtraShield() > 0 then
      curShield = string.format("<%s>%d</>", self.ExtraShieldTextColor, UE.UKismetMathLibrary.Round(tonumber(ExtraShieldComp:GetExtraShield() + CoreComp:GetShield())))
    else
      curShield = UE.UKismetMathLibrary.Round(tonumber(ExtraShieldComp:GetExtraShield() + CoreComp:GetShield()))
    end
    print("SheildInfo ", curShield, maxShield)
  end
  local CurHealth = CoreComp:GetHealth()
  local displayHealth = UE.UKismetMathLibrary.Round(CurHealth)
  local displayMaxHealth = UE.UKismetMathLibrary.Round(tonumber(CoreComp:GetMaxHealth()))
  print("HP Info ", displayHealth, displayMaxHealth)
end
function BP_RGBattleCheatManager_C:BatchCheat(CfgIdx)
  local result, batchCheatInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBBattleBatchCheat, CfgIdx)
  if not result then
    return
  end
  self:AddWeapon(batchCheatInfo.WeaponID, 1)
  self:AddSpecificModify(batchCheatInfo.Potential)
  local attributeModifyIdList = batchCheatInfo.Collection
  for i, attributeModifyId in ipairs(attributeModifyIdList) do
    self:AddAttributeModify(attributeModifyId)
  end
  local genericModifyInfoList = batchCheatInfo.GenericModify
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local RGGenericModifyComponent
  if Character then
    RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  end
  if RGGenericModifyComponent then
    for i, genericModifyInfo in ipairs(genericModifyInfoList) do
      self:AddGenericModify(genericModifyInfo.key)
      RGGenericModifyComponent:ServerUpgradeModify(genericModifyInfo.key, genericModifyInfo.value)
    end
  end
end
function BP_RGBattleCheatManager_C:CheatChatSystem(SystemMsgID)
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemMsg, tonumber(SystemMsgID))
  if not result then
    return
  end
  local PC = UE.UGameplayStatics.GetPlayerController(GameInstance, 0)
  if not PC then
    return
  end
  local PS = PC.PlayerState
  if not PS then
    return
  end
  if AttributeId == "" then
    AttributeId = "4003000"
  end
  local chatComp = PS:GetComponentByClass(UE.URGPlayerChatComponent:StaticClass())
  local msg = {
    SystemMsgID = tonumber(SystemMsgID),
    extra = {
      params = {""}
    }
  }
  local msgJson = RapidJsonEncode(msg)
  chatComp:ServerSendChatMsg(DataMgr:GetUserId(), msgJson)
end
function BP_RGBattleCheatManager_C:GetMouseCaptureMode()
  local captureMode = UE.URGBlueprintLibrary.GetMouseCaptureMode(GameInstance)
  print("MouseCaptureMode", captureMode)
end
function BP_RGBattleCheatManager_C:HideDeviceUIInfo(bIsHide)
  local hud = RGUIMgr:GetUI(UIConfig.WBP_HUD_C.UIName)
  if hud then
    UpdateVisibility(hud.Button_DSName, not bIsHide, true)
    UpdateVisibility(hud.HorizontalBox_Device, not bIsHide, true)
  end
end
function BP_RGBattleCheatManager_C:GetHighestUIInst()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if UIManager then
    local hightInst = UIManager:GetHighestUIInst()
    if hightInst then
      print("HighestUIInst", hightInst:GetName())
    end
  end
end
function BP_RGBattleCheatManager_C:CheckGenericModifyDialogue()
  function ShowError(ErrorTableName, ErrorRowname, ErrorParam, ErrorReason)
    local ShowString = "\230\179\149\229\136\153\229\175\185\232\175\157\233\133\141\231\189\174\230\163\128\230\181\139 \239\188\154 \229\188\130\229\184\184\232\161\168\230\160\188\229\145\189\239\188\154%s\227\128\130    \229\188\130\229\184\184RowName\239\188\154%s\227\128\130   \229\188\130\229\184\184\229\143\130\230\149\176\229\144\141\239\188\154%s\227\128\130    \229\188\130\229\184\184\229\142\159\229\155\160\239\188\154%s"
    UE.URGBlueprintLibrary.AddMessageLog(string.format(ShowString, ErrorTableName, ErrorRowname, ErrorParam, ErrorReason, References))
  end
  local GenericModifyDialogueRowNames = GetAllRowNames(DT.DT_GenericModifyDialogue)
  for indexRowName, vRowName in ipairs(GenericModifyDialogueRowNames) do
    local r, RowInfo = GetRowData(DT.DT_GenericModifyDialogue, vRowName)
    if r and RowInfo and RowInfo.DialogueItemIds and RowInfo.DialogueItemIds:Num() > 0 then
      for index, value in ipairs(RowInfo.DialogueItemIds:ToTable()) do
        local result, row = GetRowData(DT.DT_GenericModifyDialogueItem, value)
        if result then
          if row.DialogueList and row.DialogueList:Num() > 0 then
            for DialogueListIndex, DialogueItemId in ipairs(row.DialogueList:ToTable()) do
              local TBDialogue = LuaTableMgr.GetLuaTableByName(TableNames.TBGenericModifyDialog)
              if not TBDialogue or not TBDialogue[DialogueItemId.DialogueId] then
                ShowError("DT_GenericModifyDialogueItem", value, "\229\175\185\232\175\157\229\134\133\229\174\185", "\230\179\149\229\136\153\229\175\185\232\175\157\232\161\168\233\133\141\231\189\174\229\188\130\229\184\184" .. DialogueItemId.DialogueId)
              end
            end
          else
            ShowError("DT_GenericModifyDialogueItem", value, "\229\175\185\232\175\157\229\134\133\229\174\185", "\230\178\161\230\156\137\233\133\141\231\189\174\229\175\185\232\175\157\229\134\133\229\174\185")
          end
        else
          ShowError("DT_GenericModifyDialogue", vRowName, "DialogueItemIds", "DT_GenericModifyDialogueItem\230\178\161\230\156\137\230\137\190\229\136\176" .. value)
        end
      end
    else
      ShowError("DT_GenericModifyDialogue", vRowName, "DialogueItemIds", "\230\178\161\230\156\137\233\133\141\231\189\174DialogueItemIds")
    end
  end
end
function BP_RGBattleCheatManager_C:TriggerGenericModifyDialogue(Id)
  if not RGUIMgr:IsShown(UIConfig.WBP_GenericModifyDialog_C.UIName) then
    RGUIMgr:OpenUI(UIConfig.WBP_GenericModifyDialog_C.UIName, true)
    local ChoosePanel = RGUIMgr:GetUI(UIConfig.WBP_GenericModifyDialog_C.UIName)
    if ChoosePanel then
      ChoosePanel:OpenGenericModifyDialogByPack(Id, true)
    end
  end
end
function BP_RGBattleCheatManager_C:CheatMarquee(Content, Interval, RepeatCount, PriorityLevel)
  local MarqueeData = UE.FMarqueeData()
  MarqueeData = UE.URGBlueprintLibrary.InitMarqueeData(nil, Content, Interval, RepeatCount, PriorityLevel)
  UE.URGMarqueeSubsystem.Get(GameInstance):AddMarqueeData(MarqueeData)
  RGUIMgr:GetUI(UIConfig.WBP_Marquee.UIName):InitMarquee()
end
return BP_RGBattleCheatManager_C
