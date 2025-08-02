local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local ProficiencyHandler = require("Protocol.Proficiency.ProficiencyHandler")
local WBP_ProficiencySynopsisDetailPanel_C = UnLua.Class()
local EscKeyName = "PauseGame"

function WBP_ProficiencySynopsisDetailPanel_C:OnShow(HeroId, Level)
  self.HeroId = HeroId
  self.Level = Level
  local Result, RowInfo = ProficiencyData:GetProficiencyRowInfoByHeroIdAndLevel(HeroId, Level)
  if not Result then
    EventSystem.Invoke(EventDef.Proficiency.OnProficiencySynopsisDetailPanelVisChanged, false, self.HeroId, self.Level)
    return
  end
  ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Pressed, true, {
    self,
    self.OnEscKeyPressed
  })
  ListenForInputAction(EscKeyName, UE.EInputEvent.IE_Released, true, {
    self,
    self.OnEscKeyReleased
  })
  self:PushInputAction()
  self.IsNeedShowReceiveAwardTip = false
  if not ProficiencyData:IsCurProfyStoryRewardReceived(self.HeroId, self.Level) then
    EventSystem.AddListener(self, EventDef.Proficiency.OnGetHeroProfyStoryRewardSuccess, self.BindOnGetHeroProfyStoryRewardSuccess)
    ProficiencyHandler:RequestGetHeroProfyStoryRewardToServer(self.HeroId, self.Level)
  end
  self.WBP_InteractTipWidget:UpdateProgress(0)
  self.Txt_Title:SetText(RowInfo.Name)
  self.RichTextContext = UE.URGBlueprintLibrary.InitRichTextContext(RowInfo.Desc)
  self.CurTextNum = 0
  self.IsFinishPlay = false
  self:PlayDescText()
end

function WBP_ProficiencySynopsisDetailPanel_C:StartPlayDescText()
  if self.CurTextNum > UE.UKismetStringLibrary.Len(self.RichTextContext.PureString) then
    self.IsFinishPlay = true
    UpdateVisibility(self.Img_Loop_triangle, true)
    return
  end
  self.TextDelayTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    self.PlayDescText
  }, self.TextInterval, false)
end

function WBP_ProficiencySynopsisDetailPanel_C:PlayDescText()
  UpdateVisibility(self.Img_Loop_triangle, false)
  local TargetText = UE.URGBlueprintLibrary.GetRichTextSubString(self.RichTextContext, self.CurTextNum)
  self.Txt_Desc:SetText(TargetText .. self.AppendStr)
  self.CurTextNum = self.CurTextNum + 1
  self:StartPlayDescText()
end

function WBP_ProficiencySynopsisDetailPanel_C:OnEscKeyPressed()
  self.CurProgress = 0
  self.UpdateEscKeyPressTimer = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      self.CurProgress = self.CurProgress + 0.02
      self.WBP_InteractTipWidget:UpdateProgress(self.CurProgress)
      if self.CurProgress >= 1 then
        EventSystem.Invoke(EventDef.Proficiency.OnProficiencySynopsisDetailPanelVisChanged, false, self.HeroId, self.Level)
        if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.UpdateEscKeyPressTimer) then
          UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdateEscKeyPressTimer)
        end
      end
    end
  }, 0.02, true)
end

function WBP_ProficiencySynopsisDetailPanel_C:OnEscKeyReleased()
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.UpdateEscKeyPressTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdateEscKeyPressTimer)
  end
  self.WBP_InteractTipWidget:UpdateProgress(0)
end

function WBP_ProficiencySynopsisDetailPanel_C:BindOnEscKeyClicked()
  EventSystem.Invoke(EventDef.Proficiency.OnProficiencySynopsisDetailPanelVisChanged, false, self.HeroId, self.Level)
end

function WBP_ProficiencySynopsisDetailPanel_C:BindOnGetHeroProfyStoryRewardSuccess()
  self.IsNeedShowReceiveAwardTip = true
end

function WBP_ProficiencySynopsisDetailPanel_C:OnMouseButtonDown()
  if self.IsFinishPlay then
    EventSystem.Invoke(EventDef.Proficiency.OnProficiencySynopsisDetailPanelVisChanged, false, self.HeroId, self.Level)
  end
end

function WBP_ProficiencySynopsisDetailPanel_C:OnPreHide(...)
  UpdateVisibility(self, false)
  StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Pressed)
  StopListeningForInputAction(self, EscKeyName, UE.EInputEvent.IE_Released)
  self.WBP_InteractTipWidget.OnMainButtonClicked:Remove(self, self.BindOnEscKeyClicked)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TextDelayTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.TextDelayTimer)
  end
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.UpdateEscKeyPressTimer) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(self, self.UpdateEscKeyPressTimer)
  end
  EventSystem.RemoveListener(EventDef.Proficiency.OnGetHeroProfyStoryRewardSuccess, self.BindOnGetHeroProfyStoryRewardSuccess, self)
end

function WBP_ProficiencySynopsisDetailPanel_C:OnHide()
end

return WBP_ProficiencySynopsisDetailPanel_C
