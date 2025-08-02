local ClimbTowerData = require("UI.View.ClimbTower.ClimbTowerData")
local DebuffListItem = UnLua.Class()

function DebuffListItem:Construct()
  self.WBP_DebuffAdjust.OnLevelChange:Add(self, self.OnLevelChange)
  EventSystem.AddListener(self, EventDef.ClimbTowerView.OnDebuffChange, self.OnDebuffChange)
end

function DebuffListItem:OnLevelChange(Lv)
  local Floor = ClimbTowerData:GetFloor()
  ClimbTowerData:SetLocalDebuff(Floor, tostring(self.DebuffId), Lv)
  self:SetItemStyle(Lv)
end

function DebuffListItem:OnDebuffChange()
  if self.bListenChange then
    self:InitDebuffItem(self.DebuffId, self.bCanSetBuffItem, self.bListenChange)
  end
end

function DebuffListItem:InitDebuffItem(DebuffId, bCanSetBuffItem, bListenChange)
  self.bListenChange = bListenChange
  self.DebuffId = DebuffId
  self.bCanSetBuffItem = bCanSetBuffItem
  UpdateVisibility(self.WBP_DebuffAdjust, bCanSetBuffItem)
  local DebuffTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDebuff)
  local DebuffInfo = DebuffTable[DebuffId]
  if not DebuffInfo then
    return
  end
  self.DebuffInfo = DebuffInfo
  SetImageBrushByPath(self.Img_Icon, DebuffInfo.ICon)
  self.Name:SetText(DebuffInfo.Title)
  if bCanSetBuffItem then
    self.WBP_DebuffAdjust:Init(ClimbTowerData:GetLocalDebuffValue(ClimbTowerData:GetFloor(), tostring(DebuffId)), DebuffInfo.DebuffLevel, DebuffId)
  end
  UpdateVisibility(self.Value, 2 ~= self.DebuffInfo.Type)
  UpdateVisibility(self.Check, 2 == self.DebuffInfo.Type)
  self:SetItemStyle(ClimbTowerData:GetLocalDebuffValue(ClimbTowerData:GetFloor(), tostring(DebuffId)))
end

function DebuffListItem:SetItemStyle(Lv)
  if not self.DebuffInfo then
    return
  end
  if 0 == self.DebuffInfo.Type then
    local ShowStr = tostring(Lv * self.DebuffInfo.LevelData) .. "%"
    if Lv * self.DebuffInfo.LevelData >= 0 then
      ShowStr = "+" .. ShowStr
    end
    self.Value:SetText(ShowStr)
  end
  if 1 == self.DebuffInfo.Type then
    local ShowStr = tostring(Lv * self.DebuffInfo.LevelData)
    if Lv * self.DebuffInfo.LevelData >= 0 then
      ShowStr = "+" .. ShowStr
    end
    self.Value:SetText(ShowStr)
  end
  if 2 == self.DebuffInfo.Type then
    self.Check:SetIsChecked(0 ~= Lv)
  end
  if 0 == Lv then
    self.Value:SetColorAndOpacity(self.Color1)
  else
    self.Value:SetColorAndOpacity(self.Color2)
  end
end

function DebuffListItem:SetItemValue(DebuffId, Value, bCanSetBuffItem)
  self.DebuffId = DebuffId
  UpdateVisibility(self.WBP_DebuffAdjust, bCanSetBuffItem)
  local DebuffTable = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDebuff)
  local DebuffInfo = DebuffTable[tonumber(DebuffId)]
  if not DebuffInfo then
    return
  end
  self.DebuffInfo = DebuffInfo
  SetImageBrushByPath(self.Img_Icon, DebuffInfo.ICon)
  self.Name:SetText(DebuffInfo.Title)
  UpdateVisibility(self.Value, 2 ~= DebuffInfo.Type)
  UpdateVisibility(self.Check, 2 == DebuffInfo.Type)
  if bCanSetBuffItem then
    self.WBP_DebuffAdjust:Init(Value, DebuffInfo.DebuffLevel, DebuffId)
  end
  self:SetItemStyle(Value)
end

return DebuffListItem
