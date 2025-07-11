local GenericModifyConfig = {
    GenericModifySlotToSpritePath =
    {
        --射击
        [1] = "/Game/Rouge/UI/Atlas_DT/IconHUDSkill/Frames/Icon_Shoot.Icon_Shoot",
        --换弹
        [2] = "/Game/Rouge/UI/Atlas_DT/IconHUDSkill/Frames/Icon_Change.Icon_Change",
        --冲刺
        [3] = "/Game/Rouge/UI/Atlas_DT/IconHUDSkill/Frames/Icon_Dodge.Icon_Dodge",
        --C
        [4] = "/Game/Rouge/UI/Atlas_DT/IconHUDSkill/Frames/Icon_MinorSkills.Icon_MinorSkills",
        --E
        [5] = "/Game/Rouge/UI/Atlas_DT/IconHUDSkill/Frames/Icon_keySkills.Icon_keySkills",
        --Q
        [6] = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_taluoso_06_png.Module_taluoso_06_png",
        --求援
        [7] = "/Game/Rouge/UI/Atlas_Alpha/A_DT/ICON/MOZU_SK/Frames/Module_taluoso_02_png.Module_taluoso_02_png",
    },

    RarityToEffectWidget =
    {
        [UE.ERGItemRarity.EIR_Normal] = "AutoLoad_RarityToEff_Green",
        [UE.ERGItemRarity.EIR_Excellent] = "AutoLoad_RarityToEff_Green",
        [UE.ERGItemRarity.EIR_Rare] = "AutoLoad_RarityToEff_Green",
        [UE.ERGItemRarity.EIR_Epic] = "AutoLoad_RarityToEff_Purple",
        [UE.ERGItemRarity.EIR_Legend] = "AutoLoad_RarityToEff_Orang",
    },

    GroupIdToHoverColor =
    {
        ['0'] = UE.FLinearColor(0.109462, 0.445201, 0.745404),
        ['1'] = UE.FLinearColor(0.745404, 0.049707, 0.637597),
        ['2'] = UE.FLinearColor(0.745404, 0.057805, 0),
        ['3'] = UE.FLinearColor(0.212231, 0.887923, 0.775822),
        ['4'] = UE.FLinearColor(0.242281, 0.036889, 0.745404),
        ['5'] = UE.FLinearColor(0, 0.745404, 0.242281),
        ['6'] = UE.FLinearColor(0.745404, 0.417885, 0),
        ['7'] = UE.FLinearColor(0.0865, 0.08022, 0.887923),
        ['8'] = UE.FLinearColor(0.109462, 0.445201, 0.745404),
    },

    GroupIdToEffectWidget =
    {
        ['0'] = "WBP_GenericModifyChooseItem_blue",
        ['1'] = "WBP_GenericModifyChooseItem_purple",
        ['2'] = "WBP_GenericModifyClickEffect_OrangeRed",
        ['3'] = "WBP_GenericModifyClickEffect_DarkGreen",
        ['4'] = "WBP_GenericModifyChooseItem_red",
        ['5'] = "WBP_GenericModifyChooseItem_green",
        ['6'] = "WBP_GenericModifyClickEffect_Yellow",
        ['7'] = "WBP_GenericModifyClickEffect_DarkBlue",
        ['8'] = "WBP_GenericModifyClickEffect_DarkBlue",
    }
}

return GenericModifyConfig
