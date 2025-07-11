local Ins_2010113 = 
{
	ID = 2010113,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_09_png.Module_xiaoqingICON_09_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "攻击命中后",
		},
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "受到攻击时",
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
		[20102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","2F5E8522449A0564154B41B345DA50EC","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","600FBCDC46CCBB16D91C339322C66820","充能"),
		},
		[20105] = 
		{
			ModAdditionalNote = NSLOCTEXT("","3078791E40BD6D1B8551BAB4A97E2BF0","幻影自动向最近的敌人冲刺，并对路径上的敌人造成C技能伤害（基础75%）"),
			ModNoteTitle = NSLOCTEXT("","AAB214324328F5A154D833AE69D8660B","幻影"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010113