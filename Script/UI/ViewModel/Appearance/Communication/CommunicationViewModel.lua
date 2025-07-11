local UnLua = _G.UnLua
local RGUtil = UE.RGUtil
local rapidjson = require("rapidjson")
local StringExt = require("Utils.StringExt")
local HttpService = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(RGUtil.GetWorld(), HttpCommunication.GetHttpServiceClass())
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local CommunicationHandler = require("Protocol.Appearance.Communication.CommunicationHandler")
local CommunicationViewModel = CreateDefaultViewModel()
CommunicationViewModel.propertyBindings = {
  CurHeroId = -1,
  ShowSprayData = {},
  CurSelectSparyId = -1,
  ShowVoiceData = {},
  CurSelectVoiceId = -1,
  CurSelectCommunicationToggle = ECommunicationToggleStatus.None,
  IsEmptyShowList = true,
  RedDotIdList = {}
}
local HeroCommListSort = function(A, B)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if A.bIsUnlocked ~= B.bIsUnlocked then
    return A.bIsUnlocked
  end
  local ARare = TotalResourceTable[A.ID].Rare
  local BRare = TotalResourceTable[B.ID].Rare
  if ARare ~= BRare then
    return ARare > BRare
  end
  return A.ID > B.ID
end
function CommunicationViewModel:OnInit()
  self.Super:OnInit()
  EventSystem.AddListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
  EventSystem.AddListenerNew(EventDef.Communication.OnGetCommList, self, self.OnGetCommList)
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteAreaSelectChanged, self, self.OnRouletteAreaSelectChanged)
  CommunicationData.InitData()
end
function CommunicationViewModel:OnShutdown()
  EventSystem.RemoveListenerNew(EventDef.WSMessage.ResourceUpdate, self, self.OnResourceUpdate)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnGetCommList, self, self.OnGetCommList)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteAreaSelectChanged, self, self.OnRouletteAreaSelectChanged)
  self.Super:OnShutdown()
end
function CommunicationViewModel:OnResourceUpdate(JsonStr)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local bNeedRequest = false
  local JsonTable = rapidjson.decode(JsonStr)
  if JsonTable.resources then
    for i, res in ipairs(JsonTable.resources) do
      local id = tonumber(res.id)
      if TotalResourceTable and TotalResourceTable[id] and 16 == TotalResourceTable[id].Type then
        bNeedRequest = true
      end
    end
  end
  if bNeedRequest then
    self:SendGetCommList()
  end
end
function CommunicationViewModel:SendGetCommList(SuccCallback)
  CommunicationHandler.RequestGetCommunicationBag(SuccCallback)
end
function CommunicationViewModel:OnGetCommList(CommList)
  self:UpdateRoulette()
  local t = self.CurHeroId
  self.CurHeroId = -1
  self.CurHeroId = t
  self:UpdateSprayList()
  self:UpdateVoiceList()
  if -1 ~= self.CurSelectSparyId then
    local t = self.CurSelectSparyId
    self.CurSelectSparyId = -1
    self.CurSelectSparyId = t
  end
  if -1 ~= self.CurSelectVoiceId then
    local t = self.CurSelectVoiceId
    self.CurSelectVoiceId = -1
    self.CurSelectVoiceId = t
  end
  self:UpdateRedDotIdList()
end
function CommunicationViewModel:UpdateCurHeroId(CurHeroId)
  if self.CurHeroId == CurHeroId then
    return
  end
  self:UpdateRoulette()
  self.CurHeroId = CurHeroId
  self:UpdateSprayList()
  self:UpdateVoiceList()
  self:UpdateRedDotIdList()
end
function CommunicationViewModel:UpdateRoulette()
  local rouletteSlots = DataMgr.GetRouletteSlotsByHeroId(self.CurHeroId)
  CommunicationData.HeroCommEquip = {}
  for i, v in ipairs(rouletteSlots) do
    if v then
      table.insert(CommunicationData.HeroCommEquip, v)
    end
  end
end
function CommunicationViewModel:UpdateCurSelectCommunicationToggle(ToggleIndex)
  if self.CurSelectCommunicationToggle == ToggleIndex then
    return
  end
  self.CurSelectCommunicationToggle = ToggleIndex
  if self.CurSelectCommunicationToggle == ECommunicationToggleStatus.Spray then
    self.CurSelectVoiceId = -1
    self:UpdateSprayList()
    self.IsEmptyShowList = 0 == #self.ShowSprayData.SprayList
  elseif self.CurSelectCommunicationToggle == ECommunicationToggleStatus.Voice then
    self.CurSelectSparyId = -1
    self:UpdateVoiceList()
    self.IsEmptyShowList = 0 == #self.ShowVoiceData.VoiceList
  end
end
function CommunicationViewModel:UpdateSprayList()
  local curHeroId = self.CurHeroId
  local showHeroSprayData = {
    EquipedSprayList = {},
    SprayList = {}
  }
  local heroSprayList = CommunicationData.GetSprayListByHeroId(curHeroId)
  if heroSprayList then
    for i, v in ipairs(heroSprayList) do
      local t = {
        ID = v.ID,
        bIsUnlocked = CommunicationData.CheckCommIsUnlock(v.ID),
        bIsEquiped = CommunicationData.CheckCommIsEquiped(v.ID),
        bIsSelected = v.ID == self.CurSelectSparyId,
        bIsUnlockShow = v.IsUnlockShow
      }
      table.insert(showHeroSprayData.SprayList, t)
    end
  end
  table.sort(showHeroSprayData.SprayList, HeroCommListSort)
  if -1 == self.CurSelectSparyId and #showHeroSprayData.SprayList > 0 and self.CurSelectCommunicationToggle == ECommunicationToggleStatus.Spray then
    showHeroSprayData.SprayList[1].bIsSelected = true
    self.CurSelectSparyId = showHeroSprayData.SprayList[1].ID
  end
  self.ShowSprayData = showHeroSprayData
end
function CommunicationViewModel:UpdateVoiceList()
  local curHeroId = self.CurHeroId
  local showHeroVoiceData = {
    EquipedVoiceList = {},
    VoiceList = {}
  }
  local heroVoiceList = CommunicationData.GetVoiceListByHeroId(curHeroId)
  if heroVoiceList then
    for i, v in ipairs(heroVoiceList) do
      local t = {
        ID = v.ID,
        bIsUnlocked = CommunicationData.CheckCommIsUnlock(v.ID),
        bIsEquiped = CommunicationData.CheckCommIsEquiped(v.ID),
        bIsSelected = v.ID == self.CurSelectVoiceId
      }
      table.insert(showHeroVoiceData.VoiceList, t)
    end
  end
  table.sort(showHeroVoiceData.VoiceList, HeroCommListSort)
  if -1 == self.CurSelectVoiceId and #showHeroVoiceData.VoiceList > 0 and self.CurSelectCommunicationToggle == ECommunicationToggleStatus.Voice then
    showHeroVoiceData.VoiceList[1].bIsSelected = true
    self.CurSelectVoiceId = showHeroVoiceData.VoiceList[1].ID
  end
  self.ShowVoiceData = showHeroVoiceData
end
function CommunicationViewModel:UpdateCurSelectSpary(CommId)
  if self.CurSelectSparyId == CommId then
    return
  end
  self.CurSelectSparyId = CommId
  UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
    GameInstance,
    function()
      UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
        GameInstance,
        function()
          EventSystem.Invoke(EventDef.Communication.OnCommSelectChanged, CommId)
        end
      })
    end
  })
end
function CommunicationViewModel:UpdateCurSelectVoice(CommId)
  if self.CurSelectVoiceId == CommId then
    return
  end
  self.CurSelectVoiceId = CommId
  EventSystem.Invoke(EventDef.Communication.OnCommSelectChanged, CommId)
end
function CommunicationViewModel:GetCommDataByCommId(CommId)
  local tbGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local tbCommunication = LuaTableMgr.GetLuaTableByName(TableNames.TBResHeroCommuniRoulette)
  local CommData = {}
  if tbGeneral and tbGeneral[CommId] then
    CommData.Rare = tbGeneral[CommId].Rare
  end
  CommData.bIsUnlocked = CommunicationData.CheckCommIsUnlock(CommId)
  if tbCommunication and tbCommunication[CommId] then
    CommData.RowInfo = tbCommunication[CommId]
  end
  return CommData
end
function CommunicationViewModel:GetVoiceDataByCommId(CommId)
  return self:GetCommDataByCommId(CommId)
end
function CommunicationViewModel:GetSprayDataByCommId(CommId)
  return self:GetCommDataByCommId(CommId)
end
function CommunicationViewModel:GetCurCommData()
  if -1 ~= self.CurSelectSparyId then
    return self:GetSprayDataByCommId(self.CurSelectSparyId)
  elseif -1 ~= self.CurSelectVoiceId then
    return self:GetVoiceDataByCommId(self.CurSelectVoiceId)
  end
end
function CommunicationViewModel:EquipCommBySlotId(SlotId)
  local curCommData = self:GetCurCommData()
  if not curCommData then
    return
  end
  CommunicationHandler.RequestEquipCommunication(self.CurHeroId, SlotId - 1, curCommData.RowInfo.RouletteID, function()
    LogicRole.RequestMyHeroInfoToServer(function()
      CommunicationHandler.RequestGetCommunicationBag()
    end)
  end)
end
function CommunicationViewModel:UnequipCommBySlotId(SlotId)
  CommunicationHandler.RequestUnEquipCommunication(self.CurHeroId, SlotId - 1, function()
    LogicRole.RequestMyHeroInfoToServer(function()
      CommunicationHandler.RequestGetCommunicationBag()
    end)
  end)
end
function CommunicationViewModel:GetRouletteIdBySlotId(SlotId)
  local rouletteSlots = DataMgr.GetRouletteSlotsByHeroId(self.CurHeroId)
  if not rouletteSlots[SlotId] then
    return 0
  end
  local rouletteId = rouletteSlots[SlotId]
  return rouletteSlots[SlotId]
end
function CommunicationViewModel:OnRouletteAreaSelectChanged(SlotId)
  local rouletteId = self:GetRouletteIdBySlotId(SlotId)
  if 0 == rouletteId then
    return
  end
  local commId = CommunicationData.GetCommIdByRoulleteId(rouletteId)
  local commData = self:GetCommDataByCommId(commId)
  if not commData then
    return
  end
  if 1 == commData.RowInfo.Type then
    self:UpdateCurSelectCommunicationToggle(ECommunicationToggleStatus.Spray)
    self:UpdateCurSelectSpary(commId)
  elseif 3 == commData.RowInfo.Type then
    self:UpdateCurSelectCommunicationToggle(ECommunicationToggleStatus.Voice)
    self:UpdateCurSelectVoice(commId)
  end
end
function CommunicationViewModel:UpdateRedDotIdList()
  self.RedDotIdList = {}
  local heroSprayList = CommunicationData.GetSprayListByHeroId(self.CurHeroId)
  local heroVoiceList = CommunicationData.GetVoiceListByHeroId(self.CurHeroId)
  local redDotIdList = {}
  for i, v in ipairs(heroSprayList) do
    table.insert(redDotIdList, string.format("Roulette_Paint_Item_%d", v.ID))
  end
  for i, v in ipairs(heroVoiceList) do
    table.insert(redDotIdList, string.format("Roulette_Voice_Item_%d", v.ID))
  end
  self.RedDotIdList = redDotIdList
end
function CommunicationViewModel:GetSprayIndexById(SprayId)
  if self.ShowSprayData and self.ShowSprayData.SprayList then
    for i, v in ipairs(self.ShowSprayData.SprayList) do
      if v.ID == SprayId then
        return i
      end
    end
  end
  return -1
end
function CommunicationViewModel:GetVoiceIndexById(VoiceId)
  if self.ShowVoiceData and self.ShowVoiceData.VoiceList then
    for i, v in ipairs(self.ShowVoiceData.VoiceList) do
      if v.ID == VoiceId then
        return i
      end
    end
  end
  return -1
end
function CommunicationViewModel:CheckIsShow(Data)
  return not Data.bIsUnlockShow or Data.bIsUnlocked
end
return CommunicationViewModel
