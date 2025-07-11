local enum = _G.enum
local EUILayer = enum({
  "None",
  "Low",
  "Middle",
  "High",
  "Modal",
  "Count"
})
_G.EUILayer = _G.EUILayer or EUILayer
local UIConfig = {
  WBP_LobbyHUD_C = {
    UIName = "WBP_LobbyHUD_C",
    WidgetPath = "/Game/Rouge/UI/3DLobby/WBP_LobbyHUD.WBP_LobbyHUD_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_GameplaySelection_C = {
    UIName = "WBP_GameplaySelection_C",
    WidgetPath = "/Game/Rouge/UI/3DLobby/Gameplay/WBP_GameplaySelection.WBP_GameplaySelection_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_AttributeDebug_C = {
    UIName = "WBP_AttributeDebug_C",
    WidgetPath = "/Game/Rouge/UI/AttributeDebug/WBP_AttributeDebug.WBP_AttributeDebug_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_FightAndSkillNotifyIcon_C = {
    UIName = "WBP_FightAndSkillNotifyIcon_C",
    WidgetPath = "/Game/Rouge/UI/Battle/WBP_FightAndSkillNotifyIcon.WBP_FightAndSkillNotifyIcon_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_SnipperOverlay_C = {
    UIName = "WBP_SnipperOverlay_C",
    WidgetPath = "/Game/Rouge/UI/Battle/WBP_SnipperOverlay.WBP_SnipperOverlay_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_TeamDamagePanel_C = {
    UIName = "WBP_TeamDamagePanel_C",
    WidgetPath = "/Game/Rouge/UI/Battle/WBP_TeamDamagePanel.WBP_TeamDamagePanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MarkInteractTipItem_C = {
    UIName = "WBP_MarkInteractTipItem_C",
    WidgetPath = "/Game/Rouge/UI/Battle/Mark/WBP_MarkInteractTipItem.WBP_MarkInteractTipItem_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MarkUICrossItem_C = {
    UIName = "WBP_MarkUICrossItem_C",
    WidgetPath = "/Game/Rouge/UI/Battle/Mark/WBP_MarkUICrossItem.WBP_MarkUICrossItem_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MarkUIItem_C = {
    UIName = "WBP_MarkUIItem_C",
    WidgetPath = "/Game/Rouge/UI/Battle/Mark/WBP_MarkUIItem.WBP_MarkUIItem_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MarkUIScrollTips_C = {
    UIName = "WBP_MarkUIScrollTips_C",
    WidgetPath = "/Game/Rouge/UI/Battle/Mark/WBP_MarkUIScrollTips.WBP_MarkUIScrollTips_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_SettlementView_C = {
    UIName = "WBP_SettlementView_C",
    WidgetPath = "/Game/Rouge/UI/Battle/Settlement/WBP_SettlementView.WBP_SettlementView_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_LoadingView_C = {
    UIName = "WBP_LoadingView_C",
    WidgetPath = "/Game/Rouge/UI/Common/WBP_LoadingView.WBP_LoadingView_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MainPanel_C = {
    UIName = "WBP_MainPanel_C",
    WidgetPath = "/Game/Rouge/UI/Core/MainPanel/WBP_MainPanel.WBP_MainPanel_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_DrawCardView_C = {
    UIName = "WBP_DrawCardView_C",
    WidgetPath = "/Game/Rouge/UI/DrawCard/WBP_DrawCardView.WBP_DrawCardView_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_GameSettingsMain_C = {
    UIName = "WBP_GameSettingsMain_C",
    WidgetPath = "/Game/Rouge/UI/GameSettings/WBP_GameSettingsMain.WBP_GameSettingsMain_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_GenericModifyChoosePanel_C = {
    UIName = "WBP_GenericModifyChoosePanel_C",
    WidgetPath = "/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyChoosePanel.WBP_GenericModifyChoosePanel_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_AIAttribute_C = {
    UIName = "WBP_AIAttribute_C",
    WidgetPath = "/Game/Rouge/UI/GM/WBP_AIAttribute.WBP_AIAttribute_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_DamageFactor_C = {
    UIName = "WBP_DamageFactor_C",
    WidgetPath = "/Game/Rouge/UI/GM/WBP_DamageFactor.WBP_DamageFactor_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_GMWindow_C = {
    UIName = "WBP_GMWindow_C",
    WidgetPath = "/Game/Rouge/UI/GM/WBP_GMWindow.WBP_GMWindow_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_LevelAIInfo_C = {
    UIName = "WBP_LevelAIInfo_C",
    WidgetPath = "/Game/Rouge/UI/GM/WBP_LevelAIInfo.WBP_LevelAIInfo_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_LevelInfo_C = {
    UIName = "WBP_LevelInfo_C",
    WidgetPath = "/Game/Rouge/UI/GM/WBP_LevelInfo.WBP_LevelInfo_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_ToughnessPanel_C = {
    UIName = "WBP_ToughnessPanel_C",
    WidgetPath = "/Game/Rouge/UI/GM/WBP_ToughnessPanel.WBP_ToughnessPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Grage_C = {
    UIName = "WBP_Grage_C",
    WidgetPath = "/Game/Rouge/UI/Grage/WBP_Grage.WBP_Grage_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_HUD_C = {
    UIName = "WBP_HUD_C",
    WidgetPath = "/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MainCross_C = {
    UIName = "WBP_MainCross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/WBP_MainCross.WBP_MainCross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_NormalPickTipList_C = {
    UIName = "WBP_NormalPickTipList_C",
    WidgetPath = "/Game/Rouge/UI/HUD/WBP_NormalPickTipList.WBP_NormalPickTipList_C",
    Layer = EUILayer.Middle,
    IsFocusInput = false
  },
  WBP_Transition_C = {
    UIName = "WBP_Transition_C",
    WidgetPath = "/Game/Rouge/UI/HUD/WBP_Transition.WBP_Transition_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_BattleModeHappyJump_C = {
    UIName = "WBP_BattleModeHappyJump_C",
    WidgetPath = "/Game/Rouge/UI/HUD/BattleModeStage/WBP_BattleModeHappyJump.WBP_BattleModeHappyJump_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_BuffList_C = {
    UIName = "WBP_BuffList_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Buff/WBP_BuffList.WBP_BuffList_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_45DegreeCrossReticle_C = {
    UIName = "WBP_45DegreeCrossReticle_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_45DegreeCrossReticle.WBP_45DegreeCrossReticle_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_60DegreeCrossReticle_C = {
    UIName = "WBP_60DegreeCrossReticle_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_60DegreeCrossReticle.WBP_60DegreeCrossReticle_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_AimCrossReticle_C = {
    UIName = "WBP_AimCrossReticle_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_AimCrossReticle.WBP_AimCrossReticle_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_CB_jiguangqiang_01_C = {
    UIName = "WBP_CB_jiguangqiang_01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_CB_jiguangqiang_01.WBP_CB_jiguangqiang_01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_CB_jiguangqiang_02_C = {
    UIName = "WBP_CB_jiguangqiang_02_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_CB_jiguangqiang_02.WBP_CB_jiguangqiang_02_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_CB_xiandanqiang_01_C = {
    UIName = "WBP_CB_xiandanqiang_01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_CB_xiandanqiang_01.WBP_CB_xiandanqiang_01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_CB_xiandanqiang_02_C = {
    UIName = "WBP_CB_xiandanqiang_02_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_CB_xiandanqiang_02.WBP_CB_xiandanqiang_02_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_CircleRingCross_C = {
    UIName = "WBP_CircleRingCross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_CircleRingCross.WBP_CircleRingCross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_DegreeCrossReticle_C = {
    UIName = "WBP_DegreeCrossReticle_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_DegreeCrossReticle.WBP_DegreeCrossReticle_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_dianliu_C = {
    UIName = "WBP_dianliu_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_dianliu.WBP_dianliu_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_D_Cross_C = {
    UIName = "WBP_D_Cross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_D_Cross.WBP_D_Cross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_LiudanCross_C = {
    UIName = "WBP_LiudanCross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_LiudanCross.WBP_LiudanCross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_LiudanCross_01_C = {
    UIName = "WBP_LiudanCross_01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_LiudanCross_01.WBP_LiudanCross_01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MachineGun_01_C = {
    UIName = "WBP_MachineGun_01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_MachineGun_01.WBP_MachineGun_01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Oblique45DegreeCrossReticle_C = {
    UIName = "WBP_Oblique45DegreeCrossReticle_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_Oblique45DegreeCrossReticle.WBP_Oblique45DegreeCrossReticle_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_PaladinCross_C = {
    UIName = "WBP_PaladinCross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_PaladinCross.WBP_PaladinCross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_pao01_C = {
    UIName = "WBP_pao01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_pao01.WBP_pao01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_pao02_C = {
    UIName = "WBP_pao02_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_pao02.WBP_pao02_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Qing_01_C = {
    UIName = "WBP_Qing_01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_Qing_01.WBP_Qing_01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RF01_C = {
    UIName = "WBP_RF01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_RF01.WBP_RF01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RF02_C = {
    UIName = "WBP_RF02_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_RF02.WBP_RF02_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RF03_C = {
    UIName = "WBP_RF03_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_RF03.WBP_RF03_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RifleAimCrossReticle_C = {
    UIName = "WBP_RifleAimCrossReticle_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_RifleAimCrossReticle.WBP_RifleAimCrossReticle_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RifleAimCrossReticle_01_C = {
    UIName = "WBP_RifleAimCrossReticle_01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_RifleAimCrossReticle_01.WBP_RifleAimCrossReticle_01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RifleAimCrossReticle_02_C = {
    UIName = "WBP_RifleAimCrossReticle_02_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_RifleAimCrossReticle_02.WBP_RifleAimCrossReticle_02_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RifleAimCrossReticle_03_C = {
    UIName = "WBP_RifleAimCrossReticle_03_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_RifleAimCrossReticle_03.WBP_RifleAimCrossReticle_03_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_SBjiatelinCross_C = {
    UIName = "WBP_SBjiatelinCross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_SBjiatelinCross.WBP_SBjiatelinCross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_SBjiatelinCross_01_C = {
    UIName = "WBP_SBjiatelinCross_01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_SBjiatelinCross_01.WBP_SBjiatelinCross_01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_SG01_C = {
    UIName = "WBP_SG01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_SG01.WBP_SG01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_SG02_C = {
    UIName = "WBP_SG02_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_SG02.WBP_SG02_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_shayujianshe_C = {
    UIName = "WBP_shayujianshe_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_shayujianshe.WBP_shayujianshe_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_SR01_C = {
    UIName = "WBP_SR01_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_SR01.WBP_SR01_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_TraceCross_C = {
    UIName = "WBP_TraceCross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_TraceCross.WBP_TraceCross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_W_Cross_C = {
    UIName = "WBP_W_Cross_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Cross/WBP_W_Cross.WBP_W_Cross_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_DyingMark_C = {
    UIName = "WBP_DyingMark_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Dying/WBP_DyingMark.WBP_DyingMark_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_ButtressRespawnProgress_C = {
    UIName = "WBP_ButtressRespawnProgress_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Occupation/WBP_ButtressRespawnProgress.WBP_ButtressRespawnProgress_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Occupancy_C = {
    UIName = "WBP_Occupancy_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Occupation/WBP_Occupancy.WBP_Occupancy_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_OptimalPickup_C = {
    UIName = "WBP_OptimalPickup_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Pickup/WBP_OptimalPickup.WBP_OptimalPickup_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_PickupList_C = {
    UIName = "WBP_PickupList_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Pickup/WBP_PickupList.WBP_PickupList_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_TeamInfoList_C = {
    UIName = "WBP_TeamInfoList_C",
    WidgetPath = "/Game/Rouge/UI/HUD/TeamInfo/WBP_TeamInfoList.WBP_TeamInfoList_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_WeaponList_C = {
    UIName = "WBP_WeaponList_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Weapon/WBP_WeaponList.WBP_WeaponList_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_ItemPanel_C = {
    UIName = "WBP_ItemPanel_C",
    WidgetPath = "/Game/Rouge/UI/Item/WBP_ItemPanel.WBP_ItemPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_GameTypePanel_C = {
    UIName = "WBP_GameTypePanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/MainLobby/WBP_GameTypePanel.WBP_GameTypePanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_LobbyPanel_C = {
    UIName = "WBP_LobbyPanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/MainLobby/WBP_LobbyPanel.WBP_LobbyPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RoleChangeList_C = {
    UIName = "WBP_RoleChangeList_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/Role/WBP_RoleChangeList.WBP_RoleChangeList_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RoleUpgradePanel_C = {
    UIName = "WBP_RoleUpgradePanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/Role/WBP_RoleUpgradePanel.WBP_RoleUpgradePanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_FetterMain_C = {
    UIName = "WBP_FetterMain_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/Role/Fetter/WBP_FetterMain.WBP_FetterMain_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_FindSessionPanel_C = {
    UIName = "WBP_FindSessionPanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/Session/WBP_FindSessionPanel.WBP_FindSessionPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_AutoProcessPanel_C = {
    UIName = "WBP_AutoProcessPanel_C",
    WidgetPath = "/Game/Rouge/UI/Login/WBP_AutoProcessPanel.WBP_AutoProcessPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Lobby_C = {
    UIName = "WBP_Lobby_C",
    WidgetPath = "/Game/Rouge/UI/Login/WBP_Lobby.WBP_Lobby_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Login_C = {
    UIName = "WBP_Login_C",
    WidgetPath = "/Game/Rouge/UI/Login/WBP_Login.WBP_Login_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Room_C = {
    UIName = "WBP_Room_C",
    WidgetPath = "/Game/Rouge/UI/Login/WBP_Room.WBP_Room_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_CustomKeyPanel_C = {
    UIName = "WBP_CustomKeyPanel_C",
    WidgetPath = "/Game/Rouge/UI/Misc/WBP_CustomKeyPanel.WBP_CustomKeyPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_GameOver_Fail_C = {
    UIName = "WBP_GameOver_Fail_C",
    WidgetPath = "/Game/Rouge/UI/Misc/WBP_GameOver_Fail.WBP_GameOver_Fail_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_GameOver_Success_C = {
    UIName = "WBP_GameOver_Success_C",
    WidgetPath = "/Game/Rouge/UI/Misc/WBP_GameOver_Success.WBP_GameOver_Success_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_Pause_C = {
    UIName = "WBP_Pause_C",
    WidgetPath = "/Game/Rouge/UI/Misc/WBP_Pause.WBP_Pause_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_ModChoosePanel_C = {
    UIName = "WBP_ModChoosePanel_C",
    WidgetPath = "/Game/Rouge/UI/MOD/ModChoose/WBP_ModChoosePanel.WBP_ModChoosePanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_LevelReady_C = {
    UIName = "WBP_LevelReady_C",
    WidgetPath = "/Game/Rouge/UI/LevelReady/WBP_LevelReady.WBP_LevelReady_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_GenericModifyWaitPanel_C = {
    UIName = "WBP_GenericModifyWaitPanel_C",
    WidgetPath = "/Game/Rouge/UI/GenericModify/GenericModifyChoose/WBP_GenericModifyWaitPanel.WBP_GenericModifyWaitPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_UITestView_C = {
    UIName = "WBP_UITestView_C",
    WidgetPath = "/Game/Rouge/UI/NewUITest/WBP_UITestView.WBP_UITestView_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_MatchingTipPanel_C = {
    UIName = "WBP_MatchingTipPanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/MainLobby/WBP_MatchingTipPanel.WBP_MatchingTipPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_PrepareTipPanel_C = {
    UIName = "WBP_PrepareTipPanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/MainLobby/WBP_PrepareTipPanel_C.WBP_PrepareTipPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_HeroSelectionMainPanel_C = {
    UIName = "WBP_HeroSelectionMainPanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/HeroSelection/WBP_HeroSelectionMainPanel.WBP_HeroSelectionMainPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_HeroDisplayPanel_C = {
    UIName = "WBP_HeroDisplayPanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/WBP_HeroDisplayPanel.WBP_HeroDisplayPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_InviteTeamTip_C = {
    UIName = "WBP_InviteTeamTip_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/Team/WBP_InviteTeamTip.WBP_InviteTeamTip_C",
    Layer = EUILayer.High,
    IsFocusInput = false
  },
  WBP_Shop_C = {
    UIName = "WBP_Shop_C",
    WidgetPath = "/Game/Rouge/UI/Shop/WBP_Shop.WBP_Shop_C",
    Layer = EUILayer.Middle,
    IsFocusInput = true
  },
  WBP_MainModeSelection_C = {
    UIName = "WBP_MainModeSelection_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/ModeSelection/WBP_MainModeSelectionPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RGBeginnerGuidancePanel_C = {
    UIName = "WBP_RGBeginnerGuidancePanel_C",
    WidgetPath = "/Game/Rouge/UI/BeginnerGuidance/WBP_RGBeginnerGuidancePanel_C",
    Layer = EUILayer.High,
    IsFocusInput = false
  },
  WBP_BattleModeTeaching_C = {
    UIName = "WBP_BattleModeTeaching_C",
    WidgetPath = "/Game/Rouge/UI/Interact/WBP_BattleModeTeaching.WBP_BattleModeTeaching_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_RoleWeaponSelectPanel_C = {
    UIName = "WBP_RoleWeaponSelectPanel_C",
    WidgetPath = "/Game/Rouge/UI/Lobby/Role/WBP_RoleWeaponSelectPanel.WBP_RoleWeaponSelectPanel_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_BattleLagacyInscriptionRewardReminder_C = {
    UIName = "WBP_BattleLagacyInscriptionRewardReminder_C",
    WidgetPath = "/Game/Rouge/UI/BattleLagacy/WBP_BattleLagacyInscriptionRewardReminder.WBP_BattleLagacyInscriptionRewardReminder_C",
    Layer = EUILayer.Middle,
    IsFocusInput = true
  },
  WBP_BattleLagacyModifyRewardReminder_C = {
    UIName = "WBP_BattleLagacyModifyRewardReminder_C",
    WidgetPath = "/Game/Rouge/UI/BattleLagacy/WBP_BattleLagacyModifyRewardReminder.WBP_BattleLagacyModifyRewardReminder_C",
    Layer = EUILayer.Middle,
    IsFocusInput = true
  },
  WBP_GenericModifyChooseSell_C = {
    UIName = "WBP_GenericModifyChooseSell_C",
    WidgetPath = "/Game/Rouge/UI/GenericModify/GenericModifySell/WBP_GenericModifyChooseSell.WBP_GenericModifyChooseSell_C",
    Layer = EUILayer.Middle,
    IsFocusInput = true
  },
  WBP_BattleModeCommonTask_C = {
    UIName = "WBP_BattleModeCommonTask_C",
    WidgetPath = "/Game/Rouge/UI/HUD/BattleModeStage/WBP_BattleModeCommonTask.WBP_BattleModeCommonTask_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_BattleModeCommonTips_C = {
    UIName = "WBP_BattleModeCommonTips_C",
    WidgetPath = "/Game/Rouge/UI/HUD/BattleModeStage/WBP_BattleModeCommonTips.WBP_BattleModeCommonTips_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_RGBeginnerGuidanceSwitch_C = {
    UIName = "WBP_RGBeginnerGuidanceSwitch_C",
    WidgetPath = "/Game/Rouge/UI/BeginnerGuidance/WBP_RGBeginnerGuidanceSwitch.WBP_RGBeginnerGuidanceSwitch_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_LevelPassCheck_C = {
    UIName = "WBP_LevelPassCheck_C",
    WidgetPath = "/Game/Rouge/UI/LevelReady/WBP_LevelPassCheck.WBP_LevelPassCheck_C",
    Layer = EUILayer.High,
    IsFocusInput = false
  },
  WBP_DisplayLevels_C = {
    UIName = "WBP_DisplayLevels_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Level/WBP_DisplayLevels_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_SettleCountDown_C = {
    UIName = "WBP_SettleCountDown_C",
    WidgetPath = "/Game/Rouge/UI/HUD/WBP_SettleCountDown_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_HUDRoulette_C = {
    UIName = "WBP_HUDRoulette_C",
    WidgetPath = "/Game/Rouge/UI/Battle/Communication/WBP_HUDRoulette.WBP_HUDRoulette_C",
    Layer = EUILayer.Low,
    IsFocusInput = true
  },
  WBP_LikeAttributeModifyWindow_C = {
    UIName = "WBP_LikeAttributeModifyWindow_C",
    WidgetPath = "/Game/Rouge/UI/Battle/DamagePanel/WBP_LikeAttributeModifyWindow.WBP_LikeAttributeModifyWindow_C",
    Layer = EUILayer.Modal,
    IsFocusInput = false
  },
  WBP_GenericModifyDialog_C = {
    UIName = "WBP_GenericModifyDialog_C",
    WidgetPath = "/Game/Rouge/UI/GenericModify/GenericModifyDialog/WBP_GenericModifyDialog.WBP_GenericModifyDialog_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_GenericModify_Pack_Choose_C = {
    UIName = "WBP_GenericModify_Pack_Choose_C",
    WidgetPath = "/Game/Rouge/UI/GenericModify/GenericModifyPack/WBP_GenericModify_Pack_Choose.WBP_GenericModify_Pack_Choose",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_BossRushTip_C = {
    UIName = "WBP_BossRushTip_C",
    WidgetPath = "/Game/Rouge/UI/BossRush/WBP_BossRushTip.WBP_BossRushTip_C",
    Layer = EUILayer.Middle,
    IsFocusInput = false
  },
  WBP_Survival_Tips_C = {
    UIName = "WBP_Survival_Tips_C",
    WidgetPath = "/Game/Rouge/UI/HUD/Survival/WBP_Survival_Tips.WBP_Survival_Tips_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_SurvivorProgressBar_C = {
    UIName = "WBP_SurvivorProgressBar_C",
    WidgetPath = "/Game/Rouge/UI/Survivor/WBP_SurvivorProgressBar.WBP_SurvivorProgressBar_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_JapanCommercialPolicy_C = {
    UIName = "WBP_JapanCommercialPolicy_C",
    WidgetPath = "/Game/Rouge/UI/Login/WBP_JapanCommercialPolicy.WBP_JapanCommercialPolicy_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_JapanFundsPolicy_C = {
    UIName = "WBP_JapanFundsPolicy_C",
    WidgetPath = "/Game/Rouge/UI/Login/WBP_JapanFundsPolicy.WBP_JapanFundsPolicy_C",
    Layer = EUILayer.Low,
    IsFocusInput = false
  },
  WBP_CustomerServiceView_C = {
    UIName = "WBP_CustomerServiceView_C",
    WidgetPath = "/Game/Rouge/UI/CustomerService/WBP_CustomerServiceView.WBP_CustomerServiceView_C",
    Layer = EUILayer.High,
    IsFocusInput = true
  },
  WBP_Marquee = {
    UIName = "WBP_Marquee",
    WidgetPath = "/Game/Rouge/UI/Marquee/WBP_Marquee.WBP_Marquee",
    Layer = EUILayer.Modal,
    IsFocusInput = false
  }
}
_G.UIConfig = _G.UIConfig or UIConfig
