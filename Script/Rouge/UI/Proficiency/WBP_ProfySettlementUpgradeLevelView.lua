local WBP_ProfySettlementUpgradeLevelView = UnLua.Class()
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local SettlementConfig = require("GameConfig.Settlement.SettlementConfig")

function WBP_ProfySettlementUpgradeLevelView:Show()
  UpdateVisibility(self, true)
  local PlayerInfo = LogicSettlement:GetPlayerInfoByPlayerId(tonumber(DataMgr.GetUserId()))
  if not PlayerInfo then
    return
  end
  local CurHeroId = PlayerInfo.hero.id
  self.CurHeroId = CurHeroId
  self.Skin = PlayerInfo.hero.skin
  local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, CurHeroId)
  if result then
    self.Txt_HeroName:SetText(row.Name)
  end
  local AddExpValue = self:GetAddExpValue()
  self.OriginProfyLevel = ProficiencyData:GetMaxUnlockProfyLevel(CurHeroId)
  self.OriginProfyExp = ProficiencyData:GetCurProfyExp(CurHeroId)
  self:UpdateLevelInfo(self.OriginProfyLevel)
  self.Txt_CurExp:SetText(tostring(self.OriginProfyExp))
  UpdateVisibility(self.Img_ExpOrigin, false)
  local AResult, LevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, self.OriginProfyLevel)
  if AResult then
    local BResult, NextLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, self.OriginProfyLevel + 1)
    if BResult then
      UpdateVisibility(self.Img_ExpOrigin, true)
      self.Img_ExpOrigin:SetClippingValue((self.OriginProfyExp - LevelRowInfo.Exp) / (NextLevelRowInfo.Exp - LevelRowInfo.Exp))
    end
  end
  self.TargetProfyExp = self.OriginProfyExp + AddExpValue
  local ProfyLevelTable = LuaTableMgr.GetLuaTableByName(TableNames.TBProfyLevel)
  local TargetLevel = 0
  for Level, LevelRowInfo in pairs(ProfyLevelTable) do
    if self.TargetProfyExp >= LevelRowInfo.Exp then
      TargetLevel = Level
    end
  end
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(CurHeroId)
  local bMax = MaxLevel <= self.OriginProfyLevel
  self.TargetProfyLevel = TargetLevel
  if bMax then
    UpdateVisibility(self.Img_ExpOrigin, true)
    self.Img_ExpOrigin:SetClippingValue(1)
  end
  UpdateVisibility(self.Max, bMax)
  UpdateVisibility(self.ExpPanel, not bMax)
  self:InitPrivilegeItem()
  if 0 == AddExpValue then
    self:PlayAnimationForward(self.Ani_in)
    local BResult, NextLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, self.OriginProfyLevel + 1)
    if BResult then
      self.Txt_NextLevelExp:SetText(NextLevelRowInfo.Exp)
    end
  else
    local BResult, NextLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, TargetLevel + 1)
    if TargetLevel < MaxLevel and BResult then
      self.Txt_NextLevelExp:SetText(NextLevelRowInfo.Exp)
    end
    self:PlayAnimationForward(self.Ani_add_experience)
  end
end

function WBP_ProfySettlementUpgradeLevelView:InitPrivilegeItem()
  local RGStatisticsSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGStatisticsSubsystem:StaticClass())
  local ProficiencyExpTotal = RGStatisticsSubsystem.AddProficiencyExpSettleData.Exp
  local DetailsTb = {}
  for i, v in iterator(RGStatisticsSubsystem.AddProficiencyExpSettleData.PrivilegeExtraExpArray) do
    ProficiencyExpTotal = ProficiencyExpTotal - v.Value
    table.insert(DetailsTb, {
      PrivilegeSource = v.Source,
      Value = v.Value
    })
  end
  local Idx = 1
  local PrivilegeValueTxt = ""
  for i, v in ipairs(DetailsTb) do
    local PrivilegeItem = GetOrCreateItem(self.HorizontalBox_Privilege, Idx, self.WBP_ProfySettlement_Privilege_Item:GetClass())
    UpdateVisibility(PrivilegeItem, true)
    SetImageBrushByPath(PrivilegeItem.Img_Privilege_Icon, SettlementPrivilegeConfig[v.PrivilegeSource].IconPath)
    PrivilegeValueTxt = PrivilegeValueTxt .. string.format(SettlementConfig.PrivilegeFmt, v.Value)
    Idx = Idx + 1
  end
  HideOtherItem(self.HorizontalBox_Privilege, Idx, true)
  UpdateVisibility(self.HorizontalBox_PrivilegeIncrease, Idx > 1)
  self.Txt_AddExp:SetText(ProficiencyExpTotal)
  self.Txt_PrivilegeIncrease:SetText(PrivilegeValueTxt)
end

function WBP_ProfySettlementUpgradeLevelView:GetAddExpValue(...)
  local RGStatisticsSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGStatisticsSubsystem:StaticClass())
  return RGStatisticsSubsystem.ProficiencyExp
end

function WBP_ProfySettlementUpgradeLevelView:UpdateLevelInfo(InLevel)
  self.Txt_Level:SetText(InLevel)
  local AResult, LevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, InLevel)
  if not AResult then
    print("WBP_ProfySettlementUpgradeLevelView:UpdateLevelInfo RowInfo is nil! RowId:", InLevel)
    return
  end
end

function WBP_ProfySettlementUpgradeLevelView:OnAnimationFinished(InAnimation)
  if InAnimation == self.Ani_in then
    self:StartPlayAddExpAnim()
  elseif InAnimation == self.Ani_out then
    UpdateVisibility(self, false)
  elseif InAnimation == self.Ani_add_experience then
    self:PlayAnimationForward(self.Ani_in)
    self.Txt_CurExp:SetText(tostring(self.OriginProfyExp + self:GetAddExpValue()))
    local BResult, NextLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, self.TargetProfyLevel + 1)
    if BResult then
      self.Txt_NextLevelExp:SetText(NextLevelRowInfo.Exp)
    end
  end
end

function WBP_ProfySettlementUpgradeLevelView:StartPlayAddExpAnim(...)
  self.ExpDiffValue = self.TargetProfyExp - self.OriginProfyExp
  if self.ExpDiffValue <= 0 then
    self:EndAddExpAnim()
    return
  end
  self.CurrentProfyExp = self.OriginProfyExp
  self.CurrentProfyLevel = self.OriginProfyLevel
  self.TargetUpgradeLevelExpList = {}
  self.CurrentLevelExpList = {}
  for i = self.OriginProfyLevel, self.TargetProfyLevel do
    local AResult, LevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, i)
    if AResult then
      table.insert(self.CurrentLevelExpList, LevelRowInfo.Exp)
    end
    local BResult, NextLevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, i + 1)
    if BResult then
      table.insert(self.TargetUpgradeLevelExpList, NextLevelRowInfo.Exp)
    end
  end
  self.IsPlayExpDiffValue = true
  LogicAudio.StartAddExp()
end

function WBP_ProfySettlementUpgradeLevelView:PlayAddExpAnim(DeltaSeconds)
  if self.CurrentProfyExp >= self.TargetProfyExp then
    self:EndAddExpAnim()
    return
  end
  local TargetUpgradeLevelExp = self.TargetUpgradeLevelExpList[1]
  local CurrentLevelExp = self.CurrentLevelExpList[1]
  if not TargetUpgradeLevelExp or not CurrentLevelExp then
    self:EndAddExpAnim()
    return
  end
  self.CurrentProfyExp = self.CurrentProfyExp + self.ExpDiffValue * DeltaSeconds / self.ExpAnimDuration
  local Percent = math.min((self.CurrentProfyExp - CurrentLevelExp) / (TargetUpgradeLevelExp - CurrentLevelExp), 1.0)
  self.Img_ExpAdded:SetClippingValue(Percent)
  local CanvasPanelExpSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.CanvasPanel_Exp)
  local Size = CanvasPanelExpSlot:GetSize()
  local BarGlowSlot = UE.UWidgetLayoutLibrary.SlotAsCanvasSlot(self.CanvasPanel_BarGlow)
  local Position = BarGlowSlot:GetPosition()
  Position.X = Size.X * Percent
  BarGlowSlot:SetPosition(Position)
  self.CanvasPanel_Exp:SetVisibility(UE.ESlateVisibility.Visible)
  if TargetUpgradeLevelExp <= self.CurrentProfyExp then
    self:PlayVoice()
    UpdateVisibility(self.Img_ExpOrigin, false)
    self.CurrentProfyLevel = self.CurrentProfyLevel + 1
    self:UpdateLevelInfo(self.CurrentProfyLevel)
    table.remove(self.TargetUpgradeLevelExpList, 1)
    table.remove(self.CurrentLevelExpList, 1)
    self:PlayAnimationForward(self.Ani_LevelUp)
    self.Img_ExpAdded:SetClippingValue(0.0)
  end
end

function WBP_ProfySettlementUpgradeLevelView:EndAddExpAnim(...)
  self.IsPlayExpDiffValue = false
  LogicAudio.EndAddExp()
end

function WBP_ProfySettlementUpgradeLevelView:Hide(...)
  self:PlayAnimationForward(self.Ani_out)
end

function WBP_ProfySettlementUpgradeLevelView:PlayVoice()
  if not self.VoiceID then
    local RGVoiceSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGVoiceSubsystem:StaticClass())
    self.VoiceID = RGVoiceSubsystem:PlayVoiceByRowName("Voice.UpdateProfyLevel", nil, self.Skin)
  end
end

function WBP_ProfySettlementUpgradeLevelView:StopVoice()
  if self.VoiceID and self.VoiceID > 0 then
    UE.URGBlueprintLibrary.StopVoice(self.VoiceID)
    self.VoiceID = 0
  end
end

return WBP_ProfySettlementUpgradeLevelView
