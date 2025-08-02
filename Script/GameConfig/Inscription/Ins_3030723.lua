local Ins_3030723 = 
{
	ID = 3030723,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleC/Frames/NlRule_ptbd3_icon.NlRule_ptbd3_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "当武器换弹时",
		},
		{
			GenericModifyLevelId = "3030713",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "当武器换弹时移除持久：武器攻击命中增加武器伤害",
		},
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "造成武器伤害时移除未命名BUFF",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleC/Frames/NlRule_ptbd3_icon.NlRule_ptbd3_icon",
		bIsShowCD = false,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30123] = 
		{
			ModAdditionalNote = NSLOCTEXT("","61AB2ABE43F9D8DC341433A6A66470DD","枪械射击命中时提升枪械伤害，最高可叠加15层。"),
			ModNoteTitle = NSLOCTEXT("","151A860A4532CDFAE5DF1B9F09C942D8","持久"),
		},
	},
	ModGenreRoutineRowName = "3030410",
}
return Ins_3030723