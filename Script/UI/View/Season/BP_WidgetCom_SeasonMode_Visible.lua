local SeasonData = require("Modules.Season.SeasonData")
local BP_WidgetCom_SeasonMode_Visible = Class()
function BP_WidgetCom_SeasonMode_Visible:WidgetRebuilt(...)
  EventSystem.AddListenerNew(EventDef.Season.SeasonModeChanged, self, self.OnSeasonModeChanged)
  self:InitSeasonModeVisible(SeasonData.CurSelectSeasonMode)
end
function BP_WidgetCom_SeasonMode_Visible:OnReleaseSlateResource()
  EventSystem.RemoveListenerNew(EventDef.Season.SeasonModeChanged, self, self.OnSeasonModeChanged)
end
function BP_WidgetCom_SeasonMode_Visible:InitSeasonModeVisible(RowGameMode)
  self:OnSeasonModeChanged(RowGameMode)
end
function BP_WidgetCom_SeasonMode_Visible:OnSeasonModeChanged(SeasonMode)
  local ownerWidget = self:GetOwnerWidget()
  if not IsValidObj(ownerWidget) then
    return
  end
  if self.bShowInSeasonMode then
    UpdateVisibility(ownerWidget, SeasonMode == ESeasonMode.SeasonMode, self.bVisibleWhenShow)
  else
    UpdateVisibility(ownerWidget, SeasonMode == ESeasonMode.NormalMode, self.bVisibleWhenShow)
  end
end
return BP_WidgetCom_SeasonMode_Visible
