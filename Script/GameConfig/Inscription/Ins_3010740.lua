local Ins_3010740 = 
{
	ID = 3010740,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleA/Frames/AyRule_CSbd_icon.AyRule_CSbd_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3010740",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "当造成任意伤害时本次最终伤害增加60%;",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleA/Frames/AyRule_CSbd_icon.AyRule_CSbd_icon",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30126] = 
		{
			ModAdditionalNote = NSLOCTEXT("","E68B11704DD2EDC0BF6238A6CE3A7DBB","焚身状态下造成持续的Dot伤害，最高可叠加5层"),
			ModNoteTitle = NSLOCTEXT("","AAD6BCEC498399514CE0708BBC6179DE","焚身"),
		},
		[30127] = 
		{
			ModAdditionalNote = NSLOCTEXT("","CC5F61B840EA98D84B517BB06F5513B6","一团迷人的烟雾，出现时造成Aoe伤害，并持续对范围内敌人施加眩晕"),
			ModNoteTitle = NSLOCTEXT("","860450F04E2E4A4BF0EA4E87EB76275B","欢情之雾"),
		},
	},
	ModGenreRoutineRowName = "3010740",
}
return Ins_3010740