local WBP_EnterCountDown_C = UnLua.Class()
function WBP_EnterCountDown_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.OnStartGameCountTime, WBP_EnterCountDown_C.BindOnStartGameCountTime)
end
function WBP_EnterCountDown_C:StartCountDown()
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_EnterCountDown_C:BindOnStartGameCountTime(CountDownTime)
  self.TextBlock_Time:SetText(tostring(CountDownTime))
end
function WBP_EnterCountDown_C:RecoverCountDown()
  self:SetVisibility(UE.ESlateVisibility.Hidden)
end
function WBP_EnterCountDown_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.OnStartGameCountTime, WBP_EnterCountDown_C.BindOnStartGameCountTime, self)
end
return WBP_EnterCountDown_C
