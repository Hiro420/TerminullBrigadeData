local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local DebuffAdjust = UnLua.Class()

function DebuffAdjust:Construct()
  self.Btn_Left.OnClicked:Add(self, self.OnBtn_Left)
  self.Btn_Right.OnClicked:Add(self, self.OnBtn_Right)
end

function DebuffAdjust:OnBtn_Left()
  if self.Lv < 1 then
    return
  end
  self.Lv = self.Lv - 1
  self.OnLevelChange:Broadcast(self.Lv)
  self:SetBtnState()
end

function DebuffAdjust:OnBtn_Right()
  if self.Lv == self.MaxLv then
    return
  end
  if climbtowerdata:GetFaultScore() >= climbtowerdata:GetTargetFaultScore() then
    ShowWaveWindow(304002)
    return
  end
  self.Lv = self.Lv + 1
  self.OnLevelChange:Broadcast(self.Lv)
  self:SetBtnState()
end

function DebuffAdjust:Init(Lv, MaxLv, DebuffId)
  local ClimbTowerDebuff = LuaTableMgr.GetLuaTableByName(TableNames.TBClimbTowerDebuff)
  if ClimbTowerDebuff[tonumber(DebuffId)] then
    self.DebuffValues = ClimbTowerDebuff[tonumber(DebuffId)].DebuffValues
  end
  if nil == Lv then
  end
  self.Lv = Lv
  self.MaxLv = MaxLv
  print("DebuffId", self.Lv, self.MaxLv, DebuffId)
  if self.DebuffValues[1] then
    self.Text_Value:SetText(self.DebuffValues[1])
  else
    self.Text_Value:SetText(0)
  end
  self:SetBtnState()
end

function DebuffAdjust:SetBtnState()
  UpdateVisibility(self.Overlay_UnDisplay_Left, self.Lv < 1)
  UpdateVisibility(self.Overlay_Display_Left, self.Lv > 0)
  UpdateVisibility(self.Overlay_UnDisplay_Right, self.Lv == self.MaxLv)
  UpdateVisibility(self.Overlay_Display_Right, self.Lv < self.MaxLv)
end

return DebuffAdjust
