local Ins_3000725 = 
{
	ID = 3000725,
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
			Desc = "有25%概率",
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
			ModAdditionalNote = NSLOCTEXT("","FCC74B764E0478B6E666389F4773A6A1","敌人被冻成冰块，攻击可以推动冰块"),
			ModNoteTitle = NSLOCTEXT("","5895FE6E454547540987EDA963FC7456","冰块"),
		},
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","157C822E48760990B2C4B3A4C6187636","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","8F510F604CB25D2BAF98A6915A3C8A1A","迟缓"),
		},
	},
	ModGenreRoutineRowName = "3000711",
}
return Ins_3000725