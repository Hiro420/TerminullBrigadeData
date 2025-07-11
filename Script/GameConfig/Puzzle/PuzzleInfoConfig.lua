

local PuzzleInfoConfig = {
    ---0是是否突变
    ---1是主属性缩略名  
    ---2是词条缩略名
    ---3是形状名
    ---4是神赐标志
    ---5是强力词条图标
    NameFmt = NSLOCTEXT("PuzzleData", "PuzzleNameFmt", "{0}{1}{2}模组{3}{4}{5}"),
    MutationName = NSLOCTEXT("PuzzleData", "PuzzleMutationName", "重构·"),
    GodAttrText = "<img id=\"Puzzle\"/>",
    PowerfulInscriptionText = "<img id=\"PowerfulInscription\"/>",
    MutationSuccessTipId = 300013,
    MutationFailTipId = 300015,
    MutataionNotChangeTipId = 300014,
    IsShowGradeIcon = false,
}

return PuzzleInfoConfig