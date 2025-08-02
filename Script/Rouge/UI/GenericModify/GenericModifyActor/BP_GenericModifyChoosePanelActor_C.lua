local BP_GenericModifyChoosePanelActor_C = UnLua.Class()

function BP_GenericModifyChoosePanelActor_C:ReceiveBeginPlay()
  self.Overridden.ReceiveBeginPlay(self)
  self:UpdateActived(false)
  self:UpdateUICaptureBgActor(false)
end

function BP_GenericModifyChoosePanelActor_C:InitGenericModifyChoosePanelActor(InteractComp, Target)
  local ChoosePanel = self.RGWidget:GetWidget()
  if ChoosePanel then
    ChoosePanel:InitGenericModifyChoosePanel(InteractComp, Target)
  end
end

function BP_GenericModifyChoosePanelActor_C:FocusInput()
  self:UpdateActived(true)
  self:UpdateUICaptureBgActor(true)
  local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
  if PC then
    PC:SetViewTargetwithBlend(self.ChildActor.ChildActor)
  end
  local ChoosePanelBg = self.RGWidget1:GetWidget()
  if ChoosePanelBg then
    ChoosePanelBg:FocusInput()
  end
  self.WidgetInteraction.OnHoveredWidgetChanged:Add(self, self.OnHoveredWidgetChanged)
end

function BP_GenericModifyChoosePanelActor_C:OnDisplay()
  local ChoosePanelBg = self.RGWidget1:GetWidget()
  if ChoosePanelBg then
    ChoosePanelBg:OnDisplay()
  end
end

function BP_GenericModifyChoosePanelActor_C:UnfocusInput()
  self:UpdateActived(false)
  self:UpdateUICaptureBgActor(false)
  local ChoosePanel = self.RGWidget:GetWidget()
  if ChoosePanel then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      PC:SetViewTargetwithBlend(ChoosePanel:GetOwningPlayerPawn())
    end
  end
  local ChoosePanelBg = self.RGWidget1:GetWidget()
  if ChoosePanelBg then
    ChoosePanelBg:UnfocusInput()
  end
  self.WidgetInteraction.OnHoveredWidgetChanged:Remove(self, self.OnHoveredWidgetChanged)
end

function BP_GenericModifyChoosePanelActor_C:OnUnDisplay()
  self:UpdateActived(false)
  self:UpdateUICaptureBgActor(false)
  local ChoosePanel = self.RGWidget:GetWidget()
  if ChoosePanel then
    ChoosePanel:OnUnDisplay()
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      PC:SetViewTargetwithBlend(ChoosePanel:GetOwningPlayerPawn())
    end
  end
  local ChoosePanelBg = self.RGWidget1:GetWidget()
  if ChoosePanelBg then
    ChoosePanelBg:OnUnDisplay()
  end
end

function BP_GenericModifyChoosePanelActor_C:OnClose()
  local ChoosePanel = self.RGWidget:GetWidget()
  if ChoosePanel then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      PC:SetViewTargetwithBlend(ChoosePanel:GetOwningPlayerPawn())
    end
  end
  local ChoosePanelBg = self.RGWidget1:GetWidget()
  if ChoosePanelBg then
    ChoosePanelBg:OnClose()
  end
  self:Destroy()
end

function BP_GenericModifyChoosePanelActor_C:FadeOut(RGGenericModifyParam, GroupId)
  local ChoosePanel = self.RGWidget:GetWidget()
  if ChoosePanel then
    ChoosePanel:FadeOut(RGGenericModifyParam, GroupId)
  end
  local ChoosePanelBg = self.RGWidget1:GetWidget()
  if ChoosePanelBg then
    ChoosePanelBg:FadeOut()
  end
end

function BP_GenericModifyChoosePanelActor_C:UpdatePanel(PreviewModifyListParam, InteractComp, HoverFunc, ParentView)
  local ChooseItemList = self.RGWidget:GetWidget()
  if ChooseItemList then
    ChooseItemList:UpdatePanel(PreviewModifyListParam, InteractComp, HoverFunc, ParentView)
  end
  local ChooseItemListBg = self.RGWidget1:GetWidget()
  if ChooseItemListBg then
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if DTSubsystem and InteractComp and InteractComp.GroupId then
      local Result, GenericModifyGroupRow = DTSubsystem:GetGenericModifyGroupDataByName(InteractComp.GroupId, nil)
      if Result then
        ChooseItemListBg:InitGenericModifyBg(GenericModifyGroupRow.RoleDrawing, -1, InteractComp.GroupId)
      end
    else
      local RoleDrawing = self:GetRoleDrawing(ChooseItemListBg)
      ChooseItemListBg:InitGenericModifyBg(RoleDrawing, self:GetTypeId(ChooseItemListBg), -1)
    end
  end
end

function BP_GenericModifyChoosePanelActor_C:UpdateModifyListByShop(PreviewModifyListParam, HoverFunc, ParentView)
  local ChooseItemList = self.RGWidget:GetWidget()
  if ChooseItemList then
    ChooseItemList:UpdateModifyListByShop(PreviewModifyListParam, HoverFunc, ParentView)
  end
  local ChooseItemListBg = self.RGWidget1:GetWidget()
  if ChooseItemListBg then
    if PreviewModifyListParam.bIsUpgrade then
      local RoleDrawing = self:GetRoleDrawing(ChooseItemListBg)
      ChooseItemListBg:InitGenericModifyBg(RoleDrawing, self:GetTypeId(ChooseItemListBg), -1)
    else
      local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
      if DTSubsystem then
        local GroupId = LogicGenericModify:GetGroupIDByFirstModify(PreviewModifyListParam)
        local Result, GenericModifyGroupRow = DTSubsystem:GetGenericModifyGroupDataByName(GroupId, nil)
        if Result then
          ChooseItemListBg:InitGenericModifyBg(GenericModifyGroupRow.RoleDrawing, -1, GroupId)
        end
      end
    end
  end
end

function BP_GenericModifyChoosePanelActor_C:ReceiveEndPlay(EndPlayReason)
  self.Overridden.ReceiveEndPlay(self, EndPlayReason)
  if self.GenericModifyActor then
    self.GenericModifyActor:Destroy()
    self.GenericModifyActor = nil
  end
end

function BP_GenericModifyChoosePanelActor_C:UpdateActived(bIsActived)
  self:SetActorHiddenInGame(not bIsActived)
  self.WidgetInteraction.bEnableHitTesting = bIsActived
  if bIsActived then
    self:UpdateInput(true)
    local CameraManager = UE.UGameplayStatics.GetPlayerCameraManager(self, 0)
    if CameraManager then
      local CameraLocation = CameraManager:GetTargetCameraLocation()
      local CameraRotation = CameraManager:GetTargetCameraRotation()
      local Result = UE.FHitResult()
      self:K2_SetActorLocation(CameraLocation, true, Result, true)
      self:K2_SetActorRotation(CameraRotation, true)
    end
  else
    self:UpdateInput(false)
    local Result = UE.FHitResult()
    self:K2_SetActorLocation(UE.FVector(0, 0, -10000000), true, Result, true)
  end
end

function BP_GenericModifyChoosePanelActor_C:UpdateInput(bEnableInput)
  if bEnableInput then
    self:EnableInput(UE.UGameplayStatics.GetPlayerController(self.RGWidget:GetWidget(), 0))
  else
    self:DisableInput(UE.UGameplayStatics.GetPlayerController(self.RGWidget:GetWidget(), 0))
  end
  local ChooseItemList = self.RGWidget:GetWidget()
  if ChooseItemList then
    ChooseItemList:UpdateInput(bEnableInput)
  end
end

function BP_GenericModifyChoosePanelActor_C:UpdateUICaptureBgActor(bIsShow)
  UpdateUICaptureBgActor(bIsShow)
end

function BP_GenericModifyChoosePanelActor_C:GetTypeId(Widget)
  local Character = Widget:GetOwningPlayerPawn()
  if not Character then
    return -1
  end
  return Character:GetTypeID()
end

function BP_GenericModifyChoosePanelActor_C:GetRoleDrawing(Widget)
  local Character = Widget:GetOwningPlayerPawn()
  if not Character then
    return nil
  end
  local HeroId = Character:GetTypeID()
  local CharacterTable = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if not CharacterTable then
    return nil
  end
  if not CharacterTable[HeroId] then
    return nil
  end
  local SoftObjRef = MakeStringToSoftObjectReference(CharacterTable[HeroId].GenericModifyRole)
  if not UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
    return nil
  end
  return SoftObjRef
end

function BP_GenericModifyChoosePanelActor_C:OnHoveredWidgetChanged(WidgetCom, PreviousWidgetCom)
  if LogicGenericModify.bIsDebug then
    if not UE.RGUtil.IsUObjectValid(WidgetCom) then
      print("BP_GenericModifyChoosePanelActor_C:OnHoveredWidgetChanged WidgetCom Is Nil")
    else
      local displayName = UE.UKismetSystemLibrary.GetDisplayName(WidgetCom)
      print("BP_GenericModifyChoosePanelActor_C:OnHoveredWidgetChanged", displayName)
    end
  end
end

function BP_GenericModifyChoosePanelActor_C:SetCanInput(bCanInput)
  if bCanInput then
    self.WidgetInteraction.InteractionSource = UE.EWidgetInteractionSource.Mouse
  else
    self.WidgetInteraction.InteractionSource = UE.EWidgetInteractionSource.Custom
  end
end

return BP_GenericModifyChoosePanelActor_C
