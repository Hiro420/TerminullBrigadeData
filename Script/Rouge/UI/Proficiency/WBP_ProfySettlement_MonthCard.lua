local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local ProficiencyHandler = require("Protocol.Proficiency.ProficiencyHandler")
local WBP_ProfySettlement_MonthCard = UnLua.Class()
local EscKeyName = "PauseGame"

function WBP_ProfySettlement_MonthCard:Construct()
  self.Btn_Main.OnHovered:Add(self, self.BtnMainOnHovered)
  self.Btn_Main.OnUnhovered:Add(self, self.BtnMainOnUnhovered)
  local ShowText = ""
  self.HaveBenfit = false
  local GameLevelSystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGGameLevelSystem:StaticClass())
  local PrivilegePlayers = {}
  if GameLevelSystem and GameLevelSystem.WorldInfo.BenefitRepDatas then
    for i, BenefitRepData in iterator(GameLevelSystem.WorldInfo.BenefitRepDatas) do
      if tostring(BenefitRepData.MyUser) == DataMgr.GetUserId() then
        for PrivilegeIndex, PriviligeInfo in iterator(BenefitRepData.Rows) do
          if PriviligeInfo then
            if tostring(PriviligeInfo.FromUser) == DataMgr.GetUserId() then
              ShowText = self.PrivilegeSelfText
              break
            elseif not PrivilegePlayers[PriviligeInfo.FromUser] then
              PrivilegePlayers[PriviligeInfo.FromUser] = DataMgr.TeamMemberNameList[tostring(PriviligeInfo.FromUser)]
            end
          else
            print("WBP_ProfySettlement_MonthCard  PriviligeInfo Is Nil")
          end
          self.HaveBenfit = true
        end
        break
      end
    end
  end
  if "" == ShowText then
    local NameList = {}
    for i, v in pairs(PrivilegePlayers) do
      table.insert(NameList, v)
    end
    if 1 == #NameList then
      ShowText = UE.FTextFormat(self.PrivilegeTeamText, NameList[1], "")
    elseif 2 == #NameList then
      ShowText = UE.FTextFormat(self.PrivilegeTeamText, NameList[1], "\239\188\140" .. NameList[2])
    end
  end
  self.Text_Tips:SetText(ShowText)
  self.WBP_MonthCardIcon:Show(DataMgr.GetUserId())
end

function WBP_ProfySettlement_MonthCard:BtnMainOnHovered()
  if not self.HaveBenfit then
    return
  end
  UpdateVisibility(self.Overlay_Tips, true)
end

function WBP_ProfySettlement_MonthCard:BtnMainOnUnhovered()
  if not self.HaveBenfit then
    return
  end
  UpdateVisibility(self.Overlay_Tips, false)
end

function WBP_ProfySettlement_MonthCard:Destruct()
  self.Btn_Main.OnHovered:Remove(self, self.BtnMainOnHovered)
  self.Btn_Main.OnUnhovered:Remove(self, self.BtnMainOnUnhovered)
end

return WBP_ProfySettlement_MonthCard
