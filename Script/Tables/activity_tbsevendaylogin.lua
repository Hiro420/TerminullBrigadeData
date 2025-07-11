local activity_tbsevendaylogin = {
  [1] = {
    Day = 1,
    Icon = "",
    desc = "\229\164\169\232\181\139\230\157\144\230\150\153;\232\147\157\232\137\178\232\138\175\231\137\135\231\164\188\229\140\133*5",
    RewardList = {
      {key = 99994, value = 100},
      {key = 62002, value = 5}
    },
    showType = 2,
    unLockTimeLocMeta = NSLOCTEXT("activity_TBSevenDayLogin", "unLockTime_1", "9-19")
  },
  [2] = {
    Day = 2,
    Icon = "",
    desc = "\230\169\153\232\137\178\232\138\175\231\137\135\231\164\188\229\140\133*3",
    RewardList = {
      {key = 62011, value = 1},
      {key = 62012, value = 1},
      {key = 62013, value = 1}
    },
    showType = 2,
    unLockTimeLocMeta = NSLOCTEXT("activity_TBSevenDayLogin", "unLockTime_2", "9-20")
  },
  [3] = {
    Day = 3,
    Icon = "/Game/Rouge/UI/Sprite/LoginRewards/Frames/Login_Hero02.Login_Hero02",
    desc = "\230\160\188\231\189\151\232\142\137\228\186\154",
    RewardList = {
      {key = 100008, value = 1}
    },
    showType = 1,
    unLockTimeLocMeta = NSLOCTEXT("activity_TBSevenDayLogin", "unLockTime_3", "9-21")
  },
  [4] = {
    Day = 4,
    Icon = "/Game/Rouge/UI/Sprite/LoginRewards/Frames/Login_Hero01.Login_Hero01",
    desc = "\231\186\179\229\133\139\230\150\175 ",
    RewardList = {
      {key = 100010, value = 1}
    },
    showType = 1,
    unLockTimeLocMeta = NSLOCTEXT("activity_TBSevenDayLogin", "unLockTime_4", "9-22")
  },
  [5] = {
    Day = 5,
    Icon = "",
    desc = "\232\181\155\229\173\163\232\138\175\231\137\135*5",
    RewardList = {
      {key = 62005, value = 5}
    },
    showType = 2,
    unLockTimeLocMeta = NSLOCTEXT("activity_TBSevenDayLogin", "unLockTime_5", "9-23")
  },
  [6] = {
    Day = 6,
    Icon = "",
    desc = "\230\181\183\229\155\160\229\133\139\230\150\175",
    RewardList = {
      {key = 100009, value = 1}
    },
    showType = 1,
    unLockTimeLocMeta = NSLOCTEXT("activity_TBSevenDayLogin", "unLockTime_6", "9-24")
  },
  [7] = {
    Day = 7,
    Icon = "",
    desc = "\229\164\169\232\181\139\230\157\144\230\150\153;\230\169\153\232\137\178\232\138\175\231\137\135;\232\147\157\231\180\171\232\138\175\231\137\135",
    RewardList = {
      {key = 62004, value = 10},
      {key = 62006, value = 10},
      {key = 62003, value = 50},
      {key = 62002, value = 50},
      {key = 99994, value = 1000}
    },
    showType = 2,
    unLockTimeLocMeta = NSLOCTEXT("activity_TBSevenDayLogin", "unLockTime_7", "9-25")
  }
}
local LinkTb = {
  unLockTime = "unLockTimeLocMeta"
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
IteratorSetMetaTable(activity_tbsevendaylogin, LuaTableMeta)
return activity_tbsevendaylogin
