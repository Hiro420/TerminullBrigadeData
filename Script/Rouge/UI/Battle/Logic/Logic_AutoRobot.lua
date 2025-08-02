local M = {IsInit = false}
_G.LogicAutoRobot = _G.LogicAutoRobot or M

function LogicAutoRobot.Init()
  if LogicAutoRobot.IsInit then
    return
  end
  LogicAutoRobot.IsInit = true
  LogicAutoRobot.IsAutoBot = false
  LogicAutoRobot.BotNamePrefix = ""
  LogicAutoRobot.IsTeamCaptain = false
  LogicAutoRobot.IsPlayWithBot = false
  LogicAutoRobot.StartGameNum = 3
  LogicAutoRobot.BotHeroId = 1003
  LogicAutoRobot.ModeList = {}
  LogicAutoRobot.ModeIndex = 1
  LogicAutoRobot.BotFixedName = ""
  LogicAutoRobot.IsLogin = false
  LogicAutoRobot.IsLoopMode = false
end

function LogicAutoRobot.GetIsAutoBot()
  return LogicAutoRobot.IsAutoBot
end

function LogicAutoRobot.SetIsAutoBot(InIsAutoBot)
  LogicAutoRobot.IsAutoBot = InIsAutoBot
end

function LogicAutoRobot.GetBotNamePrefix()
  return LogicAutoRobot.BotNamePrefix
end

function LogicAutoRobot.SetBotNamePrefix(InBotNamePrefix)
  LogicAutoRobot.BotNamePrefix = InBotNamePrefix
end

function LogicAutoRobot.GetIsTeamCaptain()
  return LogicAutoRobot.IsTeamCaptain
end

function LogicAutoRobot.SetIsTeamCaptain(InIsCaptain)
  LogicAutoRobot.IsTeamCaptain = InIsCaptain
end

function LogicAutoRobot.GetIsPlayWithBot()
  return LogicAutoRobot.IsPlayWithBot
end

function LogicAutoRobot.SetIsPlayWithBot(InIsPlayWithBot)
  LogicAutoRobot.IsPlayWithBot = InIsPlayWithBot
end

function LogicAutoRobot.GetStartGameNum()
  return LogicAutoRobot.StartGameNum
end

function LogicAutoRobot.SetStartGameNum(InStartGameNum)
  LogicAutoRobot.StartGameNum = InStartGameNum
end

function LogicAutoRobot.GetBotHeroId()
  return LogicAutoRobot.BotHeroId
end

function LogicAutoRobot.SetBotHeroId(InBotHeroId)
  LogicAutoRobot.BotHeroId = InBotHeroId
end

function LogicAutoRobot.SetBotGameModeList(InModeList)
  LogicAutoRobot.ModeList = InModeList
end

function LogicAutoRobot.GetTargetGameMode()
  local IsLoopMode = LogicAutoRobot.GetIsLoopMode()
  if IsLoopMode and LogicAutoRobot.ModeIndex > #LogicAutoRobot.ModeList then
    print("LogicAutoRobot.GetTargetGameMode Reset ModeIndex")
    LogicAutoRobot.ModeIndex = 1
  end
  return LogicAutoRobot.ModeList[LogicAutoRobot.ModeIndex]
end

function LogicAutoRobot.AddModeIndex()
  LogicAutoRobot.ModeIndex = LogicAutoRobot.ModeIndex + 1
end

function LogicAutoRobot.GetBotFixedName()
  return LogicAutoRobot.BotFixedName
end

function LogicAutoRobot.SetBotFixedName(InBotFixedName)
  LogicAutoRobot.BotFixedName = InBotFixedName
end

function LogicAutoRobot.SetIsLoopMode(InIsLoopMode)
  LogicAutoRobot.IsLoopMode = InIsLoopMode
end

function LogicAutoRobot.GetIsLoopMode(...)
  return LogicAutoRobot.IsLoopMode
end
