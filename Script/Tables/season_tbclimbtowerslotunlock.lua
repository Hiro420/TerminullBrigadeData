local season_tbclimbtowerslotunlock = {
  [1] = {
    SlotId = 1,
    UnlockFloor = 0,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_1", ""),
    WaveWindowId = 1502
  },
  [2] = {
    SlotId = 2,
    UnlockFloor = 0,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_2", ""),
    WaveWindowId = 1502
  },
  [3] = {
    SlotId = 3,
    UnlockFloor = 2,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_3", "\233\128\154\229\133\179\228\191\174\230\173\163\232\161\140\229\138\1682\229\177\130"),
    WaveWindowId = 1502
  },
  [4] = {
    SlotId = 4,
    UnlockFloor = 4,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_4", "\233\128\154\229\133\179\228\191\174\230\173\163\232\161\140\229\138\1684\229\177\130"),
    WaveWindowId = 1502
  },
  [5] = {
    SlotId = 5,
    UnlockFloor = 6,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_5", "\233\128\154\229\133\179\228\191\174\230\173\163\232\161\140\229\138\1686\229\177\130"),
    WaveWindowId = 1502
  },
  [6] = {
    SlotId = 6,
    UnlockFloor = 8,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_6", "\233\128\154\229\133\179\228\191\174\230\173\163\232\161\140\229\138\1688\229\177\130"),
    WaveWindowId = 1502
  },
  [7] = {
    SlotId = 7,
    UnlockFloor = 51,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_7", "\230\154\130\228\184\141\229\188\128\230\148\190"),
    WaveWindowId = 1502
  },
  [8] = {
    SlotId = 8,
    UnlockFloor = 51,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_8", "\230\154\130\228\184\141\229\188\128\230\148\190"),
    WaveWindowId = 1502
  },
  [9] = {
    SlotId = 9,
    UnlockFloor = 51,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_9", "\230\154\130\228\184\141\229\188\128\230\148\190"),
    WaveWindowId = 1502
  },
  [10] = {
    SlotId = 10,
    UnlockFloor = 51,
    UnLockDesLocMeta = NSLOCTEXT("season_TBClimbTowerSlotUnlock", "UnLockDes_10", "\230\154\130\228\184\141\229\188\128\230\148\190"),
    WaveWindowId = 1502
  }
}
local LinkTb = {
  UnLockDes = "UnLockDesLocMeta"
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
IteratorSetMetaTable(season_tbclimbtowerslotunlock, LuaTableMeta)
return season_tbclimbtowerslotunlock
