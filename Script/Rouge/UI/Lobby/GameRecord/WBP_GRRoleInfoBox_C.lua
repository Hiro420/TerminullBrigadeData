local WBP_GRRoleInfoBox_C = UnLua.Class()
function WBP_GRRoleInfoBox_C:Construct()
  self.wbp_GRRoleInfoItemClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/GameRecord/WBP_GRRoleInfoItem.WBP_GRRoleInfoItem_C")
end
function WBP_GRRoleInfoBox_C:UpdateRoleInfoBox(UserIdList)
  local Number = #UserIdList
  local padding = UE.FMargin()
  padding.Bottom = 5
  UpdateWidgetContainerByClass(self.VerticalBox_GRRoleInfoBox, Number, self.wbp_GRRoleInfoItemClass, padding, self, self:GetOwningPlayer())
  local widgetArray = self.VerticalBox_GRRoleInfoBox:GetAllChildren()
  for key, uerId in pairs(UserIdList) do
    if widgetArray:IsValidIndex(key) then
      widgetArray:Get(key):UpdateRoleInfo(uerId)
      if 1 == key then
        widgetArray:Get(key):OnClicked_Button()
      end
    end
  end
end
function WBP_GRRoleInfoBox_C:ClearRoleInfoItemChoose()
  local padding = UE.FMargin()
  padding.Top = 5
  UpdateWidgetContainerByClass(self.VerticalBox_GRRoleInfoBox, 4, self.wbp_GRRoleInfoItemClass, padding, self, self:GetOwningPlayer())
  for key, value in pairs(self.VerticalBox_GRRoleInfoBox:GetAllChildren()) do
    value:UpdateRoleInfo(key)
    if 1 == key then
      value:OnClicked_Button()
    end
  end
end
return WBP_GRRoleInfoBox_C
