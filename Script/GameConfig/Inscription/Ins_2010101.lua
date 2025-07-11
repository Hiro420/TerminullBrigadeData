local Ins_2010101 = 
{
	ID = 2010101,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_xiaoqingICON_24_png.Module_xiaoqingICON_24_png",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "",
			bIsShowGenericModifyLevelDescInUI = true,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "击杀目标后向弹夹中装填一发致命弹药（枪械下一发伤害提高35%)",
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
		[20106] = 
		{
			ModAdditionalNote = NSLOCTEXT("","49853F3B4E16E74429AC188318B6794E","指玩家造成的伤害完成击杀，否则不算最后一击"),
			ModNoteTitle = NSLOCTEXT("","DD17444B445D3FCD63A55E81FD039573","最后一击"),
		},
		[20102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","AC915C6B4E0FC7CAFFA51CB8547E8E3C","瞬间回复对应技能效果的消耗【能量或冷却】，使之可以立即使用"),
			ModNoteTitle = NSLOCTEXT("","C340143F43C8A6971F5752B887CDBDD0","充能"),
		},
	},
	ModGenreRoutineRowName = "",
}
return Ins_2010101