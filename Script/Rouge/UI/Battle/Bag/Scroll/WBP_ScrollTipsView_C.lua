local WBP_ScrollTipsView_C = UnLua.Class()
local ScrollSetTipsItemPath = "/Game/Rouge/UI/Battle/Bag/Scroll/WBP_ScrollSetTipsItem.WBP_ScrollSetTipsItem_C"
local InteractDuration = 0.4
local InteractTimerRate = 0.02

function WBP_ScrollTipsView_C:Construct()
  self.Overridden.Construct(self)
  self.BenchMark = "BenchMark"
end

function WBP_ScrollTipsView_C:ListenForBenchInputAction()
  if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBag then
    self:ListenForBenchInputActionReleased()
    self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      self,
      self.RefreshProgress
    }, InteractTimerRate, true)
    self.StartTime = 0
    self:UpdateProgress(-1)
  elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromPickup then
    if not self:CheckPickUpCanShare() then
      return
    end
    self:ShareAndMarkModify()
  end
end

function WBP_ScrollTipsView_C:ShareAndMarkModify()
  if self:CheckPickUpCanShare() then
    local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
    if not Character or not Character.AttributeModifyComponent then
      return
    end
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return
    end
    local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
    if not PlayerMiscComp then
      return
    end
    PlayerMiscComp:SharePickupAttributeModify(Logic_Scroll.PreOptimalTarget, Character)
    UpdateVisibility(self.ShareAndMarkInteractItem, false)
    local MarkHandle = PC:GetComponentByClass(UE.URGMarkHandle:StaticClass())
    if not MarkHandle then
      return
    end
    local MarkInfo = UE.FMarkInfo()
    MarkInfo.TargetActor = Logic_Scroll.PreOptimalTarget
    MarkInfo.HitLocation = Logic_Scroll.PreOptimalTarget:K2_GetActorLocation()
    MarkInfo.Owner = Character
    MarkHandle:ServerAddMark(MarkInfo)
  end
end

function WBP_ScrollTipsView_C:RefreshProgress()
  if self.StartTime >= InteractDuration then
    if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBag then
      local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
      if Character and Character.AttributeModifyComponent then
        LogicAudio.OnDropReel()
        Character.AttributeModifyComponent:ShareModify(self.AttributeModifyId)
      end
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromPickup and self:CheckPickUpCanShare() then
      local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
      if Character and Character.AttributeModifyComponent then
        local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
        if not PC then
          return
        end
        local PlayerMiscComp = PC:GetComponentByClass(UE.URGPlayerMiscHelper:StaticClass())
        if not PlayerMiscComp then
          return
        end
        PlayerMiscComp:SharePickupAttributeModify(Logic_Scroll.PreOptimalTarget, Character)
        UpdateVisibility(self.ShareAndMarkInteractItem, false)
      end
    end
    self:Reset()
  else
    self.StartTime = self.StartTime + InteractTimerRate
    self:UpdateProgress(self.StartTime / InteractDuration)
  end
end

function WBP_ScrollTipsView_C:ShowBuyTipPanel()
  local AllChildren = self.TipsPanel:GetAllChildren()
  for index, SingleItem in pairs(AllChildren) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_ScrollTipsView_C:CheckPickUpCanShare()
  if not Logic_Scroll.PreOptimalTarget then
    print(" WBP_ScrollTipsView_C:CheckCanShare PreOptimalTarget IsNull")
    return false
  end
  if not Logic_Scroll.PreOptimalTarget.ModifyId then
    print(" WBP_ScrollTipsView_C:CheckCanShare PreOptimalTarget ModifyId IsNull")
    return false
  end
  return not Logic_Scroll.PreOptimalTarget:IsShared()
end

function WBP_ScrollTipsView_C:UpdateProgress(Percent)
  local Mat = self.WBP_ScrollInteractItemShare.RGImageProgress:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue("Percent", Percent)
  end
end

function WBP_ScrollTipsView_C:ListenForBenchInputActionReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
  end
  self:UpdateProgress(-1)
  self.StartTime = 0
end

function WBP_ScrollTipsView_C:InitScrollTipsView(ScrollId, ScrollTipsOpenTypeParam)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    print("WBP_ScrollTipsView_C:InitScrollSetTips not DTSubsystem")
    return nil
  end
  if ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromBag then
    if IsListeningForInputAction(self, self.BenchMark) then
      StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Pressed)
      StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Released)
    end
    if not IsListeningForInputAction(self, self.BenchMark) then
      ListenForInputAction(self.BenchMark, UE.EInputEvent.IE_Pressed, true, {
        self,
        WBP_ScrollTipsView_C.ListenForBenchInputAction
      })
      ListenForInputAction(self.BenchMark, UE.EInputEvent.IE_Released, true, {
        self,
        WBP_ScrollTipsView_C.ListenForBenchInputActionReleased
      })
    end
  elseif ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromPickup and not IsListeningForInputAction(self, self.BenchMark) then
    ListenForInputAction(self.BenchMark, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_ScrollTipsView_C.ListenForBenchInputAction
    })
  end
  self.AttributeModifyId = ScrollId
  self.ScrollTipsOpenType = ScrollTipsOpenTypeParam
  local bIsShowFull = false
  if ScrollTipsOpenTypeParam == EScrollTipsOpenType.EFromPickup then
    bIsShowFull = Logic_Scroll:CheckScrollIsFull()
  end
  UpdateVisibility(self.CanvasPanelFull, bIsShowFull)
  local ResultModify, AttributeModifyRow = DTSubsystem:GetAttributeModifyDataById(ScrollId, nil)
  if ResultModify then
    self.RGTextTitle:SetText(AttributeModifyRow.Name)
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if RGLogicCommandDataSubsystem then
      local InscriptionDesc = GetLuaInscriptionDesc(AttributeModifyRow.Inscription, 1)
      self.RichTextBlockDesc:SetText(InscriptionDesc)
    end
    local ScrollSetTipsItemCls = UE.UClass.Load(ScrollSetTipsItemPath)
    for i, v in iterator(AttributeModifyRow.SetArray) do
      local ScrollSetTipsItem = GetOrCreateItem(self.VerticalBoxScrollSet, i, ScrollSetTipsItemCls)
      ScrollSetTipsItem:InitScrollSetTipsItem(v, ScrollId, self.ScrollTipsOpenType)
    end
    HideOtherItem(self.VerticalBoxScrollSet, AttributeModifyRow.SetArray:Length() + 1)
    if self.ScrollTipsOpenType == EScrollTipsOpenType.EFromBag then
      UpdateVisibility(self.WBP_ScrollInteractItem, false)
      UpdateVisibility(self.ShareAndMarkInteractItem, false)
      UpdateVisibility(self.WBP_ScrollInteractItemShare, true)
      local Text = UE.URGBlueprintLibrary.TextFromStringTable("1005")
      self.WBP_ScrollInteractItemShare.RGTextInteractName:SetText(Text)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromPickup then
      UpdateVisibility(self.WBP_ScrollInteractItem, true)
      UpdateVisibility(self.WBP_ScrollInteractItemShare, false)
      UpdateVisibility(self.ShareAndMarkInteractItem, self:CheckPickUpCanShare())
      local Text = UE.URGBlueprintLibrary.TextFromStringTable("1004")
      self.WBP_ScrollInteractItemShare.RGTextInteractName:SetText(Text)
    elseif self.ScrollTipsOpenType == EScrollTipsOpenType.EFromTeamDamage then
      UpdateVisibility(self.WBP_ScrollInteractItem, false)
      UpdateVisibility(self.ShareAndMarkInteractItem, false)
      UpdateVisibility(self.WBP_ScrollInteractItemShare, false)
    end
  end
  self:BindOnKeyChanged()
  EventSystem.AddListener(self, EventDef.GameSettings.OnKeyChanged, WBP_ScrollTipsView_C.BindOnKeyChanged)
end

function WBP_ScrollTipsView_C:Reset()
  self:ListenForBenchInputActionReleased()
  StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, self.BenchMark, UE.EInputEvent.IE_Released)
  EventSystem.RemoveListener(EventDef.GameSettings.OnKeyChanged, WBP_ScrollTipsView_C.BindOnKeyChanged, self)
end

function WBP_ScrollTipsView_C:Destruct()
  self.Overridden.Destruct(self)
  self:Reset()
end

function WBP_ScrollTipsView_C:BindOnKeyChanged()
  local ScrollInteractItemText, bIsImg = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName("Interact")
  if not bIsImg then
    self.WBP_ScrollInteractItem.RGTextTag:SetText(ScrollInteractItemText)
  end
  local ScrollInteractItemShareText, bIsImg = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(self.BenchMark)
  if not bIsImg then
    self.WBP_ScrollInteractItemShare.RGTextTag:SetText(ScrollInteractItemShareText)
  end
  local ShareAndMarkInteractItemText, bIsImg = LogicGameSetting.GetCurSelectedKeyNameByKeyRowName(self.BenchMark)
  if not bIsImg then
    self.ShareAndMarkInteractItem.RGTextTag:SetText(ShareAndMarkInteractItemText)
  end
end

return WBP_ScrollTipsView_C
