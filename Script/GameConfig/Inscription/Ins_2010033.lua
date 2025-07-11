local Ins_2010033 = 
{
	ID = 2010033,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_15_png.Module_xiaoqingICON_15_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "子弹命中时向目标发射一次伤害增加0%的E技能",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = NSLOCTEXT("","7C4E54774979458FCEBB83A59D36EFEC","暗送毒波"),
		CDDesc = NSLOCTEXT("","45117BD44B15994DBA3044B84C048A81","发射额外匕首"),
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_15_png.Module_xiaoqingICON_15_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[20101] = 
		{
			ModAdditionalNote = NSLOCTEXT("","CA9A88054690B337A18D02ADE52F0689","匕首命中敌人后，将发射复数枚自动追踪的匕首追踪附近的敌人；优先锁定更多的敌人而非单一敌人"),
			ModNoteTitle = NSLOCTEXT("","C5E6E2EC470CCB2376B1889A70E7DF3A","分裂"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010033