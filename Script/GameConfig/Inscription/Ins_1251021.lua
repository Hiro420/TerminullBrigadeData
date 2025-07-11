local Ins_1251021 = 
{
	ID = 1251021,
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
			Desc = "腰射命中时子弹每击中目标5次对目标施加强化锁定,最多施加3层后，重置层数",
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
			ModAdditionalNote = NSLOCTEXT("","506B3DCB4938459A7CF67FA9725F0CD7","每层+15%弱点伤害，叠满3层后下一枪额外+150%弱点伤害，触发后移除"),
			ModNoteTitle = NSLOCTEXT("","059AEFA94F3103E83094B080B4D0B8EC","强化锁定"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_1251021