local RedDotView = UnLua.Class()
local RedDotData = require("Modules.RedDot.RedDotData")
local StateCanvasList = {}
function RedDotView:Construct()
  self.Overridden.Construct(self)
  self:ChangeRedDotId(self.RedDotClass)
  EventSystem.AddListenerNew(EventDef.RedDot.OnRedDotStateChanged, self, self.BindOnRedDotStateChanged)
  EventSystem.AddListenerNew(EventDef.RedDot.OnPlayOnceAnimation, self, self.BindOnPlayOnceAnimation)
end
function RedDotView:Destruct()
  self.Overridden.Destruct(self)
  EventSystem.RemoveListenerNew(EventDef.RedDot.OnRedDotStateChanged, self, self.BindOnRedDotStateChanged)
  EventSystem.RemoveListenerNew(EventDef.RedDot.OnPlayOnceAnimation, self, self.BindOnPlayOnceAnimation)
end
function RedDotView:ChangeRedDotId(RedDotId, RedDotClass)
  self.RedDotId = RedDotId
  self.RedDotClass = RedDotClass or self.RedDotClass
  if self.RedDotId == "" or self.RedDotClass == "" then
    UpdateVisibility(self, false)
    print("RedDotView:ChangeRedDotId, RedDotId or RedDotClass is empty", "RedDotId:", RedDotId, "RedDotClass:", self.RedDotClass)
    return
  end
  self:SetRedDotState(RedDotData:GetRedDotState(self.RedDotId))
end
function RedDotView:ChangeRedDotIdByTag(Tag)
  if Tag then
    self:ChangeRedDotId(self.RedDotClass .. "_" .. Tag)
  else
    UnLua.LogError("RedDotView:ChangeRedDotIdByTag Tag is nil")
  end
end
function RedDotView:BindOnRedDotStateChanged(RedDotId)
  if RedDotId == self.RedDotId then
    local State = RedDotData:GetRedDotState(RedDotId)
    self:SetRedDotState(State)
  end
end
function RedDotView:SetRedDotState(State)
  self.RedDotState = State
  if not State then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, State.IsActive)
  StateCanvasList = {
    Normal = self.Canvas_Normal,
    Num = self.Canvas_Num,
    Icon = self.Canvas_Icon,
    Text = self.Canvas_Text
  }
  for k, v in pairs(StateCanvasList) do
    if k == State.RedDotType then
      UpdateVisibility(v, true)
    else
      UpdateVisibility(v, false)
    end
  end
  if "Num" == State.RedDotType then
    if State.Num > 9 then
      self.Text_Num:SetText("9+")
    else
      self.Text_Num:SetText(State.Num)
    end
  elseif "Text" == State.RedDotType then
    self.Text_Text:SetText(RedDotData:GetRedDotRawDef(State.Class).Text)
  end
  self.StateAni = self["Ani_" .. State.RedDotType .. "_loop"]
end
function RedDotView:ChangeNum(delta)
  RedDotData:ChangeRedDotNum(self.RedDotId, delta)
end
function RedDotView:SetNum(Num)
  RedDotData:SetRedDotNum(self.RedDotId, Num)
end
function RedDotView:BindOnClick()
  local RedDotState = RedDotData:GetRedDotState(self.RedDotId, self.RedDotClass)
  if 0 == #RedDotState.StubbornChildList then
    RedDotData:SetRedDotActive(self.RedDotId, false)
    self:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function RedDotView:BindOnPlayOnceAnimation()
  if self.RedDotState and self.RedDotState.IsActive and self.StateAni and not self:IsAnimationPlaying(self.StateAni) then
    self:PlayAnimation(self.StateAni, 0, 1, UE.EUMGSequencePlayMode.Forward)
  end
end
return RedDotView
