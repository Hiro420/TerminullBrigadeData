local Ins_3270001 = 
{
	ID = 3270001,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3270001",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "受到电击伤害时",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/Zhufu_icon/Frames/Double_gods_icon_3270001_png.Double_gods_icon_3270001_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30116] = 
		{
			ModAdditionalNote = NSLOCTEXT("","0057020F4E1A3C8C797CD4A07FB6383C","一道可在15米内至多3名敌人间弹射的闪电"),
			ModNoteTitle = NSLOCTEXT("","3D5C1D82462200750CDE5496DFE32E43","闪电链"),
		},
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","9959E91D4EAE971EF51DD6940A1D0069","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","F9F3155B4ACC5BBC40484AA0E549B025","迟缓"),
		},
	},
	ModGenreRoutineRowName = "3270001",
}
return Ins_3270001