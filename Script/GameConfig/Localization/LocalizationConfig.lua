local ECultureType =
{
    [0] = "zh-Hans-CN",
    [1] = "en",
    [2] = "ko",
    [3] = "ja",
    [4] = "es",
    [5] = "pt",
}
_G.ECultureType = ECultureType

local ECultureINTLType =
{
    [0] = "zh",
    [1] = "en",
    [2] = "ko",
    [3] = "ja",
    [4] = "es",
    [5] = "pt",
}
_G.ECultureINTLType = ECultureINTLType

local EVoiceCultureType =
{
    [0] = "Chinese",
    [1] = "English",
    [2] = "Japanese",
    [3] = "Korean",
}
_G.EVoiceCultureType = EVoiceCultureType

local CultureToVoice =
{
    ["zh-Hans-CN"] = 0, --"Chinese",
    ["en"] = 1, --"English",
    ["ko"] = 3,  --"Korean",
    ["ja"] = 2,    --"Japanese",
}
_G.CultureToVoice = CultureToVoice


-- https://doc.weixin.qq.com/doc/w3_AUMA6AZCAIMXF9msySeSxmRI3cTJF?scode=AJEAIQdfAAot0HHTQZAUMA6AZCAIM
local ECultureType_Report =
{
    [0] = 1,--"zh",
    [1] = 2,--"en",
    [2] = 4,--"ko",
    [3] = 3,--"ja",
    [4] = 8,--"es",
    [5] = 14,--"pt",
}
_G.ECultureType_Report = ECultureType_Report

local LocalizationConfig =
{

}

return LocalizationConfig