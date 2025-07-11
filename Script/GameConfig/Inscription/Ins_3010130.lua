local Ins_3010130 = 
{
	ID = 3010130,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3010130",
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
			ModAdditionalNote = NSLOCTEXT("","4B2148AE499854CC0D37EF9C3BA83B8C","在灼烧状态下，敌人将会持续受到伤害。该状态不可叠加。"),
			ModNoteTitle = NSLOCTEXT("","5F45BE1A461CECD5FED8D893D24E84E0","灼烧"),
		},
	},
	ModGenreRoutineRowName = "3010130",
}
return Ins_3010130