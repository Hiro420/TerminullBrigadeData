local Ins_3330001 = 
{
	ID = 3330001,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3330001",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "命中触发一次伤害值为-1的杀毒伤害",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/Zhufu_icon/Frames/Double_gods_icon_3330001_png.Double_gods_icon_3330001_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30106] = 
		{
			ModAdditionalNote = NSLOCTEXT("","D1C14D9E4C6307EA79AF8DA88AFE8A75","在灼烧状态下，敌人将会持续受到伤害。该状态不可叠加。"),
			ModNoteTitle = NSLOCTEXT("","CB9E2D3F4F85E06CB5856CAB34F0EACF","灼烧"),
		},
		[30122] = 
		{
			ModAdditionalNote = NSLOCTEXT("","BD848F04417D3B623402288374435997","引来一道闪电，攻击敌人。"),
			ModNoteTitle = NSLOCTEXT("","017B6CC64FBC08375BD43090A98DBDA3","闪电"),
		},
	},
	ModGenreRoutineRowName = "3330001",
}
return Ins_3330001