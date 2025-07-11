local Ins_1251031 = 
{
	ID = 1251031,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "肩射每命中目标2次对目标施加强化锁定,最多施加3层后，重置层数",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "",
		bIsShowCD = false,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[12510] = 
		{
			ModAdditionalNote = NSLOCTEXT("","CE4B80FE4BEC64DEC40828BB3CFA3566","每层+15%弱点伤害，叠满3层后下一枪额外+150%弱点伤害，触发后移除"),
			ModNoteTitle = NSLOCTEXT("","2E4683B24751BA00ACF971B260B9FA6B","强化锁定"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_1251031