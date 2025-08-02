local WBP_Shop_C = UnLua.Class()
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")

function WBP_Shop_C:Construct()
  self.bPlayingAnim = false
  self.Btn_Refresh.OnClicked:Clear()
  self.Btn_Refresh.OnClicked:Add(self, function()
    LogicShop.RefreshShopItem()
  end)
  local BagComp = self:GetOwningPlayer():GetComponentByClass(UE.URGBagComponent:StaticClass())
  if BagComp then
    BagComp.OnBagChanged:Add(self, function()
      self:RefreshRefreshCountInfo()
    end)
  end
  BeginnerGuideData:UpdateWidget("CanvasPanel_Shop_step1", self.CanvasPanel_Shop_step1)
  BeginnerGuideData:UpdateWidget("CanvasPanel_Shop_step2", self.CanvasPanel_Shop_step2)
  BeginnerGuideData:UpdateWidget("CanvasPanel_Shop_step3", self.CanvasPanel_Shop_step3)
  BeginnerGuideData:UpdateWidget("CanvasPanel_Shop_step4", self.CanvasPanel_Shop_step4)
end

function WBP_Shop_C:OnAnimationFinished(Animation)
  self.bPlayingAnim = false
  if self.Ani_out == Animation then
    self:DoClose()
  end
  if self.Ani_in == Animation then
  end
end

function WBP_Shop_C:Destruct()
  print("WBP_Shop_C:Destruct()")
end

function WBP_Shop_C:HiddenInGame(bHidden)
  do return end
  local Pawns = UE.UGameplayStatics.GetAllActorsOfClass(self, UE.ARGCharacterBase:StaticClass(), nil)
  for key, value in pairs(Pawns:ToTable()) do
    value:SetActorHiddenInGame(bHidden)
    local ChildActors = value:GetAttachedActors(nil, true)
    for index, ChildActor in ipairs(ChildActors:ToTable()) do
      ChildActor:SetActorHiddenInGame(bHidden)
    end
  end
end

function WBP_Shop_C:DoClose()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:HideUI(UE.UGameplayStatics.GetObjectClass(self), true)
  for i, Widget in ipairs(self.WBP_Shop_ItemList.ItemWidgets) do
    if Widget and Widget.OnClose then
      Widget:OnClose()
    end
  end
  LogicShop.ClearNPC()
  UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(self:GetOwningPlayer())
  local Pawn = self:GetOwningPlayerPawn()
  if Pawn then
    local InteractComp = Pawn:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
    if InteractComp then
      InteractComp:SetAllInputIgnored(false)
    end
  end
  self:HiddenInGame(false)
  self:StopListeningForAllEnhancedInputActions()
end

function WBP_Shop_C:OnDisplay()
end

function WBP_Shop_C:OnOpen(...)
  local ShopInteractComp = LogicShop.ShopNPC:GetComponentByClass(UE.URGInteractComponent_Shop:StaticClass())
  if ShopInteractComp and ShopInteractComp.ShopType == UE.ERGShopType.Super then
    self.RGStateController_Shop:ChangeStatus("SuperShop")
    self.WBP_Shop_Title.RGStateController_Shop:ChangeStatus("SuperShop")
    self.WBP_Shop_ItemList.RGStateController_Shop:ChangeStatus("SuperShop")
  else
    self.RGStateController_Shop:ChangeStatus("Shop")
    self.WBP_Shop_Title.RGStateController_Shop:ChangeStatus("Shop")
    self.WBP_Shop_ItemList.RGStateController_Shop:ChangeStatus("Shop")
  end
  self.WBP_Shop_Equipment_Props:UpdateScrollList()
  self:RefreshRefreshCountInfo()
  self.WBP_Shop_ItemList:RefreshItemList(LogicShop.GetAllItemInfo())
  if (...) then
    if self.bPlayingAnim then
      return
    end
    self:StopAllAnimations()
    self:PlayAnimation(self.Ani_in)
    self.WBP_Shop_Item_Details:PlayAnimation(self.WBP_Shop_Item_Details.Ani_in)
    self.bPlayingAnim = true
  end
  LogicShop.OpenTimes = LogicShop.OpenTimes + 1
  NotifyObjectMessage(nil, GMP.MSG_Level_Guide_OnShopPanelShow, LogicShop.OpenTimes)
  self.SelRow = 1
  self.SelLine = 1
end

function WBP_Shop_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, WBP_Shop_C.BindOnEscKeyPress)
  self.WBP_InteractTipWidget_1:UnBindInteractAndClickEvent(self, WBP_Shop_C.OnSwitchBag)
  self:SetEnhancedInputActionBlocking(false)
  print("WBP_Shop_C:UnfocusInput")
end

function WBP_Shop_C:FocusInput()
  self.Overridden.FocusInput(self)
  SetInputIgnore(self:GetOwningPlayerPawn(), true)
  self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, WBP_Shop_C.BindOnEscKeyPress, "PauseGame")
  self.WBP_InteractTipWidget_1:BindInteractAndClickEvent(self, WBP_Shop_C.OnSwitchBag, "SwitchBag")
  self:HiddenInGame(true)
  local DefFocusWidget = self.WBP_Shop_ItemList.PowerUp:GetChildAt(0)
  if DefFocusWidget then
    DefFocusWidget:SetFocus()
  end
  self:SetEnhancedInputActionBlocking(true)
  print("WBP_Shop_C:FocusInput")
end

function WBP_Shop_C:RefreshItemDetails(ItemInfo)
  self.WBP_Shop_Item_Details:RefreshItemDetails(ItemInfo)
end

function WBP_Shop_C:RefreshItemPreview(ItemInfo)
  self.WBP_Shop_Preview:RefreshItemPreview(ItemInfo)
end

function WBP_Shop_C:RefreshRefreshCountInfo()
  local CostItemId, CostNum = UE.URGBlueprintLibrary.GetRefreshCost(self, LogicShop.GetCurRefreshCountForPriceCalc() + 1, nil, nil)
  if LogicShop.CanRefreshForFree() then
    CostNum = 0
  end
  self.Txt_CurrencyCost:SetText(tostring(CostNum))
  local RemainCount = LogicShop.GetMaxRefreshCount() - LogicShop.GetCurRefreshCount()
  local RefreshText = NSLOCTEXT("WBP_Shop_C", "Refresh", "\229\136\183\230\150\176({0}/{1})")
  local Text = UE.FTextFormat(RefreshText(), RemainCount, LogicShop.GetMaxRefreshCount())
  self.Txt_RefreshCount:SetText(Text)
  local Color = UE.FSlateColor()
  Color.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  local CanNotRefresh = false
  if RemainCount <= 0 then
    Color.SpecifiedColor = self.CanNotBuyColor
    CanNotRefresh = true
  else
    Color.SpecifiedColor = self.CanBuyColor
  end
  self.Txt_RefreshCount:SetColorAndOpacity(Color)
  if self:IsRefreshCostEnough() then
    Color.SpecifiedColor = self.CanBuyColor
  else
    Color.SpecifiedColor = self.CanNotBuyColor
  end
  self.Txt_CurrencyCost:SetColorAndOpacity(Color)
end

function WBP_Shop_C:IsRefreshCostEnough()
  if LogicShop.CanRefreshForFree() then
    return true
  end
  local CostItemId, CostNum = UE.URGBlueprintLibrary.GetRefreshCost(self, LogicShop.GetCurRefreshCountForPriceCalc() + 1, nil, nil)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if not PC then
    return
  end
  local BagComp = PC:GetComponentByClass(UE.URGBagComponent:StaticClass())
  if not BagComp then
    return
  end
  local BagItemStack = BagComp:GetItemByConfigId(CostItemId)
  return CostNum <= BagItemStack.Stack
end

function WBP_Shop_C:BindOnEscKeyPress()
  if not self.bPlayingAnim then
    self.bPlayingAnim = true
    self:StopAnimation(self.Ani_in)
    self:PlayAnimation(self.Ani_out)
  end
end

function WBP_Shop_C:OnSwitchBag()
  if self:IsPlayingAnimation() then
    return
  end
  if RGUIMgr:IsShown(UIConfig.WBP_MainPanel_C.UIName) then
    RGUIMgr:HideUI(UIConfig.WBP_MainPanel_C.UIName)
  else
    RGUIMgr:OpenUI(UIConfig.WBP_MainPanel_C.UIName, false)
    local MainPanelObj = RGUIMgr:GetUI(UIConfig.WBP_MainPanel_C.UIName)
    if MainPanelObj then
      MainPanelObj:ShowScrollInfoPanel()
    end
  end
end

function WBP_Shop_C:DoCustomNavigation(Navigation)
  if Navigation == UE.EUINavigation.Left then
    self.SelLine = self.SelLine - 1
  elseif Navigation == UE.EUINavigation.Right then
    self.SelLine = self.SelLine + 1
  elseif Navigation == UE.EUINavigation.Up then
    self.SelRow = self.SelRow - 1
  elseif Navigation == UE.EUINavigation.Down then
    self.SelRow = self.SelRow + 1
  end
  return nil
end

function WBP_Shop_C:Bp_InputTypeToGamePadUpdateFocus()
  self.WBP_Shop_ItemList:GamePadUpdateFocus()
end

return WBP_Shop_C
