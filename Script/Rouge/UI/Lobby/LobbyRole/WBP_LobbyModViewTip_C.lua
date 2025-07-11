local WBP_LobbyModViewTip_C = UnLua.Class()
function WBP_LobbyModViewTip_C:InitModTipInfo(ModInfo, ModLevelList)
  if not ModInfo then
    print("URG_InscriptionDataAsset is Nullptr")
    return
  end
  self.TextBlock_ModName:SetText(ModInfo.Name)
  self.TextBlock_ModDescribe:SetText(ModInfo.Desc)
  self.VerticalBox_ModLevel:ClearChildren()
  local widgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/LobbyRole/Mod/WBP_LobbyModLevelDes.WBP_LobbyModLevelDes_C")
  local widget
  local Count = 0
  for key, value in pairs(ModLevelList) do
    if key > 1 then
      widget = UE.UWidgetBlueprintLibrary.Create(self, widgetClass, self:GetOwningPlayer())
      if widget then
        widget:InitLevelDes(key, value)
        self.VerticalBox_ModLevel:AddChild(widget)
        Count = Count + 1
      end
    end
  end
  UpdateVisibility(self.VerticalBox_ModLevel, Count > 0)
end
return WBP_LobbyModViewTip_C
