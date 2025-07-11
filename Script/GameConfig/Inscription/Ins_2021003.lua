local Ins_2021003 = 
{
	ID = 2021003,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_taluoso_03_png.Module_taluoso_03_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "有弱化标记的敌人死亡时减少GameEffect.Ability.RecoverySkillCountSkillE2秒冷却",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = NSLOCTEXT("","E1734CEE40AEAACF192BAF8D05B098C9","效果冷却中"),
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/BUFF/Frames/2_png.2_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[20202] = 
		{
			ModAdditionalNote = NSLOCTEXT("","FEC3AB3B433DBDEBDF0F6B9E91AE8DAE","在弱化状态下，敌人的任意部位都会被视为弱点。"),
			ModNoteTitle = NSLOCTEXT("","E46B31BA4DB08719DA0E6084D0BF82E4","弱化"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2021003