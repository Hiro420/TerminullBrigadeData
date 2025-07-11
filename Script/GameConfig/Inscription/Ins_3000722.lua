local Ins_3000722 = 
{
	ID = 3000722,
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
			Desc = "有30%概率",
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
			ModAdditionalNote = NSLOCTEXT("","AF1B3B7948FBA50140A2F489685693C7","敌人被冻成冰块，攻击可以推动冰块"),
			ModNoteTitle = NSLOCTEXT("","8B5ACCA94DA67368525A1AB903782DB5","冰块"),
		},
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","AFBE29E7451FD9EBBD98DA8059B10B33","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","916431D2404771E2CB409185D5142778","迟缓"),
		},
	},
	ModGenreRoutineRowName = "3000712",
}
return Ins_3000722