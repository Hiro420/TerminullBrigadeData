local Ins_2010031 = 
{
	ID = 2010031,
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
		CDName = NSLOCTEXT("","379E15EB4B6AA889A0EC939345177A55","暗送毒波"),
		CDDesc = NSLOCTEXT("","2D42F8B145FB6EA63D8F8BAF0D2C4378","发射额外匕首"),
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_15_png.Module_xiaoqingICON_15_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[20101] = 
		{
			ModAdditionalNote = NSLOCTEXT("","3BEC7D2847E28C78AEB341BB815A60CE","匕首命中敌人后，将发射复数枚自动追踪的匕首追踪附近的敌人；优先锁定更多的敌人而非单一敌人"),
			ModNoteTitle = NSLOCTEXT("","C47D57CF4F5A9095AC4E09921D7D046C","分裂"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010031