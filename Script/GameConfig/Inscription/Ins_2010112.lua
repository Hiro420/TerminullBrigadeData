local Ins_2010112 = 
{
	ID = 2010112,
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
			ModAdditionalNote = NSLOCTEXT("","C52DF118481AE9B503793BACDDBBD6CC","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","4CD46976488F628312A5FEB0B206EE3C","充能"),
		},
		[20105] = 
		{
			ModAdditionalNote = NSLOCTEXT("","46D0607645BA2BE101075B9B6323FC13","幻影自动向最近的敌人冲刺，并对路径上的敌人造成C技能伤害（基础75%）"),
			ModNoteTitle = NSLOCTEXT("","A5C025DE4751F305A8D281BA7C098D34","幻影"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010112