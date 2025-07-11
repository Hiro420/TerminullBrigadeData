local Ins_3020001 = 
{
	ID = 3020001,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleC/Frames/SS_aqxy_icon.SS_aqxy_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3000714",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "子弹命中时本次最终伤害增加%;",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleC/Frames/SS_aqxy_icon.SS_aqxy_icon",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","FB7DBD9C49565203FFBB8EB729D00791","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","B36CB5F84830B0AF55405299C97700F9","迟缓"),
		},
	},
	ModGenreRoutineRowName = "3020001",
}
return Ins_3020001