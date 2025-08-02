local WBP_OptionalGiftMsgWaveWindow_Confirm_C = UnLua.Class()

function WBP_OptionalGiftMsgWaveWindow_Confirm_C:InitOptionalGift(GiftId, OptionalGiftIndexs)
  local TBOptionalGift = LuaTableMgr.GetLuaTableByName(TableNames.TBOptionalGift)
  if not TBOptionalGift then
    return
  end
  if not TBOptionalGift[GiftId] then
    return
  end
  local ObjCls = UE.UClass.Load("/Game/Rouge/UI/Common/BP_GetPropData.BP_GetPropData_C")
  self.PropList:ClearListItems()
  for index, Resources in ipairs(TBOptionalGift[GiftId].Resources) do
    for i, v in ipairs(OptionalGiftIndexs) do
      if v + 1 == index then
        local ItemObj = NewObject(ObjCls, self, nil)
        ItemObj.ResourcesIndex = index - 1
        ItemObj.PropId = Resources.key
        ItemObj.PropNum = Resources.value
        ItemObj.IsInscription = false
        self.PropList:AddItem(ItemObj)
      end
    end
  end
end

return WBP_OptionalGiftMsgWaveWindow_Confirm_C
