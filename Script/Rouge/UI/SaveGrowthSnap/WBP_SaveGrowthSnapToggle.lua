local SaveGrowthSnapData = require("Modules.SaveGrowthSnap.SaveGrowthSnapData")
local WBP_SaveGrowthSnapToggle = UnLua.Class()

function WBP_SaveGrowthSnapToggle:Construct()
end

function WBP_SaveGrowthSnapToggle:InitSaveGrowthSnapToggle(Pos, SnapData)
  if not SnapData or SnapData.SnapshotStagingTime == "0" or not SnapData.SnapshotStagingTime then
    self.StateCtrl_Empty:ChangeStatus(EEmpty.Empty)
    return
  end
  local timeStamp = SnapData.SnapshotStagingTime
  local dateTxt = TimestampToDateText(tonumber(timeStamp))
  self.StateCtrl_Empty:ChangeStatus(EEmpty.NotEmpty)
  self.RGTxt_Name_Select:SetText(SnapData.Remark)
  self.RGTxt_Time_Select:SetText(dateTxt)
  self.RGTxt_Name_UnSelect:SetText(SnapData.Remark)
  self.RGTxt_Time_UnSelect:SetText(dateTxt)
  local useTimesFmt = UE.URGBlueprintLibrary.TextFromStringTable("1362")
  local useTimes = SnapData.UseTimes or 0
  local useTimesLimit = SaveGrowthSnapData:GetGrowthSnapUseLimitNum()
  local useTimesLeft = SaveGrowthSnapData:GetGrowthSnapUseLeftNum(useTimes)
  if useTimesLeft >= 0 then
    local useTimeTxt = UE.FTextFormat(useTimesFmt, useTimes, useTimesLimit)
    self.RGTxt_UseTimes_UnSelect:SetText(useTimeTxt)
    self.RGTxt_UseTimes_Select:SetText(useTimeTxt)
    UpdateVisibility(self.RGTxt_UseTimes_UnSelect, true)
    UpdateVisibility(self.RGTxt_UseTimes_Select, true)
  else
    UpdateVisibility(self.RGTxt_UseTimes_UnSelect, false)
    UpdateVisibility(self.RGTxt_UseTimes_Select, false)
  end
end

function WBP_SaveGrowthSnapToggle:Destruct()
  print("WBP_SaveGrowthSnapToggle:Destruct()")
end

return WBP_SaveGrowthSnapToggle
