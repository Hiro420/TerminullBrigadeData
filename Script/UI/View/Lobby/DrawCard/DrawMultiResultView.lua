local DrawMultiResultView = UnLua.Class()
local CardItemDataPath = "/Game/Rouge/UI/DrawCard/CardItemData.CardItemData_C"
local MultiDrawTimes = 10
local MinShowRare = 4
local RarityMap = {
  [0] = UE.ERGItemRarity.EIR_Normal,
  [1] = UE.ERGItemRarity.EIR_Excellent,
  [2] = UE.ERGItemRarity.EIR_Rare,
  [3] = UE.ERGItemRarity.EIR_Epic,
  [4] = UE.ERGItemRarity.EIR_Legend,
  [5] = UE.ERGItemRarity.EIR_Immortal
}
function DrawMultiResultView:Construct()
  self.ButtonMultiContinue.OnClicked:Add(self, self.DrawMulti)
  self.PondId = nil
  self.ParentView = nil
  self.ResourceList = nil
  self.ResourceList_Sorted = nil
  self.DrawTimes = 0
  self.bShowRewardFinished = true
end
function DrawMultiResultView:Destruct()
  self.ButtonMultiContinue.OnClicked:Remove(self, self.DrawMulti)
  self.PondId = nil
  self.ParentView = nil
  self.ResourceList = nil
  self.ResourceList_Sorted = nil
  self.DrawTimes = 0
  self.bShowRewardFinished = true
end
function DrawMultiResultView:DrawMulti()
  if self.IsPlayingAnimation then
    return
  end
  if self.ParentView then
    self.ParentView:Draw(MultiDrawTimes)
  end
end
function DrawMultiResultView:Draw(DrawTimes)
  UIModelMgr:Get("DrawCardViewModel"):DrawCard(DrawTimes, self.PondId)
end
function DrawMultiResultView:InitInfo(ResourceList, PondId, SkipAni, ParentView)
  UpdateVisibility(self, true)
  self.CanvasPanelContinue:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.PondId = PondId
  self.ParentView = ParentView
  self.ResourceList = ResourceList
  self.ResourceList_Sorted = DeepCopy(ResourceList)
  UIModelMgr:Get("DrawCardViewModel"):SortResourceList(self.ResourceList_Sorted)
  self.DrawTimes = 0
  self.SkipAni = true
  self.bShowRewardFinished = false
  self.TileViewCard:ClearListItems()
  self:UpdateCost()
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequenceFinished, self.BindOnDrawCardSequenceFinished, self)
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequencePlay, self.BindOnDrawCardSequencePlay, self)
  EventSystem.AddListener(self, EventDef.DrawCard.OnDrawCardSequenceFinished, self.BindOnDrawCardSequenceFinished)
  EventSystem.AddListener(self, EventDef.DrawCard.OnDrawCardSequencePlay, self.BindOnDrawCardSequencePlay)
  self:PlayDrawCardSequence()
  UpdateVisibility(self.Canvas_Converted, false)
end
function DrawMultiResultView:ContinueInitInfo()
  self:ShowNextCard()
end
function DrawMultiResultView:ShowNextCard()
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if self.DrawTimes >= math.min(MultiDrawTimes, #self.ResourceList_Sorted) then
    self:AniFinishedFunc()
    return
  end
  self.DrawTimes = self.DrawTimes + 1
  local Resource = self.ResourceList_Sorted[self.DrawTimes]
  local DataObjCls = UE.UClass.Load(CardItemDataPath)
  local DataObj = NewObject(DataObjCls, self, nil)
  DataObj.ResourceId = Resource.resourceId
  DataObj.Amount = Resource.amount
  DataObj.bDecompose = Resource.decompose
  DataObj.Index = self.DrawTimes
  DataObj.bIsLastCard = self.DrawTimes == MultiDrawTimes
  DataObj.ParentView = self
  if not self.SkipAni then
    if TotalResourceTable[Resource.resourceId].Rare >= MinShowRare then
      DataObj.AniFinished = {
        self,
        function()
          UpdateVisibility(self, false)
          self.ParentView:DrawResultOnce(Resource, self)
        end
      }
    else
      DataObj.AniFinished = {
        self,
        self.ShowNextCard
      }
    end
    self.TileViewCard:AddItem(DataObj)
  else
    DataObj.AniFinished = nil
    self.TileViewCard:AddItem(DataObj)
    if TotalResourceTable[Resource.resourceId].Rare >= MinShowRare then
      UpdateVisibility(self, false)
      self.ParentView:DrawResultOnce(Resource, self)
    else
      self:ShowNextCard()
    end
  end
  if DataObj.bDecompose then
    UpdateVisibility(self.Canvas_Converted, true)
  end
end
function DrawMultiResultView:UpdateCost()
  local CostResId, CostNum, bIsEnough = UIModelMgr:Get("DrawCardViewModel"):GetCost(MultiDrawTimes, self.PondId)
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
  self.WBP_Price_MultiDraw:SetPrice(CostNum, CostNum, CostResId)
  self.WBP_Price_AllCount:SetPrice(CurHaveNum, CurHaveNum, CostResId)
end
function DrawMultiResultView:HideSelf()
  if not self.bShowRewardFinished then
    print("ywtao, \230\156\170\229\174\140\230\136\144\230\137\128\230\156\137\229\165\150\229\138\177\231\154\132\229\177\149\231\164\186\239\188\140\228\184\141\232\131\189\229\133\179\233\151\173")
    return
  end
  self:OnHide()
  EventSystem.Invoke(EventDef.DrawCard.OnChangeDrawCardPoolSelected, self.PondId)
end
function DrawMultiResultView:OnHide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CanvasPanelContinue:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.ParentView = nil
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequenceFinished, self.BindOnDrawCardSequenceFinished, self)
  EventSystem.RemoveListener(EventDef.DrawCard.OnDrawCardSequencePlay, self.BindOnDrawCardSequencePlay, self)
  self:StopAllAnimations()
end
function DrawMultiResultView:AniFinishedFunc()
  self.bShowRewardFinished = true
  UpdateVisibility(self.CanvasPanelContinue, true)
  UpdateVisibility(self, true)
  self.ParentView:ChangeInteractTipWidgetStatus("ShareAndEsc")
  self:PlayAnimationIn()
end
function DrawMultiResultView:BindFadeInFinished()
end
function DrawMultiResultView:BindFadeOutFinished()
end
function DrawMultiResultView:UpdateCardGuarantList(GuarantStrList)
  for _, GuarantStr in pairs(GuarantStrList) do
    local DrawCardGuarantListItem = GetOrCreateItem(self.ScrollBox_GuarantList, _, self.WBP_DrawCardGuarantListItem:GetClass())
    DrawCardGuarantListItem.RGRichTextBlock_Info:SetText(GuarantStr)
  end
  HideOtherItem(self.ScrollBox_GuarantList, #GuarantStrList + 1)
end
function DrawMultiResultView:OnAnimationFinished(Animation)
  if Animation == self.Ani_in then
    self.IsPlayingAnimation = false
  end
end
function DrawMultiResultView:PlayAnimationIn()
  self.IsPlayingAnimation = true
  self:PlayAnimation(self.Ani_in)
end
function DrawMultiResultView:BindOnDrawCardSequenceFinished()
  UpdateVisibility(self, true)
  self.ParentView:ChangeInteractTipWidgetStatus("ShareAndContinue")
  self:ShowNextCard()
end
function DrawMultiResultView:BindOnDrawCardSequencePlay()
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
    local ResourceIndex = self:GetNumberFromActorName(SingleActor:GetName())
    if ResourceIndex then
      ResourceIndex = ResourceIndex - 1
      if ResourceIndex <= #self.ResourceList and ResourceIndex > 0 then
        local Resource = TotalResourceTable[self.ResourceList[ResourceIndex].resourceId]
        local RarityEnum = RarityMap[Resource.Rare]
        SingleActor:ChangeRarity(RarityEnum)
        if MaxRarity < Resource.Rare then
          MaxRarity = Resource.Rare
        end
      end
    end
  end
  local AllLightActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "DrawCardFXItem", nil)
  for i, SingleActor in iterator(AllLightActors) do
    local RarityEnum = RarityMap[MaxRarity]
    SingleActor:ChangeRarity(RarityEnum)
  end
end
function DrawMultiResultView:PlayDrawCardSequence()
  UpdateVisibility(self, false)
  self.ParentView:PlaySeq(self.LevelSequencePath)
end
function DrawMultiResultView:GetNumberFromActorName(ActorName)
  local Number = string.match(ActorName, "%d+")
  return tonumber(Number)
end
return DrawMultiResultView
