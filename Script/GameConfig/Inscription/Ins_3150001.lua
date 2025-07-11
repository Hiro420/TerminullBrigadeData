local Ins_3150001 = 
{
	ID = 3150001,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_DT/IconRuleC/Frames/SS_ayjz_icon.SS_ayjz_icon",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3010240",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "在目标位置生成一个爱心炸弹，遇敌爆炸，使得范围-1下的敌人受到-1伤害，并使目标进入混乱状态-1秒",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Sprite/IconRuleC/Frames/SS_ayjz_icon.SS_ayjz_icon",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30130] = 
		{
			ModAdditionalNote = NSLOCTEXT("","DDF0CB7F47102D0A48866697E00A540C","音乐将敌人感化，被感化的敌人将攻击其他敌人"),
			ModNoteTitle = NSLOCTEXT("","21D184C843B1FE286C3F1E99423A2C88","倒戈"),
		},
		[30127] = 
		{
			ModAdditionalNote = NSLOCTEXT("","2829A5A34E5294CB5F0778AE3B2D06AE","一团迷人的烟雾，出现时造成Aoe伤害，并持续对范围内敌人施加眩晕"),
			ModNoteTitle = NSLOCTEXT("","949BA2434FEFAE1AABF79E80151BAA3D","欢情之雾"),
		},
	},
	ModGenreRoutineRowName = "3150001",
}
return Ins_3150001