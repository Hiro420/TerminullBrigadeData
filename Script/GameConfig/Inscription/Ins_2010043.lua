local Ins_2010043 = 
{
	ID = 2010043,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_03_png.Module_xiaoqingICON_03_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "每创建5把匕首，下一把匕首被额外强化0.7%伤害（分裂得到的匕首继承伤害强化）,最多叠加4层",
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
		[20101] = 
		{
			ModAdditionalNote = NSLOCTEXT("","AB9BA65D43B4F6ECA7FF7F974C1AD23A","匕首命中敌人后，将发射复数枚自动追踪的匕首追踪附近的敌人；优先锁定更多的敌人而非单一敌人"),
			ModNoteTitle = NSLOCTEXT("","72BD20204AC9FA0038250C8D0FD861EB","分裂"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010043