local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local CommunicationData = require("Modules.Appearance.Communication.CommunicationData")
local PreCameraData = "PrevWeapon"
local NextCameraData = "NextWeapon"
local TabKeyEvent = "TabKeyEvent"
local EscName = "PauseGame"
local CommunicationView = Class(ViewBase)
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end

function CommunicationView:OnBindUIInput()
  self.WBP_RedDotClearButtonView:BindInteractAndClickEvent()
end

function CommunicationView:OnUnBindUIInput()
  self.WBP_RedDotClearButtonView:UnBindInteractAndClickEvent()
end

function CommunicationView:BindClickHandler()
  self.RGToggleGroupFirst.OnCheckStateChanged:Add(self, self.OnFirstGroupCheckStateChanged)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, self.EscView)
end

function CommunicationView:UnBindClickHandler()
  self.RGToggleGroupFirst.OnCheckStateChanged:Remove(self, self.OnFirstGroupCheckStateChanged)
  self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Remove(self, self.EscView)
end

function CommunicationView:OnInit()
  self.DataBindTable = {
    {
      Source = "CurHeroId",
      Callback = CommunicationView.OnCurHeroIdUpdate
    },
    {
      Source = "ShowSprayData",
      Callback = CommunicationView.OnShowSprayDataUpdate
    },
    {
      Source = "CurSelectSparyId",
      Callback = CommunicationView.OnCurSelectSparyIdUpdate
    },
    {
      Source = "ShowVoiceData",
      Callback = CommunicationView.OnShowVoiceDataUpdate
    },
    {
      Source = "CurSelectVoiceId",
      Callback = CommunicationView.OnCurSelectVoiceIdUpdate
    },
    {
      Source = "CurSelectCommunicationToggle",
      Callback = CommunicationView.OnCurSelectCommunicationToggleUpdate
    },
    {
      Source = "IsEmptyShowList",
      Callback = CommunicationView.OnIsEmptyShowListUpdate
    },
    {
      Source = "RedDotIdList",
      Callback = CommunicationView.OnRedDotIdListUpdate
    }
  }
  self.viewModel = UIModelMgr:Get("CommunicationViewModel")
  self:BindClickHandler()
end

function CommunicationView:OnDestroy()
  self:UnBindClickHandler()
end

function CommunicationView:OnShow(...)
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  UpdateVisibility(self.WBP_SprayPreviewItem, false)
  self.WBP_CommunicationDropBg:InitDrop()
  LogicRole.ShowOrLoadLevel(-1)
  GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
    self.AppearanceActor:UpdateActived(true)
  end
  self.viewModel:SendGetCommList(function()
    self.viewModel:UpdateCurSelectCommunicationToggle(ECommunicationToggleStatus.None)
    self.viewModel:UpdateCurSelectCommunicationToggle(ECommunicationToggleStatus.Spray)
  end)
  self.WBP_RedDotClearButtonView.HeroId = self.viewModel.CurHeroId
  self.WBP_CommonButton_Buy.OnMainButtonClicked:Add(self, self.OnBuyClick)
  self.WBP_CommonButton_Buy.OnMainButtonHovered:Add(self, self.OnBuyHovered)
  self.WBP_CommonButton_Buy.OnMainButtonUnhovered:Add(self, self.OnBuyUnhovered)
  EventSystem.AddListenerNew(EventDef.Communication.OnRouletteAreaSelectChanged, self, self.OnRouletteAreaSelectChanged)
  EventSystem.AddListenerNew(EventDef.Communication.OnCommSelectChanged, self, self.OnCommSelectChanged)
  self:PlayAnimation(self.Anim_IN)
end

function CommunicationView:OnPreHide()
  if UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
    self.AppearanceActor:UpdateActived(false)
  end
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  self.viewModel:UpdateCurSelectSpary(-1)
  self.viewModel:UpdateCurSelectVoice(-1)
end

function CommunicationView:OnHide()
  self:StopAllAnimations()
  self:StopVoice()
  UpdateVisibility(self.CanvasPanelRoot, true)
  LogicLobby.ChangeLobbyMainModelVis(true)
  self.WBP_CommonButton_Buy.OnMainButtonClicked:Remove(self, self.OnBuyClick)
  self.WBP_CommonButton_Buy.OnMainButtonHovered:Remove(self, self.OnBuyHovered)
  self.WBP_CommonButton_Buy.OnMainButtonUnhovered:Remove(self, self.OnBuyUnhovered)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnRouletteAreaSelectChanged, self, self.OnRouletteAreaSelectChanged)
  EventSystem.RemoveListenerNew(EventDef.Communication.OnCommSelectChanged, self, self.OnCommSelectChanged)
  UE.UWidgetBlueprintLibrary.CancelDragDrop()
end

function CommunicationView:OnHideByOther()
  UE.UWidgetBlueprintLibrary.CancelDragDrop()
end

function CommunicationView:OnFirstGroupCheckStateChanged(SelectId)
  print("OnFirstGroupCheckStateChanged", SelectId)
  self.viewModel:UpdateCurSelectCommunicationToggle(SelectId)
  if SelectId == ECommunicationToggleStatus.Spray then
    self:PlayAnimation(self.Ani_CanvasSpray_in)
  elseif SelectId == ECommunicationToggleStatus.Voice then
    self:PlayAnimation(self.Ani_CanvasVoice_in)
  end
end

function CommunicationView:OnCurSelectCommunicationToggleUpdate(CurSelectCommunicationToggle)
  self.RGToggleGroupFirst:SelectId(CurSelectCommunicationToggle)
  UpdateVisibility(self.Canvas_SprayPreview, false)
  if CurSelectCommunicationToggle == ECommunicationToggleStatus.Spray then
    self.TileView_Spray:ScrollToTop()
    UpdateVisibility(self.Canvas_Spray, true)
    UpdateVisibility(self.Canvas_Voice, false)
  elseif CurSelectCommunicationToggle == ECommunicationToggleStatus.Voice then
    self.SclBox_Voice:ScrollToStart()
    UpdateVisibility(self.Canvas_Spray, false)
    UpdateVisibility(self.Canvas_Voice, true)
  end
  self:StopVoice()
  self:InitAppearanceActorByToggle(CurSelectCommunicationToggle)
end

function CommunicationView:SelectSpray(CommId)
  self.viewModel:UpdateCurSelectSpary(CommId)
end

function CommunicationView:SelectVoice(CommId)
  self.viewModel:UpdateCurSelectVoice(CommId)
  self:PlayVoiceByRouletteId(CommunicationData.GetRoulleteIdByCommId(CommId))
end

function CommunicationView:OnCurHeroIdUpdate(CurHeroId)
  if -1 == CurHeroId then
    return
  end
  self.WBP_Roulette:InitByHeroId(CurHeroId)
  self.WBP_RedDotViewSpray:ChangeRedDotIdByTag(CurHeroId)
  self.WBP_RedDotViewVoice:ChangeRedDotIdByTag(CurHeroId)
end

function CommunicationView:OnShowSprayDataUpdate(ShowSprayData)
  if not ShowSprayData.SprayList then
    return
  end
  self.TileView_Spray:RecyleAllData()
  local TileViewAry = UE.TArray(UE.UObject)
  TileViewAry:Reserve(#ShowSprayData.SprayList)
  local unlockSprayNum = 0
  for i, v in ipairs(ShowSprayData.SprayList) do
    if self.viewModel:CheckIsShow(v) then
      local DataObj = self.TileView_Spray:GetOrCreateDataObj()
      TileViewAry:Add(DataObj)
      DataObj.CommId = v.ID
      DataObj.bIsUnlocked = v.bIsUnlocked
      DataObj.bIsEquiped = v.bIsEquiped
      DataObj.bIsSelected = v.bIsSelected
      DataObj.ParentView = self
      DataObj.expireAt = CommunicationData.ExpireAtData[CommunicationData.GetRoulleteIdByCommId(v.ID)]
      if v.bIsUnlocked then
        unlockSprayNum = unlockSprayNum + 1
      end
    end
  end
  self.TileView_Spray:SetRGListItems(TileViewAry, true, true)
  self.WBP_ToggleSpray:InitSkinToggle(unlockSprayNum, #ShowSprayData.SprayList)
  if self.viewModel.CurSelectCommunicationToggle == ECommunicationToggleStatus.Spray then
    UpdateVisibility(self.Canvas_Spray, #ShowSprayData.SprayList > 0)
  end
end

function CommunicationView:OnShowVoiceDataUpdate(ShowVoiceData)
  if not ShowVoiceData.VoiceList then
    return
  end
  local unlockVoiceNum = 0
  for i, v in ipairs(ShowVoiceData.VoiceList) do
    local voiceItem = GetOrCreateItem(self.SclBox_Voice, i, self.WBP_VoiceItem:GetClass())
    local DataObj = {}
    DataObj.CommId = v.ID
    DataObj.bIsUnlocked = v.bIsUnlocked
    DataObj.bIsEquiped = v.bIsEquiped
    DataObj.bIsSelected = v.bIsSelected
    DataObj.ParentView = self
    DataObj.expireAt = CommunicationData.ExpireAtData[CommunicationData.GetRoulleteIdByCommId(v.ID)]
    if v.bIsUnlocked then
      unlockVoiceNum = unlockVoiceNum + 1
    end
    voiceItem:InitVoiceItem(DataObj)
  end
  HideOtherItem(self.SclBox_Voice, #ShowVoiceData.VoiceList + 1)
  self.WBP_ToggleVoice:InitSkinToggle(unlockVoiceNum, #ShowVoiceData.VoiceList)
  if self.viewModel.CurSelectCommunicationToggle == ECommunicationToggleStatus.Voice then
    UpdateVisibility(self.Canvas_Voice, #ShowVoiceData.VoiceList > 0)
  end
end

function CommunicationView:OnCurSelectSparyIdUpdate(CurSelectSparyId)
  if -1 == CurSelectSparyId or self.viewModel.CurSelectCommunicationToggle ~= ECommunicationToggleStatus.Spray then
    return
  end
  local sprayData = self.viewModel:GetSprayDataByCommId(CurSelectSparyId)
  if not sprayData then
    return
  end
  ComInitProEff(CurSelectSparyId, self.WBP_ComNameProEff)
  self.Txt_DetailsName:SetText(sprayData.RowInfo.Name)
  self.Txt_DetailsDesc:SetText(sprayData.RowInfo.Desc)
  UpdateVisibility(self.TXT_SpecialText, sprayData.RowInfo.SpecialText ~= "")
  UpdateVisibility(self.Img_BgIcon, "" ~= sprayData.RowInfo.SpecialBgIcon)
  self.TXT_SpecialText:SetText(sprayData.RowInfo.SpecialText)
  SetImageBrushByPath(self.Img_BgIcon, sprayData.RowInfo.SpecialBgIcon)
  self.WBP_SprayPreviewItem:InitSprayPreviewItemById(CurSelectSparyId)
  local result, itemRarityRow = GetRowData(DT.DT_ItemRarity, tostring(sprayData.Rare))
  if result then
    self.Txt_Tag:SetText(itemRarityRow.DisplayName)
    self.Img_Tag:SetColorAndOpacity(itemRarityRow.SkinRareBgColor)
  end
  self:UpdateBuyButton(sprayData)
  local SprayIndex = self.viewModel:GetSprayIndexById(CurSelectSparyId)
  if -1 ~= SprayIndex then
    if self.TileView_Spray:IsRefreshPending() then
      UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
        GameInstance,
        function()
          self.TileView_Spray:NavigateToIndex(SprayIndex - 1)
        end
      })
    else
      self.TileView_Spray:NavigateToIndex(SprayIndex - 1)
    end
  end
  local ExpireAtData = CommunicationData.ExpireAtData[CommunicationData.GetRoulleteIdByCommId(CurSelectSparyId)]
  UpdateVisibility(self.WBP_CommonExpireAt, nil ~= ExpireAtData and "0" ~= ExpireAtData)
  self.WBP_CommonExpireAt:InitCommonExpireAt(ExpireAtData)
end

function CommunicationView:OnCurSelectVoiceIdUpdate(CurSelectVoiceId)
  if -1 == CurSelectVoiceId or self.viewModel.CurSelectCommunicationToggle ~= ECommunicationToggleStatus.Voice then
    return
  end
  local voiceData = self.viewModel:GetVoiceDataByCommId(CurSelectVoiceId)
  if not voiceData then
    return
  end
  self.Txt_DetailsName:SetText(voiceData.RowInfo.Name)
  self.Txt_DetailsDesc:SetText(voiceData.RowInfo.Desc)
  UpdateVisibility(self.TXT_SpecialText, voiceData.RowInfo.SpecialText ~= "")
  UpdateVisibility(self.Img_BgIcon, "" ~= voiceData.RowInfo.SpecialBgIcon)
  self.TXT_SpecialText:SetText(voiceData.RowInfo.SpecialText)
  SetImageBrushByPath(self.Img_BgIcon, voiceData.RowInfo.SpecialBgIcon)
  local result, itemRarityRow = GetRowData(DT.DT_ItemRarity, tostring(voiceData.Rare))
  if result then
    self.Txt_Tag:SetText(itemRarityRow.DisplayName)
    self.Img_Tag:SetColorAndOpacity(itemRarityRow.SkinRareBgColor)
  end
  self:UpdateBuyButton(voiceData)
  local VoiceIndex = self.viewModel:GetVoiceIndexById(CurSelectVoiceId)
  if -1 ~= VoiceIndex then
    local TargetItem = self.SclBox_Voice:GetChildAt(VoiceIndex - 1)
    if TargetItem then
      self.SclBox_Voice:ScrollWidgetIntoView(TargetItem)
    end
  end
  local ExpireAtData = CommunicationData.ExpireAtData[CommunicationData.GetRoulleteIdByCommId(CurSelectVoiceId)]
  UpdateVisibility(self.WBP_CommonExpireAt, nil ~= ExpireAtData and "0" ~= ExpireAtData)
  self.WBP_CommonExpireAt:InitCommonExpireAt(ExpireAtData)
end

function CommunicationView:UpdateBuyButton(commData)
  if not commData then
    return
  end
  if commData.RowInfo.LinkId and commData.RowInfo.LinkId ~= "" then
    self:InitBuyPanel(commData.RowInfo.LinkId, commData.RowInfo.ParamList[2], commData.bIsUnlocked, commData.RowInfo.LinkDesc)
  else
    UpdateVisibility(self.CanvasPanelBuy, false)
  end
end

function CommunicationView:InitBuyPanel(LinkId, GoodsId, bUnlocked, AccessDesc)
  if bUnlocked then
    UpdateVisibility(self.CanvasPanelBuy, false)
    return
  end
  UpdateVisibility(self.CanvasPanelBuy, true)
  UpdateVisibility(self.WBP_Price, false)
  if tonumber(LinkId) == nil or 0 == tonumber(LinkId) then
    self.WBP_CommonButton_Buy:SetStyleByBottomStyleRowName("UnAccess")
  elseif tonumber(LinkId) == 1007 then
    self.WBP_CommonButton_Buy:SetStyleByBottomStyleRowName("Buy")
    self.WBP_CommonButton_Buy:SetInfoText(AccessDesc)
    self.WBP_CommonButton_Buy:SetContentText("")
    local TBMall = LuaTableMgr.GetLuaTableByName(TableNames.TBMall)
    if TBMall[GoodsId] then
      local GoodsInfo = TBMall[GoodsId]
      UpdateVisibility(self.WBP_Price, true)
      self.WBP_Price:SetPrice(GoodsInfo.ConsumeResources[1].z, GoodsInfo.ConsumeResources[1].y, GoodsInfo.ConsumeResources[1].x)
    end
  else
    self.WBP_CommonButton_Buy:SetStyleByBottomStyleRowName("Access")
    self.WBP_CommonButton_Buy:SetContentText(AccessDesc)
  end
end

function CommunicationView:OnBuyClick()
  local curCommData = self.viewModel:GetCurCommData()
  if self:LinkPurchaseConfirm(curCommData.RowInfo.LinkId, curCommData.RowInfo.ParamList) then
    return
  end
  local result, row = GetRowData(DT.DT_CommonLink, curCommData.RowInfo.LinkId)
  if result then
    local callback = function()
      if row.bHideOther then
        local AppearanceActorTemp = GetAppearanceActor(self)
        self.AppearanceActor:UpdateActived(false, true, false)
      end
    end
    if curCommData.RowInfo.LinkId ~= "9999" then
      local luaInst = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
      if UE.RGUtil.IsUObjectValid(luaInst) then
        luaInst:ListenForEscInputAction()
      end
      EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, "LobbyLabel.LobbyMain")
      callback = nil
    end
    if ViewID[row.UIName] == ViewID.UI_DevelopMain then
      ComLink(curCommData.RowInfo.LinkId, callback, self.viewModel.CurHeroId, self.viewModel.CurHeroId)
    else
      local ExtraData = {}
      ExtraData.HeroId = self.viewModel.CurHeroId
      ComLinkForParam(curCommData.RowInfo.LinkId, callback, curCommData.RowInfo.ParamList, ExtraData)
    end
  end
end

function CommunicationView:OnBuyHovered()
  self:StopAnimation(self.Ani_hover_out)
  self:PlayAnimation(self.Ani_hover_in, 0)
end

function CommunicationView:OnBuyUnhovered()
  self:StopAnimation(self.Ani_hover_in)
  self:PlayAnimation(self.Ani_hover_out, 0)
end

function CommunicationView:LinkPurchaseConfirm(LinkId, ParamList)
  if tonumber(LinkId) ~= 1007 then
    return false
  end
  ComLink(LinkId, nil, ParamList[2], ParamList[1], 1)
  return true
end

function CommunicationView:OnRollback()
  self:RebackView()
end

function CommunicationView:RebackView()
  self:InitAppearanceActorByToggle(self.viewModel.CurSelectCommunicationToggle)
end

function CommunicationView:EscView()
  local luaInst = UIMgr:GetLuaFromActiveView(ViewID.UI_Apearance)
  if UE.RGUtil.IsUObjectValid(luaInst) then
    luaInst:ListenForEscInputAction()
  end
end

function CommunicationView:OnRouletteAreaSelectChanged(SlotId)
  local rouletteId = self.viewModel:GetRouletteIdBySlotId(SlotId)
  self:PlayVoiceByRouletteId(rouletteId)
end

function CommunicationView:OnCommSelectChanged(CommId)
  self:PlayAnimation(self.Ani_cut)
end

function CommunicationView:PlayVoiceByRouletteId(RouletteId)
  local Result, CommunicationRowInfo = GetRowData(DT.DT_CommunicationWheel, RouletteId)
  self:StopVoice()
  if Result and CommunicationRowInfo.AudioRowName ~= "None" then
    self.PlayingVoiceId = PlayVoiceByRowName(CommunicationRowInfo.AudioRowName, self.AppearanceActor, SkinData.GetEquipedSkinIdByHeroId(self.viewModel.CurHeroId))
  end
end

function CommunicationView:StopVoice()
  if self.PlayingVoiceId then
    UE.URGBlueprintLibrary.StopVoice(self.PlayingVoiceId)
    self.PlayingVoiceId = nil
  end
end

function CommunicationView:OnIsEmptyShowListUpdate(IsEmptyShowList)
  UpdateVisibility(self.Canvas_Details, not IsEmptyShowList)
  UpdateVisibility(self.Canvas_Empty, IsEmptyShowList)
end

function CommunicationView:OnRedDotIdListUpdate(RedDotIdList)
  self.WBP_RedDotClearButtonView:UpdateRedDotIdList(RedDotIdList)
end

function CommunicationView:InitAppearanceActorByToggle(CommunicationToggle)
  if CommunicationToggle == ECommunicationToggleStatus.Spray then
    if UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
      self.AppearanceActor:UpdateActived(false, true)
    end
    LogicLobby.ShowOrHideGround(false)
    UpdateVisibility(self.Canvas_SprayPreview, true)
  elseif CommunicationToggle == ECommunicationToggleStatus.Voice then
    if UE.RGUtil.IsUObjectValid(self.AppearanceActor) then
      local WeaponResId = DataMgr.GetShowWeaponId(self.viewModel.CurHeroId)
      self.AppearanceActor:InitAppearanceActor(self.viewModel.CurHeroId, SkinData.GetEquipedSkinIdByHeroId(self.viewModel.CurHeroId), SkinData.GetEquipedWeaponSkinIdByWeaponResId(WeaponResId))
      self.AppearanceActor:UpdateActived(true)
    end
    LogicLobby.ShowOrHideGround(true)
  end
end

return CommunicationView
