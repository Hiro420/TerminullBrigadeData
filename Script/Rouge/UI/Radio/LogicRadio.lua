local M = {IsInit = false}
_G.LogicRadio = _G.LogicRadio or M
local BindCharacterBeginInteract = function(IsBind)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  if Character then
    local InteractHandle = Character:GetComponentByClass(UE.URGInteractHandle:StaticClass())
    if InteractHandle then
      if IsBind then
        InteractHandle.OnBeginInteract:Add(GameInstance, LogicRadio.BindOnBeginInteract)
      else
        InteractHandle.OnBeginInteract:Remove(GameInstance, LogicRadio.BindOnBeginInteract)
      end
    end
  end
end
local InitStartMapRadioInfoTable = function()
  LogicRadio.StartMapRadioInfoTable = {
    RadioConditionId = -1,
    RadioId = -1,
    ProgressIndex = -1
  }
end

function LogicRadio.Init()
  if LogicRadio.IsInit then
    print("Radio\229\183\178\229\136\157\229\167\139\229\140\150")
    local RGTutorialLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
    if RGTutorialLevelSystem and RGTutorialLevelSystem:IsFreshPlayer() and LogicRadio.RadioWidget and LogicRadio.RadioWidget:IsValid() then
      LogicRadio.RadioWidget:RemoveFromParent()
    end
    LogicRadio.RadioWidget = nil
    BindCharacterBeginInteract(true)
    return
  end
  LogicRadio.RadioEventInfos = {}
  LogicRadio.RadioPlayList = {}
  LogicRadio.RadioPlayedList = {}
  LogicRadio.RadioExecuteCount = {}
  InitStartMapRadioInfoTable()
  LogicRadio.RadioWidget = nil
  LogicRadio.IsInit = true
  LogicRadio.TransformRadioConditionDataTable()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGWaveWindowManager:StaticClass())
  if WaveWindowManager then
    WaveWindowManager.OnShowRadioWindow:Add(GameInstance, LogicRadio.BindOnShowRadioWindow)
  end
  BindCharacterBeginInteract(true)
end

function LogicRadio.TriggerStartRadio()
  LogicRadio.ExecuteRadioConditionByConditionId(8, {})
end

function LogicRadio:BindOnBeginInteract(Target)
end

function LogicRadio.TransformRadioConditionDataTable()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local AllRadioConditions = DTSubsystem:GetAllRadioConditions(nil)
  for i, SingleRadioCondition in iterator(AllRadioConditions) do
    local SingleRadioConditionTable = {
      ID = 0,
      ConditionNote = "",
      TriggerCondition = {
        ConditionId = 0,
        Params = {}
      },
      PreCondition = {},
      IsMutex = false,
      TypeList = {
        {
          Type = "Radio",
          IndexList = {},
          WeightList = {}
        },
        {
          Type = "Bubble",
          IndexList = {},
          WeightList = {}
        },
        {
          Type = "Subtitle",
          IndexList = {},
          WeightList = {}
        }
      }
    }
    SingleRadioConditionTable.ID = SingleRadioCondition.ID
    SingleRadioConditionTable.ConditionNote = SingleRadioCondition.ConditionNote
    SingleRadioConditionTable.TriggerCondition.ConditionId = SingleRadioCondition.TriggerCondition.ConditionId
    for i, SingleParam in iterator(SingleRadioCondition.TriggerCondition.Params) do
      table.insert(SingleRadioConditionTable.TriggerCondition.Params, SingleParam)
    end
    for i, SinglePreCondition in iterator(SingleRadioCondition.PreCondition) do
      local SinglePreConditionTable = {
        ConditionId = 0,
        Params = {}
      }
      SinglePreConditionTable.ConditionId = SinglePreCondition.ConditionId
      SinglePreConditionTable.Params = {}
      for i, SingleParam in iterator(SinglePreCondition.Params) do
        table.insert(SinglePreConditionTable.Params, SingleParam)
      end
      table.insert(SingleRadioConditionTable.PreCondition, SinglePreConditionTable)
    end
    SingleRadioConditionTable.IsMutex = SingleRadioCondition.IsMutex
    local Keys = SingleRadioCondition.RadioList:Keys()
    for i, SingleKey in iterator(Keys) do
      table.insert(SingleRadioConditionTable.TypeList[1].IndexList, SingleKey)
      table.insert(SingleRadioConditionTable.TypeList[1].WeightList, SingleRadioCondition.RadioList:Find(SingleKey))
    end
    Keys = SingleRadioCondition.BubbleList:Keys()
    for i, SingleKey in iterator(Keys) do
      table.insert(SingleRadioConditionTable.TypeList[2].IndexList, SingleKey)
      table.insert(SingleRadioConditionTable.TypeList[2].WeightList, SingleRadioCondition.BubbleList:Find(SingleKey))
    end
    Keys = SingleRadioCondition.SubtitleList:Keys()
    for i, SingleKey in iterator(Keys) do
      table.insert(SingleRadioConditionTable.TypeList[3].IndexList, SingleKey)
      table.insert(SingleRadioConditionTable.TypeList[3].WeightList, SingleRadioCondition.SubtitleList:Find(SingleKey))
    end
    LogicRadio.RadioEventInfos[SingleRadioCondition.ID] = SingleRadioConditionTable
  end
end

function LogicRadio.UpdateStartMapRadioProgress(Id, Index)
  if LogicRadio.StartMapRadioInfoTable.RadioId ~= Id then
    return
  end
  LogicRadio.StartMapRadioInfoTable.ProgressIndex = Index
end

function LogicRadio.GetStartMapRadioInfoTable()
  return LogicRadio.StartMapRadioInfoTable
end

function LogicRadio.GetUITypeList(Id)
  local RadioEventInfo = LogicRadio.RadioEventInfos[Id]
  if RadioEventInfo.IsMutex then
    local RandomNum = math.random(1, #RadioEventInfo.TypeList)
    return RadioEventInfo.TypeList[RandomNum]
  else
    return RadioEventInfo.TypeList[1]
  end
end

function LogicRadio.ShowRadioPanel(Id, Params)
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  if not LogicRadio.RadioEventInfos[Id] then
    print("not found radio info, please check DT_RadioCondition, Id:", Id)
    return
  end
  local UITypeList = LogicRadio.GetUITypeList(Id)
  local TargetRadioNum = LogicRadio.RandomListByWeight(UITypeList.IndexList, UITypeList.WeightList)
  if LogicRadio.StartMapRadioInfoTable.RadioConditionId == Id then
    if -1 ~= LogicRadio.StartMapRadioInfoTable.RadioId then
      TargetRadioNum = LogicRadio.StartMapRadioInfoTable.RadioId
    else
      LogicRadio.StartMapRadioInfoTable.RadioId = TargetRadioNum
    end
  end
  local Result, RadioRowInfo = DTSubsystem:GetRadioRowInfoByID(TargetRadioNum, nil)
  local RandomNum = math.random()
  if not Result or TargetRadioNum ~= RadioRowInfo.ID then
    return
  end
  if not RadioRowInfo.IsRepeat and table.Contain(LogicRadio.RadioPlayedList, TargetRadioNum) then
    print("\229\183\178\231\187\143\230\146\173\230\148\190\232\191\135\228\186\134")
    return
  end
  if RandomNum > RadioRowInfo.ShowProbability then
    print("\233\154\143\230\156\186\228\184\141\230\146\173\230\148\190", RadioRowInfo.ShowProbability, RandomNum)
    return
  end
  local TempParams = {}
  if "table" ~= type(Params) then
    for i, SingleStr in iterator(Params) do
      table.insert(TempParams, SingleStr)
    end
  else
    TempParams = Params
  end
  local TableParam = {
    ID = RadioRowInfo.ID,
    Params = TempParams
  }
  if not RadioRowInfo.IsRepeat then
    local IsInPlayList = false
    for i, SingleTable in ipairs(LogicRadio.RadioPlayList) do
      if SingleTable.ID == RadioRowInfo.ID then
        IsInPlayList = true
        break
      end
    end
    if IsInPlayList then
      print("\228\184\141\233\135\141\229\164\141\229\185\182\228\184\148\229\183\178\229\156\168\230\146\173\230\148\190\231\173\137\229\190\133\229\136\151\232\161\168")
      return
    end
  end
  table.insert(LogicRadio.RadioPlayList, TableParam)
  if not LogicRadio.RadioWidget or not LogicRadio.RadioWidget:IsValid() then
    local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
    if UIManager then
      local HUD = UIManager:K2_GetUI(UE.UClass.Load("/Game/Rouge/UI/HUD/WBP_HUD.WBP_HUD_C"))
      if HUD then
        print("Radio hud")
        local RGTutorialLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTutorialLevelSystem:StaticClass())
        local IsExecuteBeginGuideLogic = RGTutorialLevelSystem:GetIsExecuteBeginGuideLogic()
        if RGTutorialLevelSystem:IsFreshPlayer() or IsExecuteBeginGuideLogic then
          print("\230\150\176\230\137\139\229\133\179\229\136\155\229\187\186\230\151\160\231\186\191\231\148\181UI")
          local RadioWidgetClass = UE.UClass.Load("/Game/Rouge/UI/Radio/WBP_Radio.WBP_Radio_C")
          LogicRadio.RadioWidget = UE.UWidgetBlueprintLibrary.Create(GameInstance, RadioWidgetClass)
          LogicRadio.RadioWidget:AddToViewport(5)
        else
          LogicRadio.RadioWidget = HUD.WBP_Radio
        end
      else
        print("RadioNot HUD")
      end
    end
  elseif LogicRadio.RadioWidget.IsShow then
    print("\232\191\155\229\133\165\230\146\173\230\148\190\231\173\137\229\190\133\229\136\151\232\161\168")
    local Result, RadioRowInfo = DTSubsystem:GetRadioRowInfoByID(LogicRadio.RadioWidget.Id, nil)
    if Result then
      if not RadioRowInfo.IsCanInterrupt then
        print("\229\189\147\229\137\141\230\151\160\231\186\191\231\148\181\228\184\141\229\143\175\232\162\171\230\137\147\230\150\173", LogicRadio.RadioWidget.Id)
        return
      end
    else
      print("\230\137\190\228\184\141\229\136\176\229\189\147\229\137\141\230\146\173\230\148\190\231\154\132\230\151\160\231\186\191\231\148\181\232\161\168\228\191\161\230\129\175", LogicRadio.RadioWidget.Id)
      return
    end
    LogicRadio.RemoveRadioPlayListById(LogicRadio.RadioWidget.Id)
  end
  if LogicRadio.RadioWidget then
    if LogicRadio.RadioWidget.ShowRadio then
      LogicRadio.RadioWidget:ShowRadio(RadioRowInfo.ID, TempParams)
    else
      print("RadioWidget not found ShowRadio", LogicRadio.RadioWidget)
    end
  end
end

function LogicRadio.RemoveRadioPlayListById(Id)
  local RemoveIndex = 0
  for i, SinglePlayInfo in ipairs(LogicRadio.RadioPlayList) do
    if SinglePlayInfo.ID == Id then
      RemoveIndex = i
    end
  end
  if LogicRadio.RadioPlayList[RemoveIndex] then
    table.remove(LogicRadio.RadioPlayList, RemoveIndex)
  end
  if LogicRadio.StartMapRadioInfoTable.RadioId == Id then
    InitStartMapRadioInfoTable()
  end
end

function LogicRadio.GetAllRadioEventIdByTriggerConditionId(TriggerConditionId)
  local List = {}
  if LogicRadio.RadioEventInfos then
    for RadioEventId, SingleRadioEventInfo in pairs(LogicRadio.RadioEventInfos) do
      if SingleRadioEventInfo.TriggerCondition.ConditionId == TriggerConditionId then
        table.insert(List, RadioEventId)
      end
    end
  end
  return List
end

function LogicRadio.ExecuteRadioConditionByConditionId(ConditionId, RadioParams)
  local List = LogicRadio.GetAllRadioEventIdByTriggerConditionId(ConditionId)
  for index, SingleRadioConditionId in ipairs(List) do
    local PreConditionResult = true
    local RadioConditionInfo = LogicRadio.RadioEventInfos[SingleRadioConditionId]
    for i, SinglePreConditionInfo in ipairs(RadioConditionInfo.PreCondition) do
      local Result = LogicCondition.ExecuteConditionFunction(SinglePreConditionInfo.ConditionId, SinglePreConditionInfo.Params, 0)
      if not Result then
        PreConditionResult = false
        print("\229\137\141\231\189\174\230\157\161\228\187\182" .. SinglePreConditionInfo.ConditionId .. "\228\184\141\230\187\161\232\182\179\229\175\188\232\135\180" .. SingleRadioConditionId .. "\230\137\167\232\161\140\229\164\177\232\180\165!!!")
        break
      end
    end
    if PreConditionResult then
      local Count = LogicRadio.GetRadioExecuteCount(SingleRadioConditionId)
      if 2 ~= ConditionId then
        if LogicCondition.ExecuteConditionFunction(RadioConditionInfo.TriggerCondition.ConditionId, RadioConditionInfo.TriggerCondition.Params, Count) then
          print("\230\137\167\232\161\140\230\136\144\229\138\159" .. SingleRadioConditionId)
          if LogicRadio.RadioExecuteCount[SingleRadioConditionId] then
            LogicRadio.RadioExecuteCount[SingleRadioConditionId] = LogicRadio.RadioExecuteCount[SingleRadioConditionId] + 1
          else
            LogicRadio.RadioExecuteCount[SingleRadioConditionId] = 1
          end
          LogicRadio.ShowRadioPanel(SingleRadioConditionId, RadioParams)
        else
          print("\232\167\166\229\143\145\230\157\161\228\187\182\228\184\141\230\187\161\232\182\179\229\175\188\232\135\180\230\137\167\232\161\140\229\164\177\232\180\165" .. SingleRadioConditionId .. "!!!")
        end
      else
      end
    end
  end
end

function LogicRadio.GetRadioExecuteCount(RadioConditionId)
  return LogicRadio.RadioExecuteCount[RadioConditionId] and LogicRadio.RadioExecuteCount[RadioConditionId] or 0
end

function LogicRadio:BindOnShowRadioWindow(RadioEventId, Params)
  LogicRadio.ShowRadioPanel(RadioEventId, Params)
end

function LogicRadio.RandomListByWeight(Values, Weights)
  assert(#Values == #Weights)
  local tinsert = table.insert
  local Count = #Weights
  local Sum = 0
  for i, SingleWeight in ipairs(Weights) do
    Sum = Sum + SingleWeight
  end
  local Avg = Sum / Count
  local Aliases = {}
  for index, value in ipairs(Weights) do
    tinsert(Aliases, {1, false})
  end
  local Sidx = 1
  while Count >= Sidx and Avg <= Weights[Sidx] do
    Sidx = Sidx + 1
  end
  if Count >= Sidx then
    local Small = {
      Sidx,
      Weights[Sidx] / Avg
    }
    local Bidx = 1
    while Count >= Bidx and Avg > Weights[Bidx] do
      Bidx = Bidx + 1
    end
    local Big = {
      Bidx,
      Weights[Bidx] / Avg
    }
    while true do
      Aliases[Small[1]] = {
        Small[2],
        Big[1]
      }
      Big = {
        Big[1],
        Big[2] - (1 - Small[2])
      }
      if Big[2] < 1 then
        Small = Big
        Bidx = Bidx + 1
        while Count >= Bidx and Avg > Weights[Bidx] do
          Bidx = Bidx + 1
        end
        if Count < Bidx then
          break
        end
        Big = {
          Bidx,
          Weights[Bidx] / Avg
        }
      else
        Sidx = Sidx + 1
        while Count >= Sidx and Avg <= Weights[Sidx] do
          Sidx = Sidx + 1
        end
        if Count < Sidx then
          break
        end
        Small = {
          Sidx,
          Weights[Sidx] / Avg
        }
      end
    end
  end
  local n = math.random() * Count
  local i = math.floor(n)
  local odds, alias = Aliases[i + 1][1], Aliases[i + 1][2]
  local idx
  if odds < n - i then
    idx = alias
  else
    idx = i + 1
  end
  return Values[idx], Weights[idx]
end

function LogicRadio.ClearBattleData()
  LogicRadio.RadioWidget = nil
  LogicRadio.RadioPlayedList = {}
  LogicRadio.RadioExecuteCount = {}
  InitStartMapRadioInfoTable()
  BindCharacterBeginInteract(false)
end
