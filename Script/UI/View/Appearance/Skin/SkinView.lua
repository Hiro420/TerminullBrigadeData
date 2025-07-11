local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local HeirloomData = require("Modules.Appearance.Heirloom.HeirloomData")
local PreCameraData = "PrevWeapon"
local NextCameraData = "NextWeapon"
local TabKeyEvent = "TabKeyEvent"
local EscName = "PauseGame"
local HideAppearanceView = "HideAppearanceView"
local RoleSkinItemDataClsPath = "/Game/Rouge/UI/Appearance/Skin/RoleSkinItemData.RoleSkinItemData_C"
local BlackColorAsset = "/Game/Rouge/UI/Atlas/RoleMain/Frames/Icon_Swatches_03.Icon_Swatches_03"
local LightColorAsset = "/Game/Rouge/UI/Atlas/RoleMain/Frames/Icon_Swatches_04.Icon_Swatches_04"
local EffectText = NSLOCTEXT("WBP_SkinView_C", "EffectText", "\231\137\185\230\149\136")
local UnlockPanelTitle = NSLOCTEXT("WBP_SkinView_C", "UnlockPanelTitle", "\232\167\163\233\148\129\231\161\174\232\174\164")
local UnlockPanelContent = NSLOCTEXT("WBP_SkinView_C", "UnlockPanelContent", "\230\152\175\229\144\166\232\138\177\232\180\185\228\187\165\228\184\139\232\181\132\230\186\144\232\167\163\233\148\129\227\128\144{0}\227\128\145?")
local SkinView = Class(ViewBase)
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end
local CheckHeroSkinCanEquip = function(self, SkinResId)
  local skinData
  local bEquiped = false
  for k, v in pairs(SkinData.HeroSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.HeroSkinTb.SkinID then
        skinData = vSkinData
        bEquiped = v.EquipedSkinId == vSkinData.HeroSkinTb.SkinID
        break
      end
    end
  end
  if not skinData or not skinData.bUnlocked then
    return false
  end
  if bEquiped then
    return false
  end
  return true
end
local CheckWeaponSkinCanEquip = function(self, SkinResId)
  local skinData
  local bEquiped = false
  for k, v in pairs(SkinData.WeaponSkinMap) do
    for i, vSkinData in ipairs(v.SkinDataList) do
      if SkinResId == vSkinData.WeaponSkinTb.SkinID then
        skinData = vSkinData
        bEquiped = v.EquipedSkinId == vSkinData.WeaponSkinTb.SkinID
        break
      end
    end
  end
  if not skinData or not skinData.bUnlocked then
    return false
  end
  if bEquiped then
    return false
  end
  return true
end
local CheckHeroIsUnLock = function(self, HeroId)
  local ownHeros = DataMgr.GetMyHeroInfo()
  for i, heroInfo in ipairs(ownHeros.heros) do
    if HeroId == heroInfo.id then
      return true
    end
  end
  return false
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
local CheckHaveCustomSkin = function(self, SkinID)
  local ResID = GetTbSkinRowNameBySkinID(SkinID)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, ResID)
  if not Result then
    return false
  end
  return #RowInfo.AttachList > 0, RowInfo.AttachList
end
function SkinView:OnBindUIInput()
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
      self.HideUI
    })
  end
  self.WBP_InteractTipWidgetChangeWeaponDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetChangeDisplay.OnMainButtonClicked:Add(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetHideUI.OnMainButtonClicked:Add(self, self.HideUI)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.EscView)
end
function SkinView:OnUnBindUIInput()
  StopListeningForInputAction(self, PreCameraData, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, NextCameraData, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, TabKeyEvent, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, HideAppearanceView, UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetChangeWeaponDisplay.OnMainButtonClicked:Remove(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetChangeDisplay.OnMainButtonClicked:Remove(self, self.ListenForChangeDisplayModel)
  self.WBP_InteractTipWidgetHideUI.OnMainButtonClicked:Remove(self, self.HideUI)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Remove(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.EscView)
end
function SkinView:BindClickHandler()
  self.RGToggleGroupWeaponSkin.OnCheckStateChanged:Add(self, self.OnWeaponSkinGroupCheckStateChanged)
  self.RGToggleGroupFirst.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
  self.RGToggleGroupHeirloomLv.OnCheckStateChanged:Add(self, self.OnHeirloomLvChanged)
end
function SkinView:UnBindClickHandler()
  self.RGToggleGroupWeaponSkin.OnCheckStateChanged:Remove(self, self.OnWeaponSkinGroupCheckStateChanged)
  self.RGToggleGroupFirst.OnCheckStateChanged:Remove(self, self.OnFirstGroupCheckStateChanged)
  self.RGToggleGroupHeirloomLv.OnCheckStateChanged:Remove(self, self.OnHeirloomLvChanged)
end
function SkinView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("SkinViewModel")
  self:BindClickHandler()
end
function SkinView:OnDestroy()
  self:UnBindClickHandler()
  self:SequenceFinished()
end
function SkinView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  local apearanceView = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  self.AppearanceMovieList = nil
  if UE.RGUtil.IsUObjectValid(apearanceView) then
    self.AppearanceMovieList = apearanceView.WBP_AppearanceMovieList
  end
  self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
  self:ListenForChangeDisplayModel(true)
  self.RGToggleGroupFirst:SelectId(ESkinToggleStatus.None)
  self.RGToggleGroupFirst:SelectId(ESkinToggleStatus.HeroSkin)
  self.viewModel:SendGetHeroSkinList()
  self.viewModel:SendGetWeaponSkinList()
  local AppearanceActorTemp = GetAppearanceActor(self)
  local tbParam = {
    ...
  }
  local CurHeroId = tbParam[1]
  self.WBP_SkinDetailsItem.LocalEffectState = nil
  self.WBP_RedDotClearButtonView.HeroId = self.viewModel.CurHeroId
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    self.AppearanceActor:AppearanceToggleSkipEnter(false)
    self.AppearanceActor:InitAppearanceActor(CurHeroId, self.viewModel.CurSelectHeroSkinResId)
    LogicAudio.OnLobbyPlayHeroSound(self.viewModel.CurSelectHeroSkinResId, self.AppearanceActor, nil, true)
    self.AppearanceActor:AppearanceResetAnimation()
    self.AppearanceActor:UpdateActived(true)
    LogicRole.ShowOrLoadLevel(self.viewModel.CurSelectHeroSkinResId)
  end
  self.MediaPlayer.OnMediaReachedEnd:Add(self, self.MediaPlayerFinish)
  self.ScrollBoxWeaponSkinList.OnUserScrolled:Add(self, self.OnWeaponSkinListScrolled)
  self.WBP_RedDotViewSkin:ChangeRedDotIdByTag(self.viewModel.CurHeroId)
  self.WBP_RedDotViewWeaponSkin:ChangeRedDotIdByTag(self.viewModel.CurHeroId)
  self:RegisterScrollRecipient(self.WBP_RoleSkinList)
end
function SkinView:OnRollback()
  self:RebackView()
  self:RegisterScrollRecipient(self.WBP_RoleSkinList)
  self.WBP_CommonBg.ShowAnimation = true
end
function SkinView:EscView()
  local luaInst = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  if UE.RGUtil.IsUObjectValid(luaInst) then
    luaInst:ListenForEscInputAction()
  end
end
function SkinView:OnAccessClick()
  if self.viewModel.CurSelectSkinToggle == ESkinToggleStatus.HeroSkin then
    local heroSkinData = self.viewModel:GetHeroSkinDataBySkinResId(self.viewModel.CurSelectHeroSkinResId)
    if heroSkinData then
      if 0 ~= heroSkinData.HeroSkinTb.ParentSkinId then
        if self:CheckUnLockOriSkin(heroSkinData.HeroSkinTb.ID) then
          local Content = UE.FTextFormat(UnlockPanelContent, heroSkinData.HeroSkinTb.SkinName)
          local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroSkinExchange, heroSkinData.HeroSkinTb.SkinID)
          if Result then
            if self.viewModel:CheckSkinCost(RowInfo.CostResources[1].key, heroSkinData.HeroSkinTb.SkinID) then
              UIMgr:ShowLink(ViewID.UI_CommonSmallPopups, nil, ECommonSmallPopupTypes.UnlockSchemePanel, UnlockPanelTitle, Content, RowInfo.CostResources[1].key, RowInfo.CostResources[1].value, heroSkinData.HeroSkinTb.SkinID)
            else
              local GoodsId = RowInfo.GoodsID
              local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMall, GoodsId)
              if result then
                local OwnPackageNum = DataMgr.GetPackbackNumById(RowInfo.CostResources[1].key)
                ComLink(1007, nil, GoodsId, rowinfo.Shelfs[1], nil, RowInfo.CostResources[1].value - OwnPackageNum)
              end
            end
          end
        else
          ShowWaveWindow(308001)
        end
        return
      end
      if heroSkinData.HeroSkinTb.LinkId and heroSkinData.HeroSkinTb.LinkId ~= "" then
        if self:LinkPurchaseConfirm(heroSkinData.HeroSkinTb.LinkId, heroSkinData.HeroSkinTb.ParamList) then
          return
        end
        local result, row = GetRowData(DT.DT_CommonLink, heroSkinData.HeroSkinTb.LinkId)
        if result then
          local callback = function()
            if row.bHideOther then
              self:SequenceFinished()
              local AppearanceActorTemp = GetAppearanceActor(self)
              self.AppearanceActor:UpdateActived(false, true, false)
            end
          end
          if ViewID[row.UIName] == ViewID.UI_DevelopMain then
            ComLink(heroSkinData.HeroSkinTb.LinkId, callback, self.viewModel.CurHeroId, self.viewModel.CurHeroId)
          else
            ComLink(heroSkinData.HeroSkinTb.LinkId, callback, self.viewModel.CurHeroId, heroSkinData.HeroSkinTb.ParamList)
          end
        end
      end
    end
  elseif self.viewModel.CurSelectSkinToggle == ESkinToggleStatus.WeaponSkin then
    local weaponSkinData = self.viewModel:GetWeaponSkinDataBySkinResId(self.viewModel.CurSelectWeaponSkinResId)
    if weaponSkinData and weaponSkinData.WeaponSkinTb.LinkId and "" ~= weaponSkinData.WeaponSkinTb.LinkId then
      if self:LinkPurchaseConfirm(weaponSkinData.WeaponSkinTb.LinkId, weaponSkinData.WeaponSkinTb.ParamList) then
        return
      end
      local result, row = GetRowData(DT.DT_CommonLink, weaponSkinData.WeaponSkinTb.LinkId)
      if result then
        local callback = function()
          if row.bHideOther then
            self:SequenceFinished()
            local AppearanceActorTemp = GetAppearanceActor(self)
            self.AppearanceActor:UpdateActived(false, true, false)
          end
        end
        if ViewID[row.UIName] == ViewID.UI_DevelopMain then
          ComLink(weaponSkinData.WeaponSkinTb.LinkId, callback, self.viewModel.CurHeroId, self.viewModel.CurHeroId)
        else
          ComLink(weaponSkinData.WeaponSkinTb.LinkId, callback, self.viewModel.CurHeroId, weaponSkinData.WeaponSkinTb.ParamList)
        end
      end
    end
  end
end
function SkinView:OnEquipClick()
  if self.viewModel.CurSelectSkinToggle == ESkinToggleStatus.HeroSkin then
    self.viewModel:SendEquipHeroSkinReq(self.viewModel.CurHeroId, self.viewModel.CurSelectHeroSkinResId)
  elseif self.viewModel.CurSelectSkinToggle == ESkinToggleStatus.WeaponSkin then
    self.viewModel:EquipWeaponSkin(self.viewModel.CurSelectWeaponSkinResId)
  end
end
function SkinView:OnAccessHovered()
  self:StopAnimation(self.Ani_hover_out)
  self:PlayAnimation(self.Ani_hover_in, 0)
end
function SkinView:OnAccessUnhovered()
  self:StopAnimation(self.Ani_hover_in)
  self:PlayAnimation(self.Ani_hover_out, 0)
end
function SkinView:OnEffectHover()
  local AttachID = self.viewModel.CurSelectHeroSkinResId
  local SkinData = self.viewModel:GetHeroSkinDataBySkinResId(self.viewModel.CurSelectHeroSkinResId)
  if 0 ~= SkinData.HeroSkinTb.ParentSkinId then
    AttachID = SkinData.HeroSkinTb.ParentSkinId
  end
  local HeroEffectState = self.viewModel:GetSpecialEffectStateByHeroID(self.viewModel.CurHeroId)
  if HeroEffectState[tostring(AttachID)] then
    return
  end
  local ProEffType = TableEnums.ENUMResourceEffProType.NONE
  local ResultGenerl, RowGeneral = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, AttachID)
  if ResultGenerl then
    ProEffType = RowGeneral.ProEffType
  end
  local WidgetClassPath = "/Game/Rouge/UI/Common/WBP_CommonTips.WBP_CommonTips_C"
  self.TipsWidget = ShowCommonTips(nil, self.Btn_Effect, nil, WidgetClassPath, nil, nil, UE.FVector2D(-40, 0))
  self.TipsWidget:ShowTips(EffectText, self.EffectContent, nil, nil, nil, nil, ProEffType)
end
function SkinView:OnEffectUnhover()
  UpdateVisibility(self.TipsWidget, false)
end
function SkinView:BindOnBtnDisplayClicked()
  if self.LocalEffectState then
    return
  end
  self:SwitchEffectState(true)
end
function SkinView:BindOnBtnDisplayHovered()
  self.RGStateController_Display_Hover:ChangeStatus("Hover")
end
function SkinView:BindOnBtnDisplayUnhovered()
  self.RGStateController_Display_Hover:ChangeStatus("UnHover")
end
function SkinView:BindOnBtnHideClicked()
  if not self.LocalEffectState then
    return
  end
  self:SwitchEffectState(false)
end
function SkinView:BindOnBtnHideHovered()
  self.RGStateController_Hide_Hover:ChangeStatus("Hover")
end
function SkinView:BindOnBtnHideUnhovered()
  self.RGStateController_Hide_Hover:ChangeStatus("Hover")
end
function SkinView:SwitchEffectState(IsShow)
  self.RGStateController_Display_Select:ChangeStatus(IsShow and "Select" or "Normal")
  self.RGStateController_Hide_Select:ChangeStatus(IsShow and "Normal" or "Select")
  self.LocalEffectState = IsShow
  local CurSkinData = self.viewModel:GetHeroSkinDataBySkinResId(self.viewModel.CurSelectHeroSkinResId)
  local EffectState = self.viewModel:GetSpecialEffectStateByHeroID(self.viewModel.CurHeroId)
  local AttachID = CurSkinData.HeroSkinTb.SkinID
  if EffectState == {} and self.viewModel:CheckAllChildSkinUnlocked(CurSkinData.HeroSkinTb.ID) then
    EffectState[tostring(AttachID)] = 1
  end
  if 0 ~= CurSkinData.HeroSkinTb.ParentSkinId then
    AttachID = CurSkinData.HeroSkinTb.ParentSkinId
  end
  if EffectState[tostring(AttachID)] then
    self.viewModel:SendSetSkinEffectState(IsShow and 1 or 0, AttachID)
  end
  local ShowActor = GetAppearanceActor(self).ChildActor.ChildActor.ChildActor.ChildActor
  LogicRole.SetEffectState(ShowActor, CurSkinData.HeroSkinTb.SkinID, nil, IsShow)
end
function SkinView:SetEffectState(EffectState, SkinId)
  self.WBP_SkinDetailsItem:SetEffectState(EffectState, SkinId)
end
function SkinView:RebackView()
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    local heroSkinData = self.viewModel:GetHeroSkinDataBySkinResId(self.viewModel.CurSelectHeroSkinResId)
    if heroSkinData then
      if self.viewModel.CurSelectSkinToggle == ESkinToggleStatus.WeaponSkin then
        if self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel then
          self.CurDisplayModel = EWeaponSkinDisplayModel.WeaponModel
        elseif self.CurDisplayModel == EWeaponSkinDisplayModel.WeaponModel then
          self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
        end
        self:ListenForChangeDisplayModel(true)
        self.AppearanceActor:UpdateActived(true)
      elseif self.viewModel.CurSelectSkinToggle == ESkinToggleStatus.HeroSkin then
        self.AppearanceActor:AppearanceToggleSkipEnter(true)
        self.AppearanceActor:InitAppearanceActor(self.viewModel.CurHeroId, heroSkinData.HeroSkinTb.SkinID)
        self.AppearanceActor:UpdateActived(true)
        LogicRole.ShowOrLoadLevel(heroSkinData.HeroSkinTb.SkinID)
      end
    end
  end
end
function SkinView:HideUI()
  local luaInst = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  if UE.RGUtil.IsUObjectValid(luaInst) then
    luaInst:ListenForUpdateAppearanceShowInputAction()
  end
  self:StopVoice()
end
function SkinView:OpenSetting()
  LogicGameSetting.ShowGameSettingPanel()
end
function SkinView:MediaPlayerFinish()
  print("SkinView:MediaPlayerFinish")
  self:UpdateMovie(false)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    self.AppearanceActor:RefreshRoleAniStatus(self.viewModel.CurSelectHeroSkinResId)
  end
end
function SkinView:UpdateMovie(bIsShow, SequenceFinish)
  LogicAudio.bIsPlayingMovie = false
  if not self.viewModel.CurSelectHeroSkinResId or self.viewModel.CurSelectHeroSkinResId <= 0 then
    UpdateVisibility(self.URGImageMovie, false)
    if self.LastAkEventName then
      UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
      self.LastAkEventName = nil
    end
    self:SequenceFinished()
    return
  end
  if self.viewModel.ShowSeq then
    if bIsShow then
      local seq = LogicRole.GetSkinSequence(self.viewModel.CurSelectHeroSkinResId)
      if seq then
        UIMgr:Show(ViewID.UI_MovieLevelSequence, true, self.viewModel.CurSelectHeroSkinResId, true, function()
          self:SequenceCallBack()
        end, function()
          self:EscView()
        end)
      end
    end
    return
  end
  UpdateVisibility(self.URGImageMovie, bIsShow)
  local LastAkEventName
  if bIsShow then
    local result, row = GetRowData(DT.DT_HeirloomSkin, tostring(self.viewModel.CurSelectHeroSkinResId))
    local heirloogMediaData
    if result and row.HeirloomMediaDataAry:IsValidIndex(1) then
      heirloogMediaData = row.HeirloomMediaDataAry:Get(1)
    end
    if heirloogMediaData then
      local MovieSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
      if MovieSubSys then
        local mediaSrc = MovieSubSys:GetMediaSource(heirloogMediaData.MediaId)
        if mediaSrc then
          self.MediaPlayer:OpenSource(mediaSrc)
          self.MediaPlayer:SetLooping(false)
          if self.LastAkEventName then
            UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
            self.LastAkEventName = nil
          end
          self.LastAkEventName = MovieSubSys:GetAkEventName(heirloogMediaData.MediaId)
          UE.UAudioManager.PlaySound2DByName(self.LastAkEventName, "SkinView:UpdateMovie")
          self.MediaPlayer:Rewind()
          UpdateVisibility(self.URGImageMovie, true)
          LogicAudio.bIsPlayingMovie = true
        end
      end
    else
      UpdateVisibility(self.URGImageMovie, false)
      if self.LastAkEventName then
        UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
        self.LastAkEventName = nil
      end
    end
  elseif self.LastAkEventName then
    UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
    self.LastAkEventName = nil
  end
end
function SkinView:PlaySkinSound()
  local result, row = GetRowData(DT.DT_HeirloomSkin, tostring(self.viewModel.CurSelectHeroSkinResId))
  local heirloogMediaData
  if result and row.HeirloomMediaDataAry:IsValidIndex(1) then
    heirloogMediaData = row.HeirloomMediaDataAry:Get(1)
  end
  if heirloogMediaData then
    local MovieSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
    if MovieSubSys then
      if self.LastAkEventName then
        UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
        self.LastAkEventName = nil
      end
      self.LastAkEventName = MovieSubSys:GetAkEventName(heirloogMediaData.MediaId)
      UE.UAudioManager.PlaySound2DByName(self.LastAkEventName, "SkinView:UpdateMovie")
    end
  end
end
function SkinView:OnPreHide()
  if UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
    self.AppearanceActor:UpdateActived(false)
    self.AppearanceActor:AppearanceToggleSkipEnter(false)
  end
  self.MediaPlayer.OnMediaReachedEnd:Remove(self, self.MediaPlayerFinish)
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  self.viewModel:UpdateCurSelectHeroSkin(-1)
  self.viewModel:UpdateCurSelectWeaponSkin(-1)
  self:OnHideMovieClick()
  self:UpdateMovie(false)
  UpdateVisibility(self.TipsWidget, false)
  self.ScrollBoxWeaponSkinList.OnUserScrolled:Remove(self, self.OnWeaponSkinListScrolled)
end
function SkinView:OnHide()
  self:StopAllAnimations()
  UpdateVisibility(self.CanvasPanelRoot, true)
  self:UnregisterScrollRecipient(self.WBP_RoleSkinList)
end
function SkinView:ListenForPreCameraData()
  if self.EnterList then
    return
  end
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:MovePreCameraTrans()
  end
end
function SkinView:ListenForNextCameraData()
  if self.EnterList then
    return
  end
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:MoveNextCameraTrans()
  end
end
function SkinView:ListenForChangeDisplayModel(bNotShowGlitchMatEffect)
  local bShowGlitchMatEffect = not bNotShowGlitchMatEffect
  if self.viewModel.CurSelectSkinToggle == ESkinToggleStatus.WeaponSkin then
    if self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel then
      self.CurDisplayModel = EWeaponSkinDisplayModel.WeaponModel
      self:OnShowWeapon(bShowGlitchMatEffect)
    else
      self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
      self:OnShowRole(bShowGlitchMatEffect)
    end
    UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, self.CurDisplayModel == EWeaponSkinDisplayModel.WeaponModel)
    UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel)
  else
    UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, false)
    UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, false)
  end
end
function SkinView:OnMouseButtonDown(myMouseButtonDown, mouseEvent)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:BPLeftMouseButtonDown(true)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function SkinView:OnMouseButtonUp(myMouseButtonDown, mouseEvent)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:BPLeftMouseButtonDown(false)
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function SkinView:OnAnimationFinished(Animation)
  if Animation == self.Ani_CanvasPanelWeaponSkin_in then
    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
      GameInstance,
      function()
        if UE.RGUtil.IsUObjectValid(self) then
        end
      end
    })
  end
end
function SkinView:OnHeroSkinListUpdate(ShowHeroSkinData, CurSelectHeroSkinResId)
  if not CheckIsVisility(self.CanvasPanelRoleSkin) then
    self:PlayAnimation(self.Ani_CanvasPanelRoleSkin_in)
  end
  UpdateVisibility(self.CanvasPanelRoleSkin, true)
  UpdateVisibility(self.CanvasPanelWeaponSkin, false)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, false)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, false)
  local curSelectIdx = -1
  local heirloomIntegrationed = {}
  local IsChildSkin = false
  local ChildSkinID
  if CurSelectHeroSkinResId and CurSelectHeroSkinResId > 0 then
    local CurSkinID = CurSelectHeroSkinResId
    local ResID = GetTbSkinRowNameBySkinID(CurSelectHeroSkinResId)
    if ResID then
      local ParentID = self.viewModel:GetParentIdByResId(ResID)
      if 0 ~= ParentID then
        CurSkinID = ParentID
      end
    end
    self.WBP_RoleSkinList.TileViewRoleSkin:RecyleAllData()
    local TileViewAry = UE.TArray(UE.UObject)
    TileViewAry:Reserve(#ShowHeroSkinData.SkinDataList)
    for i, v in ipairs(ShowHeroSkinData.SkinDataList) do
      if not self:CheckIsShow(v.HeroSkinTb, v.bUnlocked) then
      else
        local heirloomInfo = HeirloomData:GetHeirloomInfoByLevel(v.HeirloomId, v.HeirloomLevel)
        if v.HeirloomId > 0 and heirloomInfo then
          if not heirloomIntegrationed[v.HeirloomId] then
            heirloomIntegrationed[v.HeirloomId] = true
            local DataObj = self.WBP_RoleSkinList.TileViewRoleSkin:GetOrCreateDataObj()
            self.WBP_RoleSkinList:InitList(self)
            TileViewAry:Add(DataObj)
            local heirloomPreviewInfo, lv = self.viewModel:GetHeirloomCurPreviewSkin(v.HeirloomId, ShowHeroSkinData.EquipedSkinId)
            local skinId = self.viewModel:GetHeroSkinByHeirloomLevel(v.HeirloomId, lv)
            local bEquiped = skinId == ShowHeroSkinData.EquipedSkinId
            if (nil == CurSkinID or CurSkinID < 0) and bEquiped then
              curSelectIdx = skinId
            end
            local maxUnlockLv = self.viewModel:GetMaxUnLockHeirloomLevel(v.HeirloomId)
            local heirloomId, level = self.viewModel:GetHeirloomIdBySkinId(CurSelectHeroSkinResId)
            local bSelected = false
            if -1 ~= heirloomId and heirloomId == v.HeirloomId then
              bSelected = true
            end
            DataObj.bIsSelected = bSelected
            DataObj.bUnlocked = maxUnlockLv > 0
            DataObj.TbId = self.viewModel:GetTbIdBySkinId(skinId)
            DataObj.bEquiped = bEquiped
            DataObj.ParentView = self
            DataObj.heirloomId = v.HeirloomId
            DataObj.expireAt = v.expireAt
            print("SkinHandler.SendGetHeroSkinList", v.expireAt)
            print("SkinView:OnHeroSkinListUpdate heirloomIntegration", v.HeirloomId, v.HeroSkinTb.SkinID, skinId, lv)
          else
            print("SkinView:OnHeroSkinListUpdate heirloomIntegrationed", v.HeirloomId, v.HeroSkinTb.SkinID)
          end
        else
          print("SkinView:OnHeroSkinListUpdate not heirloom", v.HeroSkinTb.SkinID)
          local DataObj = self.WBP_RoleSkinList.TileViewRoleSkin:GetOrCreateDataObj()
          TileViewAry:Add(DataObj)
          local bEquiped = v.HeroSkinTb.SkinID == ShowHeroSkinData.EquipedSkinId
          for i, AttachID in ipairs(v.HeroSkinTb.AttachList) do
            if AttachID == ShowHeroSkinData.EquipedSkinId then
              bEquiped = true
            end
          end
          if (nil == CurSkinID or CurSkinID < 0) and bEquiped then
            curSelectIdx = v.HeroSkinTb.SkinID
          end
          DataObj.bIsSelected = CurSkinID == v.HeroSkinTb.SkinID
          DataObj.bUnlocked = v.bUnlocked
          DataObj.TbId = v.HeroSkinTb.ID
          DataObj.bEquiped = bEquiped
          DataObj.ParentView = self
          DataObj.heirloomId = -1
          DataObj.expireAt = v.expireAt
        end
      end
    end
    self.WBP_RoleSkinList.TileViewRoleSkin:SetRGListItems(TileViewAry, true, true)
  elseif ShowHeroSkinData.EquipedSkinId and ShowHeroSkinData.EquipedSkinId > 0 then
    for i, v in ipairs(ShowHeroSkinData.SkinDataList) do
      local bEquiped = v.HeroSkinTb.SkinID == ShowHeroSkinData.EquipedSkinId
      if bEquiped then
        curSelectIdx = v.HeroSkinTb.SkinID
      end
    end
  else
    for i, v in ipairs(ShowHeroSkinData.SkinDataList) do
      if self:CheckIsShow(v.HeroSkinTb, v.bUnlocked) then
        curSelectIdx = v.HeroSkinTb.SkinID
        break
      end
    end
  end
  if curSelectIdx >= 0 then
    print("SkinView OnHeroSkinListUpdate ", curSelectIdx)
    self:SelectHeroSkin(curSelectIdx, true)
  end
end
function SkinView:SelectItem(SelectId)
  local displayItemAry = self.WBP_RoleSkinList.TileViewRoleSkin:GetDisplayedEntryWidgets()
  for i, v in pairs(displayItemAry) do
    if IsValidObj(v) and IsValidObj(v.WBP_Item) then
      v.WBP_Item:SetSel(false)
    end
  end
  local dataAry = self.WBP_RoleSkinList.TileViewRoleSkin:GetListItems()
  for i, v in pairs(dataAry) do
    if IsValidObj(v) and v.bIsSelected then
      v.bIsSelected = false
      break
    end
  end
  self.viewModel:UpdateCurSelectHeroSkin(SelectId, true, true)
end
function SkinView:OnWeaponSkinListUpdate(ShowWeaponSkinDataMap, showWeaponIdList, CurSelectWeaponSkinResId)
  if not CheckIsVisility(self.CanvasPanelWeaponSkin) then
    self:PlayAnimation(self.Ani_CanvasPanelWeaponSkin_in)
  end
  UpdateVisibility(self.CanvasPanelRoleSkin, false)
  UpdateVisibility(self.CanvasPanelWeaponSkin, true)
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
    if (nil == CurSelectWeaponSkinResId or CurSelectWeaponSkinResId < 0) and -1 == needSelectId then
      if weaponSkinListData.EquipedSkinId >= 0 then
        needSelectId = weaponSkinListData.EquipedSkinId
      else
        needSelectId = weaponSkinListData.SkinDataList[1].WeaponSkinTb.SkinID
      end
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
end
function SkinView:OnSkinTitleSelect(WeaponResId)
  if self.WeaponIdToWeaponSkinListItem and self.WeaponIdToWeaponSkinListItem[WeaponResId] then
    local idx = self.WeaponIdToSkinTitleItemTop[WeaponResId].Idx
    local offset = self.WBP_WeaponSkinListItem.SizeBoxTitle.HeightOverride * (idx - 1)
    self.ScrollBoxWeaponSkinList:ScrollWidgetIntoView(self.WeaponIdToWeaponSkinListItem[WeaponResId].Item, true, UE.EDescendantScrollDestination.TopOrLeft, offset)
  end
end
function SkinView:OnWeaponSkinListScrolled(CurrentOffset)
  self:UpdateWeaponSkinTitle(CurrentOffset)
end
function SkinView:UpdateWeaponSkinTitle(CurrentOffset)
  local GeometryScrollBoxWeaponSkinList = self.ScrollBoxWeaponSkinList:GetCachedGeometry()
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
function SkinView:OnUpdateHeroSkinToggleProgress(ShowHeroSkinData)
  local curHeroSkinNum = 0
  local totalHeroSkinNum = #ShowHeroSkinData.SkinDataList
  for i, v in ipairs(ShowHeroSkinData.SkinDataList) do
    if v.bUnlocked then
      curHeroSkinNum = curHeroSkinNum + 1
    end
  end
  self.WBP_SkinToggleHero:InitSkinToggle(curHeroSkinNum, totalHeroSkinNum)
end
function SkinView:OnUpdateWeaponSkinToggleProgress(ShowWeaponSkinDataMap)
  local curWeaponSkinNum = 0
  local totalWeaponSkinNum = 0
  for i, v in pairs(ShowWeaponSkinDataMap) do
    local weaponSkinListData = v
    for iWeaponSkinData, vWeaponSkinData in ipairs(weaponSkinListData.SkinDataList) do
      totalWeaponSkinNum = totalWeaponSkinNum + 1
      if vWeaponSkinData.bUnlocked then
        curWeaponSkinNum = curWeaponSkinNum + 1
      end
    end
  end
  self.WBP_SkinToggleWeapon:InitSkinToggle(curWeaponSkinNum, totalWeaponSkinNum)
end
function SkinView:UpdateHeroSkinDetailsView(HeroSkinData, bUpdateMovie)
  if not HeroSkinData then
    return
  end
  local ResID = GetTbSkinRowNameBySkinID(self.viewModel.CurSelectHeroSkinResId)
  if not self.bHideByOther then
    local AppearanceActorTemp = GetAppearanceActor(self)
    if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
      local seq = LogicRole.GetSkinSequence(HeroSkinData.HeroSkinTb.SkinID)
      if bUpdateMovie and seq then
      else
        self.AppearanceActor:AppearanceToggleSkipEnter(true)
        self.AppearanceActor:InitAppearanceActor(self.viewModel.CurHeroId, HeroSkinData.HeroSkinTb.SkinID, nil, true)
        LogicRole.ShowOrLoadLevel(HeroSkinData.HeroSkinTb.SkinID)
      end
    end
  end
  self.WBP_SkinDetailsItem:UpdateDetailsView(ResID, self.AppearanceMovieList, self)
  self:UpdateHeorHeirloomLv(HeroSkinData)
  self:UpdateUIColor(tostring(HeroSkinData.HeroSkinTb.SkinID))
end
function SkinView:PlaySeq(SoftObjPath)
  local seqSubSys = UE.URGSequenceSubsystem.GetInstance(self)
  if not seqSubSys then
    self:LevelSequenceFinish()
    return
  end
  if self.SequencePlayer then
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
  end
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  self.SequencePlayer = seqSubSys:CreatePlayerFromLevelSequence(self, SoftObjPath, setting)
  if self.SequencePlayer == nil then
    print("[WBP_SettlementView_C::Play] Player or SequenceActor is Empty!")
    self:LevelSequenceFinish()
    return
  end
  self.SequenceActor = self.SequencePlayer.SequenceActor
  if LogicRole.GetSequenceActor() then
    self.SequencePlayer:SetInstanceData(LogicRole.GetSequenceActor(), UE.FTransform())
  end
  self.SequencePlayer.OnFinished:Add(self, self.LevelSequenceFinish)
  self.SequencePlayer:Play()
end
function SkinView:LevelSequenceFinish()
  self:UpdateMovie(false, true)
  local CurSkinData = self.viewModel:GetHeroSkinDataBySkinResId(self.viewModel.CurSelectHeroSkinResId)
  if CurSkinData then
    LogicRole.ShowOrLoadLevel(CurSkinData.HeroSkinTb.SkinID)
  end
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    self.AppearanceActor:RefreshRoleAniStatus(self.viewModel.CurSelectHeroSkinResId)
  end
end
function SkinView:SequenceFinished(SequenceFinish)
  if self.SequencePlayer then
    if self.LastAkEventName then
      UE.UAudioManager.StopWwiseEventByName(self.LastAkEventName)
      self.LastAkEventName = nil
    end
    self.SequencePlayer:K2_DestroyActor()
    self.SequenceActor:K2_DestroyActor()
    self.SequencePlayer = nil
    self.SequenceActor = nil
    if not SequenceFinish then
      LogicRole.ShowLevelForSequence(true)
    end
  end
end
function SkinView:OnHideByOther()
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:UpdateActived(false, true)
  end
end
function SkinView:UpdateEquipButton()
  self.WBP_SkinDetailsItem:UpdateEquipButton()
end
function SkinView:UpdateCustomSkinItemSelct(SkinID)
  for i, v in ipairs(self.SBox_CustomSkin:GetAllChildren():ToTable()) do
    v:SetSel(v.SkinID == SkinID)
  end
end
function SkinView:PlaySkinVoice(SKinID)
  if not self.LastVoiceTime or os.time() - self.LastVoiceTime >= 10 then
    local heroSkinData = self.viewModel:GetHeroSkinDataBySkinResId(SKinID)
    if 3 == heroSkinData.HeroSkinTb.SkinRarity then
      self.LastVoiceTime = os.time()
      local RGVoiceSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGVoiceSubsystem:StaticClass())
      self.VoiceID = RGVoiceSubsystem:PlayVoiceByRowName("Voice.PurpleQualitySkin", GetAppearanceActor(self), SKinID)
    end
  end
end
function SkinView:StopVoice()
  if self.VoiceID and self.VoiceID > 0 then
    UE.URGBlueprintLibrary.StopVoice(self.VoiceID)
    self.VoiceID = 0
  end
end
function SkinView:UpdateUIColor(SkinId)
  local result, row = GetRowData(DT.DT_DisplaySkinUIColor, SkinId)
  if not result then
    result, row = GetRowData(DT.DT_DisplaySkinUIColor, "Default")
  end
  if result then
    self.TextToggleTitle:SetColorAndOpacity(row.UIColor)
  end
end
function SkinView:UpdateHeorHeirloomLv(HeroSkinData, EquipedSkinId)
  UpdateVisibility(self.CanvasPanelHeirloom, HeroSkinData.HeirloomId > 0)
  if HeroSkinData.HeirloomId > 0 then
    local maxLv = self.viewModel:GetHeirloomMaxLevel(HeroSkinData.HeirloomId)
    local heirloomInfoList = self.viewModel:GetHeirloomInfoListByHeirloomId(HeroSkinData.HeirloomId)
    local index = 1
    self.RGToggleGroupHeirloomLv:ClearGroup()
    for i = 1, maxLv do
      if heirloomInfoList[i] then
        local skinId, bHaveSkin = self.viewModel:GetHeroSkinByHeirloomLevel(HeroSkinData.HeirloomId, i)
        if bHaveSkin then
          local item = GetOrCreateItem(self.HorizontalBoxHeirloom, index, self.WBP_HeirloomLvItem:GetClass())
          local bIsUnlock = self.viewModel:IsUnLockHeirloom(HeroSkinData.HeirloomId, i)
          item:InitHeirloomLvItem(index, bIsUnlock)
          self.RGToggleGroupHeirloomLv:AddToGroup(skinId, item)
          index = index + 1
        end
      end
    end
    HideOtherItem(self.HorizontalBoxHeirloom, index)
    self.viewModel:GetHeirloomCurPreviewSkin(HeroSkinData.HeirloomId)
    self.RGToggleGroupHeirloomLv:SelectId(HeroSkinData.HeroSkinTb.SkinID)
  end
end
function SkinView:UpdateWeaponSkinDetailsView(WeaponSkinData)
  local ResID = GetTbSkinRowNameBySkinID(self.viewModel.CurSelectWeaponSkinResId)
  self.WBP_SkinDetailsItem:UpdateDetailsView(ResID, self.AppearanceMovieList, self)
  self.CurDisplayModel = EWeaponSkinDisplayModel.WeaponModel
  UpdateVisibility(self.WBP_InteractTipWidgetChangeDisplay, self.CurDisplayModel == EWeaponSkinDisplayModel.WeaponModel)
  UpdateVisibility(self.WBP_InteractTipWidgetChangeWeaponDisplay, self.CurDisplayModel == EWeaponSkinDisplayModel.HeroModel)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:InitWeaponMesh(WeaponSkinData.WeaponSkinTb.SkinID, self.viewModel:GetWeaponResIdBySkinId(WeaponSkinData.WeaponSkinTb.SkinID), true)
  end
  self:UpdateUIColor(tostring(WeaponSkinData.WeaponSkinTb.SkinID))
end
function SkinView:UpdateWeaponEquipButton(WeaponSkinData)
  self.WBP_SkinDetailsItem:UpdateEquipButton(WeaponSkinData)
end
function SkinView:SelectHeroSkin(HeroSkinResId, bUpdateMovie)
  self.viewModel:UpdateCurSelectHeroSkin(HeroSkinResId, bUpdateMovie)
end
function SkinView:OnWeaponSkinGroupCheckStateChanged(SelectId)
  print("OnWeaponSkinGroupCheckStateChanged", SelectId)
  self:UpdateMovie(false)
  self.viewModel:UpdateCurSelectWeaponSkin(SelectId)
end
function SkinView:OnFirstGroupCheckStateChanged(SelectId)
  print("OnFirstGroupCheckStateChanged", SelectId)
  if SelectId ~= ESkinToggleStatus.HeroSkin and not self.bHideByOther then
    LogicRole.ShowOrLoadLevel(-1)
  end
  LogicLobby.ShowOrHideGround(SelectId == ESkinToggleStatus.HeroSkin)
  self:UpdateMovie(false)
  self.viewModel:UpdateCurSelectSkinToggle(SelectId)
  if SelectId == ESkinToggleStatus.WeaponSkin then
    self.CurDisplayModel = EWeaponSkinDisplayModel.HeroModel
    self:ListenForChangeDisplayModel(true)
    self.ScrollBoxWeaponSkinList:ScrollToStart()
    UpdateVisibility(self.CanvasPanelHeirloom, false)
  elseif SelectId == ESkinToggleStatus.HeroSkin then
    self.WBP_RoleSkinList.TileViewRoleSkin:ScrollToTop()
  end
end
function SkinView:ScrollToTargetWeaponSkin(WeaponResId, WeaponSkinId)
  local WeaponWidget
  local AllChildren = self.ScrollBoxWeaponSkinList:GetAllChildren()
  for k, SingleItem in pairs(AllChildren) do
    if SingleItem.WeaponResId == WeaponResId then
      WeaponWidget = SingleItem
      break
    end
  end
  if not WeaponWidget then
    return
  end
  local WeaponSkinWidget
  local AllSkinWidget = WeaponWidget.WrapBoxWeaponSkin:GetAllChildren()
  for key, SingleItem in pairs(AllSkinWidget) do
    if SingleItem.WeaponSkinInfo.WeaponSkinTb.SkinID == WeaponSkinId then
      WeaponSkinWidget = SingleItem
      break
    end
  end
  if not WeaponSkinWidget then
    return
  end
  self.ScrollBoxWeaponSkinList:ScrollWidgetIntoView(WeaponSkinWidget)
end
function SkinView:OnHeirloomLvChanged(SkinId)
  self:SelectHeroSkin(SkinId, false)
end
function SkinView:OnHideMovieClick()
  local apearanceView = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  if UE.RGUtil.IsUObjectValid(apearanceView) then
    apearanceView.WBP_AppearanceMovieList:Hide()
  end
end
function SkinView:OnShowRole(bShowGlitchMatEffect)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    self.AppearanceActor:AppearanceToggleSkipEnter(true)
    AppearanceActorTemp:InitAppearanceActor(self.viewModel.CurHeroId, self.viewModel.CurSelectHeroSkinResId, AppearanceActorTemp.WeaponSkinId, true, bShowGlitchMatEffect)
  end
end
function SkinView:OnShowWeapon(bShowGlitchMatEffect)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    AppearanceActorTemp:InitWeaponMesh(self.viewModel.CurSelectWeaponSkinResId, self.viewModel:GetWeaponResIdBySkinId(self.viewModel.CurSelectWeaponSkinResId), bShowGlitchMatEffect)
  end
end
function SkinView:LinkPurchaseConfirm(LinkId, ParamList)
  if tonumber(LinkId) ~= 1007 then
    return false
  end
  ComLink(LinkId, nil, ParamList[2], ParamList[1], 1)
  return true
end
function SkinView:InitBuyPanel(LinkId, GoodsId, bUnlocked, AccessDesc)
  if bUnlocked then
    UpdateVisibility(self.CanvasPanelButtonMain, false)
    return
  end
  UpdateVisibility(self.WBP_Price_3, false)
  UpdateVisibility(self.WBP_Price_2, false)
  UpdateVisibility(self.CanvasPanelEquiping, false)
  UpdateVisibility(self.CanvasPanelEquiped, false)
  UpdateVisibility(self.CanvasPanelButtonMain, true)
  if tonumber(LinkId) == nil or 0 == tonumber(LinkId) then
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("UnAccess")
  elseif tonumber(LinkId) == 1007 then
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("Buy")
    self.WBP_CommonButton_Main:SetInfoText(AccessDesc)
    self.WBP_CommonButton_Main:SetContentText("")
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[GoodsId] then
      local GoodsInfo = TBMall[GoodsId]
      UpdateVisibility(self.WBP_Price_3, nil ~= GoodsInfo.ConsumeResources[1])
      self.WBP_Price_3:SetPrice(GoodsInfo.ConsumeResources[1].z, GoodsInfo.ConsumeResources[1].y, GoodsInfo.ConsumeResources[1].x)
      UpdateVisibility(self.WBP_Price_2, nil ~= GoodsInfo.ConsumeResources[2])
      if GoodsInfo.ConsumeResources[2] then
        self.WBP_Price_2:SetPrice(GoodsInfo.ConsumeResources[2].y, GoodsInfo.ConsumeResources[2].z, GoodsInfo.ConsumeResources[2].x)
      end
    end
  else
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("Access")
    self.WBP_CommonButton_Main:SetContentText(AccessDesc)
  end
end
function SkinView:InitAttachBuyPanel(SkinId)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroSkinExchange, SkinId)
  if result then
    UpdateVisibility(self.WBP_Price_2, true)
    self.WBP_CommonButton_Main:SetStyleByBottomStyleRowName("Buy")
    self.WBP_Price_2:SetPrice(rowinfo.CostResources[1].value, nil, rowinfo.CostResources[1].key)
  end
end
function SkinView:CheckIsShow(SkinTb, IsUnlocked)
  if SkinTb.IsUnlockShow and not IsUnlocked then
    return false
  end
  return SkinTb.IsShow and (0 == SkinTb.ParentSkinId or SkinTb.ParentSkinId == nil)
end
function SkinView:CheckUnLockOriSkin(SkinResID)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBCharacterSkin, SkinResID)
  if result then
    local ParentSkinID = rowinfo.ParentSkinId
    local ParentSkinData = self.viewModel:GetHeroSkinDataBySkinResId(ParentSkinID)
    return ParentSkinData.bUnlocked
  end
  return false
end
function SkinView:SkinDetailsCallBack()
  self:SequenceFinished()
  local AppearanceActorTemp = GetAppearanceActor(self)
  self.AppearanceActor:UpdateActived(false, true, false)
end
function SkinView:SequenceCallBack()
  self.WBP_CommonBg.ShowAnimation = false
  self.WBP_CommonBg:AnimationToEnd()
  self:PlayAnimation(self.Anim_IN)
end
return SkinView
