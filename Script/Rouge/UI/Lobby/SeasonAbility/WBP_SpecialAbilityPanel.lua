local WBP_SpecialAbilityPanel = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
local SeasonAbilityHandler = require("Protocol.SeasonAbility.SeasonAbilityHandler")

function WBP_SpecialAbilityPanel:OnShow()
  EventSystem.AddListener(self, EventDef.SeasonAbility.OnSpecialAbilityInfoUpdated, self.BindOnSpecialAbilityInfoUpdated)
  local SpecialAbilityInfo = SeasonAbilityData:GetSpecialAbilityInfo()
  if next(SpecialAbilityInfo) == nil then
    SeasonAbilityHandler:RequestGetSpecialAbilityInfoToServer()
  end
  self:RefreshInfo()
  self.EscInteractWidget:BindInteractAndClickEvent(self, self.ListenForEscInputAction)
  self:PlayAnimationForward(self.Ani_in)
end

function WBP_SpecialAbilityPanel:ListenForEscInputAction(...)
  EventSystem.Invoke(EventDef.SeasonAbility.OnUpdateSpecialAbilityPanelVis, false)
end

function WBP_SpecialAbilityPanel:RefreshInfo(...)
  local CurUsePointNum = SeasonAbilityData:GetSpecialAbilityCurrentMaxPointNum()
  self.Txt_CurMaxPointNum:SetText(CurUsePointNum)
  local HistoryUsePointNum = SeasonAbilityData:GetSpecialAbilityHistoryMaxPointNum()
  local SpecialAbilityTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSpecialAbility)
  local LastRowInfo = SpecialAbilityTable[#SpecialAbilityTable]
  local MaxPointNum = LastRowInfo.SpecialAbilityPointNum
  local Alignment = UE.FVector2D(0.5, 0.5)
  local ProgressSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.Overlay_Progress)
  local ProgressSizeX = ProgressSlot:GetSize().X
  local Index = 1
  for index, SingleRowInfo in ipairs(SpecialAbilityTable) do
    local Item = GetOrCreateItem(self.CanvasPanel_SpecialAbilityItem, Index, self.SingleSpecialAbilityItemTemplate:StaticClass())
    local Slot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(Item)
    local TargetPos = UE.FVector2D(0, 0)
    TargetPos.X = ProgressSizeX * (SingleRowInfo.SpecialAbilityPointNum / MaxPointNum)
    Slot:SetPosition(TargetPos)
    Slot:SetAlignment(Alignment)
    Item:Show(SingleRowInfo, Index - 1)
    Index = Index + 1
  end
  HideOtherItem(self.CanvasPanel_SpecialAbilityItem, Index)
  self.Img_HistoryTotalPointNum:SetClippingValue(HistoryUsePointNum / MaxPointNum)
  self.TargetCurPointNumPercent = math.clamp(CurUsePointNum / MaxPointNum, 0, 1)
  self:StartPlayCurPointNumProgressAnim()
end

function WBP_SpecialAbilityPanel:BindOnSpecialAbilityInfoUpdated()
  self:RefreshInfo()
end

function WBP_SpecialAbilityPanel:StartPlayCurPointNumProgressAnim()
  self.IsPlayPointNumAnim = true
  self.CurDeltaSeconds = 0
end

function WBP_SpecialAbilityPanel:LuaTick(DeltaSeconds)
  if not self.IsPlayPointNumAnim then
    return
  end
  if self.CurDeltaSeconds > self.PointNumProgressAnimDuration then
    self.IsPlayPointNumAnim = false
    self.Img_CurTotalPointNum:SetClippingValue(self.TargetCurPointNumPercent)
    return
  end
  self.CurDeltaSeconds = self.CurDeltaSeconds + DeltaSeconds
  local TargetPercent = self.TargetCurPointNumPercent * (self.CurDeltaSeconds / self.PointNumProgressAnimDuration)
  self.Img_CurTotalPointNum:SetClippingValue(TargetPercent)
end

function WBP_SpecialAbilityPanel:OnHide(...)
  EventSystem.RemoveListener(EventDef.SeasonAbility.OnSpecialAbilityInfoUpdated, self.BindOnSpecialAbilityInfoUpdated, self)
  self.EscInteractWidget:UnBindInteractAndClickEvent(self, self.ListenForEscInputAction)
  self:StopAllAnimations()
  self.IsPlayPointNumAnim = false
end

function WBP_SpecialAbilityPanel:Destruct(...)
  self:OnHide()
end

return WBP_SpecialAbilityPanel
