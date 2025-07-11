local Ins_2011015 = 
{
	ID = 2011015,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_22_png.Module_xiaoqingICON_22_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "角色Move技能造成伤害对目标造成Q技能倍击伤害",
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
		[20105] = 
		{
			ModAdditionalNote = NSLOCTEXT("","A83D50FA41CCB35EC7384A9C73DCD877","幻影自动向最近的敌人冲刺，并对路径上的敌人造成C技能伤害（基础75%）"),
			ModNoteTitle = NSLOCTEXT("","8F98AF3A4FC3FBDBD6F50582AAA94C70","幻影"),
		},
		[20104] = 
		{
			ModAdditionalNote = NSLOCTEXT("","BBDA853B445FCB79DDB15AA6F5F395D5","每层提升大招伤害15%，最多5层。叠满后额外受到青10%伤害，持续6s"),
			ModNoteTitle = NSLOCTEXT("","F76353B7472F501177D8369E784EBA2D","凝视"),
		},
		[20107] = 
		{
			ModAdditionalNote = NSLOCTEXT("","D3EC9E954AEA5C6C37C82C95B3BCF785","Q技能的最后一段高额范围伤害(受凝视与Q伤害加成影响）"),
			ModNoteTitle = NSLOCTEXT("","5EFC0F244E5BD5D8FE74319012AF92C9","尾刀"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2011015