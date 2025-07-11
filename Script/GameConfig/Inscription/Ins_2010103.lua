local Ins_2010103 = 
{
	ID = 2010103,
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
			Desc = "击杀目标后向弹夹中装填一发致命弹药（枪械下一发伤害提高150%)",
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
			ModAdditionalNote = NSLOCTEXT("","A26D845B4F3DA4056DE519BA36CBE3F5","指玩家造成的伤害完成击杀，否则不算最后一击"),
			ModNoteTitle = NSLOCTEXT("","DEF8ED864ED19DEBDE81D68EFF6358A3","最后一击"),
		},
		[20102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","B427BEF9488F7763F80886B00D275863","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","9001B13E44D549FF907F65BA4F33A173","充能"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010103