local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local rapidjson = require("rapidjson")
local UIUtil = require("Framework.UIMgr.UIUtil")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local LimitPurchaseForever = NSLOCTEXT("PropsItemView", "LimitPurchaseForever", "\230\176\184\228\185\133\233\153\144\232\180\173")
local LimitPurchaseSeason = NSLOCTEXT("PropsItemView", "LimitPurchaseSeason", "\232\181\155\229\173\163\233\153\144\232\180\173")
local LimitPurchaseMonth = NSLOCTEXT("PropsItemView", "LimitPurchaseMonth", "\230\156\172\230\156\136\233\153\144\232\180\173")
local LimitPurchaseDay = NSLOCTEXT("PropsItemView", "LimitPurchaseDay", "\230\175\143\230\151\165\233\153\144\232\180\173")
local LimitPurchaseWeekly = NSLOCTEXT("PropsItemView", "LimitPurchaseWeekly", "\230\175\143\229\145\168\233\153\144\232\180\173")
local MallExteriorView = Class(ViewBase)
local GetCameraActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end
function MallExteriorView:OnBindUIInput()
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc_1.OnMainButtonClicked:Add(self, self.ReturnLobby)
  ListenForInputAction("OpenSettings", UE.EInputEvent.IE_Pressed, true, {
    self,
    self.OpenSetting
  })
end
function MallExteriorView:OnUnBindUIInput()
  self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Remove(self, self.OpenSetting)
  self.WBP_InteractTipWidgetEsc_1.OnMainButtonClicked:Remove(self, self.ReturnLobby)
  StopListeningForInputAction(self, "OpenSettings", UE.EInputEvent.IE_Pressed)
end
function MallExteriorView:BindClickHandler()
  self.List.BP_OnItemIsHoveredChanged:Add(self, MallExteriorView.BP_OnItemIsHoveredChanged)
  self.List.BP_OnItemSelectionChanged:Add(self, MallExteriorView.BP_OnItemSelectionChanged_List)
  self.SecondShelfListView.BP_OnItemSelectionChanged:Add(self, MallExteriorView.BP_OnItemSelectionChanged_SecondShelfListView)
  self.CancelSearchBtn.OnClicked:Add(self, MallExteriorView.CancelSearch)
  self.CheckBox_Have.OnCheckStateChanged:Add(self, MallExteriorView.OnCheckStateChanged)
  self.Search.OnTextChanged:Add(self, MallExteriorView.OnTextChanged)
  self.RareBox.OnSelectionChanged:Add(self, MallExteriorView.OnSelectionChanged)
  EventSystem.AddListener(self, EventDef.WSMessage.ResourceUpdate, MallExteriorView.BindOnResourceUpdate)
end
function MallExteriorView:OnCheckStateChanged(bIsChecked)
  self.bHave = bIsChecked
  self:UpDateList(Logic_Mall.GetExteriorInfo())
end
function MallExteriorView:OnTextChanged(Text)
  self.SearchText = tostring(Text)
  self:UpDateList(Logic_Mall.GetExteriorInfo())
  UpdateVisibility(self.CancelSearchBtn, "" ~= Text, true)
  UpdateVisibility(self.URGImage_Sousuo, "" == Text, true)
end
function MallExteriorView:OnSelectionChanged(SelectedItem, Type)
  self.Rare = self.RareBox:GetSelectedIndex()
  self:UpDateList(Logic_Mall.GetExteriorInfo())
end
function MallExteriorView:ChangeShowType(SelectId)
  if self.SelectId ~= SelectId then
    self.SelectId = SelectId
    self.SelectGoodsId = nil
    self.NeedSelectIdx = nil
  end
  if not self:IsAnimationPlaying(self.Ani_in) then
    self:PlayAnimation(self.Ani_list_in)
  end
  UpdateVisibility(self.List, true, true)
  UpdateVisibility(self.List_Weapon, false, false)
  self:UpDateList(Logic_Mall.GetExteriorInfo())
  local TBShelfSecondTab = LuaTableMgr.GetLuaTableByName(TableNames.TBShelfSecondTab)
  if TBShelfSecondTab and TBShelfSecondTab[SelectId] then
    local SecondShelfName = TBShelfSecondTab[SelectId].Name
    self.Txt_Title:SetText(SecondShelfName)
    if TBShelfSecondTab[SelectId].CoinList then
      self.WBP_LobbyCurrencyList:ClearListContainer()
      self.WBP_LobbyCurrencyList:SetCurrencyList(TBShelfSecondTab[SelectId].CoinList)
    end
  end
end
function MallExteriorView:UnBindClickHandler()
end
function MallExteriorView:OpenSetting()
  LogicGameSetting.ShowGameSettingPanel()
end
function MallExteriorView:ReturnLobby()
  local LobbyDefaultLabelName = LogicLobby.GetDefaultSelectedLabelName()
  local CurShowLabelName = LogicLobby.GetCurSelectedLabelName()
  if CurShowLabelName == LobbyDefaultLabelName then
    EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, not self.IsShowLobbyMenuPanel)
  else
    LogicLobby.ChangeLobbyPanelLabelSelected(LobbyDefaultLabelName)
  end
end
function MallExteriorView:SequenceEscView()
  self:ReturnLobby()
end
function MallExteriorView:SequenceCallBack()
  self:PlayAnimation(self.Ani_in)
end
function MallExteriorView:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    self:BindOnOutAnimationFinished()
  end
end
function MallExteriorView:BindOnOutAnimationFinished()
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
end
function MallExteriorView:CanDirectSwitch(NextTabWidget)
  self:PlayAnimation(self.Ani_out)
  return false
end
function MallExteriorView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("MallExteriorViewModel")
  self:BindClickHandler()
  self.TypeFunctionDict = {
    [9] = self.InitWeaponSkin,
    [10] = self.InitCharacterSkin,
    [16] = self.InitCommuniRoulette,
    [20] = self.InitBanner,
    [19] = self.InitPortrait
  }
end
function MallExteriorView:OnDestroy()
  self:UnBindClickHandler()
  self:StopVoice()
end
function MallExteriorView:OnShowLink(LinkParams, ...)
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.MALL) then
    return
  end
  if LinkParams:Num() > 0 then
    if UIMgr:IsShow(ViewID.UI_MovieLevelSequence) then
      UIMgr:Hide(ViewID.UI_MovieLevelSequence, true)
    end
    self.SelectId = LinkParams:Get(1).IntParam
    local Params = {
      ...
    }
    local GoodsId = Params[1]
    if not GoodsId and LinkParams:IsValidIndex(2) then
      GoodsId = LinkParams:Get(2).IntParam
    end
    self.SelectGoodsId = GoodsId
    self:UpDateList(Logic_Mall.GetExteriorInfo())
  end
end
function MallExteriorView:OnHideByOther()
  self.CameraActor = GetCameraActor(self)
  self.CameraActor:UpdateActived(false, true, false)
  self:StopVoice()
  self.SelGoodsId = nil
end
function MallExteriorView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.ShelfToIndex = {}
  self.SecondShelfListView:ClearListItems()
  self.ShelfIndex = LogicLobby.UINameToShelfIndex[self.ViewID]
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBMallShelf, self.ShelfIndex)
  self.RowData = nil
  local DataObjList = {}
  if result then
    self.RowData = row
    for index, SecondShelf in ipairs(self.RowData.TapList) do
      local resultShelf, rowShelf = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBShelfSecondTab, SecondShelf)
      local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
      if resultShelf and SystemUnlockModule:CheckIsSystemUnlock(rowShelf.SystemID) and not self.SelectId then
        self.SelectId = SecondShelf
      end
      self.ShelfToIndex[SecondShelf] = index - 1
      local DataObj = self.SecondShelfListView:GetOrCreateDataObj()
      DataObj.ShelfId = self.ShelfIndex
      DataObj.SecondShelfId = SecondShelf
      table.insert(DataObjList, DataObj)
    end
  end
  self.SecondShelfListView:SetRGListItems(DataObjList, false, true)
  self.DefaultOptions = NSLOCTEXT("MallExteriorView", "DefaultOptions", "\233\187\152\232\174\164")
  self.PriceAscending = NSLOCTEXT("MallExteriorView", "PriceAscending", "\228\187\183\230\160\188\229\141\135\229\186\143")
  self.PriceDescending = NSLOCTEXT("MallExteriorView", "PriceDescending", "\228\187\183\230\160\188\233\153\141\229\186\143")
  self.CameraActor = GetCameraActor(self)
  self:ChangeCameraMode(false)
  self.RareBox:ClearOptions()
  self.RareBox:AddOption(self.DefaultOptions())
  self.RareBox:AddOption(self.PriceAscending())
  self.RareBox:AddOption(self.PriceDescending())
  self.RareBox:SetSelectedOption(self.DefaultOptions())
  self.Rare = 0
  self.SearchText = ""
  self.Init = false
  EventSystem.AddListener(self, EventDef.Mall.OnGetExteriorInfo, self.UpDateList)
  Logic_Mall.PushExteriorInfo(true, self.ShelfIndex)
  self:PlayAnimation(self.Ani_in)
  LogicLobby.ChangeLobbyMainModelVis(false)
  UpdateVisibility(self.WBP_ComShowGoodsItem, false)
end
function MallExteriorView:OnRollback()
  if self.ShowType ~= TableEnums.ENUMResourceType.HERO and self.ShowType ~= TableEnums.ENUMResourceType.Weapon and self.ShowType ~= TableEnums.ENUMResourceType.WeaponSkin and self.ShowType ~= TableEnums.ENUMResourceType.HeroSkin then
    self:ChangeCameraMode(false)
  else
    self:ChangeCameraMode(true)
  end
  local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if TBMall[self.SelectGoodsId] then
    local ResourcesID = TBMall[self.SelectGoodsId].GainResourcesID
    local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    self.ShowType = TBGeneral[ResourcesID].Type
    if self.ShowType == TableEnums.ENUMResourceType.HeroSkin then
      local Skin = Logic_Mall.GetDetailRowDataByResourceId(ResourcesID)
      if Skin then
        local SkinId = Skin.SkinID
        LogicRole.ShowOrLoadLevel(SkinId)
      end
    end
  end
end
function MallExteriorView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  EventSystem.RemoveListener(EventDef.Mall.OnGetExteriorInfo, self.UpDateList, self)
  EventSystem.RemoveListener(EventDef.WSMessage.ResourceUpdate, MallExteriorView.BindOnResourceUpdate, self)
  self:ChangeCameraMode(false)
  LogicLobby.ChangeLobbyMainModelVis(true)
  self:StopVoice()
  self.SelGoodsId = nil
  LogicRole.ShowOrLoadLevel(-1)
  LogicRole.ShowLevelForSequence(true)
end
function MallExteriorView:Construct()
end
function MallExteriorView:UpDateList(goodsInfos)
  if not self.Init then
    self.Init = true
    self.SecondShelfListView:SetSelectedIndex(self.ShelfToIndex[self.SelectId])
    return
  end
  self.List:ClearListItems()
  self.RoleNumSum = 0
  self.RoleHaveNumSum = 0
  self.WeaponNumSum = 0
  self.WeaponHaveNumSum = 0
  self.CacheItem = {}
  if nil == goodsInfos or nil == goodsInfos[self.ShelfIndex] then
    return
  end
  goodsInfos = goodsInfos[self.ShelfIndex]
  self.goodsInfos = goodsInfos
  local DataClass = UE.UClass.Load("/Game/Rouge/UI/Mall/Bundle/BP_MallBundleDataObj.BP_MallBundleDataObj_C")
  local DataTable = {}
  for key, value in pairs(goodsInfos) do
    if not self:OnShowTime(value.showStartTime, value.showEndTime) then
    else
      local DataObj = NewObject(DataClass, GameInstance, nil)
      DataObj.GoodsId = value.GoodsID
      DataObj.Amount = value.Amount
      DataObj.StartTime = value.startTime
      DataObj.EndTime = value.endTime
      DataObj.ShowStartTime = value.showStartTime
      DataObj.ShowEndTime = value.showEndTime
      DataObj.TipsWidget = self.WBP_CommonItemDetail
      DataObj.BuyLimitForAlreadyOwned = value.buyLimitForAlreadyOwned
      local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
      local ResourcesID = TBMall[DataObj.GoodsId].GainResourcesID
      local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      local Type = TBGeneral[ResourcesID].Type
      if self:HasSecondShelfIndex(TBMall[DataObj.GoodsId]) then
        table.insert(DataTable, DataObj)
      end
      self.CacheItem[value.GoodsID] = DataObj
    end
  end
  DataTable = self:Sort(DataTable, self.Rare)
  for key, value in pairs(DataTable) do
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    local Name = TBMall[value.GoodsId].Name
    if (nil == self.SearchText or string.find(tostring(Name), self.SearchText)) and self:OnShowTime(value.ShowStartTime, value.ShowEndTime) then
      if self.bHave then
        local SaleStatus = Logic_Mall.GetGoodsSalesStatus(value)
        if SaleStatus ~= EnumSalesStatus.AlreadyOwned then
          self.List:AddItem(value)
        end
      else
        self.List:AddItem(value)
      end
    end
  end
  UpdateVisibility(self.Overlay_ListEmpty, 0 == self.List:GetNumItems())
  if self.NeedSelectIdx then
    self.List:SetSelectedIndex(self.NeedSelectIdx)
    self.NeedSelectIdx = nil
  else
    if nil ~= self.SelectGoodsId and self.CacheItem and self.CacheItem[self.SelectGoodsId] then
      self.List:BP_SetSelectedItem(self.CacheItem[self.SelectGoodsId])
      return
    end
    self.List:SetSelectedIndex(0)
  end
end
function MallExteriorView:HasSecondShelfIndex(Goods)
  if not Goods then
    return false
  end
  if not Goods.TapList then
    return false
  end
  for index, value in ipairs(Goods.TapList) do
    if value == self.SelectId then
      return true
    end
  end
  return false
end
function MallExteriorView:SelectSkin(ItemResId)
  local tbMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  for index, TbMallItem in ipairs(tbMall) do
    if TbMallItem.GainResourcesID == ItemResId and TbMallItem.TapList then
      for index, ShelfId in ipairs(TbMallItem.TapList) do
        if ShelfId and self.ShelfToIndex[ShelfId] then
          self.SecondShelfListView:SetSelectedIndex(self.ShelfToIndex[ShelfId])
          break
        end
      end
    end
  end
  for i, v in iterator(self.List.ListItems) do
    local tbMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    local resId
    if tbMall and tbMall[v.GoodsId] then
      resId = tbMall[v.GoodsId].GainResourcesID
    end
    if resId == ItemResId then
      self.NeedSelectIdx = i - 1
      self.List:SetSelectedIndex(self.NeedSelectIdx)
      break
    end
  end
end
function MallExteriorView:Sort(DataTable, SortType)
  if 0 == SortType then
    table.sort(DataTable, function(a, b)
      local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
      local AResourcesID = TBMall[a.GoodsId].GainResourcesID
      local BResourcesID = TBMall[b.GoodsId].GainResourcesID
      local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
      local ARare = TBGeneral[AResourcesID].Rare
      local BRare = TBGeneral[BResourcesID].Rare
      if ARare == BRare then
        return a.StartTime > b.StartTime
      end
      return ARare > BRare
    end)
  end
  if 1 == SortType then
    table.sort(DataTable, function(a, b)
      local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
      if TBMall[a.GoodsId].ConsumeResources[2] == TBMall[b.GoodsId].ConsumeResources[2] then
        return TBMall[a.GoodsId].ConsumeResources[1].z < TBMall[b.GoodsId].ConsumeResources[1].z
      end
      return TBMall[a.GoodsId].ConsumeResources[2] == nil
    end)
  end
  if 2 == SortType then
    table.sort(DataTable, function(a, b)
      local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
      if TBMall[a.GoodsId].ConsumeResources[2] == TBMall[b.GoodsId].ConsumeResources[2] then
        return TBMall[a.GoodsId].ConsumeResources[1].z > TBMall[b.GoodsId].ConsumeResources[1].z
      end
      return TBMall[a.GoodsId].ConsumeResources[2] ~= nil
    end)
  end
  return DataTable
end
function MallExteriorView:BP_OnItemIsHoveredChanged(Item, bIsHovered)
end
function MallExteriorView:BP_OnItemSelectionChanged_SecondShelfListView(Item, bSelection)
  if bSelection then
    self:ChangeShowType(Item.SecondShelfId)
  end
end
function MallExteriorView:BP_OnItemSelectionChanged_List(Item, bSelection)
  if bSelection then
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[Item.GoodsId] then
      local GoodsInfo = TBMall[Item.GoodsId]
      local ResourcesID = GoodsInfo.GainResourcesID
      self.SelectGoodsId = Item.GoodsId
      if self.SelectGoodsId ~= self.SelGoodsId then
        if self.PlayingVoiceId then
          self:StopVoice()
        end
        local TBGeneral = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
        self.ShowType = TBGeneral[ResourcesID].Type
        self.WBP_ComShowGoodsItem:ShowItem(ResourcesID, true, self)
        self:SetSelectGoodsId(Item.GoodsId)
      end
      UpdateVisibility(self.WBP_ComShowGoodsItem, true)
      local SalesStatus = Logic_Mall.GetGoodsSalesStatus(Item)
      local bCanBuy = SalesStatus == EnumSalesStatus.OnSale or SalesStatus == EnumSalesStatus.LimitedTimeOnSale
      self.WBP_SkinDetailsItem:UpdateDetailsView(ResourcesID, self.WBP_AppearanceMovieList, self, not bCanBuy, Item.GoodsId, true, Item.Amount)
      local LimitType, LimitProgress = "", "1/1"
      if GoodsInfo.BuyLimitType == TableEnums.ENUMBuyLimitType.NONE then
        return
      elseif GoodsInfo.BuyLimitType == TableEnums.ENUMBuyLimitType.DAY then
        LimitType = LimitPurchaseDay()
      elseif GoodsInfo.BuyLimitType == TableEnums.ENUMBuyLimitType.WEEKLY then
        LimitType = LimitPurchaseWeekly()
      elseif GoodsInfo.BuyLimitType == TableEnums.ENUMBuyLimitType.MONTH then
        LimitType = LimitPurchaseMonth()
      elseif GoodsInfo.BuyLimitType == TableEnums.ENUMBuyLimitType.SEASON then
        LimitType = LimitPurchaseSeason()
      elseif GoodsInfo.BuyLimitType == TableEnums.ENUMBuyLimitType.FOREVER then
        LimitType = LimitPurchaseForever()
      end
      LimitProgress = Item.Amount .. "/" .. GoodsInfo.BuyLimit
      self.WBP_SkinDetailsItem:ShowLimit(LimitType, LimitProgress)
    end
  end
end
function MallExteriorView:InitCharacterSkin(GainResourcesID)
  if self.CameraActor then
    local CharacterSkin = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
    if CharacterSkin then
      local SkinId = CharacterSkin.SkinID
      local HeroId = CharacterSkin.CharacterID
      local WeaponId = DataMgr.GetShowWeaponId(HeroId)
      self.CameraActor:InitAppearanceActor(HeroId, SkinId, WeaponId)
      LogicRole.ShowOrLoadLevel(SkinId)
    end
  end
end
function MallExteriorView:InitWeaponSkin(GainResourcesID)
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
function MallExteriorView:InitCommuniRoulette(GainResourcesID)
  local CommuniRoulette = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
  if self.CameraActor and CommuniRoulette and 3 == CommuniRoulette.Type then
    local defaultSkin = SkinData.GetDefaultSkinIdByHeroId(CommuniRoulette.HeroID)
    if -1 ~= defaultSkin then
      local SkinId = defaultSkin
      local HeroId = CommuniRoulette.HeroID
      local WeaponId = DataMgr.GetShowWeaponId(CommuniRoulette.HeroID)
      self.CameraActor:InitAppearanceActor(HeroId, SkinId, WeaponId)
      LogicRole.ShowOrLoadLevel(SkinId)
      self:PlaySound(GainResourcesID)
    end
  end
  if CommuniRoulette and 1 == CommuniRoulette.Type then
    self.WBP_SprayPreviewItem:InitSprayPreviewItemById(GainResourcesID)
  end
end
function MallExteriorView:PlaySound(CommId)
  local RouletteId = CommunicationData.GetRoulleteIdByCommId(CommId)
  local Result, CommunicationRowInfo = GetRowData(DT.DT_CommunicationWheel, RouletteId)
  local RGSoundSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGSoundSubsystem:StaticClass())
  if Result and CommunicationRowInfo.AudioRowName ~= "None" then
    local HeroName = CommunicationData.GetHeroNameByCommId(CommId)
    local SoundEventName = CommunicationRowInfo.AudioRowName .. "_" .. HeroName
    if -1 ~= self.PlayingVoiceId then
      UE.URGBlueprintLibrary.StopVoice(self.SoundId)
    end
    self.PlayingVoiceId = PlaySound2DByName(SoundEventName, "BattlePassSubView:PlaySound")
  end
end
function MallExteriorView:InitBanner(GainResourcesID)
  local Banner = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
  if Banner then
    self.ComBannerItem:InitComBannerItem(Banner.bannerIconPathInInfo, Banner.EffectPath)
  end
end
function MallExteriorView:InitPortrait(GainResourcesID)
  local Portrait = Logic_Mall.GetDetailRowDataByResourceId(GainResourcesID)
  if Portrait then
    self.ComPortraitItem:InitComPortraitItem(Portrait.portraitIconPath, Portrait.EffectPath)
  end
end
function MallExteriorView:StopVoice()
  if self.PlayingVoiceId then
    UE.URGBlueprintLibrary.StopVoice(self.PlayingVoiceId)
    self.PlayingVoiceId = nil
  end
end
function MallExteriorView:CancelSearch()
  self:OnTextChanged("")
  self.Search:SetText("")
end
function MallExteriorView:BindOnResourceUpdate(json)
  local JsonTable = rapidjson.decode(json)
  if JsonTable.proppack == nil then
    return
  end
  self:UpDateList(Logic_Mall.GetExteriorInfo())
end
function MallExteriorView:ChangeCameraMode(bMallExterior)
  self.CameraActor = GetCameraActor(self)
  self.CameraActor:UpdateActived(bMallExterior, true, false)
end
function MallExteriorView:CheckGoodsType()
  local ConsumeNum = 0
  local GoddsId = tonumber(self.SelectGoodsId)
  local MailInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
  if MailInfo[GoddsId] then
    self.CurrencyId = MailInfo[GoddsId].ConsumeResourcesID
    ConsumeNum = MailInfo[GoddsId].DiscountPrice
  end
  local CurrencyInfo = LogicOutsidePackback.GetResourceInfoById(self.CurrencyId)
  if not CurrencyInfo then
    print("not found CurrencyId", self.CurrencyId)
    return false
  end
  local CurNum = 0
  if CurrencyInfo.Type == TableEnums.ENUMResourceType.CURRENCY then
    CurNum = DataMgr.GetOutsideCurrencyNumById(self.CurrencyId)
  else
    CurNum = DataMgr.GetPackbackNumById(self.CurrencyId)
  end
  return ConsumeNum <= CurNum, ConsumeNum - CurNum
end
function MallExteriorView:SetSelectGoodsId(GoodsId)
  self.SelGoodsId = GoodsId
end
function MallExteriorView:OnShowTime(ShowStartTime, ShowEndTime)
  local CurTimeTemp = os.time()
  return tonumber(ShowStartTime) <= tonumber(CurTimeTemp) and tonumber(CurTimeTemp) <= tonumber(ShowEndTime)
end
function MallExteriorView:ShowItemByType(ItemType, ResourcesID)
  LogicRole.ShowOrLoadLevel(-1)
  UpdateVisibility(self.CommonImageShow, false, false)
  local InnerType
  if Logic_Mall.GetDetailRowDataByResourceId(ResourcesID) then
    InnerType = Logic_Mall.GetDetailRowDataByResourceId(ResourcesID).Type
  end
  LogicLobby.ShowOrHideGround(10 == ItemType or 16 == ItemType and 3 == InnerType)
  if self.CameraActor then
    self:ChangeCameraMode(9 == ItemType or 10 == ItemType or 16 == ItemType and 3 == InnerType)
  end
  UpdateVisibility(self.ComBannerItem, 20 == ItemType, 20 == ItemType)
  UpdateVisibility(self.ComPortraitItem, 19 == ItemType, 19 == ItemType)
  UpdateVisibility(self.WBP_SprayPreviewItem, 16 == ItemType and 1 == InnerType, 16 == ItemType and 1 == InnerType)
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
return MallExteriorView
