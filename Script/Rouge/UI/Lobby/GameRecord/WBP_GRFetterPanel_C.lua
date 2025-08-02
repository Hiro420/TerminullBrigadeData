local WBP_GRFetterPanel_C = UnLua.Class()

function WBP_GRFetterPanel_C:Construct()
  EventSystem.AddListener(self, EventDef.GameRecordPanel.TypeButtonChanged, WBP_GRFetterPanel_C.OnTypeButtonChanged)
end

function WBP_GRFetterPanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.GameRecordPanel.TypeButtonChanged, WBP_GRFetterPanel_C.OnTypeButtonChanged, self)
end

function WBP_GRFetterPanel_C:OnTypeButtonChanged(LastActiveWidget, CurActiveWidget, CurrentRoleInfoData, CurrentFetterData)
  if CurActiveWidget == self then
    self:UpdateGRFetterBox(CurrentFetterData)
  end
end

function WBP_GRFetterPanel_C:UpdateGRFetterBox(CurrentFetterData)
  self.WBP_GRFetterBox:UpdateGRFetterBox(CurrentFetterData)
end

return WBP_GRFetterPanel_C
