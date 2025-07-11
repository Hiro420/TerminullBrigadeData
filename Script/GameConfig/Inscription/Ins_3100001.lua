local Ins_3100001 = 
{
	ID = 3100001,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleC/Frames/SS_ayaq_icon.SS_ayaq_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3505200",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "当造成任意伤害时攻击附带目标最大生命比例的真实伤害，小怪30%、精英1%、BOSS0.3%",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleC/Frames/SS_ayaq_icon.SS_ayaq_icon",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30127] = 
		{
			ModAdditionalNote = NSLOCTEXT("","48B5035E43FE71B74CA284B533099201","一团迷人的烟雾，出现时造成Aoe伤害，并持续对范围内敌人施加眩晕"),
			ModNoteTitle = NSLOCTEXT("","455996174BA9DFE22E004C882108E872","欢情之雾"),
		},
	},
	ModGenreRoutineRowName = "3100001",
}
return Ins_3100001