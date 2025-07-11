local Ins_2011018 = 
{
	ID = 2011018,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_16_png.Module_xiaoqingICON_16_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "带有凝视的敌人死亡，会传递100%凝视层数给附近敌人",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "",
		bIsShowCD = false,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[20104] = 
		{
			ModAdditionalNote = NSLOCTEXT("","FE546DF04D9EFE999AA390AD6C06B00E","每层提升大招伤害15%，最多5层。叠满后额外受到青10%伤害，持续6s"),
			ModNoteTitle = NSLOCTEXT("","B0698D9C445663E77D3BB39FA571F35E","凝视"),
		},
		[20107] = 
		{
			ModAdditionalNote = NSLOCTEXT("","583A83E34795604F8DE433B1AC3390F5","Q技能的最后一段高额范围伤害(受凝视与Q伤害加成影响）"),
			ModNoteTitle = NSLOCTEXT("","D14BD8E24DA2D2CE0028158D301BFD6D","尾刀"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2011018