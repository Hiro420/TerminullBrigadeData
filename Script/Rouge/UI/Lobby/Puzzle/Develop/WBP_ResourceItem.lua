local WBP_ResourceItem = UnLua.Class()

function WBP_ResourceItem:Show(ResourceId, Num)
  UpdateVisibility(self, true)
  self.ResourceId = ResourceId
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  SetImageBrushByPath(self.Img_CurrencyIcon, RowInfo.Icon, self.IconSize)
  self.Txt_Num:SetText(Num)
end

function WBP_ResourceItem:UpdateNumTextStatus(Num)
  local CurResourceNum = LogicOutsidePackback.GetResourceNumById(self.ResourceId)
  if Num > CurResourceNum then
    self.RGStateController_NumText:ChangeStatus("NotEnough")
  else
    self.RGStateController_NumText:ChangeStatus("Enough")
  end
end

function WBP_ResourceItem:GetToolTipWidget(...)
  if self.ToolTip and self.ToolTip:IsValid() then
    self.ToolTip:InitInfo(self.ResourceId)
    return self.ToolTip
  end
  local TipClassObj = UE.UClass.Load("/Game/Rouge/UI/Common/WBP_CurrencyItemTip.WBP_CurrencyItemTip_C")
  self.ToolTip = UE.UWidgetBlueprintLibrary.Create(self, TipClassObj)
  self.ToolTip:InitInfo(self.ResourceId)
  return self.ToolTip
end

function WBP_ResourceItem:Hide(...)
  UpdateVisibility(self, false)
end

return WBP_ResourceItem
