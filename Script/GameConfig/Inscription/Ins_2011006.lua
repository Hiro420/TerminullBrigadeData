local Ins_2011006 = 
{
	ID = 2011006,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_13_png.Module_xiaoqingICON_13_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "击杀目标后",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = NSLOCTEXT("","3D267DE940D507139FDAFC8F3C53B4E4","伺机而动"),
		CDDesc = NSLOCTEXT("","5B742FD0485698ED66DDBAADBA01195F","最后一击将立即获得位移技充能"),
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_13_png.Module_xiaoqingICON_13_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[20102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","2190E9A540429856C09BD7A5F7FBE767","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","E595264B4E7A9A3657068B90381F1BD9","充能"),
		},
		[20106] = 
		{
			ModAdditionalNote = NSLOCTEXT("","4D67F3A1482AB43FDB8ED79527958E91","指玩家造成的伤害完成击杀，否则不算最后一击"),
			ModNoteTitle = NSLOCTEXT("","AED92FDC44F44BB704F44A81E1E12FEC","最后一击"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2011006