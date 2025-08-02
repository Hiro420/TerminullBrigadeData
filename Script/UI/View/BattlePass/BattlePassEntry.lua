local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local rapidjson = require("rapidjson")
local BattlePassData = require("Modules.BattlePass.BattlePassData")
local BattlePassEntry = Class(ViewBase)

function BattlePassEntry:BindClickHandler()
  self.Btn_Entry.OnClicked:Add(self, self.Btn_Entry_Onclicked)
  self.Button_Open.OnClicked:Add(self, self.Btn_Entry_Onclicked)
  self.Btn_Entry.OnHovered:Add(self, self.Btn_Entry_OnHovered)
  self.Btn_Entry.OnUnhovered:Add(self, self.Btn_Entry_OnUnhovered)
end

function BattlePassEntry:UnBindClickHandler()
  self.Btn_Entry.OnClicked:Remove(self, self.Btn_Entry_Onclicked)
  self.Button_Open.OnClicked:Remove(self, self.Btn_Entry_Onclicked)
  self.Btn_Entry.OnHovered:Remove(self, self.Btn_Entry_OnHovered)
  self.Btn_Entry.OnUnhovered:Remove(self, self.Btn_Entry_OnUnhovered)
end

function BattlePassEntry:OnDestroy()
  self:UnBindClickHandler()
end

function BattlePassEntry:Construct()
  self:BindClickHandler()
  local BattlePassMainViewModel = UIModelMgr:Get("BattlePassMainViewModel")
  if BattlePassMainViewModel then
    BattlePassMainViewModel:PullBattlePassTaskInfo()
  end
end

function BattlePassEntry:Destruct()
  self:UnBindClickHandler()
end

function BattlePassEntry:OnPreHide()
  self:UnBindClickHandler()
end

function BattlePassEntry:OnHide()
  self:StopAllAnimations()
end

function BattlePassEntry:InitInfo(Level, Exp, ActivateState, BattlePassID)
  self.BattlePassID = BattlePassID
  self.ActivateState = ActivateState
  self.TXT_Level:SetText(Level)
  local BPAwardList = LuaTableMgr.GetLuaTableByName(TableNames.TBBattlePassReward)
  local curLevelInfo, nextLevelInfo
  for i, v in ipairs(BPAwardList) do
    if v.BattlePassID == BattlePassID then
      if v.BattlePassLevel == tonumber(Level) then
        curLevelInfo = v
      elseif v.BattlePassLevel == tonumber(Level) + 1 then
        nextLevelInfo = v
      end
    end
    if curLevelInfo and nextLevelInfo then
      break
    end
  end
  local curExp = tonumber(Exp) - curLevelInfo.Exp
  local MaxLevel = BattlePassData:GetBattlePassMaxLevel(BattlePassID)
  if MaxLevel <= tonumber(Level) then
    curExp = BPAwardList[2].Exp - BPAwardList[1].Exp
  end
  self.TXT_CurExp:SetText(curExp)
  if nextLevelInfo then
    local levelExp = nextLevelInfo.Exp - curLevelInfo.Exp
    self.TXT_MaxLevel:SetText(levelExp)
    self.ProgressBar_Exp:SetPercent(curExp / levelExp)
    local showAward = {}
    for i, v in pairs(nextLevelInfo.NormalReward) do
      local awardItem = GetOrCreateItem(self.HBox_Item, #showAward + 1, self.WBP_BattlePassSmallItem:GetClass())
      awardItem:InitItem(v.key, v.value)
      table.insert(showAward, awardItem)
    end
    if BattlePassData[BattlePassID] and BattlePassData[BattlePassID].battlePassActivateState ~= EBattlePassActivateState.Normal then
      for i, v in pairs(nextLevelInfo.PremiumReward) do
        local awardItem = GetOrCreateItem(self.HBox_Item, #showAward + 1, self.WBP_BattlePassSmallItem:GetClass())
        awardItem:InitItem(v.key, v.value)
        table.insert(showAward, awardItem)
      end
    end
    HideOtherItem(self.HBox_Item, #showAward + 1)
    self.IsMaxLevel = false
  else
    local levelExp = BPAwardList[2].Exp - BPAwardList[1].Exp
    self.TXT_MaxLevel:SetText(levelExp)
    self.ProgressBar_Exp:SetPercent(curExp / levelExp)
    self.IsMaxLevel = true
  end
end

function BattlePassEntry:Btn_Entry_Onclicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.PASS) then
    return
  end
  local isShowBugView = self:CheckNeedOpenBuyView()
  if isShowBugView then
    local UnlockView = UIMgr:Show(ViewID.UI_BattlePassUnLockView)
    UnlockView:InitInfo(self.BattlePassID, self.ActivateState)
  else
    local BPMainView = UIMgr:Show(ViewID.UI_BattlePassMainView, true)
    BPMainView:InitSubView(self.BattlePassID)
  end
end

function BattlePassEntry:Btn_Entry_OnHovered()
  if self.IsMaxLevel then
    return
  end
  UpdateVisibility(self.Panel_HoverTips, true)
end

function BattlePassEntry:Btn_Entry_OnUnhovered()
  if self.IsMaxLevel then
    return
  end
  UpdateVisibility(self.Panel_HoverTips, false)
end

function BattlePassEntry:CheckNeedOpenBuyView()
  local LocalBattlePassFilePath = UE.UKismetSystemLibrary.GetProjectSavedDirectory() .. "/BattlePass/BattlePassData_" .. DataMgr.GetUserId() .. ".json"
  local Result, fileStr = UE.URGBlueprintLibrary.LoadFileToString(LocalBattlePassFilePath)
  if Result then
    local BattlePassData = rapidjson.decode(fileStr)
    if BattlePassData[tostring(self.BattlePassID)] then
      return false
    else
      BattlePassData[tostring(self.BattlePassID)] = true
      local BattlePassDataJson = RapidJsonEncode(BattlePassData)
      UE.URGBlueprintLibrary.SaveStringToFile(LocalBattlePassFilePath, BattlePassDataJson)
      return true
    end
  else
    local BattlePassData = {
      [tostring(self.BattlePassID)] = true
    }
    local BattlePassDataJson = RapidJsonEncode(BattlePassData)
    UE.URGBlueprintLibrary.SaveStringToFile(LocalBattlePassFilePath, BattlePassDataJson)
    return true
  end
end

return BattlePassEntry
