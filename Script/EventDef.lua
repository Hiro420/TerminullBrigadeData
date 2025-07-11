local EventDef = {
  WSMessage = {
    ConnectWSSuccess = "wsConnSucc",
    KickOut = "kickOut",
    ConnectBattleServer = "connectBattleServer",
    ResourceIncrease = "ResourceIncrease",
    ResourceDecrease = "ResourceDecrease",
    ResourceUpdate = "ResourceUpdate",
    EnterLobby = "enterLobby",
    TeamUpdate = "wsTeamUpdate",
    TeamKickOut = "wsTeamKickOut",
    PlayStartGameAnimation = "wsStartGame",
    ChatMsg = "chatMsg",
    SystemMsg = "systemMsg",
    PersonalMsg = "personalMsg",
    DeletePersonalMsg = "deletePersonalMsg",
    ConnectLobbyServer = "connectLobbyServer",
    CancelPrepare = "wsCancelPrepare",
    StopMatch = "wsStopMatch",
    LeaveTeam = "wsSomeOneLeaveTeam",
    PickHeroDone = "wsPickHeroDone",
    AllocateBattleServerFail = "wsAllocateBattleServerFail",
    InviteJoinTeam = "wsInviteJoinTeam",
    ApplyJoinTeam = "wsApplyJoinTeam",
    RefuseJoinFriendTeam = "wsRefuseJoinFriendTeam",
    RefuseFriendJoinTeam = "wsRefuseFriendJoinTeam",
    AgreeJoinTeam = "wsAgreeJoinTeam",
    ChangeTeamCaptain = "wsChangeTeamCaptain",
    NewMail = "wsNewMail",
    CheckMail = "checkmail",
    KickByBan = "KickByBan",
    RefreshMail = "wsRefreshMail",
    TaskUpdate = "task_update",
    GlobalAnnouncement = "GlobalAnnouncement",
    SocialAskAgree = "SocialAskArgee",
    SocialAskReject = "SocialAskReject",
    SocialAskAdd = "SocialAskAdd",
    SocialRemove = "SocialRemove",
    ApplyJoinRecruitTeam = "wsApplyJoinRecruitTeam",
    SystemSwitch = "switch",
    banVoice = "banVoice",
    pushNewChip = "pushNewChip",
    wsDeleteChip = "wsDeleteChip",
    systemUnlock = "systemUnlock",
    worldChatChannel = "worldChatChannel",
    GlobalMarquee = "GlobalMarquee",
    HeroesExpired = "wsHeroesExpired"
  },
  Global = {
    OnApplicationCrash = "OnApplicationCrash",
    OnViewportResized = "OnViewportResized"
  },
  ViewAction = {
    ViewOnShow = "ViewOnShow",
    ViewOnHide = "ViewOnHide",
    ViewProrityQueueEmpty = "ViewProrityQueueEmpty"
  },
  Login = {
    GetServerList = "GetServerList",
    OnLoginProtocolSuccess = "OnLoginProtocolSuccess",
    OnLoginProtocolFail = "OnLoginProtocolFail",
    GetServerListFailed = "GetServerListFailed",
    DataResetWhenLogin = "DataResetWhenLogin",
    OnGetUserID = "OnGetUserID"
  },
  Chat = {
    ReciveNewMsg = "ReciveNewMsg",
    SendChatMsgSucc = "SendChatMsgSucc",
    SendChatMsgCallback = "SendChatMsgCallback",
    SendChatMsgFailed = "SendChatMsgFailed",
    QueryNameListSucc = "QueryNameListSucc"
  },
  Lobby = {
    UpdateTicketStatus = "UpdateTicketStatus",
    OnInviteDialogue = "OnInviteDialogue",
    OnGetPropTip = "OnGetPropTip",
    RoleItemClicked = "ChangeRoleItemClicked",
    EnterLobbyPanel = "RestoreLobbyCharacterMesh",
    LobbyPanelChanged = "LobbyActivePanelChanged",
    LobbyActivePanelClose = "LobbyActivePanelClose",
    LobbyActivePanelOpen = "LobbyActivePanelOpen",
    RoleSkillTip = "ShowSkillTips",
    RoleFetterSkillTip = "ShowFetterSkillTips",
    LobbyHeroClicked = "ActorClicked",
    LobbyHeroCursor = "ActorCursorOver",
    FetterHeroItemLeftClicked = "OnFetterHeroItemLeftMouseDown",
    LobbyUpdateRoomInfo = "UpdateRoomInfo",
    LobbyUpdateRoomPlayerInfo = "UpdateRoomPlayerInfo",
    OnChangeCanDirectChangedStatus = "OnChangeCanDirectChangedStatus",
    UpdateBasicInfo = "UpdateBasicInfo",
    FetterHeroInfoUpdate = "FetterHeroInfoUpdate",
    EquipFetterHeroByPosSuccess = "EquipFetterHeroByPosSuccess",
    FetterHeroDragCompare = "FetterHeroDragCompare",
    FetterHeroBeginOrEndDrag = "FetterHeroBeginOrEndDrag",
    UpdateMyHeroInfo = "UpdateMyHeroInfo",
    HeroStarUpgradeItemClicked = "HeroStarUpgradeItemClicked",
    UpdateResourceInfo = "UpdateResourceInfo",
    UpdateResourceInfoByType = "UpdateResourceInfoByType",
    GetRolesGameFloorData = "GetRolesGameFloorData",
    UpdateCommonTalentInfo = "UpdateCommonTalentInfo",
    UpdateCommonTalentPresetCost = "UpdateCommonTalentPresetCost",
    HeroTalentIconItemClicked = "HeroTalentIconItemClicked",
    UpdateHeroTalentInfo = "UpdateHeroTalentInfo",
    PlayInAnimation = "PlayInAnimation",
    PlayOutAnimation = "PlayOutAnimation",
    StartMatchAnimation = "OnRoomCountDown",
    ExpChanged = "ExpChanged",
    DBGAddExp = "DBGAddExp",
    FetterSlotItemClicked = "FetterSlotItemClicked",
    FetterSlotStatusUpdate = "FetterSlotStatusUpdate",
    ExitRoom = "ExitRoom",
    QuickChangeHeroPanelHide = "QuickChangeHeroPanelHide",
    UpdateRoomMembersInfo = "UpdateRoomMembersInfo",
    EquippedWeaponInfoChanged = "EquippedWeaponInfoChanged",
    WeaponSlotSelected = "WeaponSlotSelected",
    WeaponListChanged = "WeaponListChanged",
    WeaponItemSelected = "WeaponItemSelected",
    QuitRoomSuccess = "QuitRoom",
    UpdateMyTeamInfo = "UpdateMyTeamInfo",
    OnModeInfoItemClicked = "OnModeInfoItemClicked",
    OnGameplaySelectionBGClicked = "OnGameplaySelectionBGClicked",
    AccessoryListChanged = "AccessoryListChanged",
    LobbyWeaponItemHoverStatusChanged = "LobbyWeaponItemHoverStatusChanged",
    UILobbyShowMatchingPanel = "UILobbyShowMatchingPanel",
    OnAnimationCountTimeEnd = "OnAnimationCountTimeEnd",
    OnJoinGameFail = "OnJoinGameFail",
    OnStartGameCountTime = "OnStartGameCountTime",
    LobbyWeaponSlotHoverStatusChanged = "LobbyWeaponSlotHoverStatusChanged",
    OnTeamStateChanged = "OnTeamStateChanged",
    OnModelAreaHoveredChanged = "OnModelAreaHovered",
    OnModelAreaClickedChanged = "OnModelAreaClickedChanged",
    OnMultiTeamMemberOmissionButtonClicked = "OnMultiTeamMemberOmissionButtonClicked",
    OnBeginnerGuidanceSystemTipShow = "OnBeginnerGuidanceSystemTipShow",
    ChangeLobbyMenuPanelVis = "ChangeLobbyMenuPanelVis",
    OnLobbyLabelSelected = "OnLobbyLabelSelected",
    OnBasicInfoUpdated = "OnBasicInfoUpdated",
    OnUpdateGameFloorInfo = "OnUpdateGameFloorInfo",
    OnUpdateAllowMultiPlayerTeam = "OnUpdateAllowMultiPlayerTeam",
    OnUpdateLoginRewards = "OnUpdateLoginRewards",
    OnSetNickFailed = "OnSetNickFailed",
    OnSetNickSuccess = "OnSetNickSuccess",
    OnCameraTargetChangedToLobbyAnimCamera = "OnCameraTargetChangedToLobbyAnimCamera",
    OnChangeDefaultNeedMatchTeammate = "OnChangeDefaultNeedMatchTeammate",
    UpdateTopupProductInfo = "UpdateTopupProductInfo",
    UpdateRegionPing = "UpdateRegionPing",
    OnIigwRequestPrivilege = "OnIigwRequestPrivilege",
    UpdateLimitedResource = "UpdateLimitedResource",
    PredeductTicketSucc = "EventDef.Lobby.PredeductTicketSucc",
    OpenMonthCardTip = "OpenMonthCardTip"
  },
  Battle = {
    ElementChanged = "ElementChanged",
    ShopWeaponChanged = "ChangeShopChooseWeapon",
    ShopWeaponSlotClicked = "ShopEquipSlotClicked",
    RemoveInscriptionItem = "RemoveInscriptionItem",
    OnPickupWeaponSelected = "OnPickupWeaponSelected",
    OnControlledPawnChanged = "OnControlledPawnChanged",
    OnHealthChanged = "OnHealthChanged",
    OnBuffAdded = "OnBuffAdded",
    OnBuffChanged = "OnBuffChanged"
  },
  GamePokey = {
    OnAccessorySlotHovered = "OnAccessorySlotHovered",
    OnAccessorySlotUnHovered = "OnAccessorySlotUnHovered",
    OnAccessorySlotClicked = "OnAccessorySlotClicked",
    OnInscriptionHovered = "OnInscriptionHovered",
    OnInscriptionUnHovered = "OnInscriptionUnHovered",
    OnWeaponMeshPressed = "OnWeaponMeshPressed",
    OnWeaponMeshReleased = "OnWeaponMeshReleased"
  },
  MainPanel = {
    OnEnter = "OnEnter",
    OnExit = "OnExit",
    MainPanelChanged = "MainActivePanelChanged",
    MainPanelScrollPickUpPress = "MainPanelScrollPickUpPress",
    MainPanelScrollPickUpReleased = "MainPanelScrollPickUpReleased"
  },
  LobbyPanel = {
    OnHide = "OnHide",
    OnShow = "OnShow",
    SpecialFuncPanelVisCahange = "SpecialFuncPanelVisCahange"
  },
  LobbyRankPanel = {
    OnEnterDetailedData = "OnEnterDetailedData",
    OnExitDetailedData = "OnExitDetailedData"
  },
  Rank = {
    OnModeChange = "OnModeChange",
    OnRequestServerDataSuccess = "OnRequestServerDataSuccess",
    OnRequestServerElementDataSuccess = "OnRequestServerElementDataSuccess",
    OnRefreshMVP = "OnRefreshMVP",
    OnItemClicked = "OnItemClicked"
  },
  ClimbTowerView = {
    OnDailyRewardChange = "OnDailyRewardChange",
    OnDebuffChange = "OnDebuffChange",
    OnLayerChange = "OnLayerChange",
    OnHeroPanelChange = "OnHeroPanelChange",
    OnApplication = "OnApplication",
    OnPassRewardStatusChange = "OnPassRewardStatusChange",
    OnPassTeamDataChange = "OnPassTeamDataChange",
    OnPassRewardFloorChange = "OnPassRewardFloorChange"
  },
  GameRecordPanel = {
    RoleInfoItemChanged = "RoleInfoItemChanged",
    TypeButtonChanged = "TypeButtonChanged"
  },
  GunDisplayPanel = {
    OnInscriptionHovered = "OnInscriptionHovered",
    OnInscriptionUnHovered = "OnInscriptionUnHovered",
    OnAccessorySlotHovered = "OnAccessorySlotHovered",
    OnAccessorySlotUnHovered = "OnAccessorySlotUnHovered",
    OnGunSlotClicked = "OnGunSlotClicked"
  },
  GameSettings = {
    OnTitleButtonClicked = "OnTitleButtonClicked",
    OnEditItemClicked = "OnEditItemClicked",
    OnUrlItemClicked = "OnUrlItemClicked",
    OnCustomKeySelected = "OnCustomKeySelected",
    OnCustomKeyItemSelected = "OnCustomKeyItemSelected",
    OnKeyChanged = "OnKeyChanged",
    OnItemHovered = "OnItemHovered",
    OnItemSelected = "OnItemSelected",
    OnTempGameSettingListChanged = "OnTempGameSettingListChanged",
    OnGameSettingItemValueBeChanged = "OnGameSettingItemValueBeChanged",
    OnMonitorValueChanged = "OnMonitorValueChanged",
    OnSettingsSaved = "OnSettingsSaved",
    OnPreviousKeyPressed = "OnPreviousKeyPressed",
    OnNextKeyPressed = "OnNextKeyPressed",
    OnItemNavigation = "OnItemNavigation",
    OnGamepadCustomKeyNavitionUp = "OnGamepadCustomKeyNavitionUp",
    OnFocusGamePadCustomKeyItem = "OnFocusGamePadCustomKeyItem"
  },
  GenericModify = {
    OnAddModify = "OnAddModify",
    OnRemoveModify = "OnRemoveModify",
    OnUpgradeModify = "OnUpgradeModify",
    OnFinishInteract = "OnGenericModifyFinishInteract",
    OnCancelInteract = "OnGenericModifyCancelInteract",
    OnRefreshGenericModify = "OnRefreshGenericModify",
    OnRefreshFinishedGenericModify = "OnRefreshFinishedGenericModify",
    OnChoosePanelHideByFinishInteract = "OnChoosePanelHideByFinishInteract"
  },
  SpecificModify = {
    OnAddModify = "OnAddModify",
    OnRemoveModify = "OnRemoveModify",
    OnRefreshCountChange = "OnRefreshCountChange"
  },
  SurvivalModify = {
    OnAddModify = "OnSurvivalAddModify",
    OnUpgradeModify = "OnSurvivalUpgradeModify",
    OnSpecificModify = "OnSurvivalSpecificModify",
    OnModifyCountChange = "OnModifyCountChange",
    OnSpecificModifyRefreshCount = "OnSpecificModifyRefreshCount"
  },
  NPCAward = {
    NPCAwardNumAdd = "NPCAwardNumAdd",
    NPCAwardNumInteractFinish = "NPCAwardNumInteractFinish"
  },
  Inscription = {
    OnTriggerCD = "OnTriggerCD"
  },
  Shop = {
    OnShowOrHideShopItemTip = "OnShowOrHideShopItemTip",
    OnPlayHeartModifyAnim = "OnPlayHeartModifyAnim",
    OnNavigationChange = "OnNavigationChange"
  },
  Mall = {
    OnGetRechargeInfo = "OnGetRechargeInfo",
    OnGetExteriorInfo = "OnGetExteriorInfo",
    OnGetBundleInfo = "OnGetBundleInfo",
    OnGetPropsInfo = "OnGetPropsInfo"
  },
  Avatar = {
    OnAvatarItemClicked = "OnAvatarItemClicked",
    OnAvatarChooseItemClicked = "OnAvatarChooseItemClicked",
    OnPreAvatarInfoChanged = "OnPreAvatarInfoChanged",
    OnAvatarInfoChanged = "OnAvatarInfoChanged"
  },
  HeroSelect = {
    OnPickHeroStateChanged = "OnPickHeroStateChanged",
    OnWeaponItemHoveredStateChanged = "OnWeaponItemHoveredStateChanged"
  },
  Weapon = {
    WeaponSkillTip = "WeaponSkillTip"
  },
  PickTipList = {
    OnAddPickTipList = "OnAddPickTipList",
    HidePickTipItem = "HidePickTipItem"
  },
  Interact = {
    OnOptimalTargetChanged = "OnOptimalTargetChanged"
  },
  ContactPerson = {
    OnContactPersonItemClicked = "OnContactPersonItemClicked",
    OnRecentListPlayerInfoUpdate = "OnRecentListPlayerInfoChanged",
    OnFriendListUpdate = "OnFriendListUpdate",
    OnFriendApplyListUpdate = "OnFriendApplyListUpdate",
    OnPersonalChatInfoUpdate = "OnPersonalChatInfoUpdate",
    OnRemovePersonalChatInfo = "OnRemovePersonalChatInfo",
    UpdatePersonalChatPanelVis = "UpdatePersonalChatPanelVis",
    OnBlackListUpdate = "OnBlackListUpdate",
    OnRemarkNameSuccess = "OnRemarkNameSuccess",
    OnPlatformFriendInfoListUpdate = "OnPlatformFriendInfoListUpdate"
  },
  RoleMain = {
    OnTotalAttributeTipsVisChanged = "OnTotalAttributeTipsVisChanged"
  },
  ModeSelection = {
    OnChangeModeSelectionItem = "OnChangeModeSelectionItem",
    OnChangeModeDifficultLevelItem = "OnChangeModeDifficultLevelItem",
    OnChangeThumbnailModeItem = "OnChangeThumbnailModeItem",
    OnChangeModeSelectionItem_BossRush = "OnChangeModeSelectionItem_BossRush",
    OnChangeModeDifficultLevelItem_BossRush = "OnChangeModeDifficultLevelItem_BossRush"
  },
  HUD = {
    PlayScreenEdgeEffect = "PlayScreenEdgeEffect",
    PlayScreenEdgeShieldEffect = "PlayScreenEdgeShieldEffect",
    UpdateScreenEdgeShieldMat = "UpdateScreenEdgeShieldMat",
    ChangeTaskTip = "ChangeTaskTip",
    UpdateSkillPanelPosXByWeaponVSkill = "UpdateSkillPanelPosXByWeaponVSkill",
    InitHUDActor = "InitHUDActor"
  },
  Skin = {
    OnEquipHeroSkin = "OnEquipHeroSkin",
    OnEquipWeaponSkin = "OnEquipWeaponSkin",
    OnGetHeroSkinList = "OnGetHeroSkinList",
    OnGetWeaponSkinList = "OnGetWeaponSkinList",
    OnWeaponSkinUpdate = "OnWeaponSkinUpdate",
    OnHeroSkinUpdate = "OnHeroSkinUpdate",
    OnBuyHeroSKin = "OnBuyHeroSKin",
    OnSetSkinEffectState = "OnSetSkinEffectState",
    OnEffectStateChange = "OnEffectStateChange"
  },
  IllustratedGuide = {
    AttributeModifyHoveredTip = "AttributeModifyHoveredTip",
    OnGenericModifyGodItemClicked = "OnGenericModifyGodItemClicked",
    OnGenericModifyGodItemHover = "OnGenericModifyGodItemHover",
    OnGenericModifyItemSelectionChanged = "OnGenericModifyItemSelectionChanged",
    OnFocusModify = "OnFocusModify",
    OnShowSkillTips = "OnShowSkillTips",
    OnSpecificModifyItemClicked = "OnSpecificModifyItemClicked",
    OnUpdateAllSpecificModifyInfo = "OnUpdateAllSpecificModifyInfo",
    OnPlotFragmentsWorldChange = "OnPlotFragmentsWorldChange",
    OnPlotFragmentsItemChanged = "OnPlotFragmentsItemChanged",
    OnCustomNavigation_God = "OnCustomNavigation_God"
  },
  Heirloom = {
    OnHeirloomInfoChanged = "OnHeirloomInfoChanged",
    OnChangeHeirloomLevelSelected = "OnChangeHeirloomLevelSelected",
    OnAfterChangeHeirloomLevelSelected = "OnAfterChangeHeirloomLevelSelected",
    OnHeirloomSelectedItemChanged = "OnHeirloomSelectedItemChanged",
    OnHeirloomUpgradeSuccess = "OnHeirloomUpgradeSuccess",
    ChangeAppearanceViewToggleGroupSelect = "ChangeAppearanceViewToggleGroupSelect",
    MultiLayerCameraBeginPlay = "MultiLayerCameraBeginPlay",
    MultiLayerCameraSkinChanged = "MultiLayerCameraSkinChanged",
    OnHeirloomHeroSkinActionItemSelected = "OnHeirloomHeroSkinActionItemSelected"
  },
  DrawCard = {
    OnChangeDrawCardPoolSelected = "OnChangeDrawCardPoolSelected",
    OnChangeDrawCardAppearanceActor = "OnChangeDrawCardAppearanceActor",
    OnGetDrawCardResult = "OnGetDrawCardResult",
    OnGetCardPoolList = "OnGetCardPoolList",
    OnDrawCardSequencePlay = "OnDrawCardSequencePlay",
    OnDrawCardSequenceFinished = "OnDrawCardSequenceFinished",
    OnDrawCardShowFinished = "OnDrawCardShowFinished"
  },
  Mail = {
    OnUpdateAllMailListInfo = "OnUpdateAllMailListInfo",
    OnUpdateMailReadStatus = "OnUpdateMailReadStatus",
    OnUpdateMailReceiveAttachmentStatus = "OnUpdateMailReceiveAttachmentStatus",
    OnChangeMailItemSelected = "OnChangeMailItemSelected",
    OnMailContentInfoChanged = "OnMailContentInfoChanged"
  },
  MainTask = {
    OnMainTaskRefres = "OnMainTaskRefres",
    OnMainTaskFinish = "OnMainTaskFinish",
    OnMainTaskUnLock = "OnMainTaskUnLock",
    OnTaskGroupAwardReceived = "OnTaskGroupAwardReceived",
    OnReceiveAward = "OnReceiveAward",
    OnMainTaskChange = "OnMainTaskChange"
  },
  Task = {
    UpdateCustomTask = "UpdateCustomTask"
  },
  BeginnerGuide = {
    OnBeginnerGuideFinished = "OnBeginnerGuideFinished",
    OnBeginnerGuideBookTypeChanged = "OnBeginnerGuideBookTypeChanged",
    OnBeginnerGuideBookGuideChanged = "OnBeginnerGuideBookGuideChanged",
    OnGetFinishedGuideList = "OnGetFinishedGuideList",
    OnLobbyShow = "OnLobbyShow",
    OnLobbyShowAndChecked = "OnLobbyShowAndChecked",
    OnRoleMainShow = "OnRoleMainShow",
    OnTargetWidgetChange = "OnBeginnerTargetWidgetChange",
    OnBeginnerMissionFinished = "OnBeginnerMissionFinished",
    OnMainTaskDialogueShow = "OnMainTaskDialogueShow",
    OnTalentPanelShow = "OnTalentPanelShow",
    OnBanditUnLock = "OnBanditUnLock",
    OnRingedCityUnLockDifficulty2 = "OnRingedCityUnLockDifficulty2",
    OnMainTaskDetailViewShow = "OnMainTaskDetailViewShow",
    OnClickedLobbyStartMatchButton = "OnClickedLobbyStartMatchButton",
    OnMainTaskRewardUnlock = "OnMainTaskRewardUnlock",
    OnInviteDialogueShow = "OnInviteDialogueShow",
    OnOwningResStone = "OnOwningResStone",
    OnWeaponSubViewShow = "OnWeaponSubViewShow",
    OnOwningSecondWeapon = "OnOwningSecondWeapon",
    OnClickWeaponBagItem = "OnClickWeaponBagItem",
    OnDifficultLevelPanelShow = "OnDifficultLevelPanelShow",
    OnSingleModeItemClicked = "OnSingleModeItemClicked",
    OnProficiencyUnlock = "OnProficiencyUnlock",
    OnProficiencyViewShow = "OnProficiencyViewShow",
    OnGetPropsViewHide = "OnGetPropsViewHide",
    OnProfySpecialAwardDetailPanelHide = "OnProfySpecialAwardDetailPanelHide",
    OnOwningChip = "OnOwningChip",
    OnChipViewShow = "OnChipViewShow",
    OnOwningPuzzle = "OnOwningPuzzle",
    OnInitialHeroSelected = "OnInitialHeroSelected",
    OnClimbTowerUnLock = "OnClimbTowerUnLock",
    OnSettlementInComeViewShow = "OnSettlementInComeViewShow",
    OnClickOpenSnap = "OnClickOpenSnap",
    OnSurvivalUnLock = "OnSurvivalUnLock",
    OnBossRushUnLock = "OnBossRushUnLock"
  },
  Pandora = {
    pandoraOnCloseRootPanel = "pandoraOnCloseRootPanel",
    pandoraShowEntrance = "pandoraShowEntrance",
    panameraADPositionReady = "panameraADPositionReady",
    pandoraOpenUrl = "pandoraOpenUrl",
    pandoraGoSystem = "pandoraGoSystem",
    pandoraNotifyAppClose = "pandoraNotifyAppClose",
    NotifyPandorShowEntrance = "NotifyPandorShowEntrance",
    NotifyPandoraADPositionReady = "NotifyPandoraADPositionReady",
    pandoraShowRedpoint = "pandoraShowRedpoint",
    pandoraGoPandora = "pandoraGoPandora",
    pandoraShowItemTip = "pandoraShowItemTip",
    pandoraActCenterRedpoint = "pandoraActCenterRedpoint",
    pandoraActCenterReady = "pandoraActCenterReady",
    pandoraWidgetDestroy = "pandoraWidgetDestroy",
    pandoraWidgetCreated = "pandoraWidgetCreated",
    pandoraShowTextTip = "pandoraShowTextTip",
    pandoraGetUserInfo = "pandoraGetUserInfo",
    pandoraActTabReady = "pandoraActTabReady",
    pandoraCloseApp = "pandoraCloseApp",
    pandoraCopyMessageToClipboard = "pandoraCopyMessageToClipboard",
    pandoraMidasPay = "pandoraMidasPay",
    pandoraGetProductInfo = "pandoraGetProductInfo"
  },
  Settlement = {
    ShowSettleTxt = "ShowSettleTxt",
    HideSettleTxt = "HideSettleTxt",
    OnSettlementFail = "OnSettlementFail",
    OnClickSettlementTalent = "OnClickSettlementTalent",
    OnSettlementSuccess = "OnSettlementSuccess"
  },
  Achievement = {
    GetAchievementInfo = "GetAchievementInfo",
    GetAchievementInfoFailed = "GetAchievementInfoFailed",
    SetDisplayBadges = "SetDisplayBadges",
    SetDisplayBadgesFailed = "SetDisplayBadgesFailed"
  },
  BossTips = {
    BossTipsMovie = "BossTipsMovie",
    BossTipsUI = "BossTipsUI",
    BossBerserk = "BossBerserk"
  },
  RedDot = {
    OnRedDotStateChanged = "OnRedDotStateChanged",
    OnPlayOnceAnimation = "OnPlayOnceAnimation"
  },
  BattleLagacy = {
    OnSelectBattleLagacy = "OnSelectBattleLagacy",
    OnGetBattleLagacyList = "OnGetBattleLagacyList",
    OnGetCurrBattleLagacy = "OnGetCurrBattleLagacy",
    OnGetBattleLagacyListFailed = "OnGetBattleLagacyListFailed",
    OnGetCurrBattleLagacyFailed = "OnGetCurrBattleLagacyFailed",
    OnTriggerBattleLagacyList = "OnTriggerBattleLagacyList",
    OnTriggerCurrBattleLagacy = "OnTriggerCurrBattleLagacy",
    OnBattleLagacyInscriptionReminderClose = "OnBattleLagacyInscriptionReminderClose",
    OnBattleLagacyModifyClose = "OnBattleLagacyModifyClose",
    OnGetCurrBattleLagacyLogin = "OnGetCurrBattleLagacyLogin",
    OnSelectBattleLagacyFailed = "OnSelectBattleLagacyFailed",
    OnGetCurrBattleLagacyOverMaxRequestNum = "OnGetCurrBattleLagacyOverMaxRequestNum",
    OnGetBattleLagacyListOverMaxRequestNum = "OnGetBattleLagacyListOverMaxRequestNum"
  },
  PlayerInfo = {
    QueryPlayerInfoSucc = "QueryPlayerInfoSucc",
    GetBattleStatisticSucc = "GetBattleStatistic",
    GetPortraitIds = "GetPortraitIds",
    GetBannerIds = "GetBannerIds",
    GetBattleHistory = "GetBattleHistory",
    GetDisplayHeroInfo = "GetDisplayHeroInfo"
  },
  Proficiency = {
    OnProficiencyAwardItemHoverStatusChanged = "OnProficiencyAwardItemHoverStatusChanged",
    OnProficiencySynopsisDetailPanelVisChanged = "OnProficiencySynopsisDetailPanelVisChanged",
    OnGetHeroProfyStoryRewardSuccess = "OnGetHeroProfyStoryRewardSuccess"
  },
  Chip = {
    ChipsBagUpdate = "ChipBagUpdate",
    GetHeroChipBag = "GetHeroChipBag",
    CancelOrDiscard = "CancelOrDiscard",
    DiscardChip = "DiscardChip",
    EquipChip = "EquipChip",
    LockChip = "LockChip",
    MigrateChip = "MigrateChip",
    UnEquipChip = "UnEquipChip",
    UpgradeChip = "UpgradeChip",
    UpdateChipEquipSlot = "UpdateChipEquipSlot",
    GetChipUpgradeMat = "GetChipUpgradeMat",
    UpdateEquipedChipDetail = "UpdateEquipedChipDetail",
    AddChip = "AddChip",
    PickUpChip = "PickUpChip"
  },
  Develop = {
    UpdateViewSetVisible = "UpdateViewSetVisible"
  },
  RewardIncrease = {
    RewardIncreaseSucc = "RewardIncreaseSucc",
    ReceiveRewardIncreaseSucc = "ReceiveRewardIncreaseSucc",
    ReceiveRewardIncreaseFailed = "ReceiveRewardIncreaseFailed"
  },
  SeasonAbility = {
    OnSeasonAbilityInfoUpdated = "OnSeasonAbilityInfoUpdated",
    OnHeroesSeasonAbilityPointNumUpdated = "OnHeroesSeasonAbilityPointNumUpdated",
    OnSpecialAbilityInfoUpdated = "OnSpecialAbilityInfoUpdated",
    OnUpdateSeasonAbilityTipVis = "OnUpdateSeasonAbilityTipVis",
    OnUpdateSpecialAbilityPanelVis = "OnUpdateSpecialAbilityPanelVis",
    OnChangeEquipScheme = "OnChangeEquipScheme",
    OnAddSpecialAbilityPoint = "OnAddSpecialAbilityPoint",
    OnAddAbilityPoint = "OnAddAbilityPoint",
    OnResetSeasonAbilitySuccess = "OnResetSeasonAbilitySuccess"
  },
  Recruit = {
    StartRecruit = "StartRecruit",
    StopRecruit = "StopRecruit",
    GetRecruitTeamList = "GetRecruitTeamList",
    GetRecruitApplyList = "GetRecruitApplyList",
    ApplyRecruitTeam = "ApplyRecruitTeam",
    AgreeRecruitApply = "AgreeRecruitApply",
    RefuseRecruitApply = "RefuseRecruitApply",
    GetRolesGameFloorData = "RolesGameFloorData"
  },
  Communication = {
    OnGetCommList = "OnGetCommList",
    OnRouletteAreaSelectChanged = "OnRouletteAreaSelectChanged",
    OnRouletteAreaHoverChanged = "OnRouletteAreaHoverChanged",
    OnRouletteAreaUsed = "OnRouletteAreaUsed",
    OnCommSelectChanged = "OnCommSelectChanged",
    OnRouletteStartDrag = "OnRouletteStartDrag",
    OnRouletteEndDrag = "OnRouletteEndDrag"
  },
  Activity = {
    OnChangeActivityItemSelected = "OnChangeActivityItemSelected",
    OnPandoraActivityRefresh = "OnPandoraActivityRefresh",
    OnPandoraRefreshActivitiesTab = "OnPandoraRefreshActivitiesTab",
    OnPandoraActivityTabSelected = "OnPandoraActivityTabSelected"
  },
  BattlePass = {
    GetBattlePassData = "GetBattlePassData",
    ReceiveAllReward = "ReceiveAllReward",
    ReceiveReward = "ReceiveReward",
    UnlockUltra = "UnlockUltra",
    OnUpgrade = "OnUpgrade"
  },
  RuleTask = {
    OnShowRuleTaskDetailPanel = "OnShowRuleTaskDetailPanel",
    ChangeRuleTaskItemTipVis = "ChangeRuleTaskItemTipVis",
    OnMainRewardStateChanged = "OnMainRewardStateChanged"
  },
  Puzzle = {
    OnPuzzleboardDrop = "OnPuzzleboardDrop",
    OnPuzzleboardDragEnter = "OnPuzzleboardDragEnter",
    RefreshPuzzleboardItemStatus = "RefreshPuzzleboardStatus",
    OnPuzzleboardDragCancelled = "OnPuzzleboardDragCancelled",
    OnRotatePuzzleDragCoordinate = "OnRotatePuzzleDragCoordinate",
    OnUpdatePuzzleItemHoverStatus = "OnUpdatePuzzleItemHoverStatus",
    OnUpdatePuzzlePackageInfo = "OnUpdatePuzzlePackageInfo",
    OnUpdatePuzzleDetailInfo = "OnUpdatePuzzleDetailInfo",
    OnUpdatePuzzleSlotUnlockInfo = "OnUpdatePuzzleSlotUnlockInfo",
    UpdatePuzzleListStyle = "UpdatePuzzleListStyle",
    OnPuzzleItemSelected = "OnPuzzleItemSelected",
    UpdatePuzzleFilterSelectStatus = "UpdatePuzzleFilterSelectStatus",
    OnEquipPuzzleSuccess = "OnEquipPuzzleSuccess",
    OnUnEquipPuzzleSuccess = "OnUnEquipPuzzleSuccess",
    OnUpdatePuzzleWorldHoverStatus = "OnUpdatePuzzleWorldHoverStatus",
    OnChangePuzzleUpgradeLevelSelected = "OnChangePuzzleUpgradeLevelSelected",
    OnDecomposePuzzleSuccess = "OnDecomposePuzzleSuccess",
    OnPuzzlePickup = "OnPuzzlePickup",
    OnPuzzleDrag = "OnPuzzleDrag",
    OnPuzzleRefactorMaterialSelected = "OnPuzzleRefactorMaterialSelected",
    OnWashPuzzleSlotAmountSuccess = "OnWashPuzzleSlotAmountSuccess"
  },
  TeamDamage = {
    OnUpdateHoverStatus = "OnUpdateHoverStatus"
  },
  Gift = {
    OnOptionalGiftItemSelect = "OnOptionalGiftItemSelect"
  },
  SystemUnlock = {
    SystemUnlockInit = "SystemUnlockInit",
    SystemUnlockUpdate = "SystemUnlockUpdate"
  },
  Gem = {
    OnUpdateGemPackageInfo = "OnUpdateGemPackageInfo",
    OnGemDecomposeSuccess = "OnGemDecomposeSuccess",
    OnGemUpgradeSuccess = "OnGemUpgradeSuccess",
    OnGemEquipSuccess = "OnGemEquipSuccess",
    OnGemUnEquipSuccess = "OnGemUnEquipSuccess",
    OnGemDrag = "OnGemDrag",
    OnGemDragCancel = "OnGemDragCancel",
    OnRefreshGemStatus = "OnRefreshGemStatus",
    OnUpdateGemItemHoverStatus = "OnUpdateGemItemHoverStatus",
    OnGemItemSelected = "OnGemItemSelected"
  },
  SaveGrowthSnap = {
    OnRefreshSnap = "OnRefreshSnap",
    OnRefreshSelect = "OnRefreshSelect",
    OnRefreshAutoSave = "OnRefreshAutoSave"
  },
  Season = {
    SeasonModeChanged = "SeasonModeChanged"
  },
  MonthCard = {
    OnUpdateRolesMonthCardInfo = "OnUpdateRolesMonthCardInfo",
    OnUpdateRolesRivilegeInfo = "OnUpdateRolesRivilegeInfo"
  },
  InitialRoleSelection = {
    OnSelectRoleSucc = "OnSelectRoleSucc"
  },
  CustomerService = {CheatShow = "CheatShow"},
  KoreaCompliance = {ShowAgePic = "ShowAgePic"}
}
_G.EventDef = _G.EventDef or EventDef
return EventDef
