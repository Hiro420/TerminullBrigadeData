local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local MainTaskDialogueView = Class(ViewBase)

function MainTaskDialogueView:BindClickHandler()
end

function MainTaskDialogueView:UnBindClickHandler()
end

function MainTaskDialogueView:OnInit()
  self.DataBindTable = {}
  self:BindClickHandler()
end

function MainTaskDialogueView:OnDestroy()
  self:UnBindClickHandler()
end

function MainTaskDialogueView:OnShow(DialogueId)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.DialogueId = DialogueId
  local Result, RowInfo = GetRowData("MainTaskDialogue", DialogueId)
  if Result then
    self.DialogueContent = RowInfo.DialogueContent
    self.Index = 1
    UpdateVisibility(self.Image_npcbg2, RowInfo.bShowBg)
    UpdateVisibility(self.Image_npcbg, RowInfo.bShowBg)
    UpdateVisibility(self.URGImage_16, RowInfo.bShowBg)
    UpdateVisibility(self.URGImage_100, RowInfo.bShowBg)
  end
  self.NPCDynamicMaterial = self.Image_NPC:GetDynamicMaterial()
  self.PlayerName = DataMgr.GetBasicInfo().nickname
  self:ShowDialogueChild(self.Index)
  Logic_MainTask.CacheDialogueId(DialogueId)
  ListenForInputAction("PauseGame", UE.EInputEvent.IE_Pressed, true, {
    self,
    MainTaskDialogueView.PauseGame
  })
  ListenForInputAction(self.CloseKey, UE.EInputEvent.IE_Pressed, true, {
    self,
    MainTaskDialogueView.StartTimer
  })
  ListenForInputAction(self.CloseKey, UE.EInputEvent.IE_Released, true, {
    self,
    MainTaskDialogueView.ReleasTimer
  })
  self.WBP_InteractTipWidget.OnMainButtonClicked:Add(self, function()
    self:PlayAnimation(self.ani_out)
    self:StopAnimation(self.ani_loop)
  end)
  self:StopAllAnimations()
  self:PlayAnimation(self.ani_in, 0)
end

function MainTaskDialogueView:ReleasTimer()
  UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdataTimer)
  self.WBP_InteractTipWidget:UpdateProgress(0)
end

function MainTaskDialogueView:PauseGame()
  print("PauseGame")
end

function MainTaskDialogueView:StartTimer()
  self.Progress = 0
  self.UpdataTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.Progress = self.Progress + 0.02
      self.WBP_InteractTipWidget:UpdateProgress(self.Progress)
      if self.Progress >= 1 then
        self:StopAllAnimations()
        self:PlayAnimation(self.ani_out)
        UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdataTimer)
      end
    end
  }, 0.02, true)
end

function MainTaskDialogueView:OnHide()
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  StopListeningForInputAction(self, self.CloseKey, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, self.CloseKey, UE.EInputEvent.IE_Released)
  StopListeningForInputAction(self, "PauseGame", UE.EInputEvent.IE_Pressed)
end

function MainTaskDialogueView:ShowDialogueChild(Index)
  if self.DialogueContent == nil or Index > self.DialogueContent:Num() then
    self:PlayAnimation(self.ani_out)
    self:StopAnimation(self.ani_loop)
    return
  end
  if not self.DialogueContent:IsValidIndex(Index) then
    print("ERROR : DialogueId , Index", self.DialogueId, Index)
    return
  end
  local Info = self.DialogueContent:GetRef(Index)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(Info.Background) then
    SetImageBrushByTexture2DSoftObject(self.Image_Bg, Info.Background)
  end
  UpdateVisibility(self.Image_NPC, false)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(Info.NPCPaint) then
    local Texture = GetAssetBySoftObjectPtr(Info.NPCPaint, true)
    if self.NPCDynamicMaterial and Texture then
      UpdateVisibility(self.Image_NPC, true)
      self.NPCDynamicMaterial:SetTextureParameterValue("renwu", Texture)
    end
  end
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(Info.PlayerPaint) then
    SetImageBrushBySoftObject(self.Image_Player, Info.PlayerPaint)
  end
  if Info.SperkerName == "{name}" then
    Info.SperkerName = self.PlayerName
  end
  self.SpeakerName:SetText(Info.SperkerName)
  self.Content:SetText(Info.ContrntString)
  if Index == self.DialogueContent:Num() then
    self.ShowText:SetText("\231\130\185\229\135\187\229\133\179\233\151\173")
  else
    self.ShowText:SetText("\231\130\185\229\135\187\231\187\167\231\187\173")
  end
end

function MainTaskDialogueView:OnMouseButtonDown(MyGeometry, MouseEvent)
  if self:IsAnimationPlaying(self.ani_out) or self:IsAnimationPlaying(self.ani_in) then
    return
  end
  if UE.UKismetInputLibrary.PointerEvent_GetEffectingButton(MouseEvent) == self.LeftMouseButton then
    self.Index = self.Index + 1
    self:ShowDialogueChild(self.Index)
  end
end

function MainTaskDialogueView:CloseMainTaskDialogueView()
  if self.UpdataTimer then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdataTimer)
  end
  self.UpdataTimer = nil
  UIMgr:Hide(ViewID.UI_MainTaskDialogueView)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnLobbyShow)
end

function MainTaskDialogueView:OnAnimationFinished(Animation)
  if Animation == self.ani_out then
    self:CloseMainTaskDialogueView()
  end
  if Animation == self.ani_in then
    self:PlayAnimation(self.ani_loop, 0, 0)
  end
end

return MainTaskDialogueView
