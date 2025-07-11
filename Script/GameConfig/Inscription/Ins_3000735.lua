local Ins_3000735 = 
{
	ID = 3000735,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleA/Frames/SecureRule_ptbd5_icon.SecureRule_ptbd5_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3000711",
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
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleA/Frames/SecureRule_ptbd5_icon.SecureRule_ptbd5_icon",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30131] = 
		{
			ModAdditionalNote = NSLOCTEXT("","4BDC37F6414ED69883BF08A181F1C06A","敌人被冻成冰块，攻击可以推动冰块"),
			ModNoteTitle = NSLOCTEXT("","B3975B244980B6F8C89F5D9A6B395376","冰块"),
		},
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","625583F345CB6FEF5334AC805701EA83","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","779256364603BFE7E7F769B621F27EA7","迟缓"),
		},
	},
	ModGenreRoutineRowName = "3000711",
}
return Ins_3000735