local Ins_3010140 = 
{
	ID = 3010140,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3010140",
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
			ModAdditionalNote = NSLOCTEXT("","0F0E3E3E48248F0CE4543C98ECF345CE","在灼烧状态下，敌人将会持续受到伤害。该状态不可叠加。"),
			ModNoteTitle = NSLOCTEXT("","86DA0AD94F3720C4302DE599084F2232","灼烧"),
		},
	},
	ModGenreRoutineRowName = "3010140",
}
return Ins_3010140