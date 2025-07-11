local setmetatable = setmetatable
local pairs = pairs
local ipairs = ipairs
local tinsert = table.insert
local SimpleClass = function()
  local class = {}
  class.__index = class
  function class.New(...)
    local ctor = class.ctor
    local o = ctor and ctor(...) or {}
    setmetatable(o, class)
    return o
  end
  return class
end
local get_map_size = function(m)
  local n = 0
  for _ in pairs(m) do
    n = n + 1
  end
  return n
end
TableEnums = {
  ENUMGameMode = {
    NORMAL = 1001,
    UNBOUNDEDNESS = 1002,
    TOWERClIMBING = 1003,
    BEGINERGUIDANCE = 2001,
    TEACHINGGUIDANCE = 2002,
    SEASONNORMAL = 3000,
    BOSSRUSH = 3001,
    SURVIVAL = 3002
  },
  ENUMGameModeCostResType = {ONLYCAPTAIN = 1, TEAMMEMBER = 2},
  ENUMMonthCardRightsType = {
    OTHER = 0,
    NUMBERINCREASE = 1,
    RESOURCEREWARD = 2,
    PERCENTINCREASE = 3
  },
  ENUNMonthCardRightsReceiveType = {
    OTHER = 0,
    EVERYDAY = 1,
    EVERYWEEK = 2,
    NEXTSEASON = 3
  },
  ENUNPrivilegeType = {MONTHCARD = 1, NORMALPRIVILEGE = 2},
  ENUMResourceType = {
    CURRENCY = 1,
    PROP = 2,
    HERO = 3,
    RandomGift = 4,
    Weapon = 5,
    Accessory = 6,
    PresetWeapon = 7,
    ResStone = 8,
    WeaponSkin = 9,
    HeroSkin = 10,
    DigitalCollection = 11,
    Badge = 12,
    AchievementPoint = 13,
    FamilyTreasure = 14,
    HeroAppearance = 15,
    HeroCommuniRoulette = 16,
    Gift = 17,
    InfiniteProp = 18,
    Portrait = 19,
    Banner = 20,
    Chip = 21,
    Exp = 22,
    ChipUpgradeMaterial = 23,
    BattlePassExp = 24,
    PuzzleUpgradeMaterial = 25,
    Puzzle = 26,
    Gem = 27,
    OptionalGift = 28,
    PaymentCurrency = 29,
    MonthCard = 30,
    BattlePassToken = 31,
    TimeLimitGift = 32,
    HeroProfyExp = 33,
    Privilege = 34
  },
  ENUMPropType = {Common = 1},
  ENUMResourceRare = {
    EIR_Normal = 0,
    EIR_Excellent = 1,
    EIR_Rare = 2,
    EIR_Epic = 3,
    EIR_Legend = 4,
    EIR_Immortal = 5,
    EIR_Max = 6
  },
  ENUMAppearanceType = {
    BACKGROUND = 1,
    NORMALPOS = 2,
    WINPOS = 3
  },
  ENUMCommuRoulleteType = {
    PAINT = 1,
    ACTION = 2,
    VOICE = 3
  },
  ENUMResStoneType = {NORMAL = 1, SEASON = 2},
  ENUMInfinitePropType = {POTENTIALKEY = 1, ProficiencyEntries = 2},
  ENUMChipPropType = {NORMAL = 1, SEASON = 2},
  ENUMResourceResetType = {NONE = 0, SEASON = 1},
  ENUMResourceEffProType = {
    NONE = 0,
    Orange = 1,
    Red = 2
  },
  ENUMSkillType = {
    Fetter = 1,
    Light = 2,
    Q = 3,
    E = 4,
    Alt = 5,
    Passive = 6,
    Weapon = 7
  },
  ENUMHeroType = {Hero = 1, Monster = 2},
  ENUMSlotStatus = {
    Close = 0,
    CanOpen = 1,
    Open = 2
  },
  ENUMTalentType = {
    Common = 1,
    Hero = 2,
    Accumulative = 3
  },
  ENUMSafeguardTriggerType = {UNLIMITED = 0, ONCE = 1},
  ENUMQuality = {
    WHITE = 0,
    GREEN = 1,
    BLUE = 2,
    PURPLE = 3,
    ORANGE = 4,
    RED = 5
  },
  ENUMBuyLimitType = {
    NONE = 0,
    FOREVER = 1,
    SEASON = 2,
    MONTH = 3,
    WEEKLY = 4,
    DAY = 5
  },
  ENUMCurrencyType = {CNY = 0, USD = 1},
  ENUNRegion = {CN = 0, INTL = 1},
  ENUMAccType = {RequiredAccessory = 1, Accessory = 2},
  ENUMSlotType = {
    BaseWeapon = 1,
    Butt = 2,
    Grip = 3,
    Magazine = 4,
    Muzzle = 5,
    Parts = 6,
    Pendant = 7,
    Sight = 8,
    Coating = 9
  },
  ENUMChannel = {
    Lobby = 0,
    Team = 1,
    Friend = 2,
    Recurit = 3,
    System = 4
  },
  ENUMChatContent = {
    Sensitive = 1,
    ContentTooLong = 2,
    FrequencyTooFastForLobby = 3,
    FrequencyTooFastForOther = 4,
    Offline = 5,
    Silence = 6
  },
  ENUMSystemMsgParamType = {
    Text = 1,
    RoleID = 2,
    ResourceID = 3,
    RoleName = 4,
    GachaPond = 5,
    TimeRemain = 6
  },
  ENUMSystemShow = {
    Lobby = 1,
    Battle = 2,
    All = 3
  },
  ENUMResetType = {
    DISABLE = 0,
    DAY = 1,
    WEEK = 2,
    MONTH = 3
  },
  ENUMEventParamCmpOPT = {
    PARAM_EQ = 0,
    PARAM_GE = 1,
    PARAM_LE = 2
  },
  ENUMTowerLobbyAnomaly = {UNIQUE_HERO = 1},
  ENUMAbilityType = {
    None = 0,
    Weapon = 1,
    Skill = 2,
    Survival = 3
  },
  ENUMDifficultyType = {Normal = 0, Hard = 1},
  ENUMDisplayType = {
    TEXT_ONLY = 0,
    TEXT_IMAGE = 1,
    SUPERDREAM = 2
  },
  ENUMAchieveType = {
    PERSONAL = 0,
    BATTLE = 1,
    EXPLORE = 2
  },
  ENUMAttr = {LIFE = 50, POWER = 51},
  Quality = {
    GREEN = 0,
    BLUE = 1,
    PURPLE = 2,
    ORANGE = 3
  },
  ENUMInscriptionType = {Normal = 1, Powerful = 2},
  ENUMSettleType = {
    DISABLE = 0,
    SEASON = 1,
    TIME = 2
  },
  ENUMTaskType = {WEEKLYTASK = 0, SEASONTASK = 1}
}
TableEnumsAlias = {
  ENUMGameMode = {
    NORMAL = "\229\184\184\232\167\132\229\159\186\231\161\128\230\168\161\229\188\143",
    UNBOUNDEDNESS = "\230\151\160\229\176\189\230\168\161\229\188\143",
    TOWERClIMBING = "\231\136\172\229\161\148\230\168\161\229\188\143",
    BEGINERGUIDANCE = "\230\150\176\230\137\139BD\230\168\161\229\188\143",
    TEACHINGGUIDANCE = "\230\150\176\230\137\139\230\149\153\229\173\166\230\168\161\229\188\143",
    SEASONNORMAL = "\232\181\155\229\173\163\229\159\186\231\161\128\230\168\161\229\188\143",
    BOSSRUSH = "Boss\230\140\145\230\136\152\230\168\161\229\188\143",
    SURVIVAL = "\229\185\184\229\173\152\232\128\133\230\168\161\229\188\143"
  },
  ENUMGameModeCostResType = {ONLYCAPTAIN = "\233\152\159\233\149\191", TEAMMEMBER = "\233\152\159\229\145\152"},
  ENUMMonthCardRightsType = {
    OTHER = "\229\133\182\228\187\150",
    NUMBERINCREASE = "\230\149\176\229\128\188\229\162\158\229\138\160",
    RESOURCEREWARD = "\232\181\132\230\186\144\229\165\150\229\138\177",
    PERCENTINCREASE = "\229\138\160\230\136\144\230\175\148\228\190\139"
  },
  ENUNMonthCardRightsReceiveType = {
    OTHER = "\229\133\182\228\187\150",
    EVERYDAY = "\230\175\143\229\164\169",
    EVERYWEEK = "\230\175\143\229\145\168",
    NEXTSEASON = "\228\184\139\232\181\155\229\173\163"
  },
  ENUNPrivilegeType = {
    MONTHCARD = "\230\156\136\229\141\161\230\157\131\231\155\138",
    NORMALPRIVILEGE = "\230\153\174\233\128\154\230\157\131\231\155\138"
  },
  ENUMResourceType = {
    CURRENCY = "\232\180\167\229\184\129",
    PROP = "\233\129\147\229\133\183",
    HERO = "\232\139\177\233\155\132\229\141\161",
    RandomGift = "\233\154\143\230\156\186\231\164\188\229\140\133",
    Weapon = "\230\173\166\229\153\168",
    Accessory = "\233\133\141\228\187\182",
    PresetWeapon = "\233\162\132\232\174\190\230\173\166\229\153\168",
    ResStone = "\229\133\177\233\184\163\231\159\179",
    WeaponSkin = "\230\173\166\229\153\168\231\154\174\232\130\164",
    HeroSkin = "\232\139\177\233\155\132\231\154\174\232\130\164",
    DigitalCollection = "\231\167\152\229\174\157",
    Badge = "\229\190\189\231\171\160",
    AchievementPoint = "\230\136\144\229\176\177\231\130\185",
    FamilyTreasure = "\229\159\186\231\161\128\228\188\160\229\174\182\229\174\157",
    HeroAppearance = "\232\139\177\233\155\132\229\164\150\232\167\130",
    HeroCommuniRoulette = "\232\139\177\233\155\132\230\178\159\233\128\154\232\189\174\231\155\152",
    Gift = "\231\164\188\229\140\133",
    InfiniteProp = "\230\151\160\228\184\138\233\153\144\233\129\147\229\133\183",
    Portrait = "\229\164\180\229\131\143",
    Banner = "\230\168\170\229\185\133",
    Chip = "\232\138\175\231\137\135",
    Exp = "\231\187\143\233\170\140",
    ChipUpgradeMaterial = "\232\138\175\231\137\135\229\141\135\231\186\167\230\157\144\230\150\153",
    BattlePassExp = "\233\128\154\232\161\140\232\175\129\231\187\143\233\170\140",
    PuzzleUpgradeMaterial = "\230\139\188\229\155\190\229\141\135\231\186\167\230\157\144\230\150\153",
    Puzzle = "\230\139\188\229\155\190",
    Gem = "\229\174\157\231\159\179",
    OptionalGift = "\229\143\175\233\128\137\231\164\188\229\140\133",
    PaymentCurrency = "\228\187\152\232\180\185\232\180\167\229\184\129",
    MonthCard = "\230\156\136\229\141\161",
    BattlePassToken = "\233\128\154\232\161\140\232\175\129\228\187\164\231\137\140",
    TimeLimitGift = "\233\153\144\230\151\182\232\181\132\230\186\144\231\164\188\229\140\133",
    HeroProfyExp = "\232\139\177\233\155\132\231\134\159\231\187\131\229\186\166\231\187\143\233\170\140",
    Privilege = "\230\157\131\231\155\138"
  },
  ENUMPropType = {
    Common = "\230\153\174\233\128\154\233\129\147\229\133\183"
  },
  ENUMResourceRare = {
    EIR_Normal = "\230\153\174\233\128\154",
    EIR_Excellent = "\231\178\190\232\137\175",
    EIR_Rare = "\231\168\128\230\156\137",
    EIR_Epic = "\229\143\178\232\175\151",
    EIR_Legend = "\228\188\160\229\165\135",
    EIR_Immortal = "\228\184\141\230\156\189",
    EIR_Max = "\230\156\128\229\164\167"
  },
  ENUMAppearanceType = {
    BACKGROUND = "\232\131\140\230\153\175\230\157\191",
    NORMALPOS = "\229\184\184\232\167\132\229\167\191\230\128\129",
    WINPOS = "\232\131\156\229\136\169\229\167\191\230\128\129"
  },
  ENUMCommuRoulleteType = {
    PAINT = "\229\150\183\230\188\134",
    ACTION = "\229\138\168\228\189\156",
    VOICE = "\232\175\173\233\159\179"
  },
  ENUMResStoneType = {
    NORMAL = "\230\153\174\233\128\154\229\133\177\233\184\163\231\159\179",
    SEASON = "\232\181\155\229\173\163\229\133\177\233\184\163\231\159\179"
  },
  ENUMInfinitePropType = {
    POTENTIALKEY = "\230\189\156\232\131\189\229\175\134\233\146\165",
    ProficiencyEntries = "\231\134\159\231\187\131\229\186\166\232\175\141\230\157\161"
  },
  ENUMChipPropType = {
    NORMAL = "\229\184\184\232\167\132\232\138\175\231\137\135",
    SEASON = "\232\181\155\229\173\163\232\138\175\231\137\135"
  },
  ENUMResourceResetType = {
    NONE = "\228\184\141\233\135\141\231\189\174",
    SEASON = "\232\181\155\229\173\163\233\135\141\231\189\174"
  },
  ENUMResourceEffProType = {
    NONE = "\230\151\160\230\149\136\230\158\156",
    Orange = "\230\169\153\232\137\178\230\149\136\230\158\156",
    Red = "\231\186\162\232\137\178\230\149\136\230\158\156"
  },
  ENUMSkillType = {
    Fetter = "\231\190\129\231\187\138",
    Light = "\229\133\137\231\142\175",
    Q = "Q\230\138\128\232\131\189",
    E = "E\230\138\128\232\131\189",
    Alt = "Alt\230\138\128\232\131\189",
    Passive = "\232\162\171\229\138\168\230\138\128\232\131\189",
    Weapon = "\230\173\166\229\153\168\230\138\128\232\131\189"
  },
  ENUMHeroType = {Hero = "\232\139\177\233\155\132", Monster = "\230\128\170\231\137\169"},
  ENUMSlotStatus = {
    Close = "\229\133\179\233\151\173",
    CanOpen = "\229\143\175\232\167\163\233\148\129",
    Open = "\229\183\178\229\188\128\229\144\175"
  },
  ENUMTalentType = {
    Common = "\233\128\154\231\148\168",
    Hero = "\232\139\177\233\155\132",
    Accumulative = "\231\180\175\232\174\161\230\182\136\232\128\151"
  },
  ENUMSafeguardTriggerType = {
    UNLIMITED = "\230\151\160\233\153\144\229\136\182",
    ONCE = "\228\187\133\233\153\144\228\184\128\230\172\161"
  },
  ENUMQuality = {
    WHITE = "\231\153\189",
    GREEN = "\231\187\191",
    BLUE = "\232\147\157",
    PURPLE = "\231\180\171",
    ORANGE = "\230\169\153",
    RED = "\231\186\162"
  },
  ENUMBuyLimitType = {
    NONE = "\228\184\141\233\153\144\232\180\173",
    FOREVER = "\230\176\184\228\185\133\233\153\144\232\180\173",
    SEASON = "\232\181\155\229\173\163\233\153\144\232\180\173",
    MONTH = "\230\156\172\230\156\136\233\153\144\232\180\173",
    WEEKLY = "\230\156\172\229\145\168\233\153\144\232\180\173",
    DAY = "\230\156\172\230\151\165\233\153\144\232\180\173"
  },
  ENUMCurrencyType = {CNY = "", USD = ""},
  ENUNRegion = {CN = "", INTL = ""},
  ENUMAccType = {
    RequiredAccessory = "\230\158\170\228\189\147",
    Accessory = "\229\133\182\228\187\150\233\133\141\228\187\182"
  },
  ENUMSlotType = {
    BaseWeapon = "\230\158\170\228\189\147",
    Butt = "\230\158\170\230\137\152",
    Grip = "\230\143\161\230\138\138",
    Magazine = "\229\188\185\229\140\163",
    Muzzle = "\230\158\170\229\143\163",
    Parts = "\230\158\170\232\186\171",
    Pendant = "\228\184\139\230\140\130",
    Sight = "\231\158\132\229\133\183",
    Coating = "\230\182\130\232\163\133"
  },
  ENUMChannel = {
    Lobby = "\229\164\167\229\142\133",
    Team = "\233\152\159\228\188\141",
    Friend = "\229\165\189\229\143\139",
    Recurit = "\230\139\155\229\139\159",
    System = "\231\179\187\231\187\159"
  },
  ENUMChatContent = {
    Sensitive = "\230\149\143\230\132\159\232\175\141",
    ContentTooLong = "\230\182\136\230\129\175\232\191\135\233\149\191",
    FrequencyTooFastForLobby = "\229\164\167\229\142\133\229\143\145\233\128\129\233\162\145\231\142\135\229\164\170\229\191\171",
    FrequencyTooFastForOther = "\233\152\159\228\188\141\229\143\145\233\128\129\233\162\145\231\142\135\229\164\170\229\191\171",
    Offline = "\229\175\185\230\150\185\231\166\187\231\186\191",
    Silence = "\233\157\153\233\187\152"
  },
  ENUMSystemMsgParamType = {
    Text = "\230\150\135\230\156\172",
    RoleID = "\231\142\169\229\174\182ID",
    ResourceID = "\232\181\132\230\186\144ID",
    RoleName = "\231\142\169\229\174\182\230\152\181\231\167\176",
    GachaPond = "\229\141\161\230\177\160ID",
    TimeRemain = "\231\180\175\232\174\161\230\151\182\233\149\191"
  },
  ENUMSystemShow = {
    Lobby = "\229\164\167\229\142\133\230\152\190\231\164\186",
    Battle = "\229\177\128\229\134\133\230\152\190\231\164\186",
    All = "\229\177\128\229\134\133\229\164\150\229\133\168\230\152\190\231\164\186"
  },
  ENUMResetType = {
    DISABLE = "\228\184\141\233\135\141\231\189\174",
    DAY = "\230\175\143\230\151\165",
    WEEK = "\230\175\143\229\145\168",
    MONTH = "\230\175\143\230\156\136"
  },
  ENUMEventParamCmpOPT = {
    PARAM_EQ = "\231\173\137\228\186\142",
    PARAM_GE = "\229\164\167\228\186\142\231\173\137\228\186\142",
    PARAM_LE = "\229\176\143\228\186\142\231\173\137\228\186\142"
  },
  ENUMTowerLobbyAnomaly = {
    UNIQUE_HERO = "\232\139\177\233\155\132\228\184\141\231\155\184\229\144\140"
  },
  ENUMAbilityType = {
    None = "\230\151\160",
    Weapon = "\230\173\166\229\153\168",
    Skill = "\230\138\128\232\131\189",
    Survival = "\231\148\159\229\173\152"
  },
  ENUMDifficultyType = {Normal = "\230\153\174\233\128\154", Hard = "\229\155\176\233\154\190"},
  ENUMDisplayType = {
    TEXT_ONLY = "\231\186\175\230\150\135\230\156\172",
    TEXT_IMAGE = "\229\155\190\230\150\135",
    SUPERDREAM = "\232\182\133\230\162\166"
  },
  ENUMAchieveType = {
    PERSONAL = "\228\184\170\228\186\186",
    BATTLE = "\230\136\152\230\150\151",
    EXPLORE = "\230\142\162\231\180\162"
  },
  ENUMAttr = {LIFE = "\231\148\159\229\145\189", POWER = "\229\138\155\233\135\143"},
  Quality = {
    GREEN = "\231\187\191",
    BLUE = "\232\147\157",
    PURPLE = "\231\180\171",
    ORANGE = "\230\169\153"
  },
  ENUMInscriptionType = {Normal = "\230\153\174\233\128\154", Powerful = "\229\188\186\229\138\155"},
  ENUMSettleType = {
    DISABLE = "\228\184\141\231\187\147\231\174\151",
    SEASON = "\232\181\155\229\173\163",
    TIME = "\229\174\154\230\151\182"
  },
  ENUMTaskType = {
    WEEKLYTASK = "\229\145\168\229\184\184\228\187\187\229\138\161",
    SEASONTASK = "\232\181\155\229\173\163\228\187\187\229\138\161"
  }
}
TableNames = {
  TBPlayerLevel = "lobby_tbplayerlevel",
  TBSystemMail = "lobby_tbsystemmail",
  TBErrorCode = "lobby_tberrorcode",
  TBInscriptionMutex = "lobby_tbinscriptionmutex",
  TBGameFloorUnlock = "lobby_tbgamefloorunlock",
  TBRedDot = "reddot_tbreddot",
  TBGameMode = "lobby_tbgamemode",
  TBBanReason = "lobby_tbbanreason",
  TBSystemClickStatistics = "lobby_tbsystemclickstatistics",
  TBGetPropsReason = "lobby_tbgetpropsreason",
  TBConsts = "lobby_tbconsts",
  TBSystemUnlock = "lobby_tbsystemunlock",
  TBSystemUnlockEvents = "lobby_tbsystemunlockevents",
  TBGameModeTicket = "lobby_tbgamemodeticket",
  TBBattleServerList = "lobby_tbbattleserverlist",
  TBMonthCardRights = "lobby_tbmonthcardrights",
  TBRechargeValidCountry = "lobby_tbrechargevalidcountry",
  TBPlatformIcon = "lobby_tbplatformicon",
  TBNEtBarPrivilege = "lobby_tbnetbarprivilege",
  TBNEtBarPrivilegeDes = "lobby_tbnetbarprivilegedes",
  TBISOCountryCode = "lobby_tbisocountrycode",
  TBGeneral = "resource_tbgeneral",
  TBProp = "resource_tbprop",
  TBCurrency = "resource_tbcurrency",
  TBHero = "resource_tbhero",
  TBRandomGift = "resource_tbrandomgift",
  TBWeaponRes = "resource_tbweaponres",
  TBAccessoryRes = "resource_tbaccessoryres",
  TBPresetWeaponRes = "resource_tbpresetweaponres",
  TBCharacterSkin = "resource_tbcharacterskin",
  TBWeaponSkin = "resource_tbweaponskin",
  TBDigitalCollection = "resource_tbdigitalcollection",
  TBResFamilyTreasure = "resource_tbresfamilytreasure",
  TBResHeroAppearance = "resource_tbresheroappearance",
  TBResHeroCommuniRoulette = "resource_tbresherocommuniroulette",
  TBGift = "resource_tbgift",
  TBInfiniteProp = "resource_tbinfiniteprop",
  TBResAchievementBadge = "resource_tbresachievementbadge",
  TBPortrait = "resource_tbportrait",
  TBBanner = "resource_tbbanner",
  TBResChip = "resource_tbreschip",
  TBResourceExchange = "resource_tbresourceexchange",
  TBResourceChipUpgradeMaterial = "resource_tbresourcechipupgradematerial",
  TBResPuzzle = "resource_tbrespuzzle",
  TBResGem = "resource_tbresgem",
  TBOptionalGift = "resource_tboptionalgift",
  TBPaymentCurrency = "resource_tbpaymentcurrency",
  TBMonthCard = "resource_tbmonthcard",
  TBTimeLimitGift = "resource_tbtimelimitgift",
  TBHeroProfyExp = "resource_tbheroprofyexp",
  TBResPrivilege = "resource_tbresprivilege",
  TBSkillTag = "hero_tbskilltag",
  TBHeroMonster = "hero_tbheromonster",
  TBFetterSlot = "hero_tbfetterslot",
  TBHeroSkill = "hero_tbheroskill",
  TBHeroStar = "hero_tbherostar",
  TBTalent = "talent_tbtalent",
  TBProfyLevel = "hero_tbprofylevel",
  TBProfyGeneral = "hero_tbprofygeneral",
  TBFamilyTreasure = "hero_tbfamilytreasure",
  TBFamilyTreasureUpgrade = "hero_tbfamilytreasureupgrade",
  TBHeroSkinExchange = "hero_tbheroskinexchange",
  TBGachaPond = "mall_tbgachapond",
  TBGachaSafeguard = "mall_tbgachasafeguard",
  TBMall = "mall_tbmall",
  TBMallShelf = "mall_tbmallshelf",
  TBMallRecommendPage = "mall_tbmallrecommendpage",
  TBPaymentMall = "mall_tbpaymentmall",
  TBPaymentMallMallShelf = "mall_tbpaymentmallmallshelf",
  TBShelfSecondTab = "mall_tbshelfsecondtab",
  TBPaymentMallCurrency = "mall_tbpaymentmallcurrency",
  TBGachaReward = "mall_tbgachareward",
  TBWeapon = "weapon_tbweapon",
  TBAccessory = "weapon_tbaccessory",
  TBGuide = "guide_tbguide",
  TBGuideStep = "guide_tbguidestep",
  TBGuidebooktype = "guide_tbguidebooktype",
  TBChat = "chat_tbchat",
  TBChatContent = "chat_tbchatcontent",
  TBSystemMsg = "chat_tbsystemmsg",
  TBTaskGroupData = "task_tbtaskgroupdata",
  TBTaskData = "task_tbtaskdata",
  TBUnlockEventData = "task_tbunlockeventdata",
  TBTargetEventData = "task_tbtargeteventdata",
  TBClimbTowerFloor = "season_tbclimbtowerfloor",
  TBClimbTowerDebuff = "season_tbclimbtowerdebuff",
  TBClimbTowerLobbyAnomaly = "season_tbclimbtowerlobbyanomaly",
  TBClimbTowerDailyRewardBonusRate = "season_tbclimbtowerdailyrewardbonusrate",
  TBClimbTowerGlobalPassReward = "season_tbclimbtowerglobalpassreward",
  TBClimbTowerSlotUnlock = "season_tbclimbtowerslotunlock",
  TBHeroSeasonAbility = "season_tbheroseasonability",
  TBSeasonTalent = "season_tbseasontalent",
  TBSpecialAbility = "season_tbspecialability",
  TBSeasonAbilityPresentScheme = "season_tbseasonabilitypresentscheme",
  TBSeasonAbilityPointExchange = "season_tbseasonabilitypointexchange",
  TBSeasonGeneral = "season_tbseasongeneral",
  TBBossRush = "season_tbbossrush",
  TBSurvival = "season_tbsurvival",
  TBWorld = "story_tbworld",
  TBClue = "story_tbclue",
  TBFragment = "story_tbfragment",
  TBWorldIntelligence = "story_tbworldintelligence",
  TBAchievement = "achievement_tbachievement",
  TBAchievementPoint = "achievement_tbachievementpoint",
  TBPS5Achievement = "achievement_tbps5achievement",
  TBXBoxAchievement = "achievement_tbxboxachievement",
  TBMainStoryLine = "mainstoryline_tbmainstoryline",
  TBChipSubAttrInit = "chip_tbchipsubattrinit",
  TBChipSubAttrLvUp = "chip_tbchipsubattrlvup",
  TBChipInitInscription = "chip_tbchipinitinscription",
  TBChipLevelUp = "chip_tbchiplevelup",
  TBChipSlots = "chip_tbchipslots",
  TBMainAttrLvUp = "chip_tbmainattrlvup",
  TBBindHero = "chip_tbbindhero",
  TBPuzzleSubAttrInit = "puzzle_tbpuzzlesubattrinit",
  TBPuzzleSubAttrLvUp = "puzzle_tbpuzzlesubattrlvup",
  TBPuzzleInitInscription = "puzzle_tbpuzzleinitinscription",
  TBPuzzleLevelUp = "puzzle_tbpuzzlelevelup",
  TBPuzzleSlots = "puzzle_tbpuzzleslots",
  TBPuzzleMainAttrLvUp = "puzzle_tbpuzzlemainattrlvup",
  TBPuzzleBindHero = "puzzle_tbpuzzlebindhero",
  TBPuzzleWorld = "puzzle_tbpuzzleworld",
  TBPuzzleHero = "puzzle_tbpuzzlehero",
  TBPuzzleWashSlots = "puzzle_tbpuzzlewashslots",
  TBPuzzleSlotsWeight = "puzzle_tbpuzzleslotsweight",
  TBPuzzleShape = "puzzle_tbpuzzleshape",
  TBPuzzleInscriptionGroup = "puzzle_tbpuzzleinscriptiongroup",
  TBPuzzleGrade = "puzzle_tbpuzzlegrade",
  TBPuzzleAttrName = "puzzle_tbpuzzleattrname",
  TBPuzzleInscriptionName = "puzzle_tbpuzzleinscriptionname",
  TBPuzzleShapeName = "puzzle_tbpuzzleshapename",
  TBGemLevelUp = "gem_tbgemlevelup",
  TBGemLevelUpAttr = "gem_tbgemlevelupattr",
  TBSevenDayLogin = "activity_tbsevendaylogin",
  TBActivityGeneral = "activity_tbactivitygeneral",
  TBRuleTask = "activity_tbruletask",
  TBRuleInfo = "activity_tbruleinfo",
  TBPandoraInfo = "activity_tbpandorainfo",
  TBRankMode = "rank_tbrankmode",
  TBBattlePass = "battlepass_tbbattlepass",
  TBBattlePassReward = "battlepass_tbbattlepassreward",
  TBBattlePassRewardShow = "battlepass_tbbattlepassrewardshow",
  TBBattlePassTask = "battlepass_tbbattlepasstask",
  TBGenericModifyDialog = "gameplay_tbgenericmodifydialog",
  TBLobbyBatchCheat = "cheat_tblobbybatchcheat",
  TBBattleBatchCheat = "cheat_tbbattlebatchcheat"
}
local tables = {
  {
    name = "TBPlayerLevel",
    file = "lobby_tbplayerlevel",
    mode = "map",
    index = "Level",
    value_type = "lobby.OBJPlayerLevel"
  },
  {
    name = "TBSystemMail",
    file = "lobby_tbsystemmail",
    mode = "map",
    index = "Id",
    value_type = "lobby.OBJSystemMail"
  },
  {
    name = "TBErrorCode",
    file = "lobby_tberrorcode",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJErrorCode"
  },
  {
    name = "TBInscriptionMutex",
    file = "lobby_tbinscriptionmutex",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJInscriptionMutex"
  },
  {
    name = "TBGameFloorUnlock",
    file = "lobby_tbgamefloorunlock",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJGameFloorUnlock"
  },
  {
    name = "TBRedDot",
    file = "reddot_tbreddot",
    mode = "map",
    index = "Class",
    value_type = "reddot.OBJRedDot"
  },
  {
    name = "TBGameMode",
    file = "lobby_tbgamemode",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJGameMode"
  },
  {
    name = "TBBanReason",
    file = "lobby_tbbanreason",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJBanReason"
  },
  {
    name = "TBSystemClickStatistics",
    file = "lobby_tbsystemclickstatistics",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJSystemClickStatistics"
  },
  {
    name = "TBGetPropsReason",
    file = "lobby_tbgetpropsreason",
    mode = "map",
    index = "Reason",
    value_type = "lobby.OBJGetPropsReason"
  },
  {
    name = "TBConsts",
    file = "lobby_tbconsts",
    mode = "one",
    value_type = "lobby.OBJConsts"
  },
  {
    name = "TBSystemUnlock",
    file = "lobby_tbsystemunlock",
    mode = "map",
    index = "SystemID",
    value_type = "lobby.OBJSystemUnlock"
  },
  {
    name = "TBSystemUnlockEvents",
    file = "lobby_tbsystemunlockevents",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJSystemUnlockEvents"
  },
  {
    name = "TBGameModeTicket",
    file = "lobby_tbgamemodeticket",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJGameModeTicket"
  },
  {
    name = "TBBattleServerList",
    file = "lobby_tbbattleserverlist",
    mode = "map",
    index = "region",
    value_type = "lobby.OBJBattleServerList"
  },
  {
    name = "TBMonthCardRights",
    file = "lobby_tbmonthcardrights",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJMonthCardRights"
  },
  {
    name = "TBRechargeValidCountry",
    file = "lobby_tbrechargevalidcountry",
    mode = "map",
    index = "CountryCode",
    value_type = "lobby.OBJRechargeValidCountry"
  },
  {
    name = "TBPlatformIcon",
    file = "lobby_tbplatformicon",
    mode = "map",
    index = "PlatformName",
    value_type = "lobby.OBJPlatformIcon"
  },
  {
    name = "TBNEtBarPrivilege",
    file = "lobby_tbnetbarprivilege",
    mode = "map",
    index = "privilegeType",
    value_type = "lobby.OBJNetBarPrivilege"
  },
  {
    name = "TBNEtBarPrivilegeDes",
    file = "lobby_tbnetbarprivilegedes",
    mode = "map",
    index = "ID",
    value_type = "lobby.OBJNetBarPrivilegeDes"
  },
  {
    name = "TBISOCountryCode",
    file = "lobby_tbisocountrycode",
    mode = "map",
    index = "NumericCode",
    value_type = "lobby.OBJISOCountryCode"
  },
  {
    name = "TBGeneral",
    file = "resource_tbgeneral",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJGenaral"
  },
  {
    name = "TBProp",
    file = "resource_tbprop",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJProp"
  },
  {
    name = "TBCurrency",
    file = "resource_tbcurrency",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJCurrency"
  },
  {
    name = "TBHero",
    file = "resource_tbhero",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJHero"
  },
  {
    name = "TBRandomGift",
    file = "resource_tbrandomgift",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJRandomGift"
  },
  {
    name = "TBWeaponRes",
    file = "resource_tbweaponres",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJWeaponRes"
  },
  {
    name = "TBAccessoryRes",
    file = "resource_tbaccessoryres",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJAccessroyRes"
  },
  {
    name = "TBPresetWeaponRes",
    file = "resource_tbpresetweaponres",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJPresetWeaponRes"
  },
  {
    name = "TBCharacterSkin",
    file = "resource_tbcharacterskin",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJCharacterSkin"
  },
  {
    name = "TBWeaponSkin",
    file = "resource_tbweaponskin",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJWeaponSkin"
  },
  {
    name = "TBDigitalCollection",
    file = "resource_tbdigitalcollection",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJDigitalCollection"
  },
  {
    name = "TBResFamilyTreasure",
    file = "resource_tbresfamilytreasure",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResFamilyTreasure"
  },
  {
    name = "TBResHeroAppearance",
    file = "resource_tbresheroappearance",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResHeroAppearance"
  },
  {
    name = "TBResHeroCommuniRoulette",
    file = "resource_tbresherocommuniroulette",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResHeroCommuniRoulette"
  },
  {
    name = "TBGift",
    file = "resource_tbgift",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJGift"
  },
  {
    name = "TBInfiniteProp",
    file = "resource_tbinfiniteprop",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJInfiniteProp"
  },
  {
    name = "TBResAchievementBadge",
    file = "resource_tbresachievementbadge",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResAchievementBadge"
  },
  {
    name = "TBPortrait",
    file = "resource_tbportrait",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJPortrait"
  },
  {
    name = "TBBanner",
    file = "resource_tbbanner",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJBanner"
  },
  {
    name = "TBResChip",
    file = "resource_tbreschip",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResChip"
  },
  {
    name = "TBResourceExchange",
    file = "resource_tbresourceexchange",
    mode = "map",
    index = "TargetResourceID",
    value_type = "resource.OBJResourceExchange"
  },
  {
    name = "TBResourceChipUpgradeMaterial",
    file = "resource_tbresourcechipupgradematerial",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJChipUpgradeMaterial"
  },
  {
    name = "TBResPuzzle",
    file = "resource_tbrespuzzle",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResPuzzle"
  },
  {
    name = "TBResGem",
    file = "resource_tbresgem",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResGem"
  },
  {
    name = "TBOptionalGift",
    file = "resource_tboptionalgift",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJOptionalGift"
  },
  {
    name = "TBPaymentCurrency",
    file = "resource_tbpaymentcurrency",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJPaymentCurrency"
  },
  {
    name = "TBMonthCard",
    file = "resource_tbmonthcard",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJMonthCard"
  },
  {
    name = "TBTimeLimitGift",
    file = "resource_tbtimelimitgift",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJTimeLimitGift"
  },
  {
    name = "TBHeroProfyExp",
    file = "resource_tbheroprofyexp",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJHeroProfyExp"
  },
  {
    name = "TBResPrivilege",
    file = "resource_tbresprivilege",
    mode = "map",
    index = "ID",
    value_type = "resource.OBJResPrivilege"
  },
  {
    name = "TBSkillTag",
    file = "hero_tbskilltag",
    mode = "map",
    index = "ID",
    value_type = "hero.OBJSkillTag"
  },
  {
    name = "TBHeroMonster",
    file = "hero_tbheromonster",
    mode = "map",
    index = "ID",
    value_type = "hero.OBJHeroMonster"
  },
  {
    name = "TBFetterSlot",
    file = "hero_tbfetterslot",
    mode = "map",
    index = "ID",
    value_type = "hero.OBJFetterSlot"
  },
  {
    name = "TBHeroSkill",
    file = "hero_tbheroskill",
    mode = "list",
    index = "ID+Star",
    value_type = "hero.OBJHeroSkill"
  },
  {
    name = "TBHeroStar",
    file = "hero_tbherostar",
    mode = "list",
    index = "ID+Level",
    value_type = "hero.OBJHeroStar"
  },
  {
    name = "TBTalent",
    file = "talent_tbtalent",
    mode = "map",
    index = "ID",
    value_type = "talent.OBJTalent"
  },
  {
    name = "TBProfyLevel",
    file = "hero_tbprofylevel",
    mode = "map",
    index = "Level",
    value_type = "hero.OBJProfyLevel"
  },
  {
    name = "TBProfyGeneral",
    file = "hero_tbprofygeneral",
    mode = "map",
    index = "ID",
    value_type = "hero.OBJProfyGeneral"
  },
  {
    name = "TBFamilyTreasure",
    file = "hero_tbfamilytreasure",
    mode = "map",
    index = "ID",
    value_type = "hero.OBJFamilyTreasure"
  },
  {
    name = "TBFamilyTreasureUpgrade",
    file = "hero_tbfamilytreasureupgrade",
    mode = "list",
    index = "ID+Level",
    value_type = "hero.OBJFamilyTreasureUpgrade"
  },
  {
    name = "TBHeroSkinExchange",
    file = "hero_tbheroskinexchange",
    mode = "map",
    index = "ID",
    value_type = "hero.OBJHeroSkinExchange"
  },
  {
    name = "TBGachaPond",
    file = "mall_tbgachapond",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJGachaPond"
  },
  {
    name = "TBGachaSafeguard",
    file = "mall_tbgachasafeguard",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJGachaSafeguard"
  },
  {
    name = "TBMall",
    file = "mall_tbmall",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJMall"
  },
  {
    name = "TBMallShelf",
    file = "mall_tbmallshelf",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJMallShelf"
  },
  {
    name = "TBMallRecommendPage",
    file = "mall_tbmallrecommendpage",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJMallRecommendPage"
  },
  {
    name = "TBPaymentMall",
    file = "mall_tbpaymentmall",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJPaymentMall"
  },
  {
    name = "TBPaymentMallMallShelf",
    file = "mall_tbpaymentmallmallshelf",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJPaymentMallMallShelf"
  },
  {
    name = "TBShelfSecondTab",
    file = "mall_tbshelfsecondtab",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJShelfSecondTab"
  },
  {
    name = "TBPaymentMallCurrency",
    file = "mall_tbpaymentmallcurrency",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJPaymentMallCurrency"
  },
  {
    name = "TBGachaReward",
    file = "mall_tbgachareward",
    mode = "map",
    index = "ID",
    value_type = "mall.OBJGachaReward"
  },
  {
    name = "TBWeapon",
    file = "weapon_tbweapon",
    mode = "map",
    index = "BarrelID",
    value_type = "weapon.OBJWeapon"
  },
  {
    name = "TBAccessory",
    file = "weapon_tbaccessory",
    mode = "map",
    index = "AccessoryID",
    value_type = "weapon.OBJAccessroy"
  },
  {
    name = "TBGuide",
    file = "guide_tbguide",
    mode = "map",
    index = "id",
    value_type = "guide.OBJGuide"
  },
  {
    name = "TBGuideStep",
    file = "guide_tbguidestep",
    mode = "map",
    index = "id",
    value_type = "guide.OBJGuideStep"
  },
  {
    name = "TBGuidebooktype",
    file = "guide_tbguidebooktype",
    mode = "map",
    index = "id",
    value_type = "guide.OBJGuidebooktype"
  },
  {
    name = "TBChat",
    file = "chat_tbchat",
    mode = "map",
    index = "Channel",
    value_type = "chat.OBJChat"
  },
  {
    name = "TBChatContent",
    file = "chat_tbchatcontent",
    mode = "map",
    index = "ID",
    value_type = "chat.OBJChatContent"
  },
  {
    name = "TBSystemMsg",
    file = "chat_tbsystemmsg",
    mode = "map",
    index = "ID",
    value_type = "chat.OBJSystemMsg"
  },
  {
    name = "TBTaskGroupData",
    file = "task_tbtaskgroupdata",
    mode = "map",
    index = "id",
    value_type = "task.OBJTaskGroup"
  },
  {
    name = "TBTaskData",
    file = "task_tbtaskdata",
    mode = "map",
    index = "id",
    value_type = "task.OBJTask"
  },
  {
    name = "TBUnlockEventData",
    file = "task_tbunlockeventdata",
    mode = "map",
    index = "id",
    value_type = "task.OBJUnlockEvent"
  },
  {
    name = "TBTargetEventData",
    file = "task_tbtargeteventdata",
    mode = "map",
    index = "id",
    value_type = "task.OBJTargetEvent"
  },
  {
    name = "TBClimbTowerFloor",
    file = "season_tbclimbtowerfloor",
    mode = "map",
    index = "FloorID",
    value_type = "season.OBJClimbTowerFloor"
  },
  {
    name = "TBClimbTowerDebuff",
    file = "season_tbclimbtowerdebuff",
    mode = "map",
    index = "DebuffGroupID",
    value_type = "season.OBJClimbTowerDebuff"
  },
  {
    name = "TBClimbTowerLobbyAnomaly",
    file = "season_tbclimbtowerlobbyanomaly",
    mode = "map",
    index = "AnomalyID",
    value_type = "season.OBJClimbTowerLobbyAnomaly"
  },
  {
    name = "TBClimbTowerDailyRewardBonusRate",
    file = "season_tbclimbtowerdailyrewardbonusrate",
    mode = "map",
    index = "HeroID",
    value_type = "season.OBJClimbTowerDailyRewardBonusRate"
  },
  {
    name = "TBClimbTowerGlobalPassReward",
    file = "season_tbclimbtowerglobalpassreward",
    mode = "map",
    index = "RewardID",
    value_type = "season.OBJClimbTowerGlobalPassReward"
  },
  {
    name = "TBClimbTowerSlotUnlock",
    file = "season_tbclimbtowerslotunlock",
    mode = "map",
    index = "SlotId",
    value_type = "season.OBJClimbTowerSlotUnlock"
  },
  {
    name = "TBHeroSeasonAbility",
    file = "season_tbheroseasonability",
    mode = "map",
    index = "SeasonAbilityID",
    value_type = "season.OBJHeroSeasonAbility"
  },
  {
    name = "TBSeasonTalent",
    file = "season_tbseasontalent",
    mode = "map",
    index = "SeasonTalentID",
    value_type = "season.OBJSeasonTalent"
  },
  {
    name = "TBSpecialAbility",
    file = "season_tbspecialability",
    mode = "list",
    index = "SpecialAbilityID+SeasonIDX",
    value_type = "season.OBJSpecialAbility"
  },
  {
    name = "TBSeasonAbilityPresentScheme",
    file = "season_tbseasonabilitypresentscheme",
    mode = "list",
    index = "PresentSchemeID+SeasonIDX",
    value_type = "season.OBJSeasonAbilityPresentScheme"
  },
  {
    name = "TBSeasonAbilityPointExchange",
    file = "season_tbseasonabilitypointexchange",
    mode = "list",
    index = "AbilityPointID+SeasonIDX",
    value_type = "season.OBJSeasonAbilityPointExchange"
  },
  {
    name = "TBSeasonGeneral",
    file = "season_tbseasongeneral",
    mode = "map",
    index = "SeasonID",
    value_type = "season.OBJSeasonGeneral"
  },
  {
    name = "TBBossRush",
    file = "season_tbbossrush",
    mode = "map",
    index = "Id",
    value_type = "season.OBJBossRush"
  },
  {
    name = "TBSurvival",
    file = "season_tbsurvival",
    mode = "map",
    index = "Id",
    value_type = "season.OBJSurvival"
  },
  {
    name = "TBWorld",
    file = "story_tbworld",
    mode = "map",
    index = "id",
    value_type = "story.OBJStoryWorld"
  },
  {
    name = "TBClue",
    file = "story_tbclue",
    mode = "map",
    index = "id",
    value_type = "story.OBJStoryClue"
  },
  {
    name = "TBFragment",
    file = "story_tbfragment",
    mode = "map",
    index = "id",
    value_type = "story.OBJStoryFragment"
  },
  {
    name = "TBWorldIntelligence",
    file = "story_tbworldintelligence",
    mode = "map",
    index = "id",
    value_type = "story.OBJStoryWorldIntelligence"
  },
  {
    name = "TBAchievement",
    file = "achievement_tbachievement",
    mode = "map",
    index = "id",
    value_type = "achievement.OBJAchievement"
  },
  {
    name = "TBAchievementPoint",
    file = "achievement_tbachievementpoint",
    mode = "map",
    index = "id",
    value_type = "achievement.OBJAchievementPoint"
  },
  {
    name = "TBPS5Achievement",
    file = "achievement_tbps5achievement",
    mode = "map",
    index = "ObjectID",
    value_type = "achievement.OBJPS5Achievement"
  },
  {
    name = "TBXBoxAchievement",
    file = "achievement_tbxboxachievement",
    mode = "map",
    index = "Xboxid",
    value_type = "achievement.OBJXBoxAchievement"
  },
  {
    name = "TBMainStoryLine",
    file = "mainstoryline_tbmainstoryline",
    mode = "map",
    index = "id",
    value_type = "mainstoryline.OBJStoryLineMission"
  },
  {
    name = "TBChipSubAttrInit",
    file = "chip_tbchipsubattrinit",
    mode = "map",
    index = "ID",
    value_type = "chip.OBJChipSubAttrInit"
  },
  {
    name = "TBChipSubAttrLvUp",
    file = "chip_tbchipsubattrlvup",
    mode = "map",
    index = "ID",
    value_type = "chip.OBJChipSubAttrLvUp"
  },
  {
    name = "TBChipInitInscription",
    file = "chip_tbchipinitinscription",
    mode = "map",
    index = "ID",
    value_type = "chip.OBJChipInitInscription"
  },
  {
    name = "TBChipLevelUp",
    file = "chip_tbchiplevelup",
    mode = "map",
    index = "ID",
    value_type = "chip.OBJCHipLevelUp"
  },
  {
    name = "TBChipSlots",
    file = "chip_tbchipslots",
    mode = "map",
    index = "ID",
    value_type = "chip.OBJCHipSlots"
  },
  {
    name = "TBMainAttrLvUp",
    file = "chip_tbmainattrlvup",
    mode = "map",
    index = "ID",
    value_type = "chip.OBJCHipMainAttrLvUp"
  },
  {
    name = "TBBindHero",
    file = "chip_tbbindhero",
    mode = "map",
    index = "ID",
    value_type = "chip.OBJChipBindHero"
  },
  {
    name = "TBPuzzleSubAttrInit",
    file = "puzzle_tbpuzzlesubattrinit",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleSubAttrInit"
  },
  {
    name = "TBPuzzleSubAttrLvUp",
    file = "puzzle_tbpuzzlesubattrlvup",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleSubAttrLvUp"
  },
  {
    name = "TBPuzzleInitInscription",
    file = "puzzle_tbpuzzleinitinscription",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleInitInscription"
  },
  {
    name = "TBPuzzleLevelUp",
    file = "puzzle_tbpuzzlelevelup",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleLevelUp"
  },
  {
    name = "TBPuzzleSlots",
    file = "puzzle_tbpuzzleslots",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleSlots"
  },
  {
    name = "TBPuzzleMainAttrLvUp",
    file = "puzzle_tbpuzzlemainattrlvup",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleMainAttrLvUp"
  },
  {
    name = "TBPuzzleBindHero",
    file = "puzzle_tbpuzzlebindhero",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleBindHero"
  },
  {
    name = "TBPuzzleWorld",
    file = "puzzle_tbpuzzleworld",
    mode = "map",
    index = "WorldId",
    value_type = "puzzle.OBJPuzzleWorld"
  },
  {
    name = "TBPuzzleHero",
    file = "puzzle_tbpuzzlehero",
    mode = "map",
    index = "HeroId",
    value_type = "puzzle.OBJPuzzleHero"
  },
  {
    name = "TBPuzzleWashSlots",
    file = "puzzle_tbpuzzlewashslots",
    mode = "map",
    index = "slotNum",
    value_type = "puzzle.OBJPuzzleWashSlots"
  },
  {
    name = "TBPuzzleSlotsWeight",
    file = "puzzle_tbpuzzleslotsweight",
    mode = "map",
    index = "SlotNum",
    value_type = "puzzle.OBJPuzzleSlotsWeight"
  },
  {
    name = "TBPuzzleShape",
    file = "puzzle_tbpuzzleshape",
    mode = "map",
    index = "shapeID",
    value_type = "puzzle.OBJPuzzleShape"
  },
  {
    name = "TBPuzzleInscriptionGroup",
    file = "puzzle_tbpuzzleinscriptiongroup",
    mode = "map",
    index = "ID",
    value_type = "puzzle.OBJPuzzleInscriptionGroup"
  },
  {
    name = "TBPuzzleGrade",
    file = "puzzle_tbpuzzlegrade",
    mode = "map",
    index = "GradeID",
    value_type = "puzzle.OBJPuzzleGrade"
  },
  {
    name = "TBPuzzleAttrName",
    file = "puzzle_tbpuzzleattrname",
    mode = "map",
    index = "AttrCombination",
    value_type = "puzzle.OBJPuzzleAttrName"
  },
  {
    name = "TBPuzzleInscriptionName",
    file = "puzzle_tbpuzzleinscriptionname",
    mode = "map",
    index = "InscriptionId",
    value_type = "puzzle.OBJPuzzleInscriptionName"
  },
  {
    name = "TBPuzzleShapeName",
    file = "puzzle_tbpuzzleshapename",
    mode = "map",
    index = "ShapeId",
    value_type = "puzzle.OBJPuzzleShapeName"
  },
  {
    name = "TBGemLevelUp",
    file = "gem_tbgemlevelup",
    mode = "map",
    index = "ID",
    value_type = "gem.OBJGemLevelUp"
  },
  {
    name = "TBGemLevelUpAttr",
    file = "gem_tbgemlevelupattr",
    mode = "map",
    index = "ID",
    value_type = "gem.OBJGemLevelUpAttr"
  },
  {
    name = "TBSevenDayLogin",
    file = "activity_tbsevendaylogin",
    mode = "map",
    index = "Day",
    value_type = "activity.OBJSevenDayLogin"
  },
  {
    name = "TBActivityGeneral",
    file = "activity_tbactivitygeneral",
    mode = "map",
    index = "activityID",
    value_type = "activity.OBJActivityGeneral"
  },
  {
    name = "TBRuleTask",
    file = "activity_tbruletask",
    mode = "map",
    index = "activityID",
    value_type = "activity.OBJRuleTask"
  },
  {
    name = "TBRuleInfo",
    file = "activity_tbruleinfo",
    mode = "map",
    index = "ruleInfoID",
    value_type = "activity.OBJRuleInfo"
  },
  {
    name = "TBPandoraInfo",
    file = "activity_tbpandorainfo",
    mode = "map",
    index = "Id",
    value_type = "activity.OBJPandoraInfo"
  },
  {
    name = "TBRankMode",
    file = "rank_tbrankmode",
    mode = "map",
    index = "RowName",
    value_type = "rank.OBJRankMode"
  },
  {
    name = "TBBattlePass",
    file = "battlepass_tbbattlepass",
    mode = "map",
    index = "BattlePassID",
    value_type = "battlepass.OBJBattlePass"
  },
  {
    name = "TBBattlePassReward",
    file = "battlepass_tbbattlepassreward",
    mode = "list",
    index = "BattlePassID+BattlePassLevel",
    value_type = "battlepass.OBJBattlePassReward"
  },
  {
    name = "TBBattlePassRewardShow",
    file = "battlepass_tbbattlepassrewardshow",
    mode = "map",
    index = "ItemID",
    value_type = "battlepass.OBJBattlePassRewardShow"
  },
  {
    name = "TBBattlePassTask",
    file = "battlepass_tbbattlepasstask",
    mode = "map",
    index = "ID",
    value_type = "battlepass.OBJBattlePassTask"
  },
  {
    name = "TBGenericModifyDialog",
    file = "gameplay_tbgenericmodifydialog",
    mode = "map",
    index = "id",
    value_type = "gameplay.OBJGenericModifyDialog"
  },
  {
    name = "TBLobbyBatchCheat",
    file = "cheat_tblobbybatchcheat",
    mode = "map",
    index = "Index",
    value_type = "cheat.OBJLobbyBatchCheat"
  },
  {
    name = "TBBattleBatchCheat",
    file = "cheat_tbbattlebatchcheat",
    mode = "map",
    index = "Index",
    value_type = "cheat.OBJBattleBatchCheat"
  }
}
return {tables = tables}
