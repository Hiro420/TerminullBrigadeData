local PlayerInfoConfig = 
{
    DefaultBannerInfo = {bannerID=0,bannerNameLocMeta=NSLOCTEXT("resource_TBBanner","bannerName_82000","测试横幅0"),bannerIconPathInInfo="/Game/Rouge/UI/Atlas_DT/BusinessCard/Frames/Icon_Card_G05.Icon_Card_G05",bannerIconPathInCard="/Game/Rouge/UI/Atlas_DT/BusinessCard/Frames/Icon_Card_G05.Icon_Card_G05",acquirePathID=0,EffectPath=""},
    PlayerInfoRequestModeIdList =
    {
        TableEnums.ENUMGameMode.TOWERClIMBING,
        TableEnums.ENUMGameMode.BOSSRUSH,
        TableEnums.ENUMGameMode.SURVIVAL,
        TableEnums.ENUMGameMode.SEASONNORMAL,
        TableEnums.ENUMGameMode.NORMAL,
    },
}

local BattleHistoryGenericSlotList = {
    [1] = 1,    -- 射击
    [2] = 2,    -- 换弹
    [3] = 3,    -- 闪避
    [4] = 4,    -- 次要技能
    [5] = 5,    -- 主要技能
}

_G.BattleHistoryGenericSlotList = BattleHistoryGenericSlotList

return PlayerInfoConfig