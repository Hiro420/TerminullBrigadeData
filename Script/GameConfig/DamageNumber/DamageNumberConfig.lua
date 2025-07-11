local DamageNumberConfig = {
    CN = {
        {
            MaxNumber = 100000,
            DivideNumber = 1,
            Unit = "",
        },
        {
            MaxNumber = 100000000,
            DivideNumber = 10000,
            Unit = " 万",
        },
        {
            DivideNumber = 100000000,
            Unit = " 亿",
        },
    },

    INTL = {
        {
            MaxNumber = 10000,
            DivideNumber = 1,
            Unit = "",
        },
        {
            MaxNumber = 10000000,
            DivideNumber = 1000,
            Unit = " K",
        },
        {
            MaxNumber = 10000000000,
            DivideNumber = 1000000,
            Unit = " M",
        },
        {
            DivideNumber = 1000000000,
            Unit = " B",
        },
    },
}

return DamageNumberConfig