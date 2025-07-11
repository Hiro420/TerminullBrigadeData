local reddot_tbreddot = {
  Root = {
    Class = "Root",
    ParentIdList = {},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Root", ""),
    RedDotTypePriorityList = {
      "Num",
      "Icon",
      "Normal",
      "Text"
    },
    IsCacheEnable = true
  },
  Mail_Menu = {
    Class = "Mail_Menu",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Mail_Menu", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Mail_SingleItem = {
    Class = "Mail_SingleItem",
    ParentIdList = {"Mail_Menu"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Mail_SingleItem", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Learn_Menu = {
    Class = "Learn_Menu",
    ParentIdList = {"Root"},
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Learn_Menu", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Learn_Gameplay = {
    Class = "Learn_Gameplay",
    ParentIdList = {"Learn_Menu"},
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Learn_Gameplay", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Learn_Gameplay_Num = {
    Class = "Learn_Gameplay_Num",
    ParentIdList = {
      "Learn_Gameplay"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Learn_Gameplay_Num", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Friend_Menu = {
    Class = "Friend_Menu",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Friend_Menu", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Friend_Request = {
    Class = "Friend_Request",
    ParentIdList = {
      "Friend_Menu"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Friend_Request", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Friend_Chat = {
    Class = "Friend_Chat",
    ParentIdList = {
      "Friend_Menu"
    },
    RedDotType = "Num",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Friend_Chat", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Friend_Chat_Item = {
    Class = "Friend_Chat_Item",
    ParentIdList = {
      "Friend_Chat"
    },
    RedDotType = "Num",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Friend_Chat_Item", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  GameMode_Menu = {
    Class = "GameMode_Menu",
    ParentIdList = {"Root"},
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_GameMode_Menu", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  GameMode_World_Num = {
    Class = "GameMode_World_Num",
    ParentIdList = {
      "GameMode_Menu"
    },
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_GameMode_World_Num", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  GameMode_Level_Num = {
    Class = "GameMode_Level_Num",
    ParentIdList = {
      "GameMode_World_Num"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_GameMode_Level_Num", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall"] = {
    Class = "LobbyLabel.Mall",
    ParentIdList = {"Root"},
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Bundle"] = {
    Class = "LobbyLabel.Mall.Bundle",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Bundle", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Exterior"] = {
    Class = "LobbyLabel.Mall.Exterior",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Exterior", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Props"] = {
    Class = "LobbyLabel.Mall.Props",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Props", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Bundle_1"] = {
    Class = "LobbyLabel.Mall.Bundle_1",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Bundle_1", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Exterior_1"] = {
    Class = "LobbyLabel.Mall.Exterior_1",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Exterior_1", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Props_1"] = {
    Class = "LobbyLabel.Mall.Props_1",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Props_1", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Bundle_2"] = {
    Class = "LobbyLabel.Mall.Bundle_2",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Bundle_2", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Exterior_2"] = {
    Class = "LobbyLabel.Mall.Exterior_2",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Exterior_2", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Mall.Props_2"] = {
    Class = "LobbyLabel.Mall.Props_2",
    ParentIdList = {
      "LobbyLabel.Mall"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Mall.Props_2", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Bundle_SingleItem = {
    Class = "Bundle_SingleItem",
    ParentIdList = {
      "LobbyLabel.Mall.Bundle"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Bundle_SingleItem", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  All_RoleSkin = {
    Class = "All_RoleSkin",
    ParentIdList = {
      "LobbyLabel.Mall.Exterior"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_All_RoleSkin", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  All_WeaponSkin = {
    Class = "All_WeaponSkin",
    ParentIdList = {
      "LobbyLabel.Mall.Exterior"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_All_WeaponSkin", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  All_RoleSkin_Item = {
    Class = "All_RoleSkin_Item",
    ParentIdList = {
      "All_RoleSkin"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_All_RoleSkin_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  All_WeaponSkin_Item = {
    Class = "All_WeaponSkin_Item",
    ParentIdList = {
      "All_WeaponSkin"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_All_WeaponSkin_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Props = {
    Class = "Props",
    ParentIdList = {
      "LobbyLabel.Mall.Props"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Props", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Role"] = {
    Class = "LobbyLabel.Role",
    ParentIdList = {"Root"},
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Role", "\230\150\176"),
    RedDotTypePriorityList = {
      "Num",
      "Icon",
      "Normal",
      "Text"
    },
    IsCacheEnable = true
  },
  Role_SingleItem = {
    Class = "Role_SingleItem",
    ParentIdList = {
      "LobbyLabel.Role"
    },
    RedDotType = "",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Role_SingleItem", "\230\150\176"),
    RedDotTypePriorityList = {
      "Num",
      "Icon",
      "Normal",
      "Text"
    },
    IsCacheEnable = true
  },
  Role_SingleItem_Lock = {
    Class = "Role_SingleItem_Lock",
    ParentIdList = {
      "Role_SingleItem"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Role_SingleItem_Lock", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Role_Skin = {
    Class = "Role_Skin",
    ParentIdList = {"Root"},
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Role_Skin", "\230\150\176"),
    RedDotTypePriorityList = {
      "Num",
      "Icon",
      "Normal",
      "Text"
    },
    IsCacheEnable = true
  },
  Skin_Menu2 = {
    Class = "Skin_Menu2",
    ParentIdList = {"Role_Skin"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_Menu2", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_Heirloom_LevelItem = {
    Class = "Skin_Heirloom_LevelItem",
    ParentIdList = {"Skin_Menu2"},
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_Heirloom_LevelItem", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_Menu1 = {
    Class = "Skin_Menu1",
    ParentIdList = {"Role_Skin"},
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_Menu1", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_RoleSkin = {
    Class = "Skin_RoleSkin",
    ParentIdList = {"Skin_Menu1"},
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_RoleSkin", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_RoleSkin_Item = {
    Class = "Skin_RoleSkin_Item",
    ParentIdList = {
      "Skin_RoleSkin"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_RoleSkin_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_WeaponSkin = {
    Class = "Skin_WeaponSkin",
    ParentIdList = {"Skin_Menu1"},
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_WeaponSkin", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_WeaponSkin_WeaponName = {
    Class = "Skin_WeaponSkin_WeaponName",
    ParentIdList = {
      "Skin_WeaponSkin",
      "Weapon_Menu_2"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_WeaponSkin_WeaponName", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_WeaponSkin_Item = {
    Class = "Skin_WeaponSkin_Item",
    ParentIdList = {
      "Skin_WeaponSkin_WeaponName"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_WeaponSkin_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Proficiency_Menu_1 = {
    Class = "Proficiency_Menu_1",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Proficiency_Menu_1", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Proficiency_LegendTask = {
    Class = "Proficiency_LegendTask",
    ParentIdList = {
      "Proficiency_Menu_1"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Proficiency_LegendTask", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Proficiency_LevelBonus_Num = {
    Class = "Proficiency_LevelBonus_Num",
    ParentIdList = {
      "Proficiency_Menu_1"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Proficiency_LevelBonus_Num", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Proficiency_SynopsisItem_Num = {
    Class = "Proficiency_SynopsisItem_Num",
    ParentIdList = {
      "Proficiency_LegendTask"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Proficiency_SynopsisItem_Num", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Role_Weapon = {
    Class = "Role_Weapon",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Role_Weapon", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Weapon_Menu = {
    Class = "Weapon_Menu",
    ParentIdList = {
      "Role_Weapon"
    },
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Weapon_Menu", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Weapon_Menu_1 = {
    Class = "Weapon_Menu_1",
    ParentIdList = {
      "Weapon_Menu"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Weapon_Menu_1", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Weapon_Menu_2 = {
    Class = "Weapon_Menu_2",
    ParentIdList = {
      "Weapon_Menu"
    },
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Weapon_Menu_2", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Weapon_WeaponItem = {
    Class = "Weapon_WeaponItem",
    ParentIdList = {
      "Weapon_Menu_1"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Weapon_WeaponItem", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.Talent"] = {
    Class = "LobbyLabel.Talent",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.Talent", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Talent_SingleItem = {
    Class = "Talent_SingleItem",
    ParentIdList = {
      "LobbyLabel.Talent",
      "Talent_Settlement"
    },
    RedDotType = "Icon",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Talent_SingleItem", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Talent_Settlement = {
    Class = "Talent_Settlement",
    ParentIdList = {"Root"},
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Talent_Settlement", "\229\143\175\230\143\144\229\141\135"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  ["LobbyLabel.IllustratedGuideMenu"] = {
    Class = "LobbyLabel.IllustratedGuideMenu",
    ParentIdList = {"Root"},
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_LobbyLabel.IllustratedGuideMenu", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Specific_Database = {
    Class = "Specific_Database",
    ParentIdList = {
      "LobbyLabel.IllustratedGuideMenu"
    },
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Specific_Database", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Specific_ChooseHero = {
    Class = "Specific_ChooseHero",
    ParentIdList = {
      "Specific_Database"
    },
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Specific_ChooseHero", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Specific_HeroList_Item = {
    Class = "Specific_HeroList_Item",
    ParentIdList = {
      "Specific_ChooseHero"
    },
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Specific_HeroList_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Specific_GenericList = {
    Class = "Specific_GenericList",
    ParentIdList = {
      "Specific_HeroList_Item"
    },
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Specific_GenericList", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Specific_GenericList_Item = {
    Class = "Specific_GenericList_Item",
    ParentIdList = {
      "Specific_GenericList"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Specific_GenericList_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Piece_Database = {
    Class = "Piece_Database",
    ParentIdList = {
      "LobbyLabel.IllustratedGuideMenu"
    },
    RedDotType = "",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Piece_Database", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Piece_World_Num = {
    Class = "Piece_World_Num",
    ParentIdList = {
      "Piece_Database"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Piece_World_Num", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Piece_Clue_Num = {
    Class = "Piece_Clue_Num",
    ParentIdList = {
      "Piece_World_Num"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Piece_Clue_Num", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Piece_LayerStory_Num = {
    Class = "Piece_LayerStory_Num",
    ParentIdList = {
      "Piece_Clue_Num"
    },
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Piece_LayerStory_Num", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Piece_Item_Num = {
    Class = "Piece_Item_Num",
    ParentIdList = {
      "Piece_Clue_Num"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Piece_Item_Num", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  Event_LoginReward = {
    Class = "Event_LoginReward",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Event_LoginReward", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Event_LoginReward_Item = {
    Class = "Event_LoginReward_Item",
    ParentIdList = {
      "Event_LoginReward"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Event_LoginReward_Item", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Role_Chip = {
    Class = "Role_Chip",
    ParentIdList = {
      "LobbyLabel.Role"
    },
    RedDotType = "",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Role_Chip", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Toggle_UI_Chip = {
    Class = "Toggle_UI_Chip",
    ParentIdList = {"Role_Chip"},
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Toggle_UI_Chip", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Chip_Item = {
    Class = "Chip_Item",
    ParentIdList = {
      "Toggle_UI_Chip"
    },
    RedDotType = "Text",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Chip_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Personal_Menu = {
    Class = "Personal_Menu",
    ParentIdList = {"Root"},
    RedDotType = "",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Personal_Menu", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Achievement_Menu_1 = {
    Class = "Achievement_Menu_1",
    ParentIdList = {
      "Personal_Menu"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Achievement_Menu_1", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Achievement_Filter_Num = {
    Class = "Achievement_Filter_Num",
    ParentIdList = {
      "Achievement_Menu_1"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Achievement_Filter_Num", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Achievement_PhaseAward = {
    Class = "Achievement_PhaseAward",
    ParentIdList = {
      "Achievement_Menu_1"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Achievement_PhaseAward", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Achievement_IconItem = {
    Class = "Achievement_IconItem",
    ParentIdList = {
      "Achievement_Filter_Num"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Achievement_IconItem", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Login_Announcement = {
    Class = "Login_Announcement",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Login_Announcement", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  Recruit_ApplyList = {
    Class = "Recruit_ApplyList",
    ParentIdList = {"Root"},
    RedDotType = "Num",
    IsStubborn = false,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Recruit_ApplyList", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Skin_Menu3 = {
    Class = "Skin_Menu3",
    ParentIdList = {"Role_Skin"},
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Skin_Menu3", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Roulette_Paint = {
    Class = "Roulette_Paint",
    ParentIdList = {"Skin_Menu3"},
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Roulette_Paint", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Roulette_Voice = {
    Class = "Roulette_Voice",
    ParentIdList = {"Skin_Menu3"},
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Roulette_Voice", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Roulette_Paint_Item = {
    Class = "Roulette_Paint_Item",
    ParentIdList = {
      "Roulette_Paint"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Roulette_Paint_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Roulette_Voice_Item = {
    Class = "Roulette_Voice_Item",
    ParentIdList = {
      "Roulette_Voice"
    },
    RedDotType = "Text",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Roulette_Voice_Item", "\230\150\176"),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  BattlePass_Entry = {
    Class = "BattlePass_Entry",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_BattlePass_Entry", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  BattlePass_Menu_Reward = {
    Class = "BattlePass_Menu_Reward",
    ParentIdList = {
      "BattlePass_Entry"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_BattlePass_Menu_Reward", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  BattlePass_Reward = {
    Class = "BattlePass_Reward",
    ParentIdList = {
      "BattlePass_Menu_Reward"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_BattlePass_Reward", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  BattlePass_Menu_Task = {
    Class = "BattlePass_Menu_Task",
    ParentIdList = {
      "BattlePass_Entry"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_BattlePass_Menu_Task", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  BattlePass_Task_Group = {
    Class = "BattlePass_Task_Group",
    ParentIdList = {
      "BattlePass_Menu_Task"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_BattlePass_Task_Group", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  BattlePass_Task = {
    Class = "BattlePass_Task",
    ParentIdList = {
      "BattlePass_Task_Group"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_BattlePass_Task", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  Activity_Menu = {
    Class = "Activity_Menu",
    ParentIdList = {"Root"},
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Activity_Menu", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Activity_TabList = {
    Class = "Activity_TabList",
    ParentIdList = {
      "Activity_Menu"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Activity_TabList", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Activity_Tab = {
    Class = "Activity_Tab",
    ParentIdList = {
      "Activity_Menu"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Activity_Tab", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Activity_SevenDay_Reward = {
    Class = "Activity_SevenDay_Reward",
    ParentIdList = {
      "Activity_TabList"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Activity_SevenDay_Reward", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Activity_GenericMission_DataBase = {
    Class = "Activity_GenericMission_DataBase",
    ParentIdList = {
      "Activity_TabList"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Activity_GenericMission_DataBase", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Activity_GenericMission_FinalReward = {
    Class = "Activity_GenericMission_FinalReward",
    ParentIdList = {
      "Activity_TabList"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Activity_GenericMission_FinalReward", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  Activity_GenericMission_RewardList = {
    Class = "Activity_GenericMission_RewardList",
    ParentIdList = {
      "Activity_TabList"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_Activity_GenericMission_RewardList", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = true
  },
  MainModeSelect_Menu_1003 = {
    Class = "MainModeSelect_Menu_1003",
    ParentIdList = {
      "GameMode_Menu"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_MainModeSelect_Menu_1003", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  ClimbTower_DailyRewards = {
    Class = "ClimbTower_DailyRewards",
    ParentIdList = {
      "MainModeSelect_Menu_1003"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_ClimbTower_DailyRewards", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  ClimbTower_PassReward = {
    Class = "ClimbTower_PassReward",
    ParentIdList = {
      "MainModeSelect_Menu_1003"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_ClimbTower_PassReward", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  ClimbTower_PassReward_Layer = {
    Class = "ClimbTower_PassReward_Layer",
    ParentIdList = {
      "ClimbTower_PassReward"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_ClimbTower_PassReward_Layer", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  },
  ClimbTower_PassReward_Item = {
    Class = "ClimbTower_PassReward_Item",
    ParentIdList = {
      "ClimbTower_PassReward_Layer"
    },
    RedDotType = "Normal",
    IsStubborn = true,
    TextLocMeta = NSLOCTEXT("reddot_TBRedDot", "Text_ClimbTower_PassReward_Item", ""),
    RedDotTypePriorityList = {},
    IsCacheEnable = false
  }
}
local LinkTb = {
  Text = "TextLocMeta"
}
local LuaTableMeta = {
  __index = function(table, key)
    local keyIdx = LinkTb[key]
    if keyIdx then
      return table[keyIdx]()
    elseif rawget(table, key) then
      return rawget(table, key)
    end
  end
}
IteratorSetMetaTable(reddot_tbreddot, LuaTableMeta)
return reddot_tbreddot
