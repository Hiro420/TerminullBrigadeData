local WBP_AccessoryCompare_C = UnLua.Class()

function WBP_AccessoryCompare_C:InitInfoForGamePokey(BagArticleId, ChooseWeapon, Equipped)
  if ChooseWeapon then
    if Equipped then
      self.WBP_CompareAccessory:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.WBP_CurrentAccessory:InitInfo(BagArticleId, false, true, nil, -1)
    elseif ChooseWeapon.AccessoryComponent then
      local outData = UE.URGAccessoryStatics.K2_GetAccessoryRow(self, BagArticleId)
      local EquippedId = ChooseWeapon.AccessoryComponent:GetAccessoryByType(outData.AccessoryType)
      if ChooseWeapon.AccessoryComponent:HasAccessoryOfType(outData.AccessoryType) then
        self.WBP_CompareAccessory:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.WBP_CompareAccessory:InitInfo(EquippedId, false, true, nil, -1)
      else
        self.WBP_CompareAccessory:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
      self.WBP_CurrentAccessory:InitInfo(BagArticleId, true, false, EquippedId, -1)
    end
  end
end

return WBP_AccessoryCompare_C
