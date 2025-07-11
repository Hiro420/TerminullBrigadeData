local Ins_1251022 = 
{
	ID = 1251022,
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
			Desc = "腰射命中时子弹每击中目标2次对目标施加强化锁定,最多施加3层后，重置层数",
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
			ModAdditionalNote = NSLOCTEXT("","30F1F69848E208022E65C4A99D7760AA","每层+15%弱点伤害，叠满3层后下一枪额外+150%弱点伤害，触发后移除"),
			ModNoteTitle = NSLOCTEXT("","E3B237904BFCB20FCC2ACFA5B58631E6","强化锁定"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_1251022