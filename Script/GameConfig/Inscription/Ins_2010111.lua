local Ins_2010111 = 
{
	ID = 2010111,
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
			ModAdditionalNote = NSLOCTEXT("","8447385C4CE6A0D5D3A2C7A050B6EE16","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","7CC59A0748E4628E7B11D48227BFA040","充能"),
		},
		[20105] = 
		{
			ModAdditionalNote = NSLOCTEXT("","3A87F754445B1D7B2DF83E905AB862D8","幻影自动向最近的敌人冲刺，并对路径上的敌人造成C技能伤害（基础75%）"),
			ModNoteTitle = NSLOCTEXT("","B10BFC8241EA41670AAA7EADFB573AD5","幻影"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010111