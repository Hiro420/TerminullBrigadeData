local Ins_3210001 = 
{
	ID = 3210001,
	Name = nil,
	Desc = nil,
	bIsCustomDesc = true,
	bIstMergeEffectInUI  = true,
	Rarity = 0,
	Icon = "",
	InscriptionDataAry = 
	{
		{
			GenericModifyLevelId = "3210001",
			bIsShowGenericModifyLevelDescInUI = false,
			ModifyLevelDescShowType = 0,
			bIsShowHelpInUI = false,
			bUseGenericModifyLevelData = false,
			Desc = "",
		},
	},
	ModifyLevelDescShowMode = 1,
	ModifyLevelDescFmt = nil,
	bIsUseDescWhenNotActived = false,
	InscriptionCDData = 
	{
		CDName = nil,
		CDDesc = nil,
		CDIcon = "/Game/Rouge/UI/Texture/ICON/Zhufu_icon/Frames/Double-gods_icon_3210001_png.Double-gods_icon_3210001_png",
		bIsShowCD = true,
		bIsShowCDInBuff = true,
	},
	ModAdditionalNoteMap = 
	{
		[30102] = 
		{
			ModAdditionalNote = NSLOCTEXT("","3F2E79A94708BAC2C8A83E850EDDC3F9","迟缓状态下，减少敌人的移动速度。"),
			ModNoteTitle = NSLOCTEXT("","106005BF4F5964861B1BA68DC94BF29A","迟缓"),
		},
		[30105] = 
		{
			ModAdditionalNote = NSLOCTEXT("","076596FA43CDA1AFE5A13DA432F01D38","在放逐状态下，敌人无法移动、攻击。"),
			ModNoteTitle = NSLOCTEXT("","69F4B40F4AD14C5CD9517580F799A275","放逐"),
		},
		[30106] = 
		{
			ModAdditionalNote = NSLOCTEXT("","2F2D4E0749355F18104FA286CC81D85B","在灼烧状态下，敌人将会持续受到伤害。该状态不可叠加。"),
			ModNoteTitle = NSLOCTEXT("","95376F2F4E73047044D1E7A8D903DE12","灼烧"),
		},
	},
	ModGenreRoutineRowName = "3210001",
}
return Ins_3210001