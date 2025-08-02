local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local SkinHandler = require("Protocol.Appearance.Skin.SkinHandler")
local WeaponSubView = Class(ViewBase)
local PreCameraData = "PrevWeapon"
local NextCameraData = "NextWeapon"
local TabKeyEvent = "TabKeyEvent"
local HideAppearanceView = "HideAppearanceView"

function WeaponSubView:OnBindUIInput()
  if not IsListeningForInputAction(self, PreCameraData) then
    ListenForInputAction(PreCameraData, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForPreCameraData
    })
  end
  if not IsListeningForInputAction(self, NextCameraData) then
    ListenForInputAction(NextCameraData, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForNextCameraData
    })
  end
  if not IsListeningForInputAction(self, TabKeyEvent) then
    ListenForInputAction(TabKeyEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForChangeDisplayModel
    })
  end
  if not IsListeningForInputAction(self, HideAppearanceView) then
    ListenForInputAction(HideAppearanceView, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.HideUIInteract
    })
  end
  self.WBP_InteractTipWidgetBuy:BindInteractAndClickEvent(self, self.OnAccessClick)
end

function WeaponSubView:OnUnBindUIInput()
  StopListeningForInputAction(self, PreCameraData, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, NextCameraData, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, TabKeyEvent, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, HideAppearanceView, UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetBuy:UnBindInteractAndClickEvent(self, self.OnAccessClick)
end

local GetWeaponSkinDisplayActor = function(self)
  if not UE.RGUtil.IsUObjectValid(self.WeaponSkinDisplayActor) and self.WeaponSkinDisplayActorCls then
    local cls = GetAssetBySoftObjectPtr(self.WeaponSkinDisplayActorCls, true)
    if cls then
      local ActorList = UE.UGameplayStatics.GetAllActorsOfClass(self, cls, nil)
      self.WeaponSkinDisplayActor = ActorList:Get(1)
    end
  end
  return self.WeaponSkinDisplayActor
end
local CheckWeaponIsUnLock = function(self, WeaponId)
  local AllWeaponList = DataMgr.AllWeaponList
  for i, v in ipairs(AllWeaponList) do
    if tonumber(v.resourceId) == WeaponId then
      return true
    end
  end
  return false
end

function WeaponSubView:BindClickHandler()
  self.RGToggleGroupWeaponSkin.OnCheckStateChanged:Add(self, self.OnWeaponSkinGroupCheckStateChanged)
  self.WBP_CommonButton_SkinTips.OnMainButtonClicked:Add(self, self.OnAccessClick)
  self.WBP_CommonButton_Equip.OnMainButtonClicked:Add(self, self.OnEquipWeaponSkinClick)
end

function WeaponSubView:UnBindClickHandler()
  self.RGToggleGroupWeaponSkin.OnCheckStateChanged:Remove(self, self.OnWeaponSkinGroupCheckStateChanged)
  self.WBP_CommonButton_SkinTips.OnMainButtonClicked:Remove(self, self.OnAccessClick)
  self.WBP_CommonButton_Equiped.OnMainButtonClicked:Remove(self, self.OnEquipWeaponSkinClick)
end

function WeaponSubView:OnInit()
  self.DataBindTable = {
    {
      Source = "EquipedWeapon",
      Callback = self.OnEquipedWeaponUpdate
    }
  }
  self.viewModel = UIModelMgr:Get("WeaponSubViewModel")
  self:BindClickHandler()
end

function WeaponSubView:OnDestroy()
  self:UnBindClickHandler()
end

function WeaponSubView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  SkinHandler.SendGetWeaponSkinList()
  self.BP_ButtonWithSoundSkin.OnClicked:Add(self, self.OnSwitchSkinClick)
  self.BP_ButtonWithSoundWeapon.OnClicked:Add(self, self.OnSwitchWeaponClick)
  self.WBP_InteractTipWidgetChangeWeaponDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetChangeDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetHideUI.OnMainButtonClicked:Add(self, self.HideUIInteract)
  self.ScrollBoxWeaponSkinList.OnUserScrolled:Add(self, self.OnWeaponSkinListScrolled)
  EventSystem.AddListenerNew(EventDef.Weapon.WeaponSkillTip, self, self.BindOnShowSkillTips)
  self:Refresh()
  self:PushInputAction()
  self.WBP_RedDotViewWeaponSkinMenu:ChangeRedDotIdByTag(self.viewModel.CurHeroId)
  self.bCanShowGlitchMatEff = false
end

function WeaponSubView:OnRollback()
  local weaponSkinDisplayActorTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayActorTemp) then
    local weaponSkinData = self.viewModel:GetWeaponSkinDataBySkinResId(self.viewModel.CurSelectWeaponSkinResId)
    if weaponSkinData then
      if self.CurSelectModel == EWeaponSelectModel.SkinModel then
        if self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel then
          self.CurDisplayModel = EWeaponSkinDisplayModel.WeaponModel
        elseif self.CurDisplayModel == EWeaponSkinDisplayModel.WeaponModel then
          self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
        end
        self:ListenForChangeDisplayModel()
      end
      weaponSkinDisplayActorTemp:UpdateActived(true)
    end
  end
end

function WeaponSubView:Refresh()
  HideOtherItem(self.HorizontalBoxWeaponList, 1)
  local weaponSkinDisplayTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayTemp) then
    weaponSkinDisplayTemp:HideMesh()
    weaponSkinDisplayTemp:UpdateActived(true)
  end
  self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
  self:ListenForChangeDisplayModel()
  self.viewModel:SwitchWeaponInfo(true)
  self.viewModel:RefreshWeaponDetailsTip()
  self:PushInputAction()
  self.WBP_RedDotViewWeaponMenu:ChangeRedDotIdByTag(self.viewModel.CurHeroId)
  self.WBP_RedDotViewWeaponSkinMenu:ChangeRedDotIdByTag(self.viewModel.CurHeroId)
  BeginnerGuideData:UpdateWBP("WBP_WeaponSubView", self)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnWeaponSubViewShow)
  self:HideUI(true)
end

function WeaponSubView:InitBuyPanel(LinkId, GoodsId, bUnlocked, AccessDesc, ParamList)
  self.LinkId = LinkId
  self.GoodsId = GoodsId
  self.AccessDesc = AccessDesc
  self.ParamList = ParamList or {}
  if bUnlocked then
    UpdateVisibility(self.CanvasPanelBuy, false)
    return
  end
  UpdateVisibility(self.ScaleBoxPrice, tonumber(LinkId) == 1007)
  UpdateVisibility(self.ScaleBoxPrice1, tonumber(LinkId) == 1007)
  if tonumber(LinkId) == 1007 then
    self.WBP_CommonButton_SkinTips:SetStyleByBottomStyleRowName("Buy")
    self.WBP_CommonButton_SkinTips:SetInfoText(AccessDesc)
    self.WBP_CommonButton_SkinTips:SetContentText("")
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[GoodsId] then
      local GoodsInfo = TBMall[GoodsId]
      self.WBP_Price:SetPrice(GoodsInfo.ConsumeResources[1].z, GoodsInfo.ConsumeResources[1].y, GoodsInfo.ConsumeResources[1].x)
      UpdateVisibility(self.WBP_Price_1, GoodsInfo.ConsumeResources[2] ~= nil)
      if GoodsInfo.ConsumeResources[2] then
        self.WBP_Price_1:SetPrice(GoodsInfo.ConsumeResources[2].y, GoodsInfo.ConsumeResources[2].z, GoodsInfo.ConsumeResources[2].x)
      end
    end
  elseif tonumber(LinkId) == nil or 0 == tonumber(LinkId) then
    self.WBP_CommonButton_SkinTips:SetStyleByBottomStyleRowName("UnAccess")
  else
    self.WBP_CommonButton_SkinTips:SetStyleByBottomStyleRowName("Access")
    self.WBP_CommonButton_SkinTips:SetContentText(AccessDesc)
  end
end

function WeaponSubView:OnHideByOther()
  local weaponSkinDisplayTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayTemp) then
    weaponSkinDisplayTemp:UpdateActived(false, true)
  end
end

function WeaponSubView:OnPreHide()
  local weaponSkinDisplayTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayTemp) then
    weaponSkinDisplayTemp:UpdateActived(false)
  end
  self.BP_ButtonWithSoundSkin.OnClicked:Remove(self, self.OnSwitchSkinClick)
  self.BP_ButtonWithSoundWeapon.OnClicked:Remove(self, self.OnSwitchWeaponClick)
  self.ScrollBoxWeaponSkinList.OnUserScrolled:Remove(self, self.OnWeaponSkinListScrolled)
  EventSystem.RemoveListenerNew(EventDef.Weapon.WeaponSkillTip, self, self.BindOnShowSkillTips)
  self:BindOnShowSkillTips(false)
  self:HideUI(true)
  self.StoneList = {}
  self.viewModel:EmptySelectWeaponId()
  self.WBP_WeaponAttrDetailsTip:AttrExpand()
  if self.CloseCallback then
    self.CloseCallback()
    self.CloseCallback = nil
  end
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end

function WeaponSubView:OnHide()
  print("")
end

function WeaponSubView:OnWeaponSkinGroupCheckStateChanged(SelectId)
  print("OnWeaponSkinGroupCheckStateChanged", SelectId)
  self.viewModel:UpdateCurSelectWeaponSkin(SelectId)
end

function WeaponSubView:OnAccessClick()
  if self.LinkId ~= "" then
    if self:LinkPurchaseConfirm(self.LinkId, self.ParamList) then
      return
    end
    local weaponSkinDisplayActorTemp = GetWeaponSkinDisplayActor(self)
    weaponSkinDisplayActorTemp:UpdateActived(false, true)
    local result, row = GetRowData(DT.DT_CommonLink, self.LinkId)
    if result then
      if ViewID[row.UIName] == ViewID.UI_DevelopMain then
        local developMain = UIMgr:GetLuaFromActiveView(ViewID.UI_DevelopMain)
        local idx = 1
        if row.LinkParams:IsValidIndex(1) then
          idx = row.LinkParams:GetRef(1).IntParam
        end
        if developMain and developMain.WBP_ViewSet then
          developMain.WBP_ViewSet.RGToggleGroupViewSet:SelectId(idx)
        end
      else
        local developMain = UIMgr:GetLuaFromActiveView(ViewID.UI_DevelopMain)
        if developMain and developMain.WBP_ViewSet then
          developMain.WBP_ViewSet:HideView()
        end
        EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, "LobbyLabel.LobbyMain")
        ComLink(self.LinkId, nil, self.viewModel.CurHeroId, self.ParamList)
      end
    end
  end
end

function WeaponSubView:LinkPurchaseConfirm(LinkId, ParamList)
  if tonumber(LinkId) ~= 1007 then
    return false
  end
  ComLink(LinkId, nil, ParamList[2], ParamList[1], 1)
  return true
end

function WeaponSubView:ListenForPreCameraData()
  local weaponSkinDisplayActorTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayActorTemp) then
    weaponSkinDisplayActorTemp:MovePreCameraTrans()
  end
end

function WeaponSubView:ListenForNextCameraData()
  local weaponSkinDisplayActorTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayActorTemp) then
    weaponSkinDisplayActorTemp:MoveNextCameraTrans()
  end
end

function WeaponSubView:ListenForChangeDisplayModel()
  if self.CurSelectModel == EWeaponSelectModel.SkinModel then
    if self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel then
      self.CurDisplayModel = EWeaponSkinDisplayModel.WeaponModel
      self:OnShowWeapon()
    else
      self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
      self:OnShowRole()
    end
  end
end

function WeaponSubView:OnShowRole()
  local weaponSkinDisplayActorTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayActorTemp) then
    weaponSkinDisplayActorTemp:InitAppearanceActor(self.viewModel.CurHeroId, self.viewModel:GetCurEquipedHeroSkinId(), self.viewModel.CurSelectWeaponSkinResId, true)
  end
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, true)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, false)
end

function WeaponSubView:OnShowWeapon()
  local weaponSkinDisplayActorTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayActorTemp) then
    if self.CurSelectModel == EWeaponSelectModel.WeaponModel then
      weaponSkinDisplayActorTemp:InitWeaponMesh(self.viewModel.CurSelectWeaponSkinResId, self.viewModel:GetCurEquipedWeaponResId(), self.WeaponTransformOffset, nil, true)
    elseif self.CurSelectModel == EWeaponSelectModel.SkinModel then
      weaponSkinDisplayActorTemp:InitWeaponMesh(self.viewModel.CurSelectWeaponSkinResId, self.viewModel:GetCurEquipedWeaponResId(), self.SkinWeaponTransformOffset, true, true)
    end
  end
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, false)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, true)
end

function WeaponSubView:HideUIInteract()
  if self.CurSelectModel ~= EWeaponSelectModel.SkinModel then
    return
  end
  self.bShowUI = not self.bShowUI
  self:HideUI(self.bShowUI)
end

function WeaponSubView:HideUI(bIsShowUIParam)
  self.bShowUI = bIsShowUIParam
  EventSystem.Invoke(EventDef.Develop.UpdateViewSetVisible, self.bShowUI, true)
  UpdateVisibility(self.WeaponSelectPanel, self.bShowUI)
end

function WeaponSubView:OnSwitchSkinClick()
  self.CurSelectModel = EWeaponSelectModel.SkinModel
  self.viewModel:RefreshWeaponDetails()
  self.viewModel:UpdateWeaponSkinList(self.viewModel.CurSelectWeaponSkinResId)
  if not self:IsAnimationPlaying(self.Ani_Weapon_in) then
    self:PlayAnimation(self.Ani_WeaponSkin_in)
  end
  UpdateVisibility(self.CanvasPanelWeaponList, false)
  UpdateVisibility(self.CanvasPanelWeaponSkin, true)
  UpdateVisibility(self.WBP_WeaponAttrDetailsTip, false)
  UpdateVisibility(self.CanvasPanelWeaponUnSelect, true)
  UpdateVisibility(self.CanvasPanelWeaponSelect, false)
  UpdateVisibility(self.CanvasPanelSkinUnSelect, false)
  UpdateVisibility(self.CanvasPanelSkinSelect, true)
  local unLock = self.viewModel:CheckSkinUnLock()
  UpdateVisibility(self.CanvasPanelDetail, not unLock)
  UpdateVisibility(self.SkinTips, false)
  UpdateVisibility(self.WeaponTips, false)
  self.ScrollBoxWeaponSkinList:ScrollToStart()
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, false)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, true)
end

function WeaponSubView:OnSwitchWeaponClick()
  self.CurSelectModel = EWeaponSelectModel.WeaponModel
  self.viewModel:RefreshWeaponDetails()
  self.viewModel:UpdateWeaponSkinList()
  if not self:IsAnimationPlaying(self.Ani_WeaponSkin_in) then
    self:PlayAnimation(self.Ani_WeaponList_in)
  end
  UpdateVisibility(self.CanvasPanelWeaponList, true)
  UpdateVisibility(self.CanvasPanelWeaponSkin, false)
  UpdateVisibility(self.WBP_WeaponAttrDetailsTip, true)
  UpdateVisibility(self.CanvasPanelWeaponUnSelect, false)
  UpdateVisibility(self.CanvasPanelWeaponSelect, true)
  UpdateVisibility(self.CanvasPanelSkinUnSelect, true)
  UpdateVisibility(self.CanvasPanelSkinSelect, false)
  local weaponData = self.viewModel:GetCurSelectWeaponData()
  if weaponData then
    UpdateVisibility(self.CanvasPanelDetail, not weaponData.WeaponData)
    UpdateVisibility(self.SkinTips, false)
    UpdateVisibility(self.WeaponTips, not weaponData.WeaponData)
    UpdateVisibility(self.CanvasPanelInfoDetails, false)
  else
    UpdateVisibility(self.CanvasPanelDetail, false)
    UpdateVisibility(self.SkinTips, false)
    UpdateVisibility(self.WeaponTips, false)
    UpdateVisibility(self.CanvasPanelInfoDetails, false)
  end
end

function WeaponSubView:OnEquipWeaponSkinClick()
  if self.CurSelectModel == EWeaponSelectModel.WeaponModel then
    self.viewModel:SendRequestEquipWeapon()
  elseif self.CurSelectModel == EWeaponSelectModel.SkinModel then
    self.viewModel:SendEquipWeaponSkinReq(self.viewModel.CurSelectWeaponSkinResId)
  end
end

function WeaponSubView:OnWeaponSkinListUpdate(ShowWeaponSkinDataMap, showWeaponIdList, WeaponResId, CurSelectWeaponSkinResId)
  if not CheckIsVisility(self.CanvasPanelWeaponSkin) then
    self:PlayAnimation(self.Ani_CanvasPanelWeaponSkin_in)
  end
  local accumulatedIdx = 0
  local needSelectId = -1
  self.RGToggleGroupWeaponSkin:ClearGroup()
  self.WeaponIdToSkinTitleItemTop = {}
  self.WeaponIdToSkinTitleItemBottom = {}
  self.WeaponIdToWeaponSkinListItem = {}
  local cumulative = 0
  local WeaponSkinItemPadding_Y = self.WBP_WeaponSkinListItem.WrapBoxWeaponSkin.InnerSlotPadding.Y
  local TitlePadding_Y = self.WBP_WeaponSkinListItem.SizeBoxTitle.Slot.Padding.Top
  for i, v in ipairs(showWeaponIdList) do
    local weaponSkinListData = ShowWeaponSkinDataMap[v]
    local weaponSkinListItem = GetOrCreateItem(self.ScrollBoxWeaponSkinList, i, self.WBP_WeaponSkinListItem:GetClass())
    weaponSkinListItem:InitWeaponSkinListItem(weaponSkinListData, v, self.RGToggleGroupWeaponSkin, self.viewModel.CurHeroId, self)
    self.WeaponIdToWeaponSkinListItem[v] = {Item = weaponSkinListItem, PosY = cumulative}
    local skinCount = 0
    for i, v in ipairs(weaponSkinListData.SkinDataList) do
      if self:CheckIsShow(v.WeaponSkinTb, v.bUnlocked) then
        skinCount = skinCount + 1
      end
    end
    local height = weaponSkinListItem.SizeBoxTitle.HeightOverride + TitlePadding_Y + skinCount * (weaponSkinListItem.WBP_WeaponSkinItem.SizeBoxRoot.HeightOverride + WeaponSkinItemPadding_Y)
    height = height - WeaponSkinItemPadding_Y
    cumulative = cumulative + height
    if nil == CurSelectWeaponSkinResId or CurSelectWeaponSkinResId < 0 then
      if -1 == needSelectId then
        needSelectId = weaponSkinListData.EquipedSkinId
      end
    else
      needSelectId = CurSelectWeaponSkinResId
    end
    local weaponSkinTitleItemTop = GetOrCreateItem(self.VerticalBoxWeaponTitleTop, i, self.WBP_WeaponSkinTitleItemTop:GetClass())
    weaponSkinTitleItemTop:InitWeaponSkinTitleItem(v, self, i, self.viewModel.CurHeroId)
    self.WeaponIdToSkinTitleItemTop[v] = weaponSkinTitleItemTop
  end
  for i = 1, #showWeaponIdList do
    local v = showWeaponIdList[i]
    local weaponSkinTitleItemBottom = GetOrCreateItem(self.VerticalBoxWeaponTitleBottom, i, self.WBP_WeaponSkinTitleItemBottom:GetClass())
    weaponSkinTitleItemBottom:InitWeaponSkinTitleItem(v, self, i, self.viewModel.CurHeroId)
    self.WeaponIdToSkinTitleItemBottom[v] = weaponSkinTitleItemBottom
  end
  HideOtherItem(self.ScrollBoxWeaponSkinList, #showWeaponIdList + 1)
  HideOtherItem(self.VerticalBoxWeaponTitleTop, #showWeaponIdList + 1)
  HideOtherItem(self.VerticalBoxWeaponTitleBottom, #showWeaponIdList + 1)
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
        self,
        function()
          local offset = self.ScrollBoxWeaponSkinList:GetScrollOffset()
          self:UpdateWeaponSkinTitle(offset)
        end
      })
    end
  })
  if needSelectId >= 0 then
    self.RGToggleGroupWeaponSkin:SelectId(needSelectId)
  else
    self.RGToggleGroupWeaponSkin:SelectId(CurSelectWeaponSkinResId)
  end
  self.CurDisplayModel = EWeaponSkinDisplayModel.WeaponModel
  local weaponSkinDisplayTemp = GetWeaponSkinDisplayActor(self)
  if UE.RGUtil.IsUObjectValid(weaponSkinDisplayTemp) then
    if self.CurSelectModel == EWeaponSelectModel.WeaponModel then
      weaponSkinDisplayTemp:InitWeaponMesh(needSelectId, WeaponResId, self.WeaponTransformOffset, true, self.bCanShowGlitchMatEff)
    elseif self.CurSelectModel == EWeaponSelectModel.SkinModel then
      weaponSkinDisplayTemp:InitWeaponMesh(needSelectId, WeaponResId, self.SkinWeaponTransformOffset, true, self.bCanShowGlitchMatEff)
    end
  end
end

function WeaponSubView:UpdateDetailsView(bIsUnLock)
  if self.CurSelectModel == EWeaponSelectModel.WeaponModel then
    UpdateVisibility(self.HorizontalBoxInteract, false)
    local weaponData = self.viewModel:GetCurSelectWeaponData()
    UpdateVisibility(self.SkinTips, false)
    if weaponData then
      UpdateVisibility(self.CanvasPanelDetail, not weaponData.WeaponData)
      UpdateVisibility(self.WeaponTips, not weaponData.WeaponData)
      local WeaponTable = LuaTableMgr.GetLuaTableByName(TableNames.TBWeapon)
      local WeaponRowInfo = WeaponTable[weaponData.resourceId]
      if not weaponData.WeaponData and WeaponRowInfo.LinkId ~= "" then
        UpdateVisibility(self.SkinTips, true)
        self:InitBuyPanel(WeaponRowInfo.LinkId, WeaponRowInfo.ParamList[2], bIsUnLock, WeaponRowInfo.LinkDesc, WeaponRowInfo.ParamList)
        UpdateVisibility(self.WeaponTips, false)
      else
        UpdateVisibility(self.WeaponTips, true)
      end
    else
      UpdateVisibility(self.CanvasPanelDetail, true)
      UpdateVisibility(self.WeaponTips, true)
    end
    local EquipResId = DataMgr.GetEquippedWeaponList(self.viewModel.CurHeroId)[1].uuid
    local IsEquip = EquipResId == weaponData.uuid
    UpdateVisibility(self.CanvasPanelEquip, weaponData.WeaponData and not IsEquip, true)
    UpdateVisibility(self.CanvasPanelEquiping, IsEquip)
  elseif self.CurSelectModel == EWeaponSelectModel.SkinModel then
    local weaponSkinData = self.viewModel:GetWeaponSkinDataBySkinResId(self.viewModel.CurSelectWeaponSkinResId)
    UpdateVisibility(self.CanvasPanelDetail, false)
    UpdateVisibility(self.HorizontalBoxInteract, true)
    local WeaponUnlock = CheckWeaponIsUnLock(self, weaponSkinData.WeaponSkinTb.WeaponID)
    UpdateVisibility(self.CanvasPanelEquip, false)
    UpdateVisibility(self.CanvasPanelNeedUnLock, false)
    UpdateVisibility(self.CanvasPanelEquiping, false)
    if weaponSkinData then
      UpdateVisibility(self.CanvasPanelInfoDetails, true)
      self.WBP_SkinDetailsItem:UpdateDetailsView(weaponSkinData.WeaponSkinTb.ID, nil, self)
    else
      UpdateVisibility(self.CanvasPanelInfoDetails, false)
    end
    UpdateVisibility(self.SkinTips, false)
    UpdateVisibility(self.WeaponTips, false)
  end
end

function WeaponSubView:OnWeaponSkinListScrolled(CurrentOffset)
  self:UpdateWeaponSkinTitle(CurrentOffset)
end

function WeaponSubView:UpdateWeaponSkinTitle(CurrentOffset)
  local GeometryScrollBoxWeaponSkinList = self.ScrollBoxWeaponSkinList:GetCachedGeometry()
  print(CurrentOffset)
  for k, v in pairs(self.WeaponIdToWeaponSkinListItem) do
    local posY = v.PosY - CurrentOffset
    local item = v.Item
    local itemSkinTitleTop = self.WeaponIdToSkinTitleItemTop[item.WeaponResId]
    local GeometrySkinTitleTopItem = itemSkinTitleTop:GetCachedGeometry()
    local itemSkinTitleBottom = self.WeaponIdToSkinTitleItemBottom[item.WeaponResId]
    local GeometrySkinTitleBottomItem = itemSkinTitleBottom:GetCachedGeometry()
    local posTop = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryScrollBoxWeaponSkinList, GeometrySkinTitleTopItem)
    local posBottom = UE.URGBlueprintLibrary.GetAbsoluteToLocal(GeometryScrollBoxWeaponSkinList, GeometrySkinTitleBottomItem)
    if CurrentOffset > v.PosY then
      UpdateVisibility(itemSkinTitleTop, true, false, true)
    else
      UpdateVisibility(itemSkinTitleTop, false, false, true)
    end
    local ScrollBoxGeometry = self.ScrollBoxWeaponSkinList:GetCachedGeometry()
    local ScrollBoxSize = UE.USlateBlueprintLibrary.GetLocalSize(ScrollBoxGeometry)
    if ScrollBoxSize.y + CurrentOffset < v.PosY then
      UpdateVisibility(itemSkinTitleBottom, true, false, true)
    else
      UpdateVisibility(itemSkinTitleBottom, false, false, true)
    end
  end
end

function WeaponSubView:OnSkinTitleSelect(WeaponResId)
  if self.WeaponIdToWeaponSkinListItem and self.WeaponIdToWeaponSkinListItem[WeaponResId] then
    local idx = self.WeaponIdToSkinTitleItemTop[WeaponResId].Idx
    local offset = self.WBP_WeaponSkinListItem.SizeBoxTitle.HeightOverride * (idx - 1)
    self.ScrollBoxWeaponSkinList:ScrollWidgetIntoView(self.WeaponIdToWeaponSkinListItem[WeaponResId].Item, true, UE.EDescendantScrollDestination.TopOrLeft, offset)
  end
end

function WeaponSubView:OnWeaponListUpdate(WeaponList, equipedIdx, CurSelectIdx, SelectWeaponIdx)
  local WeaponListTemp = WeaponList or {}
  for i, v in ipairs(WeaponListTemp) do
    local WeaponItem = GetOrCreateItem(self.HorizontalBoxWeaponList, i, self.WBP_RoleUnEquipedWeaponItem:GetClass())
    local bIsSelect = SelectWeaponIdx == i
    if -1 == SelectWeaponIdx then
      bIsSelect = i == equipedIdx
    end
    WeaponItem:InitUnEquipedWeaponItem(v, i == equipedIdx, self, bIsSelect)
  end
  HideOtherItem(self.HorizontalBoxWeaponList, #WeaponListTemp + 1)
  local weaponResId = -1
  if WeaponListTemp[CurSelectIdx] then
    weaponResId = tonumber(WeaponListTemp[CurSelectIdx].resourceId)
  elseif WeaponListTemp[equipedIdx] then
    weaponResId = tonumber(WeaponListTemp[equipedIdx].resourceId)
  end
  if weaponResId > 0 then
    self.viewModel:SelectCurEquipedSkin(weaponResId)
  end
  if self.HorizontalBoxWeaponList:GetChildrenCount() > 1 then
    local MinUnSelectedIdx = 0
    if 1 == CurSelectIdx then
      MinUnSelectedIdx = 1
    end
    BeginnerGuideData:UpdateWidget("WeaponSubViewSecondWeapon", self.HorizontalBoxWeaponList:GetChildAt(MinUnSelectedIdx))
  end
end

function WeaponSubView:SetCloseCallback(CloseCallback)
  self.CloseCallback = CloseCallback
end

function WeaponSubView:ShowWeaponInfo(bReset, weaponResId, playAni)
  if self.CurShowModel == EWeaponShowModel.WeaponModel and false == bReset then
    return
  end
  self.CurShowModel = EWeaponShowModel.WeaponModel
  if playAni and not self:IsAnimationPlaying(self.Ani_Weapon_in) then
    self:PlayAnimation(self.Ani_Weapon_in)
  end
  UpdateVisibility(self.CanvasPanelWeaponToggle, true)
  self.WBP_RoleWeaponItem:Select()
  self:OnSwitchWeaponClick()
  self.WBP_WeaponAttrDetailsTip:SwitchToWeapon()
  if weaponResId then
    local weaponInfo = self.viewModel:GetWeaponDataByResId(weaponResId)
    self.viewModel:SelectWeapon(weaponInfo)
  end
end

function WeaponSubView:OnEquipedWeaponUpdate(EquipedWeapon)
  self.WBP_RoleWeaponItem:InitWeaponItem(EquipedWeapon, true, self)
end

function WeaponSubView:OnWeaponDetailsTipUpdate(EquipedWeapon, bMaintainVisble)
  if not EquipedWeapon then
    if not bMaintainVisble then
      UpdateVisibility(self.WBP_WeaponAttrDetailsTip, false)
    end
    return
  else
    if not bMaintainVisble then
      UpdateVisibility(self.WBP_WeaponAttrDetailsTip, true)
    end
    self.WBP_WeaponAttrDetailsTip:InitWeaponAttrDetailsTip(EquipedWeapon.resourceId, {}, self)
  end
end

function WeaponSubView:CheckIsShow(SkinTb, IsUnlocked)
  if SkinTb.IsUnlockShow and not IsUnlocked then
    return false
  end
  return SkinTb.IsShow and (0 == SkinTb.ParentSkinId or SkinTb.ParentSkinId == nil)
end

function WeaponSubView:WeaponSelectClick(WeaponInfo)
  self.bCanShowGlitchMatEff = true
  self.viewModel:RequestEquipWeapon(WeaponInfo, true)
end

function WeaponSubView:BindOnShowSkillTips(IsShow, WeaponSkillData, KeyName)
  if IsShow then
    self.NormalSkillTip:RefreshInfoByWeaponSkillData(WeaponSkillData, KeyName)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.NormalSkillTip:Hide()
  end
end

function WeaponSubView:OnAnimationFinished(Animation)
end

function WeaponSubView:AttrExpandOrRetract(bIsExpand)
  self.bIsExpand = bIsExpand
end

return WeaponSubView
