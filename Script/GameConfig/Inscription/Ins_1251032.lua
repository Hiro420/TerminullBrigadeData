local Ins_1251032 = 
{
	ID = 1251032,
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
			Desc = "肩射命中时对目标施加强化锁定,最多施加3层后，重置层数",
		},
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "肩射命中时目标有1层125,000BUFF时本次弱点伤害系数提升15%;",
		},
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "肩射命中时目标有2层125,000BUFF时本次弱点伤害系数提升30%;",
		},
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "肩射命中时目标有3层125,000BUFF时本次弱点伤害系数提升150%;",
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
			ModAdditionalNote = NSLOCTEXT("","1B9DF1C9434A80F82A052D8A0DE73B84","每层+15%弱点伤害，叠满3层后下一枪额外+150%弱点伤害，触发后移除"),
			ModNoteTitle = NSLOCTEXT("","C2CB31AA432C2BE74BEE3783614E1E34","强化锁定"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_1251032