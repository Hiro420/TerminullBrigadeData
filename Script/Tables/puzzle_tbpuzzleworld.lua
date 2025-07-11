local puzzle_tbpuzzleworld = {
  [23] = {
    WorldId = 23,
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Name_23", "[\231\169\185\233\148\139]"),
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Puzzle_01.Icon_Puzzle_01",
    GridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Cyber.Icon_Cyber",
    HollowGridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Cyber_02.Icon_Cyber_02",
    ItemFXColor = "B772FFFF",
    ItemLoopFXColor = "B772FFFF",
    ItemFrameColor = "8A00FFFF",
    IsOpen = true,
    DescLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Desc_23", "\231\169\185\233\148\139\230\136\152\230\150\151\231\159\169\233\152\181\229\143\175\232\163\133\233\133\141\230\168\161\229\157\151\230\149\176\228\184\186{1},\229\189\147\229\137\141\229\183\178\232\163\133\233\133\141{2}\228\184\170\230\168\161\229\157\151\227\128\130"),
    notes = ""
  },
  [24] = {
    WorldId = 24,
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Name_24", "[\233\148\139\229\141\171]"),
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Puzzle_04.Icon_Puzzle_04",
    GridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Wasteland.Icon_Wasteland",
    HollowGridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Wasteland_02.Icon_Wasteland_02",
    ItemFXColor = "9F6335FF",
    ItemLoopFXColor = "9C7E4FFF",
    ItemFrameColor = "C26500FF",
    IsOpen = true,
    DescLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Desc_24", "\233\148\139\229\141\171\230\136\152\230\150\151\231\159\169\233\152\181\229\143\175\232\163\133\233\133\141\230\168\161\229\157\151\230\149\176\228\184\186{1},\229\189\147\229\137\141\229\183\178\232\163\133\233\133\141{2}\228\184\170\230\168\161\229\157\151\227\128\130"),
    notes = ""
  },
  [123] = {
    WorldId = 123,
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Name_123", "[\232\163\130\229\143\152]"),
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Puzzle_03.Icon_Puzzle_03",
    GridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Interstellar.Icon_Interstellar",
    HollowGridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Interstellar_02.Icon_Interstellar_02",
    ItemFXColor = "448791FF",
    ItemLoopFXColor = "94EEFFFF",
    ItemFrameColor = "007EC2FF",
    IsOpen = true,
    DescLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Desc_123", "\232\163\130\229\143\152\230\136\152\230\150\151\231\159\169\233\152\181\229\143\175\232\163\133\233\133\141\230\168\161\229\157\151\230\149\176\228\184\186{1},\229\189\147\229\137\141\229\183\178\232\163\133\233\133\141{2}\228\184\170\230\168\161\229\157\151\227\128\130"),
    notes = ""
  },
  [124] = {
    WorldId = 124,
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Name_124", "[\230\152\159\229\158\146]"),
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Puzzle_02.Icon_Puzzle_02",
    GridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_FairyTales.Icon_FairyTales",
    HollowGridBottomIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_FairyTales_02.Icon_FairyTales_02",
    ItemFXColor = "914158FF",
    ItemLoopFXColor = "FFA7A3FF",
    ItemFrameColor = "FF4079FF",
    IsOpen = true,
    DescLocMeta = NSLOCTEXT("puzzle_TBPuzzleWorld", "Desc_124", "\230\152\159\229\158\146\230\136\152\230\150\151\231\159\169\233\152\181\229\143\175\232\163\133\233\133\141\230\168\161\229\157\151\230\149\176\228\184\186{1},\229\189\147\229\137\141\229\183\178\232\163\133\233\133\141{2}\228\184\170\230\168\161\229\157\151\227\128\130"),
    notes = ""
  }
}
local LinkTb = {
  Name = "NameLocMeta",
  Desc = "DescLocMeta"
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
IteratorSetMetaTable(puzzle_tbpuzzleworld, LuaTableMeta)
return puzzle_tbpuzzleworld
