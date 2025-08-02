local EDebuffListShowType = {
  ClimbTowerView = 1,
  HeroSelection = 2,
  DamagePanel = 3
}
local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local rapidjson = require("rapidjson")
local DebuffList = UnLua.Class()

function DebuffList:Construct()
  if self.Btn_Save then
    self.Btn_Save.OnClicked:Add(self, DebuffList.Save)
  end
  if self.Btn_Resetting then
    self.Btn_Resetting.OnClicked:Add(self, DebuffList.Resetting)
  end
  if self.Btn_Application then
    self.Btn_Application.OnClicked:Add(self, DebuffList.Application)
  end
  self.bOtherPlayer = false
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnDebuffChange, self.OnDebuffChange)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnApplication, self.OnApplication)
end

function DebuffList:Save()
  ClimbTowerData:SetDebuff(ClimbTowerData:GetFloor())
end

function DebuffList:Resetting()
  ClimbTowerData:ResettingDebuff()
end

function DebuffList:Application()
  HttpCommunication.Request("team/settowerdebuff", {
    debuffChoices = self.debuffChoices,
    floor = ClimbTowerData:GetFloor(),
    gameMode = ClimbTowerData.GameMode
  }, {
    GameInstance,
    function(Target, JsonResponse)
      print("\232\174\190\231\189\174\230\136\144\229\138\159")
      EventSystem.Invoke(EventDef.ClimbTowerView.OnApplication, self.debuffChoices)
      EventSystem.Invoke(EventDef.ClimbTowerView.OnDebuffChange)
      ShowWaveWindow(304001)
    end
  }, {
    GameInstance,
    function(Target, JsonResponse)
      print("\232\174\190\231\189\174\229\164\177\232\180\165")
    end
  })
end

function DebuffList:OnApplication(DebuffChoices)
  if not self.bOtherPlayer then
    self:UpdateList(DebuffChoices)
  end
end

function DebuffList:OnDebuffChange()
  if self.WBP_ClimbTower_DebuffList and not self.WBP_ClimbTower_DebuffList.bOtherPlayer then
    if self.Txt_Num then
      self.Txt_Num:SetText(ClimbTowerData:GetFaultScore())
    end
  else
    UpdateVisibility(self.Tips_Group, ClimbTowerData:GetFaultScore() < ClimbTowerData:GetTargetFaultScore())
  end
end

function DebuffList:InitDebuffList(Floor, bCanSetBuffItem)
  if Floor - 1 > 0 then
    ClimbTowerData:GetLocalDebuff(Floor - 1)
  end
  ClimbTowerData:GetLocalDebuff(Floor)
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if not ClimbTowerTable[Floor] then
    error(TableNames.TBClimbTowerFloor .. tostring(Floor) .. " nil", 1)
    return
  end
  local DebuffGroup = ClimbTowerTable[Floor].DebuffGroupIDs
  local Index = 1
  local IndexLeft = 1
  local IndexRight = 1
  self.DebuffList:ClearChildren()
  for index, value in ipairs(DebuffGroup) do
    Index = index
    local Item
    if 0 == Index % 2 and self.bTwoColumns then
      Item = GetOrCreateItem(self.DebuffList_1, IndexRight, self.WBP_DebuffItem:GetClass())
      IndexRight = IndexRight + 1
    else
      Item = GetOrCreateItem(self.DebuffList, IndexLeft, self.ListItemClass_Widen)
      IndexLeft = IndexLeft + 1
    end
    if Item then
      Item:InitDebuffItem(value, bCanSetBuffItem, true)
      UpdateVisibility(Item, true)
    end
  end
  if self.bTwoColumns then
    HideOtherItem(self.DebuffList, IndexLeft, true)
    HideOtherItem(self.DebuffList_1, IndexRight, true)
  else
    HideOtherItem(self.DebuffList, Index + 1, true)
  end
  UpdateVisibility(self.DebuffList_1, self.bTwoColumns)
end

function DebuffList:SetPlayerDebuffInfo(RoldId, DebuffListShowType, CallBack)
  if DebuffListShowType == EDebuffListShowType.HeroSelection then
    self.bCanSetBuffItem = RoldId == DataMgr.GetUserId()
    self.bApplication = RoldId ~= DataMgr.GetUserId()
  end
  if DebuffListShowType == EDebuffListShowType.DamagePanel then
    self.bCanSetBuffItem = false
    self.bApplication = false
    if self.debuffChoices ~= nil then
      return
    end
  end
  self:GetRolesDebuffChoices(RoldId, ClimbTowerData:GetFloor(), CallBack)
end

function DebuffList:GetRolesDebuffChoices(RoldId, Floor, CallBack)
  local Path = string.format("activity/climbtower/rolesdebuffchoices?roleIDs=%d&floor=%d", RoldId, Floor)
  HttpCommunication.RequestByGet(Path, {
    GameInstance,
    function(Target, JsonResponse)
      self.bOtherPlayer = RoldId ~= DataMgr.GetUserId()
      UpdateVisibility(self.Btn_Application, self.bApplication, self.bApplication)
      UpdateVisibility(self.Btn_Save, self.bCanSetBuffItem, self.bCanSetBuffItem)
      UpdateVisibility(self.Btn_Btn_Resetting, self.bCanSetBuffItem, self.bCanSetBuffItem)
      local JsonTable = rapidjson.decode(JsonResponse.Content)
      for key, V in pairs(JsonTable.rolesDebuffChoices) do
        self:UpdateList(V.debuffChoices)
        if CallBack then
          CallBack(V.debuffChoices)
        end
      end
    end
  })
end

function DebuffList:UpdateList(DebuffChoices)
  if nil == DebuffChoices then
    return
  end
  self.debuffChoices = DebuffChoices
  if not self.bOtherPlayer then
    if nil == ClimbTowerData.LocalDebuff then
      ClimbTowerData.LocalDebuff = {}
    end
    ClimbTowerData.LocalDebuff[ClimbTowerData:GetFloor()] = DebuffChoices
  end
  local ClimbTowerTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerFloor)
  if not ClimbTowerTable[ClimbTowerData:GetFloor()] then
    error(TableNames.TBClimbTowerFloor .. tostring(ClimbTowerData:GetFloor()) .. " nil", 1)
    return
  end
  local DebuffGroup = ClimbTowerTable[ClimbTowerData:GetFloor()].DebuffGroupIDs
  local Index = 1
  local ItemClass = UE.UClass.Load("/Game/Rouge/UI/ClimbTower/Item/WBP_DebuffItem.WBP_DebuffItem_C")
  for index, value in ipairs(DebuffGroup) do
    Index = index
    local Item = GetOrCreateItem(self.DebuffList, Index, ItemClass)
    local DebuffLv = 0
    if nil ~= DebuffChoices[tostring(value)] then
      DebuffLv = DebuffChoices[tostring(value)]
    end
    Item:SetItemValue(value, DebuffLv, self.bCanSetBuffItem)
  end
  HideOtherItem(self.DebuffList, Index + 1, true)
end

return DebuffList
