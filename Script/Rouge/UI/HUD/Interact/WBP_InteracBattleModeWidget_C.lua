local WBP_InteracBattleModeWidget_C = UnLua.Class()

function WBP_InteracBattleModeWidget_C:Construct()
  self:BindOnKeyChanged()
  EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, WBP_InteracBattleModeWidget_C.BindOnKeyChanged)
end

function WBP_InteracBattleModeWidget_C:Destruct()
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, WBP_InteracBattleModeWidget_C.BindOnKeyChanged, self)
end

function WBP_InteracBattleModeWidget_C:BindOnKeyChanged()
  local Text = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName("Interact")
  self.Txt_KeyName:SetText(Text)
end

return WBP_InteracBattleModeWidget_C
