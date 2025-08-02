local WBP_SingleAvatarChooseItem_C = UnLua.Class()

function WBP_SingleAvatarChooseItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_SingleAvatarChooseItem_C.BindOnMainButtonClicked)
end

function WBP_SingleAvatarChooseItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Avatar.OnAvatarChooseItemClicked, self.ItemId, self.Type)
end

function WBP_SingleAvatarChooseItem_C:Show(SingleItemId)
  local Result, AvatarRowInfo = GetDataLibraryObj().GetAvatarItemRowInfo(SingleItemId)
  if not Result then
    return
  end
  self.ItemId = SingleItemId
  self.Type = AvatarRowInfo.Type
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_Name:SetText(AvatarRowInfo.Name)
end

function WBP_SingleAvatarChooseItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_SingleAvatarChooseItem_C
