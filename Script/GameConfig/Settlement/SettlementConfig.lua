local SettlementDamageTitle = {
    NSLOCTEXT("SettlementDamageTitle", "SettlementDamageTitle1", "战地终结"),
    NSLOCTEXT("SettlementDamageTitle", "SettlementDamageTitle2", "输出狂魔"),
    NSLOCTEXT("SettlementDamageTitle", "SettlementDamageTitle3", "天生富人"),
}

_G.SettlementDamageTitle = _G.SettlementDamageTitle or SettlementDamageTitle

local SettlementStatus = {
    Finish = 1,
    Exit = 2,
    AllDie = 3,
}

_G.SettlementStatus = _G.SettlementStatus or SettlementStatus

local ESettleViewStatus = {
    MvpView = 1,
    ResultView = 2,
    TeamView = 3,
    IncomeView = 4,
    PlayerInfoView = 5,
    ProficiencyExpView = 6,
}

_G.ESettleViewStatus = _G.ESettleViewStatus or ESettleViewStatus

local SettlementViewStepInfo = {
    [ESettleViewStatus.MvpView] = {FuncName = "ShowMvp", Duration = 1000, FadeOutAniStartTime = nil, AniName = "", FadeOutAniName = "", ExitFuncName = "ExitMvp"},
    [ESettleViewStatus.ResultView] = {FuncName = "ShowResultView", Duration = 3.05, FadeOutAniStartTime = nil, AniName = "Ani_settlement", ExitFuncName = "ExitResultView"},
    [ESettleViewStatus.TeamView] = {FuncName = "ShowTeamView", Duration = 9, FadeInAniStartTime = 0, FadeOutAniStartTime = 8.8, AniTargetName = "WBP_SettlementTeamView", AniName = "Ani_in2", FadeOutAniName = "Ani_out", ExitFuncName = "ExitTeamView"},
    [ESettleViewStatus.IncomeView] = {FuncName = "ShowIncomeView", Duration = 10000, AniName = ""},
}

_G.SettlementViewStepInfo = _G.SettlementViewStepInfo or SettlementViewStepInfo

local ESettleIncomeViewStep = {
    Init = 0, 
    ModeInfo = 1, --探索结束/探索成功标题
    BattleLagacy = 3, --金手指
    Profy = 2, --熟练度
    Chip = 5, --模组奖励
    Income = 4,--其他奖励
    Interact = 6, --功能按钮
}

_G.ESettleIncomeViewStep = _G.ESettleIncomeViewStep or ESettleIncomeViewStep

local SettlementStepInfo = {
    [ESettleIncomeViewStep.Init] = {FuncName = "ShowInit", Duration = 0, AniName = ""},
    [ESettleIncomeViewStep.ModeInfo] = {FuncName = "ShowModeInfo", Duration = 0.5, AniName = "Ani_Title_in"},
    [ESettleIncomeViewStep.BattleLagacy] = {FuncName = "ShowBattleLagacyStep", Duration = 100, AniName = "Ani_BattleLagacy_in"},
    [ESettleIncomeViewStep.Profy] = {FuncName = "ShowProfy", Duration = 1, AniName = "Ani_Text_in"},
    [ESettleIncomeViewStep.Chip] = {FuncName = "ShowChip", Duration = 2, AniName = "Ani_Chip_in"},
    [ESettleIncomeViewStep.Income] = {FuncName = "ShowIncome", Duration = 2, AniName = "Ani_OtherInCome_in"},
    [ESettleIncomeViewStep.Interact] = {FuncName = "ShowInteract", Duration = 2, AniName = "Ani_Operator_in"},
}

_G.SettlementStepInfo = _G.SettlementStepInfo or SettlementStepInfo

local SettlementIncomePropId = 
{
    99026,
    99027,
    99028,
    99029,
    99030,
    99031,
    99032,
    99033,
    99034,
    99018,
    99989,
    99019,
}

_G.SettlementIncomePropId = _G.SettlementIncomePropId or SettlementIncomePropId

local SettlementPrivilegeConfig = {
    [UE.ERGPrivilegeSource.MonthCard] = {DescFmt = NSLOCTEXT("SettlementPrivilegeConfig", "MonthCardDescFmt", "{0}%"), IconPath = "/Game/Rouge/UI/Atlas/IconMonster/Frames/Bat_touming_icon.Bat_touming_icon"},
    [UE.ERGPrivilegeSource.NetBar] = {DescFmt = NSLOCTEXT("SettlementPrivilegeConfig", "NetBarDescFmt", "{0}%"), IconPath = "/Game/Rouge/UI/Atlas_DT/IconNetBar/Frames/Icon_NetBar_01.Icon_NetBar_01"},
}

_G.SettlementPrivilegeConfig = _G.SettlementPrivilegeConfig or SettlementPrivilegeConfig

local SettlementBeginnerClearConfig = {
    Name = NSLOCTEXT("SettlementBeginnerClearConfig", "SettlementBeginnerClearConfigName", "首通"),
}

_G.SettlementBeginnerClearConfig = _G.SettlementBeginnerClearConfig or SettlementBeginnerClearConfig

local SettlementConfig = {
    LongPressTime = 0.5,
    IncreaseRevertTime = 0.3,
    ShowRoleLightTime = 1,
    PrivilegeFmt = "+%d ",
}

return SettlementConfig




