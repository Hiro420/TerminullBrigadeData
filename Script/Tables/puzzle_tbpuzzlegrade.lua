local puzzle_tbpuzzlegrade = {
  [1] = {
    GradeID = 1,
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade02_01.Icon_Grade02_01",
    TipIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade01_01.Icon_Grade01_01",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleGrade", "Name_1", "\229\188\186\229\186\166I")
  },
  [2] = {
    GradeID = 2,
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade02_02.Icon_Grade02_02",
    TipIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade01_02.Icon_Grade01_02",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleGrade", "Name_2", "\229\188\186\229\186\166II")
  },
  [3] = {
    GradeID = 3,
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade02_03.Icon_Grade02_03",
    TipIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade01_03.Icon_Grade01_03",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleGrade", "Name_3", "\229\188\186\229\186\166III")
  },
  [4] = {
    GradeID = 4,
    Icon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade02_03.Icon_Grade02_03",
    TipIcon = "/Game/Rouge/UI/Atlas_DT/IconPuzzle/Icon_Puzzle/Frames/Icon_Grade01_03.Icon_Grade01_03",
    NameLocMeta = NSLOCTEXT("puzzle_TBPuzzleGrade", "Name_4", "\229\188\186\229\186\166IV")
  }
}
local LinkTb = {
  Name = "NameLocMeta"
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
IteratorSetMetaTable(puzzle_tbpuzzlegrade, LuaTableMeta)
return puzzle_tbpuzzlegrade
