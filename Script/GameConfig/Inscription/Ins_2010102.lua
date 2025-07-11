local Ins_2010102 = 
{
	ID = 2010102,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_24_png.Module_xiaoqingICON_24_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "击杀目标后向弹夹中装填一发致命弹药（枪械下一发伤害提高80%)",
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
		[20106] = 
		{
			ModAdditionalNote = NSLOCTEXT("","0ACF5E2F4898AFADBE8E26ACEA08AD19","指玩家造成的伤害完成击杀，否则不算最后一击"),
			ModNoteTitle = NSLOCTEXT("","1CBD9D2F41258D6B6F5B448F6F639B15","最后一击"),
		},
		[20102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","E5C146344A95A6F401C3CC814B8DE9D6","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","9C60C4E144C3759AF105E9AAE10ECF10","充能"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010102