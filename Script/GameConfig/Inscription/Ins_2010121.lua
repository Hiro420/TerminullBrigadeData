local Ins_2010121 = 
{
	ID = 2010121,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_05_png.Module_xiaoqingICON_05_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "角色使用技能",
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
			ModAdditionalNote = NSLOCTEXT("","6CB4DD074C28421559F005A66B519974","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","A369E9AD4D843098C6A373B766221527","充能"),
		},
		[20105] = 
		{
			ModAdditionalNote = NSLOCTEXT("","BB1374804DB68D766D6DEDA644E80072","幻影自动向最近的敌人冲刺，并对路径上的敌人造成C技能伤害（基础75%）"),
			ModNoteTitle = NSLOCTEXT("","B4DA99A2441E936DCED3B2A3975BD878","幻影"),
		},
		[20107] = 
		{
			ModAdditionalNote = NSLOCTEXT("","ADAA7AD34D0C37F82A7E95986CD94483","Q技能的最后一段高额范围伤害(受凝视与Q伤害加成影响）"),
			ModNoteTitle = NSLOCTEXT("","146E1723431BBC101054D697A248F2E8","尾刀"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010121