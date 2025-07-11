local DrawCardData = require("Modules.DrawCard.DrawCardData")
local DrawOnceResultView = UnLua.Class()
local RarityMap = {
  [0] = UE.ERGItemRarity.EIR_Normal,
  [1] = UE.ERGItemRarity.EIR_Excellent,
  [2] = UE.ERGItemRarity.EIR_Rare,
  [3] = UE.ERGItemRarity.EIR_Epic,
  [4] = UE.ERGItemRarity.EIR_Legend,
  [5] = UE.ERGItemRarity.EIR_Immortal
}
local MinShowRare = 4
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end
function DrawOnceResultView:Construct()
  self.ButtonOnce.OnClicked:Add(self, self.DrawContinue)
end
function DrawOnceResultView:Destruct()
  self.ButtonOnce.OnClicked:Remove(self, self.DrawContinue)
  self.ParentView = nil
end
function DrawOnceResultView:UpdateAppearanceActorInfo(ResourceId)
  self.WBP_SkinDetailsItem:ShowOrHideButtonPanel(false)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local WBP_AppearanceMovieList = self.ParentView.WBP_AppearanceMovieList
  if not WBP_AppearanceMovieList and self.ParentView and self.ParentView.ParentView and self.ParentView.ParentView.WBP_AppearanceMovieList then
    WBP_AppearanceMovieList = self.ParentView.ParentView.WBP_AppearanceMovieList
  end
  self.WBP_SkinDetailsItem:UpdateDetailsView(ResourceId, WBP_AppearanceMovieList, self)
  self.WBP_ComShowGoodsItem:ShowItem(ResourceId, true, self)
  if self.WBP_ComShowGoodsItem.bIsDrawCardShow then
    self.WBP_SkinDetailsItem:ChangeStatus("OnlyTitle")
  else
    self.WBP_SkinDetailsItem:ChangeStatus("Normal")
  end
  self:UpdateCost()
  if self.Resource.decompose then
    local DecomposeId, DecomposeNum = DrawCardData:GetDecomposeInfoById(ResourceId)
    if not DecomposeId or not DecomposeNum then
      self.Resource.decompose = false
      print("ywtao, DrawOnceResultView:UpdateAppearanceActorInfo DecomposeId or DecomposeNum is nil")
    else
      self.WBP_Price_Decompose:SetPrice(DecomposeNum, DecomposeNum, DecomposeId)
    end
  end
  UpdateVisibility(self.Canvas_Decompose, self.Resource.decompose)
end
function DrawOnceResultView:InitInfo(Resource, PondId, ParentView)
  UpdateVisibility(self, true)
  self.PondId = PondId
  self.ParentView = ParentView
  self.Resource = Resource
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequenceFinished, self.BindOnDrawCardSequenceFinished, self)
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequencePlay, self.BindOnDrawCardSequencePlay, self)
  EventSystem.AddListener(self, EventDef.DrawCard.OnDrawCardSequenceFinished, self.BindOnDrawCardSequenceFinished)
  EventSystem.AddListener(self, EventDef.DrawCard.OnDrawCardSequencePlay, self.BindOnDrawCardSequencePlay)
  self:InitDrawCardShowInfoByResourceId(Resource.resourceId)
  if self.ParentView and self.ParentView:GetName() == "WBP_DrawMultiResultView" then
    self.Canvas_BtnOnceDraw:SetVisibility(UE.ESlateVisibility.Collapsed)
    if self.ParentView.DrawTimes > 1 then
      self:BindOnDrawCardSequenceFinished()
    end
    UpdateVisibility(self.WBP_LobbyCurrencyList, false)
  else
    self.Canvas_BtnOnceDraw:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:PlayDrawCardSequence()
    UpdateVisibility(self.WBP_LobbyCurrencyList, true)
  end
end
function DrawOnceResultView:UpdateCost()
  local CostResId, CostNum, bIsEnough = UIModelMgr:Get("DrawCardViewModel"):GetCost(1, self.PondId)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ResourceRow = ResourceTable[CostResId]
  local CurHaveNum = 0
  if ResourceRow then
    if ResourceRow.Type == TableEnums.ENUMResourceType.CURRENCY then
      CurHaveNum = DataMgr.GetOutsideCurrencyNumById(CostResId)
    else
      CurHaveNum = DataMgr.GetPackbackNumById(CostResId)
    end
  end
  self.WBP_Price_OnceDraw:SetPrice(CostNum, CostNum, CostResId)
  self.WBP_Price_AllCount:SetPrice(CurHaveNum, CurHaveNum, CostResId)
end
function DrawOnceResultView:HideSelf()
  if self.ParentView and self.ParentView:GetName() ~= "WBP_DrawMultiResultView" then
    EventSystem.Invoke(EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.PondId)
  end
  self:OnHide()
end
function DrawOnceResultView:OnHide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Canvas_BtnOnceDraw:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ParentView = nil
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequenceFinished, self.BindOnDrawCardSequenceFinished, self)
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequencePlay, self.BindOnDrawCardSequencePlay, self)
  local AppearanceActorTemp = GetAppearanceActor(self)
  if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
    self.AppearanceActor:ChangeTransformByIndex(1)
  end
  self.WBP_ComShowGoodsItem:Hide()
  EventSystem.Invoke(EventDef.DrawCard.OnDrawCardShowFinished)
end
function DrawOnceResultView:DrawContinue()
  self.ParentView:Draw(1, function()
    local AppearanceActorTemp = GetAppearanceActor(self)
    if UE.RGUtil.IsUObjectValid(AppearanceActorTemp) then
      self.AppearanceActor:ChangeTransformByIndex(1)
    end
    self.WBP_ComShowGoodsItem:Hide()
    EventSystem.Invoke(EventDef.DrawCard.OnDrawCardShowFinished)
  end)
end
function DrawOnceResultView:PlayAnimationIn()
  self:PlayAnimation(self.Ani_in)
end
function DrawOnceResultView:BindOnDrawCardSequenceFinished()
  UpdateVisibility(self, true)
  if self.ParentView:GetName() ~= "WBP_DrawMultiResultView" then
    self.ParentView:ChangeInteractTipWidgetStatus("ShareAndEsc")
  end
  self:PlayAnimationIn()
  self:UpdateAppearanceActorInfo(self.Resource.resourceId)
end
function DrawOnceResultView:BindOnDrawCardSequencePlay()
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "DrawCardCamera", nil)
  local TargetCamera
  for i, SingleActor in iterator(AllActors) do
    TargetCamera = SingleActor
    break
  end
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    PC:SetViewTargetwithBlend(TargetCamera, 0)
  end
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local AllLightActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "DrawCardLightItem", nil)
  local MaxRarity = 0
  for i, SingleActor in iterator(AllLightActors) do
    local ActorName = tostring(SingleActor:GetName())
    if "BP_DrawCardLightItem" == ActorName then
      local Resource = TotalResourceTable[self.Resource.resourceId]
      local RarityEnum = RarityMap[Resource.Rare]
      SingleActor:ChangeRarity(RarityEnum)
      MaxRarity = Resource.Rare
      break
    end
  end
  local AllLightActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "DrawCardFXItem", nil)
  for i, SingleActor in iterator(AllLightActors) do
    local RarityEnum = RarityMap[MaxRarity]
    SingleActor:ChangeRarity(RarityEnum)
  end
end
function DrawOnceResultView:PlayDrawCardSequence()
  UpdateVisibility(self, false)
  self.ParentView:PlaySeq(self.LevelSequencePath)
end
function DrawOnceResultView:SelectHeroSkin(HeroSkinResId, bUpdateMovie)
  local ResID = GetTbSkinRowNameBySkinID(HeroSkinResId)
  self.WBP_ComShowGoodsItem:SetIsDrawCardShow(false)
  self.WBP_ComShowGoodsItem:InitCharacterSkin(ResID, true)
end
function DrawOnceResultView:SequenceCallBack()
end
function DrawOnceResultView:InitDrawCardShowInfoByResourceId(ResourceId)
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ResourceRow = ResourceTable[ResourceId]
  local bShouldDrawCardShow = false
  if ResourceRow then
    local AppearanceActorTemp = GetAppearanceActor(self)
    if ResourceRow.Type == TableEnums.ENUMResourceType.HeroSkin and ResourceRow.Rare >= MinShowRare then
      local CharacterSkin = Logic_Mall.GetDetailRowDataByResourceId(ResourceId)
      if CharacterSkin then
        local SkinId = CharacterSkin.SkinID
        local seq = LogicRole.GetSkinSequence(SkinId)
        if seq then
          bShouldDrawCardShow = false
        else
          bShouldDrawCardShow = true
        end
      end
    else
      bShouldDrawCardShow = false
    end
  end
  self.WBP_ComShowGoodsItem:SetIsDrawCardShow(bShouldDrawCardShow)
end
return DrawOnceResultView
