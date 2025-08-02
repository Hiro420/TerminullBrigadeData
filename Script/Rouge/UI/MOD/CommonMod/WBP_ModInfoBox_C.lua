local WBP_ModInfoBox_C = UnLua.Class()

function WBP_ModInfoBox_C:Construct()
  self.wbp_ModInfoItemClass = UE.UClass.Load("/Game/Rouge/UI/MOD/CommonMod/WBP_ModInfoItem.WBP_ModInfoItem_C")
end

function WBP_ModInfoBox_C:UpdateModInfoBox(ModIdList, bIsLegend, padding)
  local Number = #ModIdList
  UpdateWidgetContainerByClass(self.HorizontalBox_ModInfoBox, Number, self.wbp_ModInfoItemClass, padding, self, self:GetOwningPlayer())
  local widgetArray = self.HorizontalBox_ModInfoBox:GetAllChildren()
  for key, modIdList in pairs(ModIdList) do
    if widgetArray:IsValidIndex(key) then
      widgetArray:Get(key):UpdateInitModInfoItem(modIdList, bIsLegend)
    end
  end
end

return WBP_ModInfoBox_C
