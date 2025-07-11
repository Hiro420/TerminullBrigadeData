local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local PreCameraData = "PrevWeapon"
local NextCameraData = "NextWeapon"
local HeirloomHandler = require("Protocol.Appearance.Heirloom.HeirloomHandler")
local TabKeyEvent = "TabKeyEvent"
local HeirloomView = Class(ViewBase)
function HeirloomView:OnBindUIInput()
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
  self.WBP_InteractTipWidgetUnlock:BindInteractAndClickEvent(self, self.BindOnUnLockButtonClicked)
  self.WBP_InteractTipWidgetDetail:BindInteractAndClickEvent(self, self.BindOnMovieButtonClicked)
end
function HeirloomView:OnUnBindUIInput()
  StopListeningForInputAction(self, PreCameraData, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, NextCameraData, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, TabKeyEvent, UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetUnlock:UnBindInteractAndClickEvent(self, self.BindOnUnLockButtonClicked)
  self.WBP_InteractTipWidgetDetail:UnBindInteractAndClickEvent(self, self.BindOnMovieButtonClicked)
end
function HeirloomView:BindClickHandler()
  self.Btn_UnLock.OnClicked:Add(self, self.BindOnUnLockButtonClicked)
  self.Btn_UnLock.OnHovered:Add(self, self.BindOnUnLockButtonHovered)
  self.Btn_UnLock.OnUnhovered:Add(self, self.BindOnUnLockButtonUnhovered)
  self.Btn_GoToSkin.OnClicked:Add(self, self.BindOnGoToSkinButtonClicked)
  self.Btn_GoToSkin.OnHovered:Add(self, self.BindOnGoToSkinButtonHovered)
  self.Btn_GoToSkin.OnUnhovered:Add(self, self.BindOnGoToSkinButtonUnhovered)
  self.Btn_Movie.OnClicked:Add(self, self.BindOnMovieButtonClicked)
  self.Btn_Action.OnClicked:Add(self, self.BindOnActionButtonClicked)
  self.Btn_AutoPlayAction.OnClicked:Add(self, self.BindOnAutoPlayActionButtonClicked)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.BindOnEscTipWidgetClicked)
  self.WBP_InteractTipWidgetChangeWeaponDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetChangeDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
end
function HeirloomView:UnBindClickHandler()
  self.Btn_UnLock.OnClicked:Remove(self, self.BindOnUnLockButtonClicked)
  self.Btn_UnLock.OnHovered:Remove(self, self.BindOnUnLockButtonHovered)
  self.Btn_UnLock.OnUnhovered:Remove(self, self.BindOnUnLockButtonUnhovered)
  self.Btn_GoToSkin.OnClicked:Remove(self, self.BindOnGoToSkinButtonClicked)
  self.Btn_GoToSkin.OnHovered:Remove(self, self.BindOnGoToSkinButtonHovered)
  self.Btn_GoToSkin.OnUnhovered:Remove(self, self.BindOnGoToSkinButtonUnhovered)
  self.Btn_Movie.OnClicked:Remove(self, self.BindOnMovieButtonClicked)
  self.Btn_Action.OnClicked:Remove(self, self.BindOnActionButtonClicked)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.BindOnEscTipWidgetClicked)
  self.WBP_InteractTipWidgetChangeWeaponDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetChangeDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
end
local GetAppearanceActor = function(self)
  if not UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
    local CameraActorList = UE.UGameplayStatics.GetAllActorsOfClass(self, self.AppearanceActorClass, nil)
    self.AppearanceActor = CameraActorList:Get(1)
  end
  return self.AppearanceActor
end
function HeirloomView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("HeirloomViewModel")
  self:BindClickHandler()
end
function HeirloomView:OnDestroy()
  self:UnBindClickHandler()
  self:OnHide()
end
function HeirloomView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  GetAppearanceActor(self)
  local apearanceView = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  if UE.RGUtil.IsUObjectValid(apearanceView) then
    apearanceView.WBP_AppearanceMovieList:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  self.TargetHeirloomId = -1
  local AllHeirloomIds = self.ViewModel:GetAllHeirloomByCurOperateHeroId()
  for index, SingleHeirloomId in ipairs(AllHeirloomIds) do
    self.TargetHeirloomId = SingleHeirloomId
    break
  end
  if -1 == self.TargetHeirloomId then
    self.Btn_GoToSkin:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.HeirloomInfoPanel:Show(self.TargetHeirloomId)
    print("HeirloomView:OnShow \229\189\147\229\137\141\230\156\170\233\133\141\231\189\174\228\188\160\229\174\182\229\174\157\239\188\140HeroId:", self.ViewModel:GetCurOperateHeroId())
    return
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, HeirloomData:GetHeirloomResourceId(self.TargetHeirloomId))
  if Result then
    self.Txt_HeirloomName:SetText(RowInfo.Name)
    local Result, ItemRarityRowInfo = GetRowData(DT.DT_ItemRarity, RowInfo.Rare)
    if Result then
      self.Img_HeirloomTitleBottom:SetColorAndOpacity(ItemRarityRowInfo.DisplayNameColor.SpecifiedColor)
    end
  end
  self:SetIsAutoPlayCharacterAction(self.IsAutoPlayCharacterAction)
  self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:OnAnimationFinished(self.Ani_UnLockBtn_hover_out)
  self:OnAnimationFinished(self.Ani_GoToSkinBtn_hover_out)
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomInfoChanged, self.BindOnHeirloomInfoChanged)
  EventSystem.AddListener(self, EventDef.Heirloom.OnAfterChangeHeirloomLevelSelected, self.BindOnChangeHeirloomLevelSelected)
  EventSystem.AddListener(self, EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.BindOnHeirloomSelectedItemChanged)
  EventSystem.AddListener(self, EventDef.Skin.OnHeroSkinUpdate, self.BindOnHeroSkinUpdate)
  EventSystem.AddListener(self, EventDef.Skin.OnWeaponSkinUpdate, self.BindOnWeaponSkinUpdate)
  EventSystem.AddListener(self, EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged)
  EventSystem.AddListenerNew(EventDef.Heirloom.OnHeirloomHeroSkinActionItemSelected, self, self.BindOnHeirloomHeroSkinActionItemSelected)
  self.HeirloomInfoPanel:Show(self.TargetHeirloomId)
end
function HeirloomView:BindOnEscTipWidgetClicked()
  local AppearanceView = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  if AppearanceView then
    AppearanceView:ListenForEscInputAction()
  end
end
function HeirloomView:OnRollback()
  HeirloomData:SetCurSelectHeirloomIdAndLevel(self.CurSelectHeirloomId, self.CurSelectHeirloomLevel)
  HeirloomHandler:RequestGetFamilytreasureToServer()
  self:BindOnHeirloomSelectedItemChanged(self.CurSelectItemResourceId)
  self:RefreshCostPanel()
  self:RefreshButtonStatus()
end
function HeirloomView:BindOnUnLockButtonClicked()
  if not self.CanUnLock then
    return
  end
  if self.IsUnLockButtonNeedComLink then
    local CurSelectHeirloomLevel = HeirloomData:GetCurSelectLevel()
    local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
    local RowInfo = HeirloomData:GetHeirloomInfoByLevel(CurSelectHeirloomId, CurSelectHeirloomLevel)
    if RowInfo and not UE.UKismetStringLibrary.IsEmpty(RowInfo.LinkId) then
      ComLink(RowInfo.LinkId)
    end
    return
  end
  self.ViewModel:RequestUpgradeFamilyTreasureToServer(self.TargetHeirloomId)
end
function HeirloomView:BindOnUnLockButtonHovered()
  self.UnLockBtnHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationForward(self.Ani_UnLockBtn_hover_in)
end
function HeirloomView:BindOnUnLockButtonUnhovered()
  self:PlayAnimationForward(self.Ani_UnLockBtn_hover_out)
end
function HeirloomView:OnAnimationFinished(Animation)
  if Animation == self.Ani_UnLockBtn_hover_out then
    self.UnLockBtnHoveredPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  elseif Animation == self.Ani_GoToSkinBtn_hover_out then
    self.GoToSkinBtnHoveredPanel:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end
function HeirloomView:BindOnGoToSkinButtonClicked()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.CurSelectItemResourceId)
  if Result and RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
    if UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
      self.AppearanceActor:UpdateActived(false)
    end
    EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, true, 0)
  elseif RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
    EventSystem.Invoke(EventDef.Heirloom.ChangeAppearanceViewToggleGroupSelect, EAppearanceToggleStatus.Skin)
    local SkinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
    if SkinView then
      SkinView.RGToggleGroupFirst:SelectId(ESkinToggleStatus.WeaponSkin)
      local SkinResult, SkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, self.CurSelectItemResourceId)
      if SkinResult then
        SkinView:ScrollToTargetWeaponSkin(SkinRowInfo.WeaponID, SkinRowInfo.SkinID)
      end
    end
  elseif RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
    EventSystem.Invoke(EventDef.Heirloom.ChangeAppearanceViewToggleGroupSelect, EAppearanceToggleStatus.Skin)
  end
end
function HeirloomView:BindOnGoToSkinButtonHovered()
  self.GoToSkinBtnHoveredPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self:PlayAnimationForward(self.Ani_GoToSkinBtn_hover_in)
end
function HeirloomView:BindOnGoToSkinButtonUnhovered()
  self:PlayAnimationForward(self.Ani_GoToSkinBtn_hover_out)
end
function HeirloomView:BindOnMovieButtonClicked(...)
  local apearanceView = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  if UE.RGUtil.IsUObjectValid(apearanceView) then
    apearanceView.WBP_AppearanceMovieList:InitMovieList(self.CurSkinId)
  end
end
function HeirloomView:BindOnActionButtonClicked(...)
  local TargetVis = not self.IsExpandActionList
  self:UpdateExpandActionListVis(TargetVis)
end
function HeirloomView:BindOnAutoPlayActionButtonClicked(...)
  self:SetIsAutoPlayCharacterAction(not self.IsAutoPlayCharacterAction)
end
function HeirloomView:UpdateExpandActionListVis(IsShow)
  UpdateVisibility(self.SizeBox_ExpandActionList, IsShow)
  self.IsExpandActionList = IsShow
  if IsShow then
    self.Img_ActionArrow:SetRenderTransformAngle(180)
    self.Img_Action_BG:SetColorAndOpacity(self.ExpandActionBGColor)
    self.Img_ActionArrow:SetColorAndOpacity(self.ExpandActionArrowColor)
    self.Txt_Action:SetColorAndOpacity(self.ExpandActionTextColor)
  else
    self.Img_ActionArrow:SetRenderTransformAngle(0)
    self.Img_Action_BG:SetColorAndOpacity(self.NormalActionBGColor)
    self.Img_ActionArrow:SetColorAndOpacity(self.NormalActionArrowColor)
    self.Txt_Action:SetColorAndOpacity(self.NormalActionTextColor)
  end
end
function HeirloomView:BindOnHeirloomInfoChanged()
  self:RefreshHeirloomLevelItemLockStatus()
  self:RefreshCostPanel()
  self:RefreshButtonStatus()
  self:RefreshGoToSkinButtonVis()
end
function HeirloomView:BindOnChangeHeirloomLevelSelected(HeirloomId, Level)
  self.CurSelectHeirloomId = HeirloomId
  self.CurSelectHeirloomLevel = Level
  self:RefreshModelAndMovieInfo()
  self:RefreshCostPanel()
  self:RefreshButtonStatus()
  self:RefreshGoToSkinButtonVis()
  self:PlayVoice()
end
function HeirloomView:BindOnHeirloomSelectedItemChanged(ResourceId)
  self.CurSelectItemResourceId = ResourceId
  self:RefreshSkinDetailInfo(ResourceId)
  self:RefreshModelAndMovieInfo()
  self:RefreshGoToSkinButtonVis()
end
function HeirloomView:BindOnHeroSkinUpdate()
  self:RefreshGoToSkinButtonVis()
end
function HeirloomView:BindOnWeaponSkinUpdate()
  self:RefreshGoToSkinButtonVis()
end
function HeirloomView:BindOnEquippedWeaponInfoChanged()
  self:RefreshGoToSkinButtonVis()
end
function HeirloomView:BindOnHeirloomHeroSkinActionItemSelected(Index)
  self.ActionIndex = Index
  local TargetActionRowName = self.HeroSkinActionList[Index]
  if not TargetActionRowName then
    return
  end
  LogicRole.PlayCharacterActionByHeroSkinId(self.AppearanceActor.ChildActor.ChildActor.ChildActor.ChildActor, TargetActionRowName)
end
function HeirloomView:RefreshSkinDetailInfo(ResourceId)
  self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.Collapsed)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, ResourceId)
  if not Result then
    return
  end
  self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.Txt_SkinName:SetText(RowInfo.Name)
  self.Txt_SkinDesc:SetText(RowInfo.Desc)
  self.Txt_UnlockDesc:SetText(RowInfo.Desc)
  self.Txt_ResourceType:SetText(RowInfo.TypeDesc)
  UpdateVisibility(self.SizeBox_SkinDesc, false)
  UpdateVisibility(self.SizeBox_UnlockDesc, false, false, true)
  if RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
    UpdateVisibility(self.SizeBox_UnlockDesc, true)
  else
    UpdateVisibility(self.SizeBox_SkinDesc, true)
  end
  local HeroSkinId = 0
  if RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
    local BResult, HeroSkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, ResourceId)
    if BResult then
      HeroSkinId = HeroSkinRowInfo.SkinID
    end
    print("HeroSkinRowInfo")
  end
  local appearanceViewModel = UIModelMgr:Get("AppearanceViewModel")
  appearanceViewModel:UpdateHeroSkinDetailsView("DefaultHeirloom")
end
function HeirloomView:RefreshModelAndMovieInfo()
  if not UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
    return
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.CurSelectItemResourceId)
  if not Result then
    return
  end
  self.AppearanceActor.ChildActor.ChildActor.ChildActor.ChildActor:StopAllMontages()
  self:SetIsAutoPlayCharacterAction(false)
  local SkinResult, SkinRowInfo = false
  UpdateVisibility(self.CanvasPanel_HeroSkinDetail, false)
  UpdateVisibility(self.CanvasPanel_WeaponDetail, false)
  UpdateVisibility(self.Horizontal_AutoPlayAction, false)
  if RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
    self:OnShowModel(EWeaponSkinDisplayModel.HeroModel)
  elseif RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
    SkinResult, SkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, self.CurSelectItemResourceId)
    UpdateVisibility(self.CanvasPanel_HeroSkinDetail, SkinResult)
    self.CurSkinId = SkinResult and SkinRowInfo.SkinID or -1
    self:OnShowModel(EWeaponSkinDisplayModel.HeroModel)
    self:RefreshSkinActionList()
  elseif RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
    local WeaponResult, WeaponRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, self.CurSelectItemResourceId)
    if WeaponResult then
      UpdateVisibility(self.CanvasPanel_WeaponDetail, true)
      self:RefreshWeaponSkill(self.CurSelectItemResourceId)
      self:OnShowModel(EWeaponSkinDisplayModel.WeaponModel)
    else
      print("HeirloomView:BindOnHeirloomSelectedItemChanged \230\178\161\230\137\190\229\136\176\230\173\166\229\153\168, ResourceId:", self.CurSelectItemResourceId)
    end
  end
end
function HeirloomView:RefreshWeaponSkill(WeaponId)
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(WeaponId))
  local index = 1
  if Result and RowData.WeaponSkillDataAry:Num() > 0 then
    for i, v in iterator(RowData.WeaponSkillDataAry) do
      local item = GetOrCreateItem(self.VerticalBoxSkill, i, self.WBP_WeaponTipsSkillItem:GetClass())
      UpdateVisibility(item, true)
      item:RefreshWeaponTipsSkillItemInfo(v, i, true)
      index = index + 1
    end
  end
  HideOtherItem(self.VerticalBoxSkill, index)
end
function HeirloomView:RefreshSkinActionList(...)
  local Result, SkinRowInfo = GetRowData(DT.DT_Skin, self.CurSkinId)
  UpdateVisibility(self.Overlay_ActionPanel, false)
  self:UpdateExpandActionListVis(false)
  UpdateVisibility(self.Horizontal_AutoPlayAction, false)
  if not Result then
    return
  end
  self.HeroSkinActionList = SkinRowInfo.CharacterActionList:ToTable()
  if 0 == SkinRowInfo.CharacterActionList:Length() then
    return
  end
  UpdateVisibility(self.Overlay_ActionPanel, true)
  UpdateVisibility(self.Horizontal_AutoPlayAction, true)
  local Index = 1
  for i, ActionTableRowName in pairs(self.HeroSkinActionList) do
    local Item = GetOrCreateItem(self.ScrollBox_ActionList, Index, self.ActionItemTemplate:StaticClass())
    Item:Show(ActionTableRowName, Index)
    Index = Index + 1
  end
  HideOtherItem(self.ScrollBox_ActionList, Index)
  EventSystem.Invoke(EventDef.Heirloom.OnHeirloomHeroSkinActionItemSelected, 0)
end
function HeirloomView:SetIsAutoPlayCharacterAction(IsAutoPlay)
  self.IsAutoPlayCharacterAction = IsAutoPlay
  UpdateVisibility(self.Img_AutoPlayAction, self.IsAutoPlayCharacterAction)
  if self.IsAutoPlayCharacterAction then
    self.AutoPlayCharacterActionTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.OnAutoPlayCharacterAction
    }, self.AutoPlayInterval, true)
  elseif UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.AutoPlayCharacterActionTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.AutoPlayCharacterActionTimer)
  end
end
function HeirloomView:OnAutoPlayCharacterAction(...)
  local TargetIndex = self.ActionIndex + 1
  if TargetIndex > table.count(self.HeroSkinActionList) then
    TargetIndex = 1
  end
  self:BindOnHeirloomHeroSkinActionItemSelected(TargetIndex)
end
function HeirloomView:RefreshCostPanel()
  self.CostList:SetVisibility(UE.ESlateVisibility.Collapsed)
  local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
  local CurSelectLevel = HeirloomData:GetCurSelectLevel()
  local RowInfo = HeirloomData:GetHeirloomInfoByLevel(CurSelectHeirloomId, CurSelectLevel)
  if not RowInfo or not RowInfo.CostResources then
    return
  end
  local IsUnLock = HeirloomData:IsUnLockHeirloom(CurSelectHeirloomId, CurSelectLevel)
  if IsUnLock then
    return
  end
  self.CostList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local Item
  for i, SingleCost in ipairs(RowInfo.CostResources) do
    Item = GetOrCreateItem(self.CostList, i, self.CostResourceItemTemplate)
    Item:SetCompareInfo(SingleCost.key, SingleCost.value)
  end
  HideOtherItem(self.CostList, table.count(RowInfo.CostResources) + 1)
end
function HeirloomView:RefreshButtonStatus()
  self.IsUnLockButtonNeedComLink = false
  local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
  local CurSelectLevel = HeirloomData:GetCurSelectLevel()
  local IsUnLock = HeirloomData:IsUnLockHeirloom(CurSelectHeirloomId, CurSelectLevel)
  if IsUnLock then
    self.Btn_UnLock:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanNotUnLockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  if 1 == CurSelectLevel then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBFamilyTreasure, CurSelectHeirloomId)
    if Result then
      self.Txt_ButtonText:SetText(RowInfo.LinkDesc)
    end
    self:RefreshUnLockButtonStyle(true)
    self.CostList:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.IsUnLockButtonNeedComLink = true
    return
  end
  self.CostList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local MaxHeirloomLevel = HeirloomData:GetMaxUnLockHeirloomLevel(CurSelectHeirloomId)
  if MaxHeirloomLevel < CurSelectLevel - 1 then
    self.Txt_CanNotUnLockText:SetText(string.format(self.PreLockText, CurSelectLevel - 1))
    self:RefreshUnLockButtonStyle(false)
  else
    local RowInfo = HeirloomData:GetHeirloomInfoByLevel(CurSelectHeirloomId, CurSelectLevel)
    local HaveEnoughResource = true
    for i, SingleCost in ipairs(RowInfo.CostResources) do
      local CurHavaNum = LogicOutsidePackback.GetResourceNumById(SingleCost.key)
      if CurHavaNum < SingleCost.value then
        HaveEnoughResource = false
        break
      end
    end
    if HaveEnoughResource then
      self.Txt_ButtonText:SetText(self.UnLockText)
      self:RefreshUnLockButtonStyle(true)
    else
      self.IsUnLockButtonNeedComLink = true
      local RowInfo = HeirloomData:GetHeirloomInfoByLevel(CurSelectHeirloomId, CurSelectLevel)
      if RowInfo then
        self.Txt_ButtonText:SetText(RowInfo.LinkDesc)
      end
      self:RefreshUnLockButtonStyle(true)
      self.CostList:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
end
function HeirloomView:RefreshUnLockButtonStyle(CanUnLock)
  self.CanUnLock = CanUnLock
  self.UnLockNormalPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CanNotUnLockPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  if CanUnLock then
    self.UnLockNormalPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_UnLock:SetVisibility(UE.ESlateVisibility.Visible)
    self.Img_Line:SetColorAndOpacity(self.CanUnLockLineColor)
    self.Img_LineAnim:SetColorAndOpacity(self.CanUnLockLineColor)
  else
    self.CanNotUnLockPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Btn_UnLock:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Line:SetColorAndOpacity(self.CanNotUnLockLineColor)
    self.Img_LineAnim:SetColorAndOpacity(self.CanNotUnLockLineColor)
  end
end
function HeirloomView:RefreshGoToSkinButtonVis()
  local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
  local Level = HeirloomData:GetCurSelectLevel()
  local IsEquipped = false
  if HeirloomData:IsUnLockHeirloom(CurSelectHeirloomId, Level) then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.CurSelectItemResourceId)
    if Result then
      if RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
        local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.ViewModel:GetCurOperateHeroId())
        if EquippedWeaponInfo and EquippedWeaponInfo[1] and tonumber(EquippedWeaponInfo[1].resourceId) == self.CurSelectItemResourceId then
          IsEquipped = true
        end
      elseif RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
        local BResult, WeaponSkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, self.CurSelectItemResourceId)
        if BResult then
          local CurEquipSkinId = SkinData.GetEquipedWeaponSkinIdByWeaponResId(WeaponSkinRowInfo.WeaponID)
          if CurEquipSkinId == WeaponSkinRowInfo.SkinID then
            IsEquipped = true
          end
        end
      elseif RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin then
        local CurEquipSkinId = SkinData.GetEquipedSkinIdByHeroId(self.ViewModel:GetCurOperateHeroId())
        local BResult, HeroSkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, self.CurSelectItemResourceId)
        if BResult and CurEquipSkinId == HeroSkinRowInfo.SkinID then
          IsEquipped = true
        end
      end
    end
    UpdateVisibility(self.Btn_GoToSkin, not IsEquipped, true)
    UpdateVisibility(self.Overlay_Equipped, IsEquipped)
  else
    UpdateVisibility(self.Btn_GoToSkin, false)
    UpdateVisibility(self.Overlay_Equipped, false)
  end
end
function HeirloomView:RefreshHeirloomLevelItemLockStatus()
  self.HeirloomInfoPanel:RefreshHeirloomLevelItemLockStatus()
end
function HeirloomView:PlayVoice()
  local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
  local CurSelectLevel = HeirloomData:GetCurSelectLevel()
  local IsUnLock = HeirloomData:IsUnLockHeirloom(CurSelectHeirloomId, CurSelectLevel)
  if not IsUnLock then
    return
  end
  local RGVoiceSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGVoiceSubsystem:StaticClass())
  if self.VoiceID then
    self:StopVoice()
  end
  local skinID = HeirloomData:GetHeirloomSkinID(self.CurSelectHeirloomId, self.CurSelectHeirloomLevel)
  if skinID then
    self.VoiceID = RGVoiceSubsystem:PlayVoiceByRowName("Voice.HeirloomSkin", GetAppearanceActor(self), skinID)
  end
end
function HeirloomView:StopVoice()
  if self.VoiceID and self.VoiceID > 0 then
    UE.URGBlueprintLibrary.StopVoice(self.VoiceID)
    self.VoiceID = 0
  end
end
function HeirloomView:ListenForPreCameraData()
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:MovePreCameraTrans()
  end
end
function HeirloomView:ListenForNextCameraData()
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:MoveNextCameraTrans()
  end
end
function HeirloomView:ListenForChangeDisplayModel()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.CurSelectItemResourceId)
  if not Result then
    return
  end
  if RowInfo.Type ~= TableEnums.ENUMResourceType.WeaponSkin and RowInfo.Type ~= TableEnums.ENUMResourceType.Weapon then
    return
  end
  if self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel then
    self:OnShowModel(EWeaponSkinDisplayModel.WeaponModel)
  else
    self:OnShowModel(EWeaponSkinDisplayModel.HeroModel)
  end
end
function HeirloomView:OnLeftMouseButtonDown()
  if self.IsExpandActionList then
    self:BindOnActionButtonClicked()
    return UE.UWidgetBlueprintLibrary.Handled()
  end
  return UE.UWidgetBlueprintLibrary.Unhandled()
end
function HeirloomView:OnShowModel(CurDisplayModel)
  self.CurDisplayModel = CurDisplayModel
  local AppearanceActorTemp = GetAppearanceActor(self)
  if not UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    return
  end
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.CurSelectItemResourceId)
  if not Result then
    return
  end
  local CurHeroId = self.ViewModel:GetCurOperateHeroId()
  local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
  local CurSelectLevel = HeirloomData:GetCurSelectLevel()
  local HeroSkin = HeirloomData:GetHeroSkinByHeirloomLevel(CurSelectHeirloomId, CurSelectLevel)
  local WeaponSkinId = HeirloomData:GetWeaponSkinByHeirloomLevel(CurSelectHeirloomId, CurSelectLevel)
  local WeaponResId = -1
  if RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
    local WeaponResult, WeaponRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, self.CurSelectItemResourceId)
    if WeaponResult then
      WeaponSkinId = WeaponRowInfo.SkinID
      WeaponResId = self.CurSelectItemResourceId
    end
  elseif RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, self.CurSelectItemResourceId)
    if Result then
      WeaponSkinId = RowInfo.SkinID
      WeaponResId = RowInfo.WeaponID
    end
  end
  if self.CurDisplayModel == EWeaponSkinDisplayModel.WeaponModel then
    AppearanceActorTemp:InitWeaponMesh(WeaponSkinId, WeaponResId)
    LogicRole.ShowOrLoadLevel(WeaponSkinId)
  else
    AppearanceActorTemp:InitAppearanceActor(CurHeroId, HeroSkin, WeaponSkinId)
    LogicRole.ShowOrLoadLevel(HeroSkin)
  end
  AppearanceActorTemp:UpdateActived(true)
  self:UpdateUITextColor()
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, RowInfo.Type ~= TableEnums.ENUMResourceType.HeroSkin and self.CurDisplayModel == EWeaponSkinDisplayModel.WeaponModel)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, RowInfo.Type ~= TableEnums.ENUMResourceType.HeroSkin and self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel)
end
function HeirloomView:UpdateUITextColor(...)
  local Result, RowInfo = false
  local IsInHeirloomLevel = false
  local TextShadowColor = self.DefaultShadowColorAndOpacity
  if self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel then
    local CurSelectHeirloomId = HeirloomData:GetCurSelectHeirloomId()
    local CurSelectLevel = HeirloomData:GetCurSelectLevel()
    local HeroSkin = HeirloomData:GetHeroSkinByHeirloomLevel(CurSelectHeirloomId, CurSelectLevel)
    Result, RowInfo = GetRowData(DT.DT_DisplaySkinUIColor, HeroSkin)
    IsInHeirloomLevel = Result
    if not Result then
      Result, RowInfo = GetRowData(DT.DT_DisplaySkinUIColor, "Default")
    else
      TextShadowColor = self.HeirloomShadowColorAndOpacity
    end
  else
    Result, RowInfo = GetRowData(DT.DT_DisplaySkinUIColor, "Default")
  end
  self.Txt_SkinName:SetColorAndOpacity(RowInfo.UIColor)
  self.Txt_ResourceType:SetColorAndOpacity(RowInfo.UIColor)
  self.Txt_SkinDesc:SetColorAndOpacity(RowInfo.UIColor)
  self.Img_LineBetween:SetColorAndOpacity(RowInfo.UIColor.SpecifiedColor)
  self.Txt_SkinName:SetShadowColorAndOpacity(TextShadowColor)
  self.Txt_ResourceType:SetShadowColorAndOpacity(TextShadowColor)
  self.Txt_SkinDesc:SetShadowColorAndOpacity(TextShadowColor)
  local AllWeaponSkillItem = self.VerticalBoxSkill:GetAllChildren()
  for k, SingleItem in pairs(AllWeaponSkillItem) do
    SingleItem:SetNameColorAndOpacity(RowInfo.UIColor)
    SingleItem:SetDescColorAndOpacity(RowInfo.UIColor)
    SingleItem:SetBottomColorAndOpacity(RowInfo.UIColor.SpecifiedColor)
    SingleItem:SetIsInHeirloomLevel(IsInHeirloomLevel)
  end
end
function HeirloomView:OnPreHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  if UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
    self.AppearanceActor:UpdateActived(false)
  end
  self.IsUnLockButtonNeedComLink = false
  self.HeirloomInfoPanel:Hide()
  self:SetIsAutoPlayCharacterAction(false)
  EventSystem.RemoveListener(EventDef.Heirloom.OnHeirloomInfoChanged, self.BindOnHeirloomInfoChanged, self)
  EventSystem.RemoveListener(EventDef.Heirloom.OnAfterChangeHeirloomLevelSelected, self.BindOnChangeHeirloomLevelSelected, self)
  EventSystem.RemoveListener(EventDef.Heirloom.OnHeirloomSelectedItemChanged, self.BindOnHeirloomSelectedItemChanged, self)
  EventSystem.RemoveListener(EventDef.Skin.OnHeroSkinUpdate, self.BindOnHeroSkinUpdate, self)
  EventSystem.RemoveListener(EventDef.Skin.OnWeaponSkinUpdate, self.BindOnWeaponSkinUpdate, self)
  EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged, self)
  EventSystem.RemoveListenerNew(EventDef.Heirloom.OnHeirloomHeroSkinActionItemSelected, self, self.BindOnHeirloomHeroSkinActionItemSelected)
end
function HeirloomView:OnHide()
  UpdateVisibility(self.CanvasPanelRoot, true)
  self:StopVoice()
end
return HeirloomView
