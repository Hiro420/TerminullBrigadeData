local WBP_InteractLongPressWidget_C = UnLua.Class()

function WBP_InteractLongPressWidget_C:Construct()
  self:BindOnKeyChanged()
  EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, WBP_InteractLongPressWidget_C.BindOnKeyChanged)
end

function WBP_InteractLongPressWidget_C:Destruct()
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, WBP_InteractLongPressWidget_C.BindOnKeyChanged, self)
end

function WBP_InteractLongPressWidget_C:UpdateInteractInfo(InteractTipRow)
  self:UpdateProgress(0)
end

function WBP_InteractLongPressWidget_C:UpdateProgress(ProgressParam)
  local Mat = self.RGImageOpenProgress:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue("Percent", ProgressParam)
  end
end

function WBP_InteractLongPressWidget_C:BindOnKeyChanged()
  local Text = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName("Interact")
  self.Txt_KeyName:SetText(Text)
end

return WBP_InteractLongPressWidget_C
