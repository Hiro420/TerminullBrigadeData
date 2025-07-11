local rapidjson = require("rapidjson")
local BeginnerGuideBookTypeItemView = UnLua.Class()
function BeginnerGuideBookTypeItemView:Construct()
  self.GuideTypeId = nil
  self.Button_GuideTypeSelect.OnClicked:Add(self, self.OnClicked)
  EventSystem.AddListener(self, EventDef.BeginnerGuide.OnBeginnerGuideBookTypeChanged, self.BindOnBeginnerGuideBookTypeChanged)
end
function BeginnerGuideBookTypeItemView:Destruct()
  self.GuideTypeId = nil
  self.Button_GuideTypeSelect.OnClicked:Remove(self, self.OnClicked)
  EventSystem.RemoveListener(EventDef.BeginnerGuide.OnBeginnerGuideBookTypeChanged, self.BindOnBeginnerGuideBookTypeChanged, self)
end
function BeginnerGuideBookTypeItemView:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function BeginnerGuideBookTypeItemView:Init(GuideTypeId)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.GuideTypeId = GuideTypeId
  local GuideInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuidebooktype)[GuideTypeId]
  self.Text_GuideTypeName:SetText(GuideInfo.name)
  self.WBP_RedDotView:ChangeRedDotIdByTag(GuideTypeId)
end
function BeginnerGuideBookTypeItemView:OnClicked()
  EventSystem.Invoke(EventDef.BeginnerGuide.OnBeginnerGuideBookTypeChanged, self.GuideTypeId)
end
function BeginnerGuideBookTypeItemView:BindOnBeginnerGuideBookTypeChanged(GuideTypeId)
  if self.GuideTypeId == GuideTypeId then
    self.WBP_RedDotView:BindOnClick()
    self.Canvas_Select:SetVisibility(UE.ESlateVisibility.Visible)
    self.Text_GuideTypeName:SetColorAndOpacity(self.SelectedTextColor)
  else
    self.Canvas_Select:SetVisibility(UE.ESlateVisibility.Hidden)
    self.Text_GuideTypeName:SetColorAndOpacity(self.UnSelectedTextColor)
  end
end
return BeginnerGuideBookTypeItemView
