local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local rapidjson = require("rapidjson")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local PlayerInfoData = require("Modules.PlayerInfoMain.PlayerInfo.PlayerInfoData")
local BundleContentView = Class(ViewBase)

function BundleContentView:OnBindUIInput()
  self.WBP_InteractTipWidgetEsc:BindInteractAndClickEvent(self, self.ReturnLobby)
end

function BundleContentView:OnUnBindUIInput()
  self.WBP_InteractTipWidgetEsc:UnBindInteractAndClickEvent(self, self.ReturnLobby)
end

function BundleContentView:BindClickHandler()
end

function BundleContentView:UnBindClickHandler()
end

function BundleContentView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function BundleContentView:OnDestroy()
  self:UnBindClickHandler()
  self:StopVoice()
end

function BundleContentView:OnShowLink(LinkParams, HeroId, GoodsIdTable)
  local GoodsId = GoodsIdTable[2]
  if not GoodsId then
    return
  end
  local BundleViewContentModel = UIModelMgr:Get("BundleViewContentModel")
  if BundleViewContentModel then
    local GainResourcesID = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)[GoodsId].GainResourcesID
    BundleViewContentModel:ShowBundleContent(GainResourcesID, GoodsId)
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  local GiftId
  if TBMall[GoodsId] then
    GiftId = TBMall[GoodsId].GainResourcesID
  end
  if not GiftId then
    return
  end
  local TBRandomGift = LuaTableMgr.GetLuaTableByName(TableNames.TBGift)
  local BundleInfo = TBRandomGift[GiftId]
  self:UpDateList(GoodsId, BundleInfo)
  LogicRole.ShowOrHideRoleMainHero(false)
end

function BundleContentView:OnShow()
  print("BundleContentView OnShow")
  self.ViewModel = UIModelMgr:Get("BundleViewContentModel")
  EventSystem.AddListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.Refresh)
  EventSystem.AddListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.Refresh)
  EventSystem.AddListenerNew(EventDef.PlayerInfo.GetPortraitIds, self, self.Refresh)
  EventSystem.AddListenerNew(EventDef.PlayerInfo.GetBannerIds, self, self.Refresh)
  EventSystem.AddListenerNew(EventDef.Communication.OnGetCommList, self, self.Refresh)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.TileList.BP_OnItemClicked:Clear()
  self.TileList.BP_OnItemClicked:Add(self, BundleContentView.BP_OnItemClicked)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.ReturnLobby)
  self:PlayAnimation(self.Ani_in)
end

function BundleContentView:OpenSetting()
  LogicGameSetting.ShowGameSettingPanel()
end

function BundleContentView:ReturnLobby()
  UIMgr:Hide(ViewID.UI_Mall_Bundle_Content, true)
end

function BundleContentView:OnHideByOther()
  self.CameraActor = self:GetCameraActor(self)
  self.CameraActor:UpdateActived(false, true, false)
  self:StopVoice()
end

function BundleContentView:OnRollback()
  self.CameraActor = self:GetCameraActor(self)
  if self.ShowType == TableEnums.ENUMResourceType.HeroCommuniRoulette or self.ShowType == TableEnums.ENUMResourceType.Banner or self.ShowType == TableEnums.ENUMResourceType.PROP then
  else
    self.CameraActor:UpdateActived(true, true, false)
  end
  self.WBP_CommonBg.ShowAnimation = true
end

function BundleContentView:PlaySound(CommId)
  local RouletteId = CommunicationData.GetRoulleteIdByCommId(CommId)
  local Result, CommunicationRowInfo = GetRowData(DT.DT_CommunicationWheel, RouletteId)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if Result and CommunicationRowInfo.AudioRowName ~= "None" then
    local HeroName = CommunicationData.GetHeroNameByCommId(CommId)
    local SoundEventName = CommunicationRowInfo.AudioRowName .. "_" .. HeroName
    self.ItemVoice = CommId
    self.PlayingVoiceId = PlaySound2DByName(SoundEventName, "BundleContentView:PlaySound")
  end
end

function BundleContentView:StopVoice()
  if self.PlayingVoiceId then
    self.ItemVoice = nil
    UE.URGBlueprintLibrary.StopVoice(self.PlayingVoiceId)
    self.PlayingVoiceId = nil
  end
end

function BundleContentView:BP_OnItemClicked(Item)
  if nil == Item then
    return
  end
  UpdateVisibility(self.VerticalBoxWeaponSkill, false)
  local ItemInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if ItemInfo[Item.ItemId] then
    self.ShowType = ItemInfo[Item.ItemId].Type
    local ResourcesID = Item.ItemId
    self.WBP_ComShowGoodsItem:ShowItem(ResourcesID, true, self)
    self.WBP_SkinDetailsItem:UpdateDetailsView(Item.ItemId, self.WBP_AppearanceMovieList, self, nil, nil, true)
    self.WBP_SkinDetailsItem:UpdateBuyButtonByGoodsId(self.GoddsId, not self.bCanBuy)
  end
end

function BundleContentView:SequenceEscView()
  self:ReturnLobby()
end

function BundleContentView:SequenceCallBack()
  self.WBP_CommonBg.ShowAnimation = false
  self.WBP_CommonBg:AnimationToEnd()
  self:PlayAnimation(self.Ani_in)
end

function BundleContentView:UpDateCamera(bShow, HeroId, SkinId, WeaponSkinId, WeaponResId)
  local CameraActor = self:GetCameraActor()
  if bShow then
    if -1 ~= HeroId and -1 ~= SkinId then
      CameraActor:InitAppearanceActor(HeroId, SkinId, WeaponSkinId)
      LogicRole.ShowOrLoadLevel(SkinId)
    end
    if -1 ~= WeaponSkinId and -1 ~= WeaponResId then
      CameraActor:InitWeaponMesh(WeaponSkinId, WeaponResId)
      LogicRole.ShowOrLoadLevel(WeaponSkinId)
    end
  end
  CameraActor:UpdateActived(bShow, true, false)
  if bShow then
  else
    ChangeToLobbyAnimCamera()
  end
end

function BundleContentView:UpdateCameraByShowItem(bShow, HeroId, SkinId, WeaponSkinId, WeaponResId)
  local CameraActor = self:GetCameraActor()
  if bShow then
    if -1 ~= HeroId and -1 ~= SkinId then
      CameraActor:InitAppearanceActor(HeroId, SkinId, WeaponSkinId)
      LogicRole.ShowOrLoadLevel(SkinId)
    end
    if -1 ~= WeaponSkinId and -1 ~= WeaponResId then
      CameraActor:InitWeaponMesh(WeaponSkinId, WeaponResId)
      LogicRole.ShowOrLoadLevel(WeaponSkinId)
    end
  end
  CameraActor:UpdateActived(bShow, true, false)
  if bShow then
  else
    LogicRole.ShowOrLoadLevel(-1)
  end
end

function BundleContentView:GetCameraActor()
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end

function BundleContentView:OnHide()
  print("BundleContentView OnHide")
  self:PlayAnimation(self.Ani_out)
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetHeroSkinList, self, self.Refresh)
  EventSystem.RemoveListenerNew(EventDef.Skin.OnGetWeaponSkinList, self, self.Refresh)
  EventSystem.RemoveListenerNew(EventDef.PlayerInfo.GetPortraitIds, self, self.Refresh)
  EventSystem.RemoveListenerNew(EventDef.PlayerInfo.GetBannerIds, self, self.Refresh)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnGetCommList, self, self.Refresh)
  self:UpDateCamera(false)
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Remove(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.ReturnLobby)
  self:StopVoice()
  LogicRole.ShowOrLoadLevel(-1)
  LogicRole.ShowLevelForSequence(true)
end

function BundleContentView:Refresh(JsonStr)
  if self.BundleInfo and self.GoddsId then
    self:UpDateList(self.GoddsId, self.BundleInfo)
  end
end

function BundleContentView:UpDateList(GoddsId, BundleInfo, Item)
  self.GoddsId = GoddsId
  self.BundleInfo = BundleInfo
  local DataClass = UE.UClass.Load("/Game/Rouge/UI/Mall/Bundle/BP_MallBundleContentDataObj.BP_MallBundleContentDataObj_C")
  self.TileList:ClearListItems()
  local HaveSkin = {}
  for key, HeroSkinMap in pairs(SkinData.HeroSkinMap) do
    for key, SkinDataList in pairs(HeroSkinMap.SkinDataList) do
      if SkinDataList.bUnlocked then
        table.insert(HaveSkin, SkinDataList.HeroSkinTb.ID)
      end
    end
  end
  for key, HeroSkinMap in pairs(SkinData.WeaponSkinMap) do
    for key, SkinDataList in pairs(HeroSkinMap.SkinDataList) do
      if SkinDataList.bUnlocked then
        table.insert(HaveSkin, SkinDataList.WeaponSkinTb.ID)
      end
    end
  end
  for key, WeaponMap in pairs(DataMgr.GetWeaponList()) do
    table.insert(HaveSkin, tonumber(WeaponMap.resourceId))
  end
  for key, RoulleteId in pairs(CommunicationData.HeroCommBag) do
    table.insert(HaveSkin, CommunicationData.GetTBCommonicationDataByRouletteId(RoulleteId).ID)
  end
  for key, PortraitID in pairs(PlayerInfoData.PortraitIDs) do
    if PlayerInfoData:GetTBPortraitDataByPortraitId(PortraitID) then
      table.insert(HaveSkin, PlayerInfoData:GetTBPortraitDataByPortraitId(PortraitID).ID)
    end
  end
  for key, BannerID in pairs(PlayerInfoData.BannerIDs) do
    if PlayerInfoData:GetTBBannerDataByBannerId(BannerID) then
      table.insert(HaveSkin, PlayerInfoData:GetTBBannerDataByBannerId(BannerID).ID)
    end
  end
  for index, value in ipairs(DataMgr.GetMyHeroInfo().heros) do
    local TBHero = LuaTableMgr.GetLuaTableByName(TableNames.TBHero)
    for key, TBHeroRow in pairs(TBHero) do
      if TBHeroRow.HeroID == value.id then
        table.insert(HaveSkin, TBHeroRow.ID)
      end
    end
  end
  local bCanBuy = false
  if self.ViewModel and BundleInfo then
    for index, value in ipairs(BundleInfo.Resources) do
      local ItemObj = NewObject(DataClass, GameInstance, nil)
      ItemObj.ItemId = value.key
      print("ItemId", value.key)
      ItemObj.bHave = table.Contain(HaveSkin, tonumber(value.key))
      if not ItemObj.bHave then
        bCanBuy = true
      end
      ItemObj.Num = value.value
      ItemObj.ChildWidget = self.WBP_CommonItemDetail
      self.TileList:AddItem(ItemObj)
      if 1 == index then
        self:BP_OnItemClicked(ItemObj)
        self.TileList:BP_SetSelectedItem(ItemObj)
      end
    end
  end
  local SalesStatus = Logic_Mall.GetGoodsSalesStatus(Item)
  if SalesStatus == EnumSalesStatus.OnSale or SalesStatus == EnumSalesStatus.LimitedTimeOnSale or nil == Item then
    self.bCanBuy = bCanBuy
  else
    self.bCanBuy = false
  end
  self.WBP_SkinDetailsItem:UpdateBuyButtonByGoodsId(self.GoddsId, not self.bCanBuy)
  local MailInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if MailInfo[GoddsId] then
    self.Text_Name:SetText(MailInfo[GoddsId].Name)
  end
end

function BundleContentView:RefreshWeaponSkill(WeaponId)
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(WeaponId))
  local index = 1
  if Result and RowData.WeaponSkillDataAry:Num() > 0 then
    for i, v in iterator(RowData.WeaponSkillDataAry) do
      local item = GetOrCreateItem(self.VerticalBoxWeaponSkill, i, self.WBP_WeaponTipsSkillItem:GetClass())
      UpdateVisibility(item, true)
      item:RefreshWeaponTipsSkillItemInfo(v, i, true)
      index = index + 1
    end
  end
  UpdateVisibility(self.VerticalBoxWeaponSkill, true)
  HideOtherItem(self.VerticalBoxWeaponSkill, index)
end

function BundleContentView:CheckGoodsType()
  local ConsumeNum = 0
  local GoddsId = tonumber(self.ViewModel.GoodsId)
  local MailInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if MailInfo[GoddsId] then
    self.CurrencyId = MailInfo[GoddsId].ConsumeResources[1].x
    ConsumeNum = MailInfo[GoddsId].ConsumeResources[1].z
  end
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not CurrencyInfo then
    print("not found CurrencyId", self.CurrencyId)
    return false, ConsumeNum
  end
  local CurNum = 0
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
    CurNum = DataMgr.GetOutsideCurrencyNumById(self.CurrencyId)
  else
    CurNum = DataMgr.GetPackbackNumById(self.CurrencyId)
  end
  return ConsumeNum <= CurNum, ConsumeNum - CurNum
end

function BundleContentView:SelectHeroSkin(HeroSkinResId, bUpdateMovie)
  local ResID = GetTbSkinRowNameBySkinID(HeroSkinResId)
  self.WBP_ComShowGoodsItem:InitCharacterSkin(ResID)
end

return BundleContentView
