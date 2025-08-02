local UILayer = require("Framework.UIMgr.UILayer")
local ViewNameList = {
  "UI_Login",
  "UI_WeaponMain",
  "UI_WeaponSub",
  "UI_ContactPerson",
  "UI_ContactPersonOperateButtonPanel",
  "UI_KickTeamTip",
  "UI_MainModeSelection",
  "UI_Apearance",
  "UI_Skin",
  "UI_Heirloom",
  "UI_Communication",
  "UI_AwardPanel",
  "UI_Mall_Goods",
  "UI_Mall_Bundle",
  "UI_Mall_Bundle_1",
  "UI_Mall_Bundle_2",
  "UI_Mall_Bundle_Content",
  "UI_Common_GetProps",
  "UI_Mall_Exterior",
  "UI_Mall_Exterior_1",
  "UI_Mall_Exterior_2",
  "UI_Mall_Props",
  "UI_Mall_Props_1",
  "UI_Mall_Props_2",
  "UI_Mall_PurchaseConfirm",
  "UI_Mall_RechargeView",
  "UI_DrawCard",
  "UI_Mail",
  "UI_RecruitMainView",
  "UI_MainTaskDetail",
  "UI_MainTaskDialogueView",
  "UI_MainTaskUnLockTip",
  "UI_BeginnerGuidanceSystemTips",
  "UI_BeginnerGuideBookView",
  "UI_ProficiencyView",
  "UI_InviteTeamTip",
  "UI_UserAgreement",
  "UI_PrivacyPolicy",
  "UI_AgeReminder",
  "UI_FriendRemarkName",
  "UI_Loading",
  "UI_GRInfoView",
  "UI_RankView_Nor",
  "UI_Achievement",
  "UI_HeirloomUpgradeSuccess",
  "UI_LobbyMain",
  "UI_RoleMain",
  "UI_LobbyPanel",
  "UI_TalentPanel",
  "UI_MatchingTipPanel",
  "UI_PrepareTipPanel",
  "UI_RecruitingTipPanel",
  "UI_HeroSelectionMainPanel",
  "UI_GoingToBattle",
  "UI_RoleWeaponSelectPanel",
  "UI_ThreeDUITest",
  "UI_IllustratedGuideMenu",
  "UI_IllustratedGuide",
  "UI_IllustratedGuideSpecificModify",
  "UI_IllustratedGuidePlotFragments",
  "UI_IGuidePlotFragmentsWorldMenu",
  "UI_LobbyGM",
  "UI_HttpRequestLoadingView",
  "UI_LevelUp",
  "UI_PlayerInfoMain",
  "UI_PlayerInfo",
  "UI_History",
  "UI_Chip",
  "UI_ProficiencySpecialAwardDetailPanel",
  "UI_BattleModeCommonTips",
  "UI_DevelopMain",
  "UI_BattleModeCommonTask",
  "UI_ProficiencyLegendSynopsis",
  "UI_ProficiencySynopsisDetailPanel",
  "UI_ReportView",
  "UI_LoginRewards",
  "UI_LoginRewardActivity",
  "UI_ChipSlotUnlockView",
  "UI_ChipSeasonSlotUnlockView",
  "UI_ModeSelectionUnlockPanel",
  "UI_GameSettingsMain",
  "UI_MatchingPanel",
  "UI_PandoraRootPanel",
  "UI_SeasonAbilityPanel",
  "UI_ClimbTower",
  "UI_DailyRewards",
  "UI_ChangeSchemeNamePanel",
  "UI_UnlockSchemePanel",
  "UI_ExchangeAbilityPointPanel",
  "UI_ResetSeasonAbilityPanel",
  "UI_SpecialAbilityActivatedPanel",
  "UI_AutoExchangeAbilityPointPanel",
  "UI_ViewSetChangeHeroTip",
  "UI_ActivityPanel",
  "UI_BattlePassMainView",
  "UI_BattlePassSubView",
  "UI_BattlePassUnLockView",
  "UI_ActivityRuleDesc",
  "UI_RuleTask",
  "UI_RuleTaskDetailPanel",
  "UI_RuleTaskCreditExchangePanel",
  "UI_CustomerServiceView",
  "UI_Puzzle",
  "UI_PuzzleDevelopMain",
  "UI_PuzzleDevelop",
  "UI_PuzzleDecompose",
  "UI_PuzzleUpgradeSuccess",
  "UI_PandoraActivityPanel",
  "UI_PandoraActivityPanel_Menu",
  "UI_PandoraActivityPanel_Popup",
  "UI_SpecificLobbyUnlockShow",
  "UI_CommonSmallPopups",
  "UI_WebBrowserView",
  "UI_BossRush",
  "UI_GemUpgrade",
  "UI_GemDecompose",
  "UI_TopupCurrencyPanel",
  "UI_ExchangePanel",
  "UI_SeasonMode_Pop",
  "UI_SeasonMode",
  "UI_MonthCardPanel",
  "UI_SurvivalPanel",
  "UI_ClimbTowerRank",
  "UI_PuzzleRefactor",
  "UI_InitialRoleSelection",
  "UI_InitialRoleSelectionMask",
  "UI_MovieLevelSequence",
  "UI_MovieLevelSequence",
  "UI_LobbyEscMenuPanel",
  "UI_ProfyUpgradeAnimPanel",
  "UI_MidasPayPanel",
  "UI_ComplianceWaveWindow",
  "UI_DrawCardRule",
  "UI_Marquee"
}
local ViewID = enum(ViewNameList)
_G.ViewID = ViewID
_G.ViewNameList = ViewNameList
local UIDef = {
  [ViewID.UI_Login] = {
    ID = ViewID.UI_Login,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Login/WBP_Login",
    UIScript = "UI/View/Login/LoginView"
  },
  [ViewID.UI_WeaponMain] = {
    ID = ViewID.UI_WeaponMain,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Weapon/WBP_WeaponMainView",
    UIScript = "UI/View/Weapon/WeaponMainView"
  },
  [ViewID.UI_WeaponSub] = {
    ID = ViewID.UI_WeaponSub,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Weapon/WeaponSubView/WBP_WeaponSubView",
    UIScript = "UI/View/Weapon/WeaponSubView/WeaponSubView"
  },
  [ViewID.UI_ContactPerson] = {
    ID = ViewID.UI_ContactPerson,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/ContactPerson/WBP_ContactPersonList",
    UIScript = "UI/View/ContactPerson/ContactPersonView"
  },
  [ViewID.UI_ContactPersonOperateButtonPanel] = {
    ID = ViewID.UI_ContactPersonOperateButtonPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/ContactPerson/WBP_ContactPersonOperateButtonPanel",
    UIScript = "UI/View/ContactPerson/ContactPersonOperateButtonPanel"
  },
  [ViewID.UI_KickTeamTip] = {
    ID = ViewID.UI_KickTeamTip,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Team/WBP_KickTeamTip",
    UIScript = "UI/View/Team/WBP_KickTeamTip"
  },
  [ViewID.UI_MainModeSelection] = {
    ID = ViewID.UI_MainModeSelection,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/ModeSelection/WBP_MainModeSelectPanel",
    UIScript = "/Game/Rouge/UI/Lobby/ModeSelection/WBP_MainModeSelectPanel",
    CameraLobbyRow = "UI_MainModeSelection"
  },
  [ViewID.UI_Apearance] = {
    ID = ViewID.UI_Apearance,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Appearance/WBP_AppearanceView",
    UIScript = "UI/View/Appearance/AppearanceView"
  },
  [ViewID.UI_Skin] = {
    ID = ViewID.UI_Skin,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Appearance/Skin/WBP_SkinView",
    UIScript = "UI/View/Appearance/Skin/SkinView"
  },
  [ViewID.UI_Heirloom] = {
    ID = ViewID.UI_Heirloom,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Appearance/Heirloom/WBP_HeirloomView",
    UIScript = "UI/View/Appearance/Heirloom/HeirloomView"
  },
  [ViewID.UI_Communication] = {
    ID = ViewID.UI_Communication,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Appearance/Communication/WBP_CommunicationView",
    UIScript = "UI/View/Appearance/Communication/CommunicationView"
  },
  [ViewID.UI_AwardPanel] = {
    ID = ViewID.UI_AwardPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Common/WBP_AwardPanel",
    UIScript = "Rouge/UI/Common/WBP_AwardPanel_C"
  },
  [ViewID.UI_Mall_Goods] = {
    ID = ViewID.UI_Mall_Goods,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/Goods/WBP_Mall_Goods",
    UIScript = "/Rouge/UI/Mall/Goods/GoodsView",
    SwitchID = "mall"
  },
  [ViewID.UI_Mall_Bundle] = {
    ID = ViewID.UI_Mall_Bundle,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle",
    UIScript = "/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle_C",
    SwitchID = "mall",
    CameraLobbyRow = "UI_Mall_Props"
  },
  [ViewID.UI_Mall_Bundle_1] = {
    ID = ViewID.UI_Mall_Bundle_1,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle",
    UIScript = "/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle_C",
    SwitchID = "mall",
    CameraLobbyRow = "UI_Mall_Props"
  },
  [ViewID.UI_Mall_Bundle_2] = {
    ID = ViewID.UI_Mall_Bundle_2,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle",
    UIScript = "/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle_C",
    SwitchID = "mall",
    CameraLobbyRow = "UI_Mall_Props"
  },
  [ViewID.UI_Mall_Bundle_Content] = {
    ID = ViewID.UI_Mall_Bundle_Content,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle_Content",
    UIScript = "/Rouge/UI/Mall/Bundle/WBP_Mall_Bundle_Content_C",
    SwitchID = "mall"
  },
  [ViewID.UI_Mall_Props] = {
    ID = ViewID.UI_Mall_Props,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Mall/Props/WBP_Mall_Props",
    UIScript = "/Rouge/UI/Mall/Props/PropsView",
    SwitchID = "mall",
    CameraLobbyRow = "UI_Mall_Props"
  },
  [ViewID.UI_Mall_Props_1] = {
    ID = ViewID.UI_Mall_Props_1,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Mall/Props/WBP_Mall_Props",
    UIScript = "/Rouge/UI/Mall/Props/PropsView",
    SwitchID = "mall",
    CameraLobbyRow = "UI_Mall_Props"
  },
  [ViewID.UI_Mall_Props_2] = {
    ID = ViewID.UI_Mall_Props_2,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Mall/Props/WBP_Mall_Props",
    UIScript = "/Rouge/UI/Mall/Props/PropsView",
    SwitchID = "mall",
    CameraLobbyRow = "UI_Mall_Props"
  },
  [ViewID.UI_Mall_Exterior] = {
    ID = ViewID.UI_Mall_Exterior,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Mall/Exterior/WBP_Mall_Exterior",
    UIScript = "/Rouge/UI/Mall/Exterior/MallExteriorView",
    SwitchID = "mall"
  },
  [ViewID.UI_Mall_Exterior_1] = {
    ID = ViewID.UI_Mall_Exterior_1,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Mall/Exterior/WBP_Mall_Exterior",
    UIScript = "/Rouge/UI/Mall/Exterior/MallExteriorView",
    SwitchID = "mall"
  },
  [ViewID.UI_Mall_Exterior_2] = {
    ID = ViewID.UI_Mall_Exterior_2,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Mall/Exterior/WBP_Mall_Exterior",
    UIScript = "/Rouge/UI/Mall/Exterior/MallExteriorView",
    SwitchID = "mall"
  },
  [ViewID.UI_Mall_PurchaseConfirm] = {
    ID = ViewID.UI_Mall_PurchaseConfirm,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Mall/WBP_PurchaseConfirm",
    UIScript = "/Rouge/UI/Mall/PurchaseConfirmView",
    bJustSendHideNotify = true
  },
  [ViewID.UI_CommonSmallPopups] = {
    ID = ViewID.UI_CommonSmallPopups,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Common/WBP_CommonSmallPopups",
    UIScript = "/Rouge/UI/Common/WBP_CommonSmallPopups_C"
  },
  [ViewID.UI_Mall_RechargeView] = {
    ID = ViewID.UI_Mall_RechargeView,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/Recharge/WBP_Mall_Recharge",
    UIScript = "/Rouge/UI/Mall/Recharge/RechargeView",
    SwitchID = "mall"
  },
  [ViewID.UI_Common_GetProps] = {
    ID = ViewID.UI_Common_GetProps,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Common/WBP_GetProps",
    UIScript = "/Rouge/UI/Common/GetPorpsItemView"
  },
  [ViewID.UI_ComplianceWaveWindow] = {
    ID = ViewID.UI_ComplianceWaveWindow,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/WaveWindow/WBP_ComplianceWaveWindow",
    UIScript = "/Rouge/UI/WaveWindow/ComplianceWaveWindow"
  },
  [ViewID.UI_DrawCard] = {
    ID = ViewID.UI_DrawCard,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/DrawCard/WBP_DrawCardView",
    UIScript = "UI/View/Lobby/DrawCard/DrawCardView"
  },
  [ViewID.UI_Mail] = {
    ID = ViewID.UI_Mail,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Mail/WBP_MailView",
    UIScript = "UI/View/Mail/MailView",
    SwitchID = "mail",
    CameraLobbyRow = "UI_Mail"
  },
  [ViewID.UI_MainTaskDetail] = {
    ID = ViewID.UI_MainTaskDetail,
    Layer = UILayer.Menu,
    UIBP = "/Game/Rouge/UI/MainTask/Detail/WBP_MainTask_Detail",
    UIScript = "UI/View/MainTask/MainTaskDetailView",
    CameraLobbyRow = "UI_MainTask"
  },
  [ViewID.UI_MainTaskDialogueView] = {
    ID = ViewID.UI_MainTaskDialogueView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/MainTask/Dialogue/WBP_MainTask_Dialogue",
    UIScript = "UI/View/MainTask/MainTaskDialogueView"
  },
  [ViewID.UI_MainTaskUnLockTip] = {
    ID = ViewID.UI_MainTaskUnLockTip,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/MainTask/WBP_MainTaskUnLockTip",
    UIScript = "Rouge/UI/MainTask/WBP_MainTaskUnLockTip_C"
  },
  [ViewID.UI_BeginnerGuidanceSystemTips] = {
    ID = ViewID.UI_BeginnerGuidanceSystemTips,
    Layer = UILayer.Guide,
    UIBP = "/Game/Rouge/UI/BeginnerGuidance/System/WBP_RGBeginnerGuidanceSystemTip",
    UIScript = "UI/View/BeginnerGuidance/System/BeginnerGuidanceSystemTipsView",
    DontHideOther = true,
    SwitchID = "guide"
  },
  [ViewID.UI_BeginnerGuideBookView] = {
    ID = ViewID.UI_BeginnerGuideBookView,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/IllustratedGuide/Beginner/WBP_BeginnerGuideBookView",
    UIScript = "UI/View/BeginnerGuidance/GuideBook/BeginnerGuideBookView",
    CameraLobbyRow = "UI_BeginnerGuideBookView"
  },
  [ViewID.UI_InviteTeamTip] = {
    ID = ViewID.UI_InviteTeamTip,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Lobby/Team/WBP_InviteTeamTip",
    UIScript = "UI/Lobby/Team/WBP_InviteTeamTip_C",
    DontHideOther = true
  },
  [ViewID.UI_ProficiencyView] = {
    ID = ViewID.UI_ProficiencyView,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Proficiency/WBP_ProficiencyView",
    UIScript = "UI/View/Proficiency/ProficiencyView"
  },
  [ViewID.UI_UserAgreement] = {
    ID = ViewID.UI_UserAgreement,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Login/WBP_UserAgreement",
    UIScript = "UI/View/Login/UserAgreementView"
  },
  [ViewID.UI_PrivacyPolicy] = {
    ID = ViewID.UI_PrivacyPolicy,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Login/WBP_PrivacyPolicy",
    UIScript = "UI/View/Login/PrivacyPolicyView"
  },
  [ViewID.UI_AgeReminder] = {
    ID = ViewID.UI_AgeReminder,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Login/WBP_AgeReminder",
    UIScript = "UI/View/Login/AgeReminderView"
  },
  [ViewID.UI_FriendRemarkName] = {
    ID = ViewID.UI_FriendRemarkName,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/ContactPerson/WBP_FriendRemarkName",
    UIScript = "UI/View/ContactPerson/FriendRemarkNameView"
  },
  [ViewID.UI_Loading] = {
    ID = ViewID.UI_Loading,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Common/WBP_LoadingView.WBP_LoadingView",
    UIScript = "UI/CommonView/WBP_LoadingView_C",
    DontHideOther = true
  },
  [ViewID.UI_GRInfoView] = {
    ID = ViewID.UI_GRInfoView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Rank/RankInfo/WBP_GRInformationPanel",
    UIScript = "UI.View.Rank.GRInfoView"
  },
  [ViewID.UI_RankView_Nor] = {
    ID = ViewID.UI_RankView_Nor,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Rank/RankMode/WBP_Rank_Normal",
    UIScript = "UI.View.Rank.Mode.RankNor"
  },
  [ViewID.UI_Achievement] = {
    ID = ViewID.UI_Achievement,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Achievement/WBP_AchievementView",
    UIScript = "UI.View.Achievement.AchievementView",
    SwitchID = "achievement"
  },
  [ViewID.UI_HeirloomUpgradeSuccess] = {
    ID = ViewID.UI_HeirloomUpgradeSuccess,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Appearance/Heirloom/WBP_HeirloomUpgradeSuccess",
    UIScript = "UI.View.Appearance.Heirloom.HeirloomUpgradeSuccessView"
  },
  [ViewID.UI_LobbyMain] = {
    ID = ViewID.UI_LobbyMain,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Lobby/MainLobby/WBP_LobbyMain",
    UIScript = "UI.View.Lobby.LobbyMainView"
  },
  [ViewID.UI_RoleMain] = {
    ID = ViewID.UI_RoleMain,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Lobby/WBP_RoleMain",
    UIScript = "Rouge.UI.Lobby.WBP_RoleMain"
  },
  [ViewID.UI_LobbyPanel] = {
    ID = ViewID.UI_LobbyPanel,
    Layer = UILayer.Menu,
    UIBP = "/Game/Rouge/UI/Lobby/MainLobby/WBP_LobbyPanel",
    UIScript = "Rouge.UI.Lobby.MainLobby.WBP_LobbyPanel"
  },
  [ViewID.UI_TalentPanel] = {
    ID = ViewID.UI_TalentPanel,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Lobby/WBP_TalentPanel",
    UIScript = "Rouge.UI.Lobby.WBP_TalentPanel"
  },
  [ViewID.UI_MatchingTipPanel] = {
    ID = ViewID.UI_MatchingTipPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/MainLobby/WBP_MatchingTipPanel",
    UIScript = "Rouge.UI.Lobby.MainLobby.WBP_MatchingTipPanel_C",
    DontHideOther = true
  },
  [ViewID.UI_RecruitingTipPanel] = {
    ID = ViewID.UI_RecruitingTipPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/MainLobby/WBP_RecruitingTipPanel",
    UIScript = "Rouge.UI.Lobby.MainLobby.WBP_RecruitingTipPanel_C",
    DontHideOther = true
  },
  [ViewID.UI_PrepareTipPanel] = {
    ID = ViewID.UI_PrepareTipPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/MainLobby/WBP_PrepareTipPanel",
    UIScript = "Rouge.UI.Lobby.MainLobby.WBP_MatchingTipPanel_C"
  },
  [ViewID.UI_HeroSelectionMainPanel] = {
    ID = ViewID.UI_HeroSelectionMainPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/HeroSelection/WBP_HeroSelectionMainPanel",
    UIScript = "Rouge.UI.Lobby.HeroSelection.WBP_HeroSelectionMainPanel_C"
  },
  [ViewID.UI_GoingToBattle] = {
    ID = ViewID.UI_GoingToBattle,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Common/WBP_GoingToBattle",
    UIScript = "Rouge.UI.Common.WBP_GoingToBattle_C"
  },
  [ViewID.UI_RoleWeaponSelectPanel] = {
    ID = ViewID.UI_RoleWeaponSelectPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/Role/WBP_RoleWeaponSelectPanel",
    UIScript = "Rouge.UI.Lobby.Role.WBP_RoleWeaponSelectPanel_C"
  },
  [ViewID.UI_ThreeDUITest] = {
    ID = ViewID.UI_ThreeDUITest,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/3DUITest/ThreeDUITestView",
    UIScript = "UI.View.ThreeDUITest.ThreeDUITestView"
  },
  [ViewID.UI_IllustratedGuideMenu] = {
    ID = ViewID.UI_IllustratedGuideMenu,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/IllustratedGuide/WBP_IllustratedGuide_Menu",
    UIScript = "UI.View.IllustratedGuide.IllustratedGuideMenuView"
  },
  [ViewID.UI_IGuidePlotFragmentsWorldMenu] = {
    ID = ViewID.UI_IGuidePlotFragmentsWorldMenu,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/IllustratedGuide/WBP_IGuide_PlotFragmentsWorldMenu",
    UIScript = "UI.View.IllustratedGuide.IGuidePlotFragmentsWorldMenuView"
  },
  [ViewID.UI_IllustratedGuide] = {
    ID = ViewID.UI_IllustratedGuide,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/IllustratedGuide/WBP_IllustratedGuide",
    UIScript = "UI.View.IllustratedGuide.IllustratedGuideView"
  },
  [ViewID.UI_IllustratedGuideSpecificModify] = {
    ID = ViewID.UI_IllustratedGuideSpecificModify,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/IllustratedGuide/WBP_IGuide_SpecificModify",
    UIScript = "UI.View.IllustratedGuide.IllustratedGuideSpecificModifyView",
    CameraLobbyRow = "UI_IllustratedGuideSpecificModify"
  },
  [ViewID.UI_IllustratedGuidePlotFragments] = {
    ID = ViewID.UI_IllustratedGuidePlotFragments,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/IllustratedGuide/WBP_IGuide_PlotFragments",
    UIScript = "UI.View.IllustratedGuide.IllustratedGuidePlotFragmentsView"
  },
  [ViewID.UI_LobbyGM] = {
    ID = ViewID.UI_LobbyGM,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/GM/Lobby/WBP_GMLobbyWindow",
    UIScript = "Rouge.UI.GM.Lobby.WBP_GMLobbyWindow"
  },
  [ViewID.UI_HttpRequestLoadingView] = {
    ID = ViewID.UI_HttpRequestLoadingView,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Common/WBP_HttpRequestLoadingView.WBP_HttpRequestLoadingView",
    UIScript = "UI/CommonView/WBP_HttpRequestLoadingView_C",
    DontHideOther = true
  },
  [ViewID.UI_LevelUp] = {
    ID = ViewID.UI_LevelUp,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Grage/WBP_Grage.WBP_Grage",
    UIScript = "UI/Lobby/Level/WBP_LevelView_C",
    DontHideOther = true
  },
  [ViewID.UI_PlayerInfoMain] = {
    ID = ViewID.UI_PlayerInfoMain,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/PlayerMainInfo/WBP_PlayerInfoMainView.WBP_PlayerInfoMainView",
    UIScript = "UI/View/PlayerInfoMain/PlayerInfoMainView"
  },
  [ViewID.UI_PlayerInfo] = {
    ID = ViewID.UI_PlayerInfo,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/PlayerMainInfo/PlayerInfo/WBP_PlayerInfoView.WBP_PlayerInfoView",
    UIScript = "UI/View/PlayerInfoMain/PlayerInfo/PlayerInfoView"
  },
  [ViewID.UI_History] = {
    ID = ViewID.UI_History,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/PlayerMainInfo/History/WBP_BattleHistoryView.WBP_BattleHistoryView",
    UIScript = "UI/View/PlayerInfoMain/History/BattleHistoryView"
  },
  [ViewID.UI_Chip] = {
    ID = ViewID.UI_Chip,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Chip/WBP_ChipView.WBP_ChipView",
    UIScript = "UI/View/Chip/ChipView"
  },
  [ViewID.UI_ProficiencySpecialAwardDetailPanel] = {
    ID = ViewID.UI_ProficiencySpecialAwardDetailPanel,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Proficiency/WBP_ProfySpecialAwardDetailPanel.WBP_ProfySpecialAwardDetailPanel",
    UIScript = "UI/View/Proficiency/WBP_ProfySpecialAwardDetailPanel_C"
  },
  [ViewID.UI_BattleModeCommonTips] = {
    ID = ViewID.UI_BattleModeCommonTips,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/HUD/BattleModeStage/WBP_BattleModeCommonTips.WBP_BattleModeCommonTips",
    UIScript = "UI/View/HUD/BattleModeStage/BattleModeCommonTipsView"
  },
  [ViewID.UI_DevelopMain] = {
    ID = ViewID.UI_DevelopMain,
    Layer = UILayer.Menu,
    UIBP = "/Game/Rouge/UI/Develop/WBP_DevelopMainView.WBP_DevelopMainView",
    UIScript = "UI/View/Develop/DevelopMainView"
  },
  [ViewID.UI_BattleModeCommonTask] = {
    ID = ViewID.UI_BattleModeCommonTask,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/HUD/BattleModeStage/WBP_BattleModeCommonTask.WBP_BattleModeCommonTask",
    UIScript = "UI/View/HUD/BattleModeStage/BattleModeCommonTaskView"
  },
  [ViewID.UI_ProficiencyLegendSynopsis] = {
    ID = ViewID.UI_ProficiencyLegendSynopsis,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Proficiency/WBP_ProficiencyLegendSynopsis.WBP_ProficiencyLegendSynopsis",
    UIScript = "UI/View/Proficiency/WBP_ProficiencyLegendSynopsis"
  },
  [ViewID.UI_ProficiencySynopsisDetailPanel] = {
    ID = ViewID.UI_ProficiencySynopsisDetailPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Proficiency/WBP_ProficiencySynopsisDetailPanel.WBP_ProficiencySynopsisDetailPanel",
    UIScript = "Rouge/UI/Proficiency/WBP_ProficiencySynopsisDetailPanel_C"
  },
  [ViewID.UI_ReportView] = {
    ID = ViewID.UI_ReportView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Report/WBP_Report.WBP_Report",
    UIScript = "Rouge/UI/Report/ReportView"
  },
  [ViewID.UI_LoginRewards] = {
    ID = ViewID.UI_LoginRewards,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/LoginRewards/WBP_LoginRewards.WBP_LoginRewards",
    UIScript = "Rouge/UI/LoginRewards/LoginRewardsView"
  },
  [ViewID.UI_LoginRewardActivity] = {
    ID = ViewID.UI_LoginRewardActivity,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/LoginRewards/WBP_LoginRewardActivity.WBP_LoginRewardActivity",
    UIScript = "Rouge/UI/LoginRewards/LoginRewardActivityView"
  },
  [ViewID.UI_ChipSlotUnlockView] = {
    ID = ViewID.UI_ChipSlotUnlockView,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/ChipSlotUnlock/WBP_ChipSlotUnlock.WBP_ChipSlotUnlock",
    UIScript = "Rouge/UI/ChipSlotUnlock/ChipSlotUnlockView"
  },
  [ViewID.UI_ChipSeasonSlotUnlockView] = {
    ID = ViewID.UI_ChipSeasonSlotUnlockView,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/ChipSlotUnlock/WBP_ChipSeasonSlotUnlockView.WBP_ChipSeasonSlotUnlockView",
    UIScript = "Rouge/UI/ChipSlotUnlock/ChipSeasonSlotUnlockView"
  },
  [ViewID.UI_ModeSelectionUnlockPanel] = {
    ID = ViewID.UI_ModeSelectionUnlockPanel,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Lobby/ModeSelection/WBP_ModeSelectionUnlockPanel",
    UIScript = "Rouge/UI/Lobby/ModeSelection/WBP_ModeSelectionUnlockPanel"
  },
  [ViewID.UI_GameSettingsMain] = {
    ID = ViewID.UI_GameSettingsMain,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/GameSettings/WBP_GameSettingsMain",
    UIScript = "Rouge/UI/GameSettings/WBP_GameSettingsMain_C",
    CameraLobbyRow = "UI_GameSettingsMain"
  },
  [ViewID.UI_MatchingPanel] = {
    ID = ViewID.UI_MatchingPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/3DLobby/WBP_MatchingPanel",
    UIScript = "Rouge/UI/3DLobby/WBP_MatchingPanel_C"
  },
  [ViewID.UI_PandoraRootPanel] = {
    ID = ViewID.UI_PandoraRootPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Pandora/WBP_PandoraRootPanel",
    UIScript = "Rouge/UI/Pandora/WBP_PandoraRootPanel",
    SupportBack = true
  },
  [ViewID.UI_SeasonAbilityPanel] = {
    ID = ViewID.UI_SeasonAbilityPanel,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Lobby/SeasonAbility/WBP_SeasonAbilityPanel",
    UIScript = "Rouge.UI.Lobby.SeasonAbility.WBP_SeasonAbilityPanel",
    CameraLobbyRow = "UI_SeasonAbilityPanel"
  },
  [ViewID.UI_RecruitMainView] = {
    ID = ViewID.UI_RecruitMainView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Recruit/WBP_RecruitMainView",
    UIScript = "Rouge/UI/View/Recruit/RecruitMainView",
    CameraLobbyRow = "UI_RecruitMainView"
  },
  [ViewID.UI_ClimbTower] = {
    ID = ViewID.UI_ClimbTower,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/ClimbTower/WBP_ClimbTower",
    UIScript = "UI/View/ClimbTower/ClimbTowerView"
  },
  [ViewID.UI_DailyRewards] = {
    ID = ViewID.UI_DailyRewards,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/ClimbTower/WBP_DailyRewardsView",
    UIScript = "UI/View/ClimbTower/DailyRewardsView"
  },
  [ViewID.UI_ChangeSchemeNamePanel] = {
    ID = ViewID.UI_ChangeSchemeNamePanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/SeasonAbility/WBP_ChangeSchemeNamePanel",
    UIScript = "Rouge.UI.Lobby.SeasonAbility.WBP_ChangeSchemeNamePanel"
  },
  [ViewID.UI_UnlockSchemePanel] = {
    ID = ViewID.UI_UnlockSchemePanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/SeasonAbility/WBP_UnlockSchemePanel",
    UIScript = "Rouge.UI.Lobby.SeasonAbility.WBP_UnlockSchemePanel"
  },
  [ViewID.UI_ExchangeAbilityPointPanel] = {
    ID = ViewID.UI_ExchangeAbilityPointPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/SeasonAbility/WBP_ExchangeAbilityPointPanel",
    UIScript = "Rouge.UI.Lobby.SeasonAbility.WBP_ExchangeAbilityPointPanel"
  },
  [ViewID.UI_ResetSeasonAbilityPanel] = {
    ID = ViewID.UI_ResetSeasonAbilityPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/SeasonAbility/WBP_ResetSeasonAbilityPanel",
    UIScript = "Rouge.UI.Lobby.SeasonAbility.WBP_ResetSeasonAbilityPanel"
  },
  [ViewID.UI_SpecialAbilityActivatedPanel] = {
    ID = ViewID.UI_SpecialAbilityActivatedPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/SeasonAbility/WBP_SpecialAbilityActivatedPanel",
    UIScript = "Rouge.UI.Lobby.SeasonAbility.WBP_SpecialAbilityActivatedPanel"
  },
  [ViewID.UI_AutoExchangeAbilityPointPanel] = {
    ID = ViewID.UI_AutoExchangeAbilityPointPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/SeasonAbility/WBP_AutoExchangeAbilityPointPanel",
    UIScript = "Rouge.UI.Lobby.SeasonAbility.WBP_AutoExchangeAbilityPointPanel"
  },
  [ViewID.UI_ViewSetChangeHeroTip] = {
    ID = ViewID.UI_ViewSetChangeHeroTip,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Common/ViewSet/WBP_ViewSetChangeHeroTip",
    UIScript = "Rouge.UI.Common.ViewSet.ViewSetChangeHeroTip"
  },
  [ViewID.UI_ActivityPanel] = {
    ID = ViewID.UI_ActivityPanel,
    Layer = UILayer.Menu,
    UIBP = "/Game/Rouge/UI/Lobby/WBP_ActivityPanel",
    UIScript = "Rouge.UI.Lobby.WBP_ActivityPanel"
  },
  [ViewID.UI_BattlePassMainView] = {
    ID = ViewID.UI_BattlePassMainView,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/BattlePass/WBP_BattlePassMainView",
    UIScript = "Rouge.UI.View.BattlePass.BattlePassMainView"
  },
  [ViewID.UI_BattlePassSubView] = {
    ID = ViewID.UI_BattlePassSubView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/BattlePass/WBP_BattlePassSubView",
    UIScript = "Rouge.UI.View.BattlePass.BattlePassSubView"
  },
  [ViewID.UI_BattlePassUnLockView] = {
    ID = ViewID.UI_BattlePassUnLockView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/BattlePass/WBP_BattlePassUnLockView",
    UIScript = "Rouge.UI.View.BattlePass.BattlePassUnLockView"
  },
  [ViewID.UI_ActivityRuleDesc] = {
    ID = ViewID.UI_ActivityRuleDesc,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/Activity/WBP_ActivityRuleDesc",
    UIScript = "Rouge.UI.Lobby.Activity.WBP_ActivityRuleDesc"
  },
  [ViewID.UI_RuleTask] = {
    ID = ViewID.UI_RuleTask,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Lobby/Activity/RuleTask/WBP_RuleTaskPanel",
    UIScript = "Rouge.UI.Lobby.Activity.RuleTask.WBP_RuleTaskPanel"
  },
  [ViewID.UI_RuleTaskDetailPanel] = {
    ID = ViewID.UI_RuleTaskDetailPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/Activity/RuleTask/WBP_RuleTaskDetailPanel",
    UIScript = "Rouge.UI.Lobby.Activity.RuleTask.WBP_RuleTaskDetailPanel"
  },
  [ViewID.UI_RuleTaskCreditExchangePanel] = {
    ID = ViewID.UI_RuleTaskCreditExchangePanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/Activity/RuleTask/WBP_RuleTaskCreditExchangePanel",
    UIScript = "Rouge.UI.Lobby.Activity.RuleTask.WBP_RuleTaskCreditExchangePanel"
  },
  [ViewID.UI_CustomerServiceView] = {
    ID = ViewID.UI_CustomerServiceView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/CustomerService/WBP_CustomerServiceView",
    UIScript = "UI/View/CustomerService/WBP_CustomerServiceView_C",
    CameraLobbyRow = "UI_CustomerServiceView"
  },
  [ViewID.UI_Puzzle] = {
    ID = ViewID.UI_Puzzle,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Puzzle/WBP_PuzzleView",
    UIScript = "Rouge.UI.Lobby.Puzzle.WBP_PuzzleView"
  },
  [ViewID.UI_PuzzleDevelopMain] = {
    ID = ViewID.UI_PuzzleDevelopMain,
    Layer = UILayer.Menu,
    UIBP = "/Game/Rouge/UI/Lobby/Puzzle/Develop/WBP_PuzzleDevelopMainView",
    UIScript = "Rouge.UI.Lobby.Puzzle.Develop.WBP_PuzzleDevelopMainView"
  },
  [ViewID.UI_PuzzleDevelop] = {
    ID = ViewID.UI_PuzzleDevelop,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Puzzle/Develop/WBP_PuzzleDevelopView",
    UIScript = "Rouge.UI.Lobby.Puzzle.Develop.WBP_PuzzleDevelopView"
  },
  [ViewID.UI_PuzzleDecompose] = {
    ID = ViewID.UI_PuzzleDecompose,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Puzzle/Develop/WBP_PuzzleDecomposeView",
    UIScript = "Rouge.UI.Lobby.Puzzle.Develop.WBP_PuzzleDecomposeView"
  },
  [ViewID.UI_PuzzleUpgradeSuccess] = {
    ID = ViewID.UI_PuzzleUpgradeSuccess,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Lobby/Puzzle/Develop/WBP_UpgradeSuccessView",
    UIScript = "Rouge.UI.Lobby.Puzzle.Develop.WBP_UpgradeSuccessView"
  },
  [ViewID.UI_PandoraActivityPanel] = {
    ID = ViewID.UI_PandoraActivityPanel,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Lobby/Activity/Pandora/WBP_PandoraActivityPanel_Content",
    UIScript = "Rouge.UI.Lobby.Activity.Pandora.WBP_PandoraActivityPanel"
  },
  [ViewID.UI_PandoraActivityPanel_Menu] = {
    ID = ViewID.UI_PandoraActivityPanel_Menu,
    Layer = UILayer.Menu,
    UIBP = "/Game/Rouge/UI/Lobby/Activity/Pandora/WBP_PandoraActivityPanel_Menu",
    UIScript = "Rouge.UI.Lobby.Activity.Pandora.WBP_PandoraActivityPanel"
  },
  [ViewID.UI_PandoraActivityPanel_Popup] = {
    ID = ViewID.UI_PandoraActivityPanel_Popup,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/Activity/Pandora/WBP_PandoraActivityPanel_Popup",
    UIScript = "Rouge.UI.Lobby.Activity.Pandora.WBP_PandoraActivityPanel"
  },
  [ViewID.UI_SpecificLobbyUnlockShow] = {
    ID = ViewID.UI_SpecificLobbyUnlockShow,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/IllustratedSpecificUnlock/WBP_IGuide_SpecificLobbyUnlockShow.WBP_IGuide_SpecificLobbyUnlockShow",
    UIScript = "Rouge.UI.View.IllustratedSpecificUnlock.WBP_IGuide_SpecificLobbyUnlockShow"
  },
  [ViewID.UI_WebBrowserView] = {
    ID = ViewID.UI_WebBrowserView,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/WebBrowser/WBP_WebBrowserView",
    UIScript = "UI/View/WebBrowser/WBP_WebBrowserView_C",
    SupportBack = true
  },
  [ViewID.UI_BossRush] = {
    ID = ViewID.UI_BossRush,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/BossRush/WBP_BossRushSelectionPanel",
    UIScript = "Rouge/UI/Lobby/ModeSelection/WBP_BossRushSelectionPanel_C.lua"
  },
  [ViewID.UI_GemUpgrade] = {
    ID = ViewID.UI_GemUpgrade,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Gem/WBP_GemUpgradeView",
    UIScript = "Rouge.UI.Lobby.Gem.WBP_GemUpgradeView"
  },
  [ViewID.UI_GemDecompose] = {
    ID = ViewID.UI_GemDecompose,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Gem/WBP_GemDecomposeView",
    UIScript = "Rouge.UI.Lobby.Gem.WBP_GemDecomposeView"
  },
  [ViewID.UI_TopupCurrencyPanel] = {
    ID = ViewID.UI_TopupCurrencyPanel,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/Topup/Currency/WBP_TopupCurrencyPanel",
    UIScript = "Rouge.UI.Mall.Topup.Currency.WBP_TopupCurrencyPanel",
    SwitchID = "mall"
  },
  [ViewID.UI_ExchangePanel] = {
    ID = ViewID.UI_ExchangePanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Mall/WBP_RGExchangePanel",
    UIScript = "Rouge.UI.Mall.WBP_RGExchangePanel"
  },
  [ViewID.UI_SeasonMode_Pop] = {
    ID = ViewID.UI_SeasonMode_Pop,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Season/WBP_SeasonMode_Pop",
    UIScript = "/Game/Rouge/UI/Season/WBP_SeasonMode_Pop.lua"
  },
  [ViewID.UI_SeasonMode] = {
    ID = ViewID.UI_SeasonMode,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Season/WBP_SeasonMode",
    UIScript = "/Game/Rouge/UI/Season/WBP_SeasonMode.lua"
  },
  [ViewID.UI_MonthCardPanel] = {
    ID = ViewID.UI_MonthCardPanel,
    Layer = UILayer.Game,
    UIBP = "/Game/Rouge/UI/Mall/MonthCard/WBP_MonthCardPanel",
    UIScript = "Rouge.UI.Mall.MonthCard.WBP_MonthCardPanel",
    SwitchID = "mall"
  },
  [ViewID.UI_SurvivalPanel] = {
    ID = ViewID.UI_SurvivalPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/ModeSelection/WBP_SurvivalPanel",
    UIScript = "Rouge/UI/View/Survival/SurvivalPanel.lua"
  },
  [ViewID.UI_ClimbTowerRank] = {
    ID = ViewID.UI_ClimbTowerRank,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/ClimbTower/Rank/WBP_ClimbTower_Rank",
    UIScript = "Rouge/UI/View/ClimbTowerRank/ClimbTowerRankView.lua"
  },
  [ViewID.UI_PuzzleRefactor] = {
    ID = ViewID.UI_PuzzleRefactor,
    Layer = UILayer.Window,
    UIBP = "/Game/Rouge/UI/Lobby/Puzzle/Develop/WBP_PuzzleRefactorView",
    UIScript = "Rouge.UI.Lobby.Puzzle.Develop.WBP_PuzzleRefactorView"
  },
  [ViewID.UI_InitialRoleSelection] = {
    ID = ViewID.UI_InitialRoleSelection,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/InitialRoleSelection/WBP_InitialRoleSelectionPanel",
    UIScript = "Rouge.UI.InitialRoleSelection.WBP_InitialRoleSelectionPanel",
    ShowActorListTagName = {
      "InitialRoleSelection"
    },
    HideActorListTagName = {"LobbyMain"}
  },
  [ViewID.UI_InitialRoleSelectionMask] = {
    ID = ViewID.UI_InitialRoleSelectionMask,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/InitialRoleSelection/WBP_InitialRoleSelectionMask",
    UIScript = "Rouge.UI.InitialRoleSelection.WBP_InitialRoleSelectionMask"
  },
  [ViewID.UI_MovieLevelSequence] = {
    ID = ViewID.UI_MovieLevelSequence,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/MovieLevelSequence/WBP_MovieLevelSequence",
    UIScript = "Rouge/UI/View/LevelSequence/WBP_MovieLevelSequence.lua"
  },
  [ViewID.UI_LobbyEscMenuPanel] = {
    ID = ViewID.UI_LobbyEscMenuPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/WBP_LobbyEscMenuPanel",
    UIScript = "Rouge/UI/Lobby/WBP_LobbyEscMenuPanel.lua"
  },
  [ViewID.UI_ProfyUpgradeAnimPanel] = {
    ID = ViewID.UI_ProfyUpgradeAnimPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Proficiency/WBP_ProfyUpgradeAnimPanel.WBP_ProfyUpgradeAnimPanel",
    UIScript = "Rouge.UI.Proficiency.WBP_ProfyUpgradeAnimPanel",
    DontHideOther = true
  },
  [ViewID.UI_MidasPayPanel] = {
    ID = ViewID.UI_MidasPayPanel,
    Layer = UILayer.HighWindow,
    UIBP = "/Game/Rouge/UI/Lobby/WBP_MidasPayPanel.WBP_MidasPayPanel",
    UIScript = "Rouge.UI.Lobby.WBP_MidasPayPanel",
    DontHideOther = true
  },
  [ViewID.UI_DrawCardRule] = {
    ID = ViewID.UI_DrawCardRule,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/DrawCard/WBP_DrawCardRuleView",
    UIScript = "UI/View/Lobby/DrawCard/DrawCardRuleView"
  },
  [ViewID.UI_Marquee] = {
    ID = ViewID.UI_Marquee,
    Layer = UILayer.Modal,
    UIBP = "/Game/Rouge/UI/Marquee/WBP_Marquee",
    UIScript = "UI/View/Marquee/WBP_Marquee",
    DontHideOther = true
  }
}
_G.UIDef = UIDef
