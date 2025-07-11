local WBP_HUDRoulette_C = UnLua.Class()
function WBP_HUDRoulette_C:Construct()
  self.Overridden.Construct(self)
  self.CurHoveredArea = 0
end
function WBP_HUDRoulette_C:FocusInput()
  self.Overridden.FocusInput(self)
  local Pawn = self:GetOwningPlayerPawn()
  if not Pawn then
    return
  end
  SetInputIgnore(Pawn, true)
  local InputComp = Pawn:GetComponentByClass(UE.URGCharacterInputHandle:StaticClass())
  InputComp:SetMoveInputIgnored(false)
  self:SetEnhancedInputActionBlocking(true)
end
function WBP_HUDRoulette_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  local PC = self:GetOwningPlayer()
  local Pawn = self:GetOwningPlayerPawn()
  if not PC or not Pawn then
    return
  end
  UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(PC)
  SetInputIgnore(Pawn, false)
  self:SetEnhancedInputActionBlocking(false)
end
function WBP_HUDRoulette_C:Destruct()
  self.Overridden.Destruct(self)
end
function WBP_HUDRoulette_C:OnDisplay()
  self.Overridden.OnDisplay(self)
  local HeroInfo = DataMgr.GetMyHeroInfo()
  print("WBP_HUDRoulette_C:OnDisplay")
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local RouletteSlots = {}
  if Character then
    local WheelComp = Character:GetComponentByClass(UE.URGCommunicationWheelComponent:StaticClass())
    if WheelComp then
      RouletteSlots = WheelComp.Wheel:ToTable()
    end
  end
  if 0 == #RouletteSlots then
    UE.URGBlueprintLibrary.SetTimerForNextTick(GameInstance, {
      GameInstance,
      function()
        RGUIMgr:HideUI(UIConfig.WBP_HUDRoulette_C.UIName)
      end
    })
    return
  end
  for i, v in ipairs(RouletteSlots) do
    print("RouletteSlots", i, v)
  end
  local WBP_Roulette = self.WBP_Roulette
  WBP_Roulette:InitBySlots(RouletteSlots, true)
  WBP_Roulette:PlayAnimationIn()
end
function WBP_HUDRoulette_C:OnUnDisplay()
  self.Overridden.OnUnDisplay(self, true)
  local WBP_Roulette = self.WBP_Roulette
  WBP_Roulette:UseSelectedAreaComm()
  WBP_Roulette:PlayAnimationOut()
end
function WBP_HUDRoulette_C:LuaTick(InDeltaTime)
  self.WBP_Roulette:UpdateAreaCoolDown(InDeltaTime)
end
function WBP_HUDRoulette_C:OnMouseLeave()
  self.WBP_Roulette:OnMouseLeave()
end
function WBP_HUDRoulette_C:OnMouseMove(MyGeometry, MouseEvent)
  self.WBP_Roulette:OnMouseMove(MyGeometry, MouseEvent)
end
return WBP_HUDRoulette_C
