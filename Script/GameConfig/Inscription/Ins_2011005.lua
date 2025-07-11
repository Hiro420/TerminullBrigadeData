local Ins_2011005 = 
{
	ID = 2011005,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_02_png.Module_xiaoqingICON_02_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "角色2技能击杀后弱点命中且击杀敌人",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = NSLOCTEXT("","88C7694748DB4395D5FD629994011E05","屠而不倦"),
		CDDesc = NSLOCTEXT("","91046B0A40BF958AB1C8AEAC92BB12FC","匕首击杀或弱点击杀重置E技能冷却区"),
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_02_png.Module_xiaoqingICON_02_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[20102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","5E993BBC4B496E11A1D4B4B4C76DB5A3","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","2465FA3D424972A8399405BACE685797","充能"),
		},
		[20106] = 
		{
			ModAdditionalNote = NSLOCTEXT("","BB2201EC41E697C0E311CDBB37248A7C","指玩家造成的伤害完成击杀，否则不算最后一击"),
			ModNoteTitle = NSLOCTEXT("","E2F9C785441A7C1D9F95CBB8A05887D7","最后一击"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2011005