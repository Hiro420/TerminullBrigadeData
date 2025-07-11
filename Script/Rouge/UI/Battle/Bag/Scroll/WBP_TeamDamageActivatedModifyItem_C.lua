local AttributeModityData = require("Modules.AttributeModity.AttributeModityData")
local WBP_TeamDamageActivatedModifyItem_C = UnLua.Class()
function WBP_TeamDamageActivatedModifyItem_C:Construct()
  self.Overridden.Construct(self)
  self.ScrollId = -1
  self.Index = -1
  self.bIsHovered = false
  EventSystem.AddListenerNew(EventDef.TeamDamage.OnUpdateHoverStatus, self, self.BindOnUpdateHoverStatus)
end
function WBP_TeamDamageActivatedModifyItem_C:UpdateScrollData(ScollId, UpdateScrollTips, ParentView, ParentItemPanel, Index, PS)
  self.ParentView = ParentView
  self.ParentItemPanel = ParentItemPanel
  self.ScrollId = ScollId
  self.Index = Index
  self.UpdateScrollTips = UpdateScrollTips
  self.PS = PS
  if ScollId then
    UpdateVisibility(self.Canvas_Null, false)
    self.WBP_Item:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    if self.bIsHovered then
      self:Hovered(false)
    end
    self.WBP_Item:InitItem(ScollId)
    self.RGStateController_Like:ChangeStatus("LikeByNone")
    if self.PS then
      local LikeUserIdList = UE.URGGameplayLibrary.GetItemRequestUsers(self, tonumber(self.PS:GetUserId()), ScollId)
      if LikeUserIdList and LikeUserIdList:Num() > 0 then
        local bIsLikeBySelf = false
        for i, UserId in iterator(LikeUserIdList) do
          if UserId == tonumber(DataMgr.GetUserId()) then
            bIsLikeBySelf = true
          end
        end
        if bIsLikeBySelf then
          self.RGStateController_Like:ChangeStatus("LikeBySelf")
        elseif self.PS:GetUserId() == tonumber(DataMgr.GetUserId()) then
          self.RGStateController_Like:ChangeStatus("LikeByOther")
        end
      end
    end
  else
    UpdateVisibility(self.Canvas_Null, true)
    UpdateVisibility(self.WBP_Item, false)
    self.RGStateController_Like:ChangeStatus("LikeByNone")
  end
end
function WBP_TeamDamageActivatedModifyItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self:Hovered(true)
end
function WBP_TeamDamageActivatedModifyItem_C:Hovered(bIsNeedInit)
  if self.ParentView and self.ScrollId and self.ScrollId > 0 then
    self.UpdateScrollTips(self.ParentView, true, self.ScrollId, self, EScrollTipsOpenType.EFromScrollSlot, bIsNeedInit, self.PS:GetUserId())
  end
  UpdateVisibility(self.URGImageHover, true)
  self.bIsHovered = true
  if not IsListeningForInputAction(self, "Interact") then
    ListenForInputAction("Interact", UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_TeamDamageActivatedModifyItem_C.ListenForInteractInputAction
    })
  end
end
function WBP_TeamDamageActivatedModifyItem_C:UnHovered()
  if self.ParentView then
    self.UpdateScrollTips(self.ParentView, false, -1, nil, EScrollTipsOpenType.EFromScrollSlot, false, nil)
  end
  UpdateVisibility(self.URGImageHover, false)
  self.bIsHovered = false
  if IsListeningForInputAction(self, "Interact") then
    StopListeningForInputAction(self, "Interact", UE.EInputEvent.IE_Pressed)
  end
end
function WBP_TeamDamageActivatedModifyItem_C:OnMouseLeave(MyGeometry, MouseEvent)
  self:UnHovered()
end
function WBP_TeamDamageActivatedModifyItem_C:UpdateHighlight(bIsShow)
  UpdateVisibility(self.URGImageHover, bIsShow)
end
function WBP_TeamDamageActivatedModifyItem_C:IsEmptySlot()
  return -1 == self.ScrollId or self.ScrollId == nil
end
function WBP_TeamDamageActivatedModifyItem_C:Hide()
  UpdateVisibility(self, false)
  if self.bIsHovered then
    self:UnHovered()
  end
  self.ParentView = nil
  self.ParentItemPanel = nil
  self.UpdateScrollTips = nil
  self.Index = -1
  self.ScrollId = -1
end
function WBP_TeamDamageActivatedModifyItem_C:ListenForInteractInputAction()
  if self.bIsTeamDamage and not self.bIsOwner then
    local CurrentUserId = self.PS and self.PS:GetUserId() or nil
    if CurrentUserId then
      if AttributeModityData:GetRequesing(CurrentUserId) ~= nil then
        ShowWaveWindow(1212)
        return
      end
      if nil ~= AttributeModityData:GetRefused(CurrentUserId) then
        ShowWaveWindow(1209)
        return
      end
      local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
      if not Character then
        return
      end
      for i, v in iterator(Character.AttributeModifyComponent.ActivatedModifies) do
        if v == self.ScrollId then
          ShowWaveWindow(1137)
          return
        end
      end
      if Character.AttributeModifyComponent.ActivatedModifies:Length() >= Character.AttributeModifyComponent.MaxAttributeModifyNumber then
        ShowWaveWindow(1210)
        return
      end
      AttributeModityData:AddRequesing(CurrentUserId, self.ScrollId)
      UE.URGGameplayLibrary.RequestItem(self, tonumber(DataMgr.GetUserId()), CurrentUserId, self.ScrollId)
      PlayVoice("Voice.Attributemodify.Request", UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0))
      if self.ParentView and self.ScrollId and self.ScrollId > 0 then
        self.UpdateScrollTips(self.ParentView, true, self.ScrollId, self, EScrollTipsOpenType.EFromScrollSlot, false, CurrentUserId)
      end
    else
      print("ywtao, \232\175\165\231\142\169\229\174\182\229\183\178\230\142\137\231\186\191\239\188\140\230\151\160\230\179\149\230\160\135\232\174\176\232\151\143\229\147\129\239\188\129")
    end
  end
end
function WBP_TeamDamageActivatedModifyItem_C:Destruct()
  self.ParentView = nil
  self.ParentItemPanel = nil
  self.UpdateScrollTips = nil
  self.Index = -1
  self.bIsHovered = false
  EventSystem.RemoveListenerNew(EventDef.TeamDamage.OnUpdateHoverStatus, self, self.BindOnUpdateHoverStatus)
end
function WBP_TeamDamageActivatedModifyItem_C:BindOnUpdateHoverStatus(UserId, AttributeModifyIndex, GenericModifyIndex)
  if self.PS and tonumber(self.PS:GetUserId()) == tonumber(UserId) and self.Index == AttributeModifyIndex then
    self:SetKeyboardFocus()
  end
end
function WBP_TeamDamageActivatedModifyItem_C:OnAddedToFocusPath(...)
  self:Hovered()
end
function WBP_TeamDamageActivatedModifyItem_C:OnRemovedFromFocusPath(...)
  self:UnHovered()
end
function WBP_TeamDamageActivatedModifyItem_C:DoCustomNavigation_Left()
  if self.ParentItemPanel then
    return self.ParentItemPanel:GetModifyItemLeft(self.Index, false)
  end
end
function WBP_TeamDamageActivatedModifyItem_C:DoCustomNavigation_Right()
  if self.ParentItemPanel then
    return self.ParentItemPanel:GetModifyItemRight(self.Index, false)
  end
end
function WBP_TeamDamageActivatedModifyItem_C:DoCustomNavigation_Up()
  if self.ParentItemPanel then
    return self.ParentItemPanel:GetModifyItemUp(self.Index)
  end
end
function WBP_TeamDamageActivatedModifyItem_C:DoCustomNavigation_Down()
  if self.ParentItemPanel then
    return self.ParentItemPanel:GetModifyItemDown(self.Index)
  end
end
return WBP_TeamDamageActivatedModifyItem_C
