local WBP_LobbyMemberSlot_C = UnLua.Class()
function WBP_LobbyMemberSlot_C:Construct()
  self.Button_Slot.OnHovered:Add(self, self.BindOnSlotButtonHovered)
  self.Button_Slot.OnUnhovered:Add(self, self.BindOnSlotButtonUnhovered)
  self.Button_Slot.OnClicked:Add(self, self.BindOnSlotButtonClicked)
end
function WBP_LobbyMemberSlot_C:BindOnSlotButtonHovered()
  if not self.HoveredPanel:IsVisible() then
    self.HoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAnimationForward(self.Ani_hover_in)
end
function WBP_LobbyMemberSlot_C:BindOnSlotButtonUnhovered()
  if not self.HoveredPanel:IsVisible() then
    self.HoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self:PlayAnimationForward(self.Ani_hover_out)
end
function WBP_LobbyMemberSlot_C:BindOnSlotButtonClicked()
  if self.bIsOwn then
    local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
    if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.CAREER) then
      return
    end
    UIMgr:Show(ViewID.UI_PlayerInfoMain, true, DataMgr.GetUserId())
  end
end
function WBP_LobbyMemberSlot_C:Destruct()
  self.IconObj = nil
end
function WBP_LobbyMemberSlot_C:ShowMemberIcon(Show, Local)
  if Show then
    if not self.IconObj then
      local paperSprite
      if Local then
        paperSprite = DataMgr.GetLocalAccountIcon()
      else
        paperSprite = DataMgr.GetRandomAccountIcon()
      end
      self.IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(paperSprite)
      if self.IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(self.IconObj, 43, 43)
        self.ComPortraitItem:InitComPortraitItemByBrush(Brush, "")
      end
    end
    UpdateVisibility(self.ComPortraitItem, true)
  else
    UpdateVisibility(self.ComPortraitItem, false, false, true)
  end
end
function WBP_LobbyMemberSlot_C:Show(SinglePlayerInfo, bIsOwn)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.PlayerInfo = SinglePlayerInfo
  UpdateVisibility(self.ComPortraitItem, true)
  self.bIsOwn = bIsOwn
  local PortraitRowInfo = LogicLobby.GetPlayerPortraitTableRowInfo(SinglePlayerInfo.portrait)
  if PortraitRowInfo then
    self.ComPortraitItem:InitComPortraitItem(PortraitRowInfo.portraitIconPath, PortraitRowInfo.EffectPath)
  end
end
function WBP_LobbyMemberSlot_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.PlayerInfo = nil
end
return WBP_LobbyMemberSlot_C
