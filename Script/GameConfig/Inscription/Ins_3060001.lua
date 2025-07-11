local Ins_3060001 = 
{
	ID = 3060001,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleC/Frames/SS_aqcf_icon.SS_aqcf_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "子弹命中时秒杀小怪，对精英、BOSS无效",
		},
		{
			GenericModifyLevelId = "3000711",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleC/Frames/SS_aqcf_icon.SS_aqcf_icon",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","AFD3CC074EBA329313B15EA4F8492696","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","C06E09B345F42B66122788ACE1029E92","迟缓"),
		},
	},
	ModGenreRoutineRowName = "3060001",
}
return Ins_3060001