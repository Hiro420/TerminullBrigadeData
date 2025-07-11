local Ins_3000732 = 
{
	ID = 3000732,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleA/Frames/SecureRule_ptbd2_icon.SecureRule_ptbd2_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3000712",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "有40%概率",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleA/Frames/SecureRule_ptbd2_icon.SecureRule_ptbd2_icon",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30131] = 
		{
			ModAdditionalNote = NSLOCTEXT("","06A114A9444808E6D2E62E9864E17925","敌人被冻成冰块，攻击可以推动冰块"),
			ModNoteTitle = NSLOCTEXT("","3AD1F3BA4DD653757A10B39CD9A11E3F","冰块"),
		},
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","72F4B17541E5E8F599B2B4BB48F3CC28","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","D443DA5847A26B2C116C4999A52E03F0","迟缓"),
		},
	},
	ModGenreRoutineRowName = "3000712",
}
return Ins_3000732