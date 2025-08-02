local WBP_SettleCountDown_C = UnLua.Class()

function WBP_SettleCountDown_C:Construct()
end

function WBP_SettleCountDown_C:Destruct()
  self.Timer = nil
end

function WBP_SettleCountDown_C:LuaTick(DeltaTime)
  if not self.Timer then
    return
  end
  if self.Timer >= self.CountDown then
    RGUIMgr:HideUI(UIConfig.WBP_SettleCountDown_C.UIName)
    self.Txt_CountDown:SetText(0)
    self.Timer = nil
  else
    self.Timer = self.Timer + DeltaTime
    self.Txt_CountDown:SetText(tostring(math.ceil(self.CountDown - self.Timer)))
  end
end

function WBP_SettleCountDown_C:OnDisplay(Param)
  self.Overridden.OnDisplay(self, Param)
end

function WBP_SettleCountDown_C:InitCountDwon(CountDown)
  self.CountDown = CountDown
  self.Txt_CountDown:SetText(self.CountDown)
  self.Timer = 0
end

function WBP_SettleCountDown_C:OnUnDisplay(bIsPlaySound)
  self.Overridden.OnUnDisplay(self, bIsPlaySound)
  self.Timer = nil
end

return WBP_SettleCountDown_C
