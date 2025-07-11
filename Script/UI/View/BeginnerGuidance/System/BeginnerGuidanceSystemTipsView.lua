local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local LobbyModule = ModuleManager:Get("LobbyModule")
local BeginnerGuidanceSystemTipsView = Class(ViewBase)
local AreaParamNum = 2
local EscActionName = "PauseGame"
local SkipInteractTimerRate = 0.02
function BeginnerGuidanceSystemTipsView:BindClickHandler()
  self.Button_Next.OnClicked:Add(self, self.OnNextClicked)
  self.Button_Next.OnHovered:Add(self, self.OnNextHovered)
  self.Button_Next.OnUnhovered:Add(self, self.OnNextUnhovered)
  self.Button_Skip.OnClicked:Add(self, self.OnSkipClicked)
  self.Button_Skip.OnHovered:Add(self, self.OnSkipHovered)
  self.Button_Skip.OnUnhovered:Add(self, self.OnSkipUnhovered)
  self.Button_Esc.OnClicked:Add(self, self.OnEscInputAction)
  self.Button_ForceNext.OnClicked:Add(self, self.OnNextClicked)
end
function BeginnerGuidanceSystemTipsView:UnBindClickHandler()
  self.Button_Next.OnClicked:Remove(self, self.OnNextClicked)
  self.Button_Next.OnHovered:Remove(self, self.OnNextHovered)
  self.Button_Next.OnUnhovered:Remove(self, self.OnNextUnhovered)
  self.Button_Skip.OnClicked:Remove(self, self.OnSkipClicked)
  self.Button_Skip.OnHovered:Remove(self, self.OnSkipHovered)
  self.Button_Skip.OnUnhovered:Remove(self, self.OnSkipUnhovered)
  self.Button_Esc.OnClicked:Remove(self, self.OnEscInputAction)
  self.Button_ForceNext.OnClicked:Remove(self, self.OnNextClicked)
end
function BeginnerGuidanceSystemTipsView:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("BeginnerGuidanceSystemTipsViewModel")
  self:BindClickHandler()
  self.TargetWidget = nil
  self.SkipKeyName = "Space"
end
function BeginnerGuidanceSystemTipsView:OnDestroy()
  self:UnBindClickHandler()
end
function BeginnerGuidanceSystemTipsView:OnShow(...)
  local args = {
    ...
  }
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self:InitByGuideStepInfo(args[1])
  self:StopAllAnimations()
  UE.URGBlueprintLibrary.SetTimerForNextTick(self, {
    self,
    function()
      self:PlayAnimation(self.Ani_in)
      for Key, Widget in pairs(self.CanvasPanel_ClickAreas:GetAllChildren()) do
        Widget:PlayInAnim()
      end
    end
  })
  self.CanvasPanel_Skip:SetVisibility(UE.ESlateVisibility.Collapsed)
  if UE.UKismetStringLibrary.IsEmpty(self.GuideStepInfo.TipUIName) and self.TipTimeoutSecond ~= nil then
    if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimeoutAutoFinishNowGuideTimer) then
      UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimeoutAutoFinishNowGuideTimer)
    end
    self.TimeoutAutoFinishNowGuideTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
      GameInstance,
      function()
        print("ywtao,TimeoutAutoFinishNowGuideTimer")
        self.CanvasPanel_Skip:SetVisibility(UE.ESlateVisibility.Visible)
      end
    }, self.TipTimeoutSecond, false)
  end
  if not IsListeningForInputAction(self, self.SkipKeyName) then
    ListenForInputAction(self.SkipKeyName, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnSkipKeyClicked
    })
  end
  self:BindOnEscKeyReleased()
  if self.GuideStepInfo.CanSkip then
    if not IsListeningForInputAction(self, EscActionName) then
      ListenForInputAction(EscActionName, UE.EInputEvent.IE_Pressed, true, {
        self,
        self.BindOnEscKeyPressed
      })
      ListenForInputAction(EscActionName, UE.EInputEvent.IE_Released, true, {
        self,
        self.BindOnEscKeyReleased
      })
    end
  elseif IsListeningForInputAction(self, EscActionName) then
    StopListeningForInputAction(self, EscActionName, UE.EInputEvent.IE_Pressed)
    StopListeningForInputAction(self, EscActionName, UE.EInputEvent.IE_Released)
  end
  UpdateVisibility(self.CanvasPanel_LongPressToSkip, self.GuideStepInfo.CanSkip)
  self:SetEnhancedInputActionBlocking(true)
  self:HideKeyboardUI()
end
function BeginnerGuidanceSystemTipsView:InitByGuideStepInfo(GuideStepInfo)
  self.Des = GuideStepInfo.content
  self.BtnName = tostring(GuideStepInfo.btncontent)
  self.GuideStepInfo = GuideStepInfo
  if #GuideStepInfo.pivot >= 1 then
    self.ContentPivot = {
      x = GuideStepInfo.pivot[1].key,
      y = GuideStepInfo.pivot[1].value
    }
  else
    self.ContentPivot = {x = 100, y = 0}
  end
  if #GuideStepInfo.pos >= 1 then
    self.ContentPos = {
      x = GuideStepInfo.pos[1].key,
      y = GuideStepInfo.pos[1].value
    }
  else
    self.ContentPos = {x = 0, y = 0}
  end
  local AllChildren = self.CanvasPanel_AllTip:GetAllChildren()
  for key, SingleWidget in pairs(AllChildren) do
    UpdateVisibility(SingleWidget, false)
  end
  if UE.UKismetStringLibrary.IsEmpty(self.GuideStepInfo.TipHeadIconPath) then
    UpdateVisibility(self.Img_SubtitleNpcIcon, false)
  else
    UpdateVisibility(self.Img_SubtitleNpcIcon, true)
    SetImageBrushByPath(self.Img_SubtitleNpcIcon, self.GuideStepInfo.TipHeadIconPath)
  end
  self:UpdateTargetWidget()
end
function BeginnerGuidanceSystemTipsView:TryGetAreaInfo()
  local AreaInfoList = {}
  local ScreenScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
  if self:IsValid() == false then
    print("ywtao, BeginnerGuidanceSystemTipsView:TryGetAreaInfo self is not valid!!!")
  end
  local SelfGeometry = self:GetCachedGeometry()
  if next(self.GuideStepInfo.uiname) == nil then
    table.insert(AreaInfoList, {
      Pos = UE.FVector2D(0, 0),
      Size = UE.FVector2D(0, 0)
    })
  else
    for index, SingleWidgetName in ipairs(self.GuideStepInfo.uiname) do
      local Widget = BeginnerGuideData:GetWidget(self.GuideStepInfo.bpname, SingleWidgetName)
      if Widget and Widget:IsValid() then
        local CachedGeometry = Widget:GetCachedGeometry()
        local AbsoluteSize = UE.USlateBlueprintLibrary.GetAbsoluteSize(CachedGeometry)
        local AbsolutePos = UE.URGBlueprintLibrary.GetAbsolutePosition(CachedGeometry)
        local ActiveArea_LocalSize = AbsoluteSize / ScreenScale
        local ActiveArea_LocalPos = UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, AbsolutePos)
        local TempTable = {Pos = ActiveArea_LocalPos, Size = ActiveArea_LocalSize}
        if 0 ~= TempTable.Pos.X or 0 ~= TempTable.Pos.Y or 0 ~= TempTable.Size.X or 0 ~= TempTable.Size.Y then
          table.insert(AreaInfoList, TempTable)
        end
        if self.GuideStepInfo.bRaiseTargetLayer then
          if Widget.UpdateBeginnerGuidArea then
            Widget:UpdateBeginnerGuidArea(self.GuideStepInfo.NotCanClickSelectArea)
          else
            print("chj,Widget.UpdateBeginnerGuidArea is nil", Widget:GetName())
          end
        end
      end
    end
  end
  return AreaInfoList
end
function BeginnerGuidanceSystemTipsView:OnTick()
  if LobbyModule.CurShowViewData ~= nil then
    print("ywtao, \229\189\147\229\137\141\230\156\137\229\188\185\231\170\151\230\152\190\231\164\186\239\188\140\229\188\186\229\136\182\233\128\128\229\135\186\229\189\147\229\137\141\229\188\149\229\175\188" .. UIDef[LobbyModule.CurShowViewData.ViewID].UIBP)
    self:OnEscInputAction()
    return
  end
  self:UpdateTargetWidget()
  local MyGeometry = self:GetCachedGeometry()
  local ScreenMousePos = UE.UWidgetLayoutLibrary.GetMousePositionOnViewport(self)
  UE.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, ScreenMousePos)
  local CanClick = false
  if self.ActiveGuideAreaInfoList then
    for index, SingleAreaInfo in ipairs(self.ActiveGuideAreaInfoList) do
      if ScreenMousePos.X >= SingleAreaInfo.Pos.X and ScreenMousePos.X <= SingleAreaInfo.Pos.X + SingleAreaInfo.Size.X and ScreenMousePos.Y >= SingleAreaInfo.Pos.Y and ScreenMousePos.Y <= SingleAreaInfo.Pos.Y + SingleAreaInfo.Size.Y and not self.GuideStepInfo.NotCanClickSelectArea then
        CanClick = true
      end
    end
  end
  self.CanClick = true
  if self.GuideStepInfo.bRaiseTargetLayer then
    self.Img_BG:SetVisibility(UE.ESlateVisibility.Visible)
  elseif CanClick then
    self.Img_BG:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.Img_BG:SetVisibility(UE.ESlateVisibility.Visible)
  end
end
function BeginnerGuidanceSystemTipsView:OnHide()
  self.viewModel:ClearNowGuideInfo()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  self:SetEnhancedInputActionBlocking(false)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimeoutAutoFinishNowGuideTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimeoutAutoFinishNowGuideTimer)
  end
  if IsListeningForInputAction(self, self.SkipKeyName) then
    StopListeningForInputAction(self, self.SkipKeyName, UE.EInputEvent.IE_Pressed)
  end
  if IsListeningForInputAction(self, EscActionName) then
    StopListeningForInputAction(self, EscActionName, UE.EInputEvent.IE_Pressed)
    StopListeningForInputAction(self, EscActionName, UE.EInputEvent.IE_Released)
  end
  self:BindOnEscKeyReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TryGetTargetWidgetTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TryGetTargetWidgetTimer)
  end
  self:ResetTargetUI()
end
function BeginnerGuidanceSystemTipsView:OnEscInputAction()
  UIMgr:Hide(ViewID.UI_BeginnerGuidanceSystemTips)
end
function BeginnerGuidanceSystemTipsView:OnNextClicked()
  self:StopAnimation(self.Ani_in)
  self:PlayAnimationForward(self.Ani_out)
end
function BeginnerGuidanceSystemTipsView:OnSkipClicked()
  self:ResetTargetUI()
  local IsForce = tostring(self.GuideStepInfo.btncontent) == "" and 1 or 0
  print("ywtao,SendClientLogGuideSkip:" .. tostring(self.GuideStepInfo.id) .. "," .. tostring(self.GuideStepInfo.name) .. "," .. IsForce)
  UE.URGLogLibrary.SendClientLogGuideSkip(GameInstance, tostring(self.GuideStepInfo.id), tostring(self.GuideStepInfo.name), IsForce)
  self.viewModel:FinishNowGuide(true)
  UIMgr:Hide(ViewID.UI_BeginnerGuidanceSystemTips)
end
function BeginnerGuidanceSystemTipsView:ResetTargetUI()
  if next(self.GuideStepInfo.uiname) == nil then
  else
    for index, SingleWidgetName in ipairs(self.GuideStepInfo.uiname) do
      local Widget = BeginnerGuideData:GetWidget(self.GuideStepInfo.bpname, SingleWidgetName)
      if Widget and Widget:IsValid() and Widget.ResetGuidArea then
        Widget:ResetGuidArea(self.GuideStepInfo.NotCanClickSelectArea)
      elseif Widget and Widget:IsValid() and not Widget.ResetGuidArea then
        print("chj,BeginnerGuidanceSystemTipsView Widget.ResetGuidArea is nil", Widget:GetName())
      end
    end
  end
end
function BeginnerGuidanceSystemTipsView:OnNextHovered()
  self:PlayAnimationForward(self.Ani_hover_in)
end
function BeginnerGuidanceSystemTipsView:OnNextUnhovered()
  self:PlayAnimationForward(self.Ani_hover_out)
end
function BeginnerGuidanceSystemTipsView:OnSkipHovered()
  self:PlayAnimationForward(self.Ani_hover_in_skip)
end
function BeginnerGuidanceSystemTipsView:OnSkipUnhovered()
  self:PlayAnimationForward(self.Ani_hover_out_skip)
end
function BeginnerGuidanceSystemTipsView:OnAnimationFinished(Animation)
  if self.Ani_out == Animation then
    self.viewModel:NextGuideStep()
  end
  if self.Ani_in == Animation then
  end
end
function BeginnerGuidanceSystemTipsView:UpdateTargetWidget()
  local AreaInfoList = {
    Pos = UE.FVector2D(0, 0),
    Size = UE.FVector2D(0, 0)
  }
  AreaInfoList = self:TryGetAreaInfo()
  if next(AreaInfoList) == nil then
    self:UpdateActiveAreas({
      {
        Pos = UE.FVector2D(0, 0),
        Size = UE.FVector2D(0, 0)
      }
    })
    local MaxTryCount = 30
    local TryCount = 0
    if not UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TryGetTargetWidgetTimer) then
      self.TryGetTargetWidgetTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
        GameInstance,
        function()
          local TargetAreaInfoList = self:TryGetAreaInfo()
          if next(TargetAreaInfoList) ~= nil then
            UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TryGetTargetWidgetTimer)
            self:UpdateTargetWidget()
          end
          TryCount = TryCount + 1
          if TryCount >= MaxTryCount then
            UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TryGetTargetWidgetTimer)
            self:OnEscInputAction()
            print("ywtao,GetTargetWidget failed")
          end
        end
      }, 0.1, true)
    end
    return
  end
  local TipWidget = self:GetTipWidget()
  if TipWidget then
    TipWidget:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  end
  self.ActiveGuideAreaInfoList = AreaInfoList
  self:UpdateActiveAreas(AreaInfoList)
end
function BeginnerGuidanceSystemTipsView:UpdateActiveAreas(ActiveAreas)
  local ScreenScale = UE.UWidgetLayoutLibrary.GetViewportScale(self)
  local DynamicMaterial = self.Img_BG:GetDynamicMaterial()
  local ParamName = "Area"
  local Index = 1
  for i = 1, #ActiveAreas do
    local ActiveArea = ActiveAreas[i]
    local ActiveArea_LocalPos = ActiveArea.Pos
    local ActiveArea_LocalSize = ActiveArea.Size
    if not self.GuideStepInfo.bRaiseTargetLayer then
      local Vector4d = UE.FLinearColor()
      local X, Y = 0, 0
      Vector4d.R = ActiveArea_LocalPos.X * ScreenScale + X
      Vector4d.G = ActiveArea_LocalPos.Y * ScreenScale + Y
      Vector4d.B = (ActiveArea_LocalPos.X + ActiveArea_LocalSize.X) * ScreenScale + X
      Vector4d.A = (ActiveArea_LocalPos.Y + ActiveArea_LocalSize.Y) * ScreenScale + Y
      DynamicMaterial:SetVectorParameterValue(ParamName .. i, Vector4d)
      Index = Index + 1
      UpdateVisibility(self.CanvasPanel_ClickAreas, true)
      local ClickAreaItem = GetOrCreateItem(self.CanvasPanel_ClickAreas, i, self.ClickAreaTemplate:StaticClass())
      local Slot_Image_CanClickArea = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(ClickAreaItem)
      Slot_Image_CanClickArea:SetPosition(ActiveArea_LocalPos)
      Slot_Image_CanClickArea:SetSize(ActiveArea_LocalSize)
      if self.BtnName ~= "" then
        ClickAreaItem:SetClickAreaType("Hide")
      else
        ClickAreaItem:SetClickAreaType("Normal")
      end
      ClickAreaItem:Show()
    else
      UpdateVisibility(self.CanvasPanel_ClickAreas, false)
    end
    if ActiveArea_LocalSize ~= UE.FVector2D(0, 0) then
      local TipWidget = self:GetTipWidget()
      if TipWidget and UE.UKismetStringLibrary.IsEmpty(self.GuideStepInfo.TipUIName) then
        local Canvas_Tips = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(TipWidget)
        local Canvas_Tips_Size = Canvas_Tips:GetSize()
        Canvas_Tips:SetPosition(UE.FVector2D(ActiveArea_LocalPos.X + ActiveArea_LocalSize.X * self.ContentPivot.x / 100 + self.ContentPos.x * Canvas_Tips_Size.X / 100, ActiveArea_LocalPos.Y + ActiveArea_LocalSize.Y * self.ContentPivot.y / 100 + self.ContentPos.y * Canvas_Tips_Size.Y / 100))
      end
    end
  end
  HideOtherItem(self.CanvasPanel_ClickAreas, #ActiveAreas + 1)
  for i = Index, AreaParamNum do
    local Vector4D = UE.FLinearColor()
    Vector4D.R = 0
    Vector4D.G = 0
    Vector4D.B = 0
    Vector4D.A = 0
    DynamicMaterial:SetVectorParameterValue(ParamName .. i, Vector4D)
  end
  if #ActiveAreas > 0 and self.Des ~= nil then
    self.Text_Des:SetText(self.Des)
    self.Txt_SubtitleDesc:SetText(self.Des)
  end
  if self.BtnName ~= "" then
    self.CanvasPanel_Next:SetVisibility(UE.ESlateVisibility.Visible)
    self.Text_BtnName:SetText(self.BtnName)
  else
    self.CanvasPanel_Next:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function BeginnerGuidanceSystemTipsView:HideKeyboardUI()
  EventSystem.Invoke(EventDef.Lobby.ChangeLobbyMenuPanelVis, false)
  if UIMgr:IsShow(ViewID.UI_GameSettingsMain) then
    print("ywtao,BeginnerGuidanceSystemTipsView:HideKeyboardUI:UI_GameSettingsMain")
    UIMgr:Hide(ViewID.UI_GameSettingsMain, true)
  end
end
function BeginnerGuidanceSystemTipsView:GetTipWidget(...)
  if UE.UKismetStringLibrary.IsEmpty(self.GuideStepInfo.TipUIName) then
    return self.Canvas_Tips
  end
  return self[self.GuideStepInfo.TipUIName]
end
function BeginnerGuidanceSystemTipsView:BindOnSkipKeyClicked()
  print("ywtao,BeginnerGuidanceSystemTipsView:BindOnSkipKeyClicked")
end
function BeginnerGuidanceSystemTipsView:BindOnEscKeyPressed(...)
  self:BindOnEscKeyReleased()
  self.Timer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.RefreshProgress
  }, SkipInteractTimerRate, true)
end
function BeginnerGuidanceSystemTipsView:RefreshProgress()
  if self.StartTime >= self.SkipTime then
    self:OnSkipClicked()
    self:BindOnEscKeyReleased()
  else
    self.StartTime = self.StartTime + SkipInteractTimerRate
    self:UpdateProgress(self.StartTime / self.SkipTime)
  end
end
function BeginnerGuidanceSystemTipsView:UpdateProgress(Percent)
  local Mat = self.URGImageCircle:GetDynamicMaterial()
  if Mat then
    Mat:SetScalarParameterValue("percent", Percent)
  end
end
function BeginnerGuidanceSystemTipsView:BindOnEscKeyReleased(...)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.Timer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.Timer)
    self.Timer = nil
  end
  self:UpdateProgress(0)
  self.StartTime = 0
end
function BeginnerGuidanceSystemTipsView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self.GuideStepInfo.CanClickToNextStep then
    self:OnNextClicked()
  end
  if self.CanClick then
    return UE.UWidgetBlueprintLibrary.UnHandled()
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end
function BeginnerGuidanceSystemTipsView:Destruct(...)
  self:OnHide()
end
return BeginnerGuidanceSystemTipsView
