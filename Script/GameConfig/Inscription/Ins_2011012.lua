local Ins_2011012 = 
{
	ID = 2011012,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_10_png.Module_xiaoqingICON_10_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "玩家每为敌人附加一次凝视buff，下次shift额外创建一个幻影，短暂延迟后自动冲刺攻击附近的敌人（最多一次创建5个）",
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
			ModAdditionalNote = NSLOCTEXT("","7394CF954CC6970B9696A99C76619457","幻影自动向最近的敌人冲刺，并对路径上的敌人造成C技能伤害（基础75%）"),
			ModNoteTitle = NSLOCTEXT("","59495ECE45583871C643FCA51B6DC9A5","幻影"),
		},
		[20104] = 
		{
			ModAdditionalNote = NSLOCTEXT("","39F284B64EB251630BF1F9AF29EB0DD7","每层提升大招伤害15%，最多5层。叠满后额外受到青10%伤害，持续6s"),
			ModNoteTitle = NSLOCTEXT("","2DA8C6D14B626B000D100FB7C2A9A043","凝视"),
		},
		[20107] = 
		{
			ModAdditionalNote = NSLOCTEXT("","564A0A08422509E1137B7E847E8D1F92","Q技能的最后一段高额范围伤害(受凝视与Q伤害加成影响）"),
			ModNoteTitle = NSLOCTEXT("","F62521C3410CD896FCBD2491A21C1DF1","尾刀"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2011012