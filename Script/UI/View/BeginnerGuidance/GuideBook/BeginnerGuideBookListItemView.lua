local rapidjson = require("rapidjson")
local BeginnerGuideBookListItemView = UnLua.Class()
function BeginnerGuideBookListItemView:Construct()
  self.GuideId = nil
  self.Button_GuideSelect.OnClicked:Add(self, self.OnClicked)
  EventSystem.AddListener(self, EventDef.BeginnerGuide.OnBeginnerGuideBookGuideChanged, self.BindOnBeginnerGuideBookGuideChanged)
end
function BeginnerGuideBookListItemView:Destruct()
  self.GuideId = nil
  self.Button_GuideSelect.OnClicked:Remove(self, self.OnClicked)
  EventSystem.RemoveListener(EventDef.BeginnerGuide.OnBeginnerGuideBookGuideChanged, self.BindOnBeginnerGuideBookGuideChanged, self)
end
function BeginnerGuideBookListItemView:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function BeginnerGuideBookListItemView:Init(GuideId)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.GuideId = GuideId
  local GuideInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)[GuideId]
  self.Text_GuideName:SetText(GuideInfo.name)
  self.WBP_RedDotView:ChangeRedDotIdByTag(GuideId)
end
function BeginnerGuideBookListItemView:OnClicked()
  EventSystem.Invoke(EventDef.BeginnerGuide.OnBeginnerGuideBookGuideChanged, self.GuideId)
end
function BeginnerGuideBookListItemView:BindOnBeginnerGuideBookGuideChanged(GuideId)
  if self.GuideId == GuideId then
    self.WBP_RedDotView:SetNum(0)
    self.Canvas_Select:SetVisibility(UE.ESlateVisibility.Visible)
    self.Canvas_Normal:SetVisibility(UE.ESlateVisibility.Hidden)
    self.Text_GuideName:SetColorAndOpacity(self.SelectedTextColor)
  else
    self.Canvas_Normal:SetVisibility(UE.ESlateVisibility.Visible)
    self.Canvas_Select:SetVisibility(UE.ESlateVisibility.Hidden)
    self.Text_GuideName:SetColorAndOpacity(self.UnSelectedTextColor)
  end
end
return BeginnerGuideBookListItemView
