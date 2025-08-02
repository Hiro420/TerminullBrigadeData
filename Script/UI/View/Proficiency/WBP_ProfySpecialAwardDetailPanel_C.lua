local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local WBP_ProfySpecialAwardDetailPanel_C = Class(ViewBase)
local TabKeyEvent = "TabKeyEvent"
local EscName = "PauseGame"
local HideViewKeyName = "HideAppearanceView"
local PreCameraData = "PrevWeapon"
local NextCameraData = "NextWeapon"
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end

function WBP_ProfySpecialAwardDetailPanel_C:BindClickHandler()
  self.WBP_InteractTipWidgetChangeWeaponDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetChangeDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetHideUI.OnMainButtonClicked:Add(self, self.ListenForUpdateViewShowInputAction)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, self.OnSettingKeyPressed)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.ListenForEscKeyPressed)
end

function WBP_ProfySpecialAwardDetailPanel_C:UnBindClickHandler()
  self.WBP_InteractTipWidgetChangeWeaponDisplay.OnMainButtonClicked:Remove(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetChangeDisplay.OnMainButtonClicked:Remove(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetHideUI.OnMainButtonClicked:Remove(self, self.ListenForUpdateViewShowInputAction)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Remove(self, self.OnSettingKeyPressed)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.ListenForEscKeyPressed)
end

function WBP_ProfySpecialAwardDetailPanel_C:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function WBP_ProfySpecialAwardDetailPanel_C:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_ProfySpecialAwardDetailPanel_C:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local AppearanceActorTemp = GetAppearanceActor(self)
  local tbParam = {
    ...
  }
  self.CurHeroId = tbParam[1]
  self.ResourceId = tbParam[2]
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.ResourceId)
  self.Type = RowInfo.Type
  self.bIsViewShow = true
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, false)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, false)
  self:InitModel()
  self:ListenInputEvent()
  self:RefreshDescPanel()
  EventSystem.AddListenerNew(EventDef.Weapon.WeaponSkillTip, self, self.BindOnShowSkillTips)
end

function WBP_ProfySpecialAwardDetailPanel_C:OnRollback(...)
  ChangeLobbyCamera(self, "Proficiency")
  self.AppearanceActor:UpdateActived(true)
end

function WBP_ProfySpecialAwardDetailPanel_C:InitModel()
  local CurEquipHeroSkinResId = SkinData.GetEquipedSkinIdByHeroId(self.CurHeroId)
  local CurBGSkinId = CurEquipHeroSkinResId
  if self.Type == TableEnums.ENUMResourceType.HeroSkin then
    local Result, HeroSkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, self.ResourceId)
    if Result then
      CurEquipHeroSkinResId = HeroSkinRowInfo.SkinID
      CurBGSkinId = HeroSkinRowInfo.SkinID
    end
    self.AppearanceActor:InitAppearanceActor(self.CurHeroId, CurEquipHeroSkinResId)
  elseif self.Type == TableEnums.ENUMResourceType.Weapon then
    local WeaponResult, WeaponRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, self.ResourceId)
    if WeaponResult then
      CurBGSkinId = WeaponRowInfo.SkinID
      self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
      self:ListenForChangeDisplayModel(true)
    end
  elseif self.Type == TableEnums.ENUMResourceType.WeaponSkin then
    self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
    self:ListenForChangeDisplayModel(true)
    local WeaponSkinResult, WeaponSkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, self.ResourceId)
    if WeaponSkinResult then
      CurBGSkinId = WeaponSkinRowInfo.SkinID
    end
  end
  LogicRole.ShowOrLoadLevel(CurBGSkinId)
  self.AppearanceActor:UpdateActived(true)
end

function WBP_ProfySpecialAwardDetailPanel_C:RefreshDescPanel()
  UpdateVisibility(self.SkinDescPanel, false)
  UpdateVisibility(self.WeaponDescPanel, false)
  local Result, SkinRowInfo = false
  if self.Type == TableEnums.ENUMResourceType.Weapon then
    UpdateVisibility(self.WeaponDescPanel, true)
    self.WBP_WeaponAttrDetailsTip:InitWeaponAttrDetailsTip(self.ResourceId, {}, nil, true, true)
  else
    UpdateVisibility(self.SkinDescPanel, true)
    if self.Type == TableEnums.ENUMResourceType.WeaponSkin then
      Result, SkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, self.ResourceId)
    elseif self.Type == TableEnums.ENUMResourceType.HeroSkin then
      Result, SkinRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, self.ResourceId)
    end
    self.Txt_SkinName:SetText(SkinRowInfo.SkinName)
    self.Txt_SkinDesc:SetText(SkinRowInfo.Desc)
    local result, itemRarityRow = GetRowData(DT.DT_ItemRarity, tostring(SkinRowInfo.SkinRarity))
    if result then
      self.RGTextTag:SetText(itemRarityRow.DisplayName)
    end
    local resultRarity, rowRarity = GetRowData(DT.DT_ItemRarity, tostring(SkinRowInfo.SkinRarity))
    if resultRarity then
      self.URGImageTag:SetColorAndOpacity(rowRarity.SkinRareBgColor)
    end
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:ListenInputEvent()
  if not IsListeningForInputAction(self, TabKeyEvent) then
    ListenForInputAction(TabKeyEvent, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForChangeDisplayModel
    })
  end
  if not IsListeningForInputAction(self, HideViewKeyName) then
    ListenForInputAction(HideViewKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForUpdateViewShowInputAction
    })
  end
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
  if not IsListeningForInputAction(self, EscName) then
    ListenForInputAction(EscName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.ListenForEscKeyPressed
    })
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:ListenForChangeDisplayModel(bNotShowGlitchMatEffect)
  local bShowGlitchMatEffectTemp = not bNotShowGlitchMatEffect
  if self.Type ~= TableEnums.ENUMResourceType.WeaponSkin and self.Type ~= TableEnums.ENUMResourceType.Weapon then
    return
  end
  if self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel then
    self.CurDisplayModel = EWeaponSkinDisplayModel.WeaponModel
    self:OnShowWeapon(bShowGlitchMatEffectTemp)
  else
    self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
    self:OnShowRole(bShowGlitchMatEffectTemp)
  end
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, self.CurDisplayModel == EWeaponSkinDisplayModel.WeaponModel)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel)
end

function WBP_ProfySpecialAwardDetailPanel_C:OnShowRole(bShowGlitchMatEffectTemp)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    local WeaponSkinId = -1
    if self.Type == TableEnums.ENUMResourceType.Weapon then
      local WeaponResult, WeaponRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, self.ResourceId)
      if WeaponResult then
        WeaponSkinId = WeaponRowInfo.SkinID
      end
    elseif self.Type == TableEnums.ENUMResourceType.WeaponSkin then
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, self.ResourceId)
      if Result then
        WeaponSkinId = RowInfo.SkinID
      end
    end
    AppearanceActorTemp:InitAppearanceActor(self.CurHeroId, SkinData.GetEquipedSkinIdByHeroId(self.CurHeroId), WeaponSkinId, bShowGlitchMatEffectTemp)
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:OnShowWeapon(bShowGlitchMatEffectTemp)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    local SkinId, WeaponId = -1, -1
    if self.Type == TableEnums.ENUMResourceType.Weapon then
      local WeaponResult, WeaponRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeapon, self.ResourceId)
      if WeaponResult then
        SkinId = WeaponRowInfo.SkinID
        WeaponId = self.ResourceId
      end
    elseif self.Type == TableEnums.ENUMResourceType.WeaponSkin then
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBWeaponSkin, self.ResourceId)
      if Result then
        SkinId = RowInfo.SkinID
        WeaponId = RowInfo.WeaponID
      end
    end
    AppearanceActorTemp:InitWeaponMesh(SkinId, WeaponId, bShowGlitchMatEffectTemp)
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:BindOnShowSkillTips(IsShow, WeaponSkillData, KeyName)
  if IsShow then
    self.NormalSkillTip:RefreshInfoByWeaponSkillData(WeaponSkillData, KeyName)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.NormalSkillTip:Hide()
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:ListenForUpdateViewShowInputAction()
  if self.bIsViewShow then
    self.bIsViewShow = false
    if self.Type == TableEnums.ENUMResourceType.WeaponSkin or self.Type == TableEnums.ENUMResourceType.HeroSkin then
      UpdateVisibility(self.SkinDescPanel, false)
    else
      UpdateVisibility(self.WeaponDescPanel, false)
    end
  else
    self.bIsViewShow = true
    if self.Type == TableEnums.ENUMResourceType.WeaponSkin or self.Type == TableEnums.ENUMResourceType.HeroSkin then
      UpdateVisibility(self.SkinDescPanel, true)
    else
      UpdateVisibility(self.WeaponDescPanel, true)
    end
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:ListenForPreCameraData()
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:MovePreCameraTrans()
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:ListenForNextCameraData()
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:MoveNextCameraTrans()
  end
end

function WBP_ProfySpecialAwardDetailPanel_C:ListenForEscKeyPressed()
  UIMgr:Hide(ViewID.UI_ProficiencySpecialAwardDetailPanel, true)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnProfySpecialAwardDetailPanelHide)
end

function WBP_ProfySpecialAwardDetailPanel_C:OnSettingKeyPressed(...)
  LogicGameSetting.ShowGameSettingPanel()
end

function WBP_ProfySpecialAwardDetailPanel_C:OnMouseButtonDown(myMouseButtonDown, mouseEvent)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:BPLeftMouseButtonDown(true)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_ProfySpecialAwardDetailPanel_C:OnMouseButtonUp(myMouseButtonDown, mouseEvent)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:BPLeftMouseButtonDown(false)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_ProfySpecialAwardDetailPanel_C:OnPreHide(...)
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  local AppearanceActorTemp = GetAppearanceActor(self)
  AppearanceActorTemp:UpdateActived(false)
  LogicRole.ShowOrLoadLevel(-1)
  StopListeningForInputAction(self, TabKeyEvent, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, EscName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, HideViewKeyName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, PreCameraData, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, NextCameraData, UE.EInputEvent.IE_Pressed)
  EventSystem.RemoveListenerNew(EventDef.Weapon.WeaponSkillTip, self, self.BindOnShowSkillTips)
end

function WBP_ProfySpecialAwardDetailPanel_C:OnHide()
end

return WBP_ProfySpecialAwardDetailPanel_C
