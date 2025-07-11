local Ins_3010120 = 
{
	ID = 3010120,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3010120",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "核心技能伤害增加-1",
		},
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "武器伤害加:-1%;",
		},
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "角色1技能命中的目标每隔-1秒造成-1伤害，持续-1秒",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/Zhufu_icon/Frames/Ashmedai_icon_3010110_png.Ashmedai_icon_3010110_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30106] = 
		{
			ModAdditionalNote = NSLOCTEXT("","0D5383404E6A5161932F0787DFF8C386","在灼烧状态下，敌人将会持续受到伤害。该状态不可叠加。"),
			ModNoteTitle = NSLOCTEXT("","0603D3034F58241E0FE12D98513E330F","灼烧"),
		},
	},
	ModGenreRoutineRowName = "3010120",
}
return Ins_3010120