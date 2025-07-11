local WBP_ProficiencyAwardItem = UnLua.Class()
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local ProficiencyHandler = require("Protocol.Proficiency.ProficiencyHandler")
function WBP_ProficiencyAwardItem:Construct()
  self.Btn_Main.OnClicked:Add(self, self.BindOnMainButtonClicked)
end
function WBP_ProficiencyAwardItem:Destruct()
  self:Hide()
end
function WBP_ProficiencyAwardItem:Show(Level, ProficiencyGeneralRowId, CurHeroId)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.Level = Level
  self.ProficiencyGeneralRowId = ProficiencyGeneralRowId
  self.CurHeroId = CurHeroId
  self.Txt_Level:SetText(Level)
  self.WBP_RedDotView:ChangeRedDotIdByTag(tostring(CurHeroId) .. "_" .. tostring(Level))
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, Level)
  if Result and not UE.UKismetStringLibrary.IsEmpty(RowInfo.HeadFrameIconPath) then
    SetImageBrushByPath(self.Img_LevelIcon, RowInfo.HeadFrameIconPath, self.LevelIconSize)
  end
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(self.CurHeroId)
  self.IsBigReward = self.Level == MaxLevel
  UpdateVisibility(self.CanvasPanel_Normal, not self.IsBigReward)
  UpdateVisibility(self.CanvasPanel_BigReward, self.IsBigReward)
  self:RefreshStatus()
  self:RefreshRewardItem()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo)
end
function WBP_ProficiencyAwardItem:RefreshStatus()
  local CurUnLockLevel = ProficiencyData:GetMaxUnlockProfyLevel(self.CurHeroId)
  UpdateVisibility(self.CanvasPanel_Lock, false)
  UpdateVisibility(self.CanvasPanel_ReceivedReward, false)
  UpdateVisibility(self.CanvasPanel_ReceivedReward_BigReward, false)
  UpdateVisibility(self.CanvasPanel_Hover, false)
  UpdateVisibility(self.CanvasPanel_Hover_BigReward, false)
  UpdateVisibility(self.ExpTextPanel, false)
  if CurUnLockLevel >= self.Level then
    if ProficiencyData:IsCurProfyLevelRewardReceived(self.CurHeroId, self.Level) then
      UpdateVisibility(self.CanvasPanel_ReceivedReward, true)
      UpdateVisibility(self.CanvasPanel_ReceivedReward_BigReward, true)
    end
    self.Img_ProficiencyExpProgressFill:SetClippingValue(1.0)
  elseif self.Level == CurUnLockLevel + 1 then
    UpdateVisibility(self.ExpTextPanel, true)
    local CurExp = ProficiencyData:GetCurProfyExp(self.CurHeroId, self.Level)
    self.Txt_CurExp:SetText(tostring(CurExp))
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, self.Level)
    local LastLevelExp = 0
    local BResult, LastLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, self.Level - 1)
    if BResult then
      LastLevelExp = LastLevelRowInfo.Exp
    end
    if Result then
      self.Txt_NextLevelExp:SetText(tostring(RowInfo.Exp))
      self.Img_ProficiencyExpProgressFill:SetClippingValue((CurExp - LastLevelExp) / (RowInfo.Exp - LastLevelExp))
    else
      print("WBP_ProficiencyAwardItem:RefreshStatus Profy Level RowInfo is nil, Level:", self.Level)
    end
  else
    UpdateVisibility(self.CanvasPanel_Lock, true)
    self.Img_ProficiencyExpProgressFill:SetClippingValue(0.0)
  end
end
function WBP_ProficiencyAwardItem:RefreshRewardItem()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyGeneral, self.ProficiencyGeneralRowId)
  if not Result then
    return
  end
  local LevelRewardInfo = RowInfo.LvRewardList[1]
  self.IsInscriptionReward = false
  if not LevelRewardInfo then
    self.LevelRewardId = RowInfo.inscriptions[1]
    self.IsInscriptionReward = true
  else
    self.LevelRewardId = LevelRewardInfo.key
  end
  if not self.LevelRewardId then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self.Overlay_Reward, true)
  if self.IsInscriptionReward then
    self.WBP_Item:InitItem(self.LevelRewardId, nil, true)
  elseif LevelRewardInfo.value > 1 then
    self.WBP_Item:InitItem(self.LevelRewardId, LevelRewardInfo.value)
  else
    self.WBP_Item:InitItem(self.LevelRewardId)
  end
  self:RefreshItemTag(RowInfo.ItemTagName)
end
function WBP_ProficiencyAwardItem:RefreshItemTag(ItemTagName)
  if not ItemTagName or UE.UKismetStringLibrary.IsEmpty(ItemTagName) then
    UpdateVisibility(self.CanvasPanel_Tag, false)
    return
  end
  UpdateVisibility(self.CanvasPanel_Tag, true)
  self.Txt_TagName:SetText(ItemTagName)
end
function WBP_ProficiencyAwardItem:BindOnMainButtonClicked()
  if not self.LevelRewardId then
    return
  end
  if not self.IsInscriptionReward then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, self.LevelRewardId)
    if Result and (RowInfo.Type == TableEnums.ENUMResourceType.Weapon or RowInfo.Type == TableEnums.ENUMResourceType.WeaponSkin or RowInfo.Type == TableEnums.ENUMResourceType.HeroSkin) then
      UIMgr:Show(ViewID.UI_ProficiencySpecialAwardDetailPanel, true, self.CurHeroId, self.LevelRewardId)
    end
  end
  local CurUnLockLevel = ProficiencyData:GetMaxUnlockProfyLevel(self.CurHeroId)
  if CurUnLockLevel < self.Level then
    return
  end
  if ProficiencyData:IsCurProfyLevelRewardReceived(self.CurHeroId, self.Level) then
    return
  end
  ProficiencyHandler:RequestGetHeroProfyLevelRewardToServer(self.CurHeroId, self.Level)
end
function WBP_ProficiencyAwardItem:BindOnUpdateMyHeroInfo()
  self:RefreshStatus()
end
function WBP_ProficiencyAwardItem:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo, self)
end
function WBP_ProficiencyAwardItem:OnMouseEnter()
  if not self.LevelRewardId then
    return
  end
  if self.IsBigReward then
    UpdateVisibility(self.CanvasPanel_Hover_BigReward, true)
  else
    UpdateVisibility(self.CanvasPanel_Hover, true)
  end
  local CurUnLockLevel = ProficiencyData:GetMaxUnlockProfyLevel(self.CurHeroId)
  EventSystem.Invoke(EventDef.Proficiency.OnProficiencyAwardItemHoverStatusChanged, true, self.LevelRewardId, self.IsInscriptionReward, self.Level, CurUnLockLevel >= self.Level)
end
function WBP_ProficiencyAwardItem:OnMouseLeave()
  if not self.LevelRewardId then
    return
  end
  if self.IsBigReward then
    UpdateVisibility(self.CanvasPanel_Hover_BigReward, false)
  else
    UpdateVisibility(self.CanvasPanel_Hover, false)
  end
  EventSystem.Invoke(EventDef.Proficiency.OnProficiencyAwardItemHoverStatusChanged, false)
end
return WBP_ProficiencyAwardItem
