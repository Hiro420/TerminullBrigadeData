local BatchCheatConfig = 
{
    ------------------------ 局外 -----------------------------------------
    -- 角色ID列表
    RoleIdList = 
    {
        100003,
        100006,
        100007,
        100008,
        100011,
        100012,
    },
    -- 芯片资源id：数量，绑定英雄id，词条id，装备英雄id，装备槽位，子属性列表
    ChipCfgListMap = 
    {
        [1] =
        {
            {ResId = 36111, Num = 1, BindHeroID = 0, Inscription = 0, EquipHeroID = 1010, EquipSlot = 1, SubAttr = {
                    {
                        attrID = 2,
                        value = 4,
                    },
                    {
                        attrID = 6,
                        value = 3,
                    }
                }
            },
        },
        [2] =
        {
            {ResId = 36111, Num = 1, BindHeroID = 0, Inscription = 0, EquipHeroID = 1010, EquipSlot = 1, SubAttr = {
                    {
                        attrID = 2,
                        value = 4,
                    },
                    {
                        attrID = 6,
                        value = 3,
                    }
                }
            },
        },
    },
    -- 天赋id
    TalentCfgListMap =
    {
        [1] =
        {
            {TalentId = 1010101},
        },
        [2] =
        {
            {TalentId = 1010101},
        },
    },
    -- 英雄id：熟练度等级
    ProfyCfgListMap = 
    {
        [1] =
        {
            [1010] = {ProfyLv = 2},
        },
        [2] =
        {
            [1010] = {ProfyLv = 2},
        },
    },
    -- 任务组id：任务id
    PlotFragmentCfg = 
    {
        [1] =
        {
            {TaskGroupID = 100101, TaskID = 910101},
            {TaskGroupID = 100101, TaskID = 910102},
            {TaskGroupID = 100101, TaskID = 910103},
            {TaskGroupID = 100101, TaskID = 910104},
            {TaskGroupID = 100101, TaskID = 910105},
            {TaskGroupID = 100101, TaskID = 910106},

            {TaskGroupID = 100102, TaskID = 910201},
            {TaskGroupID = 100102, TaskID = 910202},
            {TaskGroupID = 100102, TaskID = 910203},
            {TaskGroupID = 100102, TaskID = 910204},
            {TaskGroupID = 100102, TaskID = 910205},

            {TaskGroupID = 100103, TaskID = 910301},
            {TaskGroupID = 100103, TaskID = 910302},
            {TaskGroupID = 100103, TaskID = 910303},
            {TaskGroupID = 100103, TaskID = 910304},
            {TaskGroupID = 100103, TaskID = 910305},
        },
    },
    -- 经验值
    EXPCfg =
    {
        [1] = 10000,
        [2] = 100,
    },
    -- 世界id：难度
    LevelCfg =
    {
        {WorldId = 23, Level = 7},
        {WorldId = 24, Level = 7},
        {WorldId = 30, Level = 7},
    },
    -----------------------------------------------------------------------

    ------------------------ 局内 -----------------------------------------
    -- 潜能秘钥列表
    SpecificModifyList =
    {
        [1] =
        {
            9040111,
        },
    },

    -- 权限id:等级
    GenericModifyList =
    {
        [1] =
        {
            [3000210] = 2,
            [3000310] = 3,
            [3000410] = 1,
            [3000740] = 1,
        },
    },

    -- 密卷id
    AttributeModifyList =
    {
        [1] =
        {
            4003000,
            4003011,
            4012017,
        },
    },

    -----------------------------------------------------------------------
}

return BatchCheatConfig
