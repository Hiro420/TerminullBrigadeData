local ThreeDUITestItem = Class()

function ThreeDUITestItem:Construct()
  self.BP_ButtonWithSoundSelect.Onclicked:Add(self, self.OnSelectClick)
end

function ThreeDUITestItem:InitThreeDUIItem(ThreeDUIItemData)
  self.ThreeDUIItemData = ThreeDUIItemData
  SetImageBrushByPath(self.URGImageIcon, ThreeDUIItemData.Icon)
end

function ThreeDUITestItem:OnSelectClick()
  print("ThreeDUITestItem:OnSelectClick", self.ThreeDUIItemData.Desc)
end

function ThreeDUITestItem:Hover()
  self.URGImageIcon:SetRenderScale(UE.FVector2D(1.1))
end

function ThreeDUITestItem:UnHover()
  self.URGImageIcon:SetRenderScale(UE.FVector2D(1))
end

function ThreeDUITestItem:Hide()
  self.ThreeDUIItemData = nil
end

return ThreeDUITestItem
