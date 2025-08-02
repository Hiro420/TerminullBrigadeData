local RankModeItem = UnLua.Class()

function RankModeItem:Construct()
  self.Button_Mode.OnClicked:Add(self, RankModeItem.OnClicked_Button)
  self.TextBlock_Mode:Settext(self.ShowName)
  EventSystem.AddListener(self, EventDef.Rank.OnModeChange, RankModeItem.SetSel)
end

function RankModeItem:Destruct()
  self.Button_Mode.OnClicked:Remove(self, RankModeItem.OnClicked_Button)
  EventSystem.RemoveListener(EventDef.Rank.OnModeChange, RankModeItem.SetSel, self)
end

function RankModeItem:SetSel(RankMode)
  UpdateVisibility(self.Img_Sel, RankMode == self.GameWorld)
end

function RankModeItem:OnClicked_Button()
  EventSystem.Invoke(EventDef.Rank.OnModeChange, self.GameWorld)
end

return RankModeItem
