local WBP_SpecialAbilityTip = UnLua.Class()
local SeasonAbilityData = require("Modules.SeasonAbility.SeasonAbilityData")
function WBP_SpecialAbilityTip:RefreshInfo(SpecialAbilityId)
  self.SpecialAbilityId = SpecialAbilityId
  local SpecialAbilityTable = LuaTableMgr.GetLuaTableByName(TableNames.TBSpecialAbility)
  local TargetRowInfo
  for i, SingleRowInfo in ipairs(SpecialAbilityTable) do
    if self.SpecialAbilityId == SingleRowInfo.SpecialAbilityID then
      TargetRowInfo = SingleRowInfo
      break
    end
  end
  local DA = GetLuaInscription(TargetRowInfo.Inscription)
  SetImageBrushByPath(self.Img_Icon, DA.Icon)
  local name = GetInscriptionName(TargetRowInfo.Inscription)
  local desc = GetLuaInscriptionDesc(TargetRowInfo.Inscription)
  self.Txt_Name:SetText(name)
  self.Txt_Desc:SetText(desc)
  local Status = SeasonAbilityData:GetSpecialAbilityStatus(self.SpecialAbilityId)
  UpdateVisibility(self.Overlay_StatusOperate, Status ~= SpecialAbilityStatus.Activated)
  UpdateVisibility(self.WBP_InteractTipWidget, Status == SpecialAbilityStatus.UnLock)
  UpdateVisibility(self.Txt_UnlockNumDesc, Status == SpecialAbilityStatus.Lock)
  if Status == SpecialAbilityStatus.Lock then
    local HistoryUsePointNum = SeasonAbilityData:GetSpecialAbilityHistoryMaxPointNum()
    self.Txt_UnlockNumDesc:SetText(UE.FTextFormat(self.UnlockNumDescText, TargetRowInfo.SpecialAbilityPointNum - HistoryUsePointNum))
  end
end
return WBP_SpecialAbilityTip
