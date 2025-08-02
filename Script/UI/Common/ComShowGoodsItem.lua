local UnLua = _G.UnLua
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local ComShowGoodsItem = UnLua.Class()
local GetCameraActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end

function ComShowGoodsItem:Construct()
  self.Overridden.Construct(self)
  self.CameraActor = GetCameraActor(self)
  self.TypeFunctionDict = {
    [TableEnums.ENUMResourceType.HERO] = self.InitCharacter,
    [TableEnums.ENUMResourceType.Weapon] = self.InitWeapon,
    [9] = self.InitWeaponSkin,
    [10] = self.InitCharacterSkin,
    [16] = self.InitCommuniRoulette,
    [20] = self.InitBanner,
    [19] = self.InitPortrait
  }
end

function ComShowGoodsItem:Destruct()
  self.Overridden.Destruct(self)
end

function ComShowGoodsItem:ShowItem(ResourcesID, showSeq, ParentView)
  if ResourcesID ~= self.ResourcesID then
    self:StopVoice()
  end
  self.ParentView = ParentView
  self.showSeq = showSeq
  self.ResourcesID = ResourcesID
  local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ItemType = TBGeneral[ResourcesID].Type
  LogicRole.ShowOrLoadLevel(-1)
  UpdateVisibility(self.CommonImageShow, false, false)
  local InnerType
  if Logic_Mall.GetDetailRowDataByResourceId(ResourcesID) then
    InnerType = Logic_Mall.GetDetailRowDataByResourceId(ResourcesID).Type
  end
  LogicLobby.ShowOrHideGround(ItemType == TableEnums.ENUMResourceType.HERO or 10 == ItemType)
  if self.CameraActor then
    self:ChangeCameraMode(ItemType == TableEnums.ENUMResourceType.HERO or ItemType == TableEnums.ENUMResourceType.Weapon or 9 == ItemType or 10 == ItemType)
  end
  UpdateVisibility(self.ComBannerItem, 20 == ItemType, 20 == ItemType)
  UpdateVisibility(self.ComPortraitItem, 19 == ItemType, 19 == ItemType)
  UpdateVisibility(self.WBP_SprayPreviewItem, 16 == ItemType and 1 == InnerType, 16 == ItemType and 1 == InnerType)
  UpdateVisibility(self.WBP_CommonVoiceItem, 16 == ItemType and 3 == InnerType, 16 == ItemType and 3 == InnerType)
  if self.TypeFunctionDict[ItemType] then
    self.TypeFunctionDict[ItemType](self, ResourcesID)
  else
    local item = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)[ResourcesID]
    if item then
      UpdateVisibility(self.CommonImageShow, true, false)
      SetImageBrushByPath(self.CommonImageShow, item.Icon)
    end
  end
end

function ComShowGoodsItem:ChangeCameraMode(bMallExterior)
  self.CameraActor = GetCameraActor(self)
  self.CameraActor:UpdateActived(bMallExterior, true, false)
  if not bMallExterior then
    self.CameraActor:ChangeToActivedCamera()
  end
end

function ComShowGoodsItem:InitCharacterSkin(GainResourcesID, bInitRoleScale)
  if self.CameraActor then
    local CharacterSkin = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
    if CharacterSkin then
      local SkinId = CharacterSkin.SkinID
      local HeroId = CharacterSkin.CharacterID
      local WeaponId = DataMgr.GetShowWeaponId(HeroId)
      local WeaponSkinId = SkinData.GetEquipedWeaponSkinIdByWeaponResId(WeaponId)
      local seq = LogicRole.GetSkinSequence(SkinId)
      if self.bIsDrawCardShow then
        if seq then
          self.bIsDrawCardShow = false
        else
          seq = self.DrawCardShowSequencePath
        end
      end
      if seq and self.showSeq then
        local SequenceCallBack
        if self.ParentView and self.ParentView.SequenceCallBack then
          function SequenceCallBack()
            self.ParentView:SequenceCallBack()
          end
        end
        local SequenceEscView
        if self.ParentView and self.ParentView.SequenceEscView then
          function SequenceEscView()
            self.ParentView:SequenceEscView()
          end
        end
        UIMgr:Show(ViewID.UI_MovieLevelSequence, true, SkinId, true, SequenceCallBack, SequenceEscView, seq, self.bIsDrawCardShow)
      else
        self.CameraActor:InitAppearanceActor(HeroId, SkinId, WeaponSkinId)
        if bInitRoleScale then
          self.CameraActor:InitRoleScaleByHeroId(HeroId)
        end
        LogicRole.ShowOrLoadLevel(SkinId)
      end
    end
  end
end

function ComShowGoodsItem:InitWeaponSkin(GainResourcesID)
  if self.CameraActor then
    local WeaponSkin = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
    if WeaponSkin then
      local WeaponSkinId = WeaponSkin.SkinID
      local WeaponResId = WeaponSkin.WeaponID
      self.CameraActor:InitWeaponMesh(WeaponSkinId, WeaponResId)
      LogicRole.ShowOrLoadLevel(WeaponSkinId)
    end
  end
end

function ComShowGoodsItem:InitCommuniRoulette(GainResourcesID)
  local CommuniRoulette = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
  if CommuniRoulette and 3 == CommuniRoulette.Type then
    self.WBP_CommonVoiceItem:ShowItem(GainResourcesID)
    self:PlaySound(GainResourcesID)
  end
  if CommuniRoulette and 1 == CommuniRoulette.Type then
    self.WBP_SprayPreviewItem:InitSprayPreviewItemById(GainResourcesID)
  end
end

function ComShowGoodsItem:PlaySound(CommId)
  local RouletteId = CommunicationData.GetRoulleteIdByCommId(CommId)
  local Result, CommunicationRowInfo = GetRowData(DT.DT_CommunicationWheel, RouletteId)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if Result and CommunicationRowInfo.AudioRowName ~= "None" then
    local HeroName = CommunicationData.GetHeroNameByCommId(CommId)
    local SoundEventName = CommunicationRowInfo.AudioRowName .. "_" .. HeroName
    if -1 ~= self.PlayingVoiceId then
      UE.URGBlueprintLibrary.StopVoice(self.SoundId)
    end
    self.PlayingVoiceId = PlaySound2DByName(SoundEventName, "ComShowGoodsItem:PlaySound")
  end
end

function ComShowGoodsItem:InitBanner(GainResourcesID)
  local Banner = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
  if Banner then
    self.ComBannerItem:InitComBannerItem(Banner.bannerIconPathInInfo, Banner.EffectPath)
  end
end

function ComShowGoodsItem:InitPortrait(GainResourcesID)
  local Portrait = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
  if Portrait then
    self.ComPortraitItem:InitComPortraitItem(Portrait.portraitIconPath, Portrait.EffectPath)
  end
end

function ComShowGoodsItem:InitCharacter(GainResourcesID)
  local HeroId = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID).HeroID
  local SkinId = SkinData.GetDefaultSkinIdByHeroId(HeroId)
  local WeaponId = DataMgr.GetShowWeaponId(HeroId)
  local WeaponSkinId = SkinData.GetEquipedWeaponSkinIdByWeaponResId(WeaponId)
  self.CameraActor:InitAppearanceActor(HeroId, SkinId, WeaponSkinId)
end

function ComShowGoodsItem:InitWeapon(GainResourcesID)
  if self.CameraActor then
    local WeaponSkinId
    local WeaponResId = GainResourcesID
    local TBWeapon = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
    if TBWeapon then
      WeaponSkinId = TBWeapon.SkinID
      self.CameraActor:InitWeaponMesh(WeaponSkinId, WeaponResId)
      LogicRole.ShowOrLoadLevel(WeaponSkinId)
    end
  end
end

function ComShowGoodsItem:StopVoice()
  if self.PlayingVoiceId then
    UE.URGBlueprintLibrary.StopVoice(self.PlayingVoiceId)
    self.PlayingVoiceId = nil
  end
end

function ComShowGoodsItem:Hide()
  self.CameraActor = GetCameraActor(self)
  self.CameraActor:UpdateActived(false, true, false)
  LogicRole.ShowOrLoadLevel(-1)
  self:StopVoice()
  self.ResourcesID = nil
end

function ComShowGoodsItem:SetIsDrawCardShow(bIsDrawCardShow)
  self.bIsDrawCardShow = bIsDrawCardShow
end

return ComShowGoodsItem
