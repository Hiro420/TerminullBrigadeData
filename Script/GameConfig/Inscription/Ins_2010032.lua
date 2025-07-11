local Ins_2010032 = 
{
	ID = 2010032,
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
		CDName = NSLOCTEXT("","55B8F189445739E72E2B4698AB59C58F","暗送毒波"),
		CDDesc = NSLOCTEXT("","295577E84540232E701AFB9B757FCAEE","发射额外匕首"),
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_15_png.Module_xiaoqingICON_15_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[20101] = 
		{
			ModAdditionalNote = NSLOCTEXT("","2A380BA4485F85B8E386D6BD525AE92B","匕首命中敌人后，将发射复数枚自动追踪的匕首追踪附近的敌人；优先锁定更多的敌人而非单一敌人"),
			ModNoteTitle = NSLOCTEXT("","B734F8644FC69B1BD88B21A0FB32CF95","分裂"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010032