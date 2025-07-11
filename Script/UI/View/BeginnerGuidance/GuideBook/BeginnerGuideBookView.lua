local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local BeginnerGuideHandler = require("Protocol.BeginnerGuide.BeginnerGuideHandler")
local BeginnerGuideBookView = Class(ViewBase)
function BeginnerGuideBookView:OnBindUIInput()
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    BeginnerGuideBookView.OnEscInputAction
  })
  self.WBP_InteractTipWidgetPrev:BindInteractAndClickEvent(self, self.LastGuide)
  self.WBP_InteractTipWidgetNext:BindInteractAndClickEvent(self, self.NextGuide)
end
function BeginnerGuideBookView:OnUnBindUIInput()
  StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
  self.WBP_InteractTipWidgetPrev:UnBindInteractAndClickEvent(self, self.LastGuide)
  self.WBP_InteractTipWidgetNext:UnBindInteractAndClickEvent(self, self.NextGuide)
end
function BeginnerGuideBookView:BindClickHandler()
  self.BP_ButtonWithSoundEsc.OnClicked:Add(self, self.OnEscInputAction)
  self.Button_Last.OnClicked:Add(self, self.LastGuide)
  self.Button_Last.OnHovered:Add(self, self.OnLastHovered)
  self.Button_Last.OnUnhovered:Add(self, self.OnLastUnhovered)
  self.Button_Next.OnClicked:Add(self, self.NextGuide)
  self.Button_Next.OnHovered:Add(self, self.OnNextHovered)
  self.Button_Next.OnUnhovered:Add(self, self.OnNextUnhovered)
  EventSystem.AddListener(self, EventDef.BeginnerGuide.OnBeginnerGuideBookGuideChanged, BeginnerGuideBookView.BindOnBeginnerGuideBookGuideChanged)
  EventSystem.AddListener(self, EventDef.BeginnerGuide.OnBeginnerGuideBookTypeChanged, BeginnerGuideBookView.BindOnBeginnerGuideBookTypeChanged)
  EventSystem.AddListener(self, EventDef.BeginnerGuide.OnGetFinishedGuideList, BeginnerGuideBookView.OnFinishedGuideListChange)
end
function BeginnerGuideBookView:UnBindClickHandler()
  self.BP_ButtonWithSoundEsc.OnClicked:Remove(self, self.OnEscInputAction)
  self.Button_Last.OnClicked:Remove(self, self.LastGuide)
  self.Button_Last.OnHovered:Remove(self, self.OnLastHovered)
  self.Button_Last.OnUnhovered:Remove(self, self.OnLastUnhovered)
  self.Button_Next.OnClicked:Remove(self, self.NextGuide)
  self.Button_Next.OnHovered:Remove(self, self.OnNextHovered)
  self.Button_Next.OnUnhovered:Remove(self, self.OnNextUnhovered)
  EventSystem.RemoveListener(EventDef.BeginnerGuide.OnBeginnerGuideBookGuideChanged, BeginnerGuideBookView.BindOnBeginnerGuideBookGuideChanged, self)
  EventSystem.RemoveListener(EventDef.BeginnerGuide.OnBeginnerGuideBookTypeChanged, BeginnerGuideBookView.BindOnBeginnerGuideBookTypeChanged, self)
  EventSystem.RemoveListener(EventDef.BeginnerGuide.OnGetFinishedGuideList, BeginnerGuideBookView.OnFinishedGuideListChange, self)
end
function BeginnerGuideBookView:OnInit()
  self.DataBindTable = {
    {
      Source = "FinishedGuideList",
      Callback = self.OnFinishedGuideListChange
    }
  }
  self.viewModel = UIModelMgr:Get("BeginnerGuideBookViewModel")
  self:BindClickHandler()
end
function BeginnerGuideBookView:OnDestroy()
  self:UnBindClickHandler()
end
function BeginnerGuideBookView:OnShow(...)
  local args = {
    ...
  }
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self:UpdateGuideBook()
  if not LogicLobby.IsInit then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return
    end
    SetInputMode_GameAndUIEx(PC, nil, UE.EMouseLockMode.LockAlways)
    PC.bShowMouseCursor = true
  end
end
function BeginnerGuideBookView:OnHide()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  if not LogicLobby.IsInit then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if not PC then
      return
    end
    UE.UWidgetBlueprintLibrary.SetInputMode_GameOnly(PC)
    PC.bShowMouseCursor = false
  end
end
function BeginnerGuideBookView:OnEscInputAction()
  UIMgr:Hide(ViewID.UI_BeginnerGuideBookView, true)
end
function BeginnerGuideBookView:OnFinishedGuideListChange(FinishedGuideList)
  self.FinishedGuideList = FinishedGuideList
  self:UpdateGuideBook()
end
function BeginnerGuideBookView:UpdateGuideBook()
  self:UpdateGuideTypeItemList()
end
function BeginnerGuideBookView:UpdateGuideItemList()
  local TotalGuideTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)
  local index = 0
  local HasSelected = false
  for _, GuideInfo in pairs(TotalGuideTable) do
    if 1 == GuideInfo.intohandbook and GuideInfo.type == self.GuideTypeId then
      index = index + 1
      local GuideGroupItem = GetOrCreateItem(self.ScrollBox_GuidItemList, index, self.WBP_BeginnerGuideBookListItemView:GetClass())
      GuideGroupItem:Init(GuideInfo.id, self)
      if self.viewModel:CheckGuideFinished(GuideInfo.id) or 4 == GuideInfo.guidetype then
        GuideGroupItem:SetVisibility(UE.ESlateVisibility.Visible)
        if false == HasSelected then
          HasSelected = true
          EventSystem.Invoke(EventDef.BeginnerGuide.OnBeginnerGuideBookGuideChanged, GuideInfo.id)
        end
      else
        GuideGroupItem:SetVisibility(UE.ESlateVisibility.Collapsed)
      end
    end
  end
  HideOtherItem(self.ScrollBox_GuidItemList, index + 1)
end
function BeginnerGuideBookView:UpdateGuideTypeItemList()
  local TotalGuideTypeTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGuidebooktype)
  local index = 0
  for _, GuideTypeInfo in pairs(TotalGuideTypeTable) do
    index = index + 1
    local GuideTypeItem = GetOrCreateItem(self.ScrollBox_GuideTypeItemList, index, self.WBP_BeginnerGuideBookListTypeItemView:GetClass())
    GuideTypeItem:Init(GuideTypeInfo.id, self)
    if 1 == index then
      EventSystem.Invoke(EventDef.BeginnerGuide.OnBeginnerGuideBookTypeChanged, GuideTypeInfo.id)
    end
  end
  HideOtherItem(self.ScrollBox_GuideTypeItemList, index + 1)
end
function BeginnerGuideBookView:NextGuide()
  local NextGuideId = self:GetNextGuideId()
  if nil == NextGuideId then
    print("ywtao,\230\178\161\230\156\137\228\184\139\228\184\128\228\184\170\230\140\135\229\188\149\228\186\134")
    return
  end
  self:UpdateInfo(self.GuideId, NextGuideId)
end
function BeginnerGuideBookView:LastGuide()
  local LastGuideId = self:GetLastGuideId()
  if nil == LastGuideId then
    print("ywtao,\230\178\161\230\156\137\228\184\138\228\184\128\228\184\170\230\140\135\229\188\149\228\186\134")
    return
  end
  self:UpdateInfo(self.GuideId, LastGuideId)
end
function BeginnerGuideBookView:UpdateInfo(GuideId, GuideStepId)
  if nil == GuideStepId then
    GuideStepId = self:GetNextGuideId()
  end
  self:UpdateGuideStepInfo(GuideId, GuideStepId)
  self:UpdateButton()
end
function BeginnerGuideBookView:UpdateButton()
  if self:GetLastGuideId() == nil then
    self.RGStateController_Last:ChangeStatus("Disable")
  else
    self.RGStateController_Last:ChangeStatus("Enable")
  end
  if nil == self:GetNextGuideId() then
    self.RGStateController_Next:ChangeStatus("Disable")
  else
    self.RGStateController_Next:ChangeStatus("Enable")
  end
end
function BeginnerGuideBookView:UpdateGuideInfo(GuideId)
  local GuideInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)[GuideId]
  self.RichTextBlock_GuideName:SetText(GuideInfo.name)
  self.RichTextBlock_GuideDes:SetText("")
  self.GuideId = GuideId
  self.GuideStepId = nil
end
function BeginnerGuideBookView:UpdateGuideStepInfo(GuideId, GuideStepId)
  if nil == GuideStepId then
    self.RichTextBlock_GuideName:SetText("\230\156\170\233\133\141\231\189\174\230\140\135\229\188\149\230\173\165\233\170\164\229\144\141")
    self.RichTextBlock_GuideDes:SetText("\230\156\170\233\133\141\231\189\174\230\140\135\229\188\149\230\173\165\233\170\164\229\134\133\229\174\185")
  else
    local GuideInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)[GuideId]
    local GuideStepInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuideStep)[GuideStepId]
    self.RichTextBlock_GuideName:SetText(GuideStepInfo.name)
    self.RichTextBlock_GuideDes:SetText(GuideStepInfo.content)
  end
  self.GuideStepId = GuideStepId
  self.GuideId = GuideId
  self:InitMovie(GuideStepId)
end
function BeginnerGuideBookView:InitMovie(GuideStepId)
  if nil == GuideStepId then
    self.MoviePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ImagePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  self.MediaPlayer:SetLooping(true)
  local GuideStepInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuideStep)[GuideStepId]
  local ObjRef = MakeStringToSoftObjectReference(GuideStepInfo.video)
  local SuccessInitMovie = false
  if ObjRef and UE.UKismetSystemLibrary.IsValidSoftObjectReference(ObjRef) then
    self.MoviePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(ObjRef)
    if Obj and Obj:Cast(UE.UFileMediaSource) then
      self.MediaPlayer:OpenSource(Obj)
      self.MediaPlayer:Rewind()
      SuccessInitMovie = true
    end
  end
  if not SuccessInitMovie then
    self.MoviePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.ImagePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local IconObj = UE.UObject.Load(GuideStepInfo.image)
    if nil == IconObj then
      self.ImagePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
      return
    end
    if IconObj:Cast(UE.UPaperSprite) then
      local BrushIconDraw = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Image:SetBrush(BrushIconDraw)
    elseif IconObj:Cast(UE.UTexture2D) then
      local BrushIconDraw = UE.UWidgetBlueprintLibrary.MakeBrushFromTexture(IconObj, 0, 0)
      self.Img_Image:SetBrush(BrushIconDraw)
    end
  else
    self.ImagePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function BeginnerGuideBookView:BindOnBeginnerGuideBookGuideChanged(GuideId)
  local GuideInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)[GuideId]
  self.GuideId = GuideId
  self.GuideStepId = nil
  self:UpdateInfo(GuideId, nil)
end
function BeginnerGuideBookView:BindOnBeginnerGuideBookTypeChanged(GuideTypeId)
  self.GuideTypeId = GuideTypeId
  self:UpdateGuideItemList()
end
function BeginnerGuideBookView:GetNextGuideId()
  local GuideInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)[self.GuideId]
  if nil == GuideInfo then
    return nil
  end
  if nil == self.GuideStepId then
    return GuideInfo.guidelist[1]
  else
    for index, GuideStepId in pairs(GuideInfo.guidelist) do
      if GuideStepId == self.GuideStepId then
        return GuideInfo.guidelist[index + 1]
      end
    end
  end
end
function BeginnerGuideBookView:GetLastGuideId()
  local GuideInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBGuide)[self.GuideId]
  if self.GuideStepId == nil then
    return nil
  else
    for index, GuideStepId in pairs(GuideInfo.guidelist) do
      if GuideStepId == self.GuideStepId then
        return GuideInfo.guidelist[index - 1]
      end
    end
  end
end
function BeginnerGuideBookView:OnLastHovered()
  self.LastButtonHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function BeginnerGuideBookView:OnLastUnhovered()
  self.LastButtonHoverPanel:SetVisibility(UE.ESlateVisibility.Hidden)
end
function BeginnerGuideBookView:OnNextHovered()
  self.NextButtonHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function BeginnerGuideBookView:OnNextUnhovered()
  self.NextButtonHoverPanel:SetVisibility(UE.ESlateVisibility.Hidden)
end
return BeginnerGuideBookView
