local IllustratedGuideData = require("Modules.IllustratedGuide.IllustratedGuideData")
local WBP_IGuide_SM_SMItem_C = UnLua.Class()

function WBP_IGuide_SM_SMItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Add(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BindOnMainButtonUnhovered)
  self.SpecificModifyId = -1
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnSpecificModifyItemClicked, self.BindOnSpecificModifyItemClicked)
end

function WBP_IGuide_SM_SMItem_C:Destruct()
  self.Btn_Main.OnClicked:Remove(self, self.BindOnMainButtonClicked)
  self.Btn_Main.OnHovered:Remove(self, self.BindOnMainButtonHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.BindOnMainButtonUnhovered)
  EventSystem.RemoveListener(EventDef.IllustratedGuide.OnSpecificModifyItemClicked, self.BindOnSpecificModifyItemClicked, self)
end

function WBP_IGuide_SM_SMItem_C:OnAnimationFinished(Ani)
  if Ani == self.Ani_Locked then
    UpdateVisibility(self.Canvas_Locked, false)
  end
end

function WBP_IGuide_SM_SMItem_C:RefreshInfo(ParentView, SpecificModifyId)
  local specificModifyIdStr = tostring(SpecificModifyId)
  if IllustratedGuideData.SpecificUnlockAniMap[specificModifyIdStr] then
    UpdateVisibility(self.Canvas_Locked, true)
    self:PlayAnimation(self.Ani_Locked, 0, 1, UE.EUMGSequencePlayMode.Forward, 1, true)
    IllustratedGuideData.SpecificUnlockAniMap[specificModifyIdStr] = nil
  elseif not self:IsAnimationPlaying(self.Ani_Locked) then
    UpdateVisibility(self.Canvas_Locked, false)
  end
  self.ParentView = ParentView
  self.SpecificModifyId = SpecificModifyId
  self:SetVisibility(UE.ESlateVisibility.Visible)
  UpdateVisibility(self.Canvas_Hover, false)
  UpdateVisibility(self.Canvas_Checked, false)
  local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if nil == logicCommandDataSubsystem then
    return
  end
  local OutSaveData = GetLuaInscription(SpecificModifyId)
  local ModifyData = {}
  self.WBP_GenericModifyItem:InitSpecificModifyItem(SpecificModifyId, false, true)
  if ParentView.SelectedSpecificModifyId == SpecificModifyId then
    UpdateVisibility(self.Canvas_Checked, true)
  end
  if not UIModelMgr:Get("IllustratedGuideSpecificModifyViewModel"):CheckOwnedSpecificModify(SpecificModifyId) then
    UpdateVisibility(self.Canvas_Locked, true)
    SetImageBrushByPath(self.Img_LockedBg, OutSaveData.Icon)
    SetImageBrushByPath(self.Img_LockedSMIcon, OutSaveData.Icon)
  elseif not self:IsAnimationPlaying(self.Ani_Locked) then
    UpdateVisibility(self.Canvas_Locked, false)
  else
    SetImageBrushByPath(self.Img_LockedSMIcon, OutSaveData.Icon)
  end
  if nil == ParentView.SelectedSpecificModifyId then
    self:BindOnMainButtonClicked()
  end
  self.WBP_RedDotView:ChangeRedDotIdByTag(SpecificModifyId)
end

function WBP_IGuide_SM_SMItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.IllustratedGuide.OnSpecificModifyItemClicked, self.SpecificModifyId)
end

function WBP_IGuide_SM_SMItem_C:BindOnMainButtonHovered()
  UpdateVisibility(self.Canvas_Hover, true)
end

function WBP_IGuide_SM_SMItem_C:BindOnMainButtonUnhovered()
  UpdateVisibility(self.Canvas_Hover, false)
end

function WBP_IGuide_SM_SMItem_C:BindOnSpecificModifyItemClicked(SpecificModifyId)
  if SpecificModifyId == self.SpecificModifyId then
    UpdateVisibility(self.Canvas_Checked, true)
    if UIModelMgr:Get("IllustratedGuideSpecificModifyViewModel"):CheckOwnedSpecificModify(self.SpecificModifyId) then
      self.WBP_RedDotView:SetNum(0)
    end
  else
    UpdateVisibility(self.Canvas_Checked, false)
  end
end

function WBP_IGuide_SM_SMItem_C:Hide()
  self:StopAnimation(self.Ani_Locked)
  UpdateVisibility(self.Canvas_Hover, false)
  UpdateVisibility(self.Canvas_Checked, false)
  UpdateVisibility(self.Canvas_Locked, false)
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return WBP_IGuide_SM_SMItem_C
