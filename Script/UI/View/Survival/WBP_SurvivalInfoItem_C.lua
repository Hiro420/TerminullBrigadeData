local WBP_SurvivalInfoItem_C = UnLua.Class()
local LockText = NSLOCTEXT("WBP_SurvivalInfoItem_C", "LockText", "\232\175\183\229\133\136\233\128\154\229\133\179{0}")
function WBP_SurvivalInfoItem_C:Construct()
  self.IsSelect = false
  self.Btn_Select.OnClicked:Add(self, self.OnBtnSelectClicked)
  self.Btn_Select.OnHovered:Add(self, self.OnBtnSelectHovered)
  self.Btn_Select.OnUnhovered:Add(self, self.OnBtnSelectUnhovered)
end
function WBP_SurvivalInfoItem_C:OnDestroy()
  self.Btn_Select.OnClicked:Remove(self, self.OnBtnSelectClicked)
  self.Btn_Select.OnHovered:Remove(self, self.OnBtnSelectHovered)
  self.Btn_Select.OnUnhovered:Remove(self, self.OnBtnSelectUnhovered)
end
function WBP_SurvivalInfoItem_C:InitInfo(SurvivalInfo, ModeId, ParentView, index)
  self.SurvivalInfo = SurvivalInfo
  self.LevelId = SurvivalInfo.LevelId
  self.ModeId = ModeId
  self.ParentView = ParentView
  self.Index = index
  self.TXT_Difficulty:SetText(SurvivalInfo.DifficultyName)
  self.TXT_SelectDifficulty:SetText(SurvivalInfo.DifficultyName)
  SetImageBrushByPath(self.Img_SmallBG, SurvivalInfo.SmallIcon)
  SetImageBrushByPath(self.Img_Icon, SurvivalInfo.DifficultyIcon)
  SetImageBrushByPath(self.Img_BigBG, SurvivalInfo.BigIcon)
  local Index = 1
  for i, SingleDescription in ipairs(SurvivalInfo.FloorDescription) do
    local Item = GetOrCreateItem(self.FloorDescPanel, Index, self.FloorDescItemTemplate:StaticClass())
    Item:Show(SingleDescription)
    Index = Index + 1
  end
  HideOtherItem(self.FloorDescPanel, Index)
  local DropRatioList = {}
  local DropRatio
  for i, SingleDropRatioInfoKey in ipairs(SurvivalInfo.DropResourcesRatioKey) do
    DropRatioList[SingleDropRatioInfoKey] = SurvivalInfo.DropResourcesRatioValue[i]
  end
  for index, SingleResourceId in ipairs(SurvivalInfo.DropResources) do
    local Item = GetOrCreateItem(self.DropList, index, self.SingleModeDropItemTemplate:StaticClass())
    DropRatio = DropRatioList[tostring(SingleResourceId)]
    Item:Show(SingleResourceId, DropRatio)
  end
  local result, rowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, self.LevelId)
  if result then
    self.LevelInfo = rowInfo
  end
  self.TicketID = self.LevelInfo.ticketID
  self:SetSelect(false)
  self.IsSelfUnlock = self:IsUnlock()
  UpdateVisibility(self.Img_SmallBG, self.IsSelfUnlock)
  UpdateVisibility(self.Img_Select_NotUnlocked, not self.IsSelfUnlock)
  UpdateVisibility(self["Difficulty_0" .. index], true)
  local result, LockTeamMembers = LogicTeam.GetTeamUnLockModeAndMember(self.LevelInfo.gameMode, self.LevelInfo.gameWorldID)
  if not result and not self.LevelInfo.initUnlock then
    self.WBP_LockWordTip:Show(LockTeamMembers)
    self.IsTeamMemberLock = true
    UpdateVisibility(self.WBP_LockWordTip, true)
  else
    self.IsTeamMemberLock = false
    UpdateVisibility(self.WBP_LockWordTip, false)
  end
  UpdateVisibility(self.Img_Ban, self.IsTeamMemberLock)
  self:PlayAnimation(self.Ani_loop, 0, 0)
end
function WBP_SurvivalInfoItem_C:SetSelect(IsSelect)
  self.IsSelect = IsSelect
  UpdateVisibility(self.CanvasPanel_UnSelect, not IsSelect)
  UpdateVisibility(self.CanvasPanel_Select, IsSelect)
end
function WBP_SurvivalInfoItem_C:OnBtnSelectClicked()
  self:SetSelect(true)
  self:PlayAnimation(self.Ani_click)
  self.ParentView.SelectItemChange(self.ParentView, self.LevelId, self.TicketID)
  SetImageBrushByPath(self.ParentView.Img_Icon, self.SurvivalInfo.PanelIcon)
  self.ParentView.TXT_Difficulty:SetText(self.SurvivalInfo.DifficultyName)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameModeTicket, self.LevelInfo.ticketID)
  if self.IsSelfUnlock then
    if not self.IsTeamMemberLock then
      LogicTeam.RequestSetTeamDataToServer(self.LevelInfo.gameWorldID, self.LevelInfo.gameMode, self.LevelInfo.floor)
      if Result then
        local TeamMemberCount = DataMgr.GetTeamMemberCount()
        self.ParentView.MaxNum = RowInfo.costResources[1].value * TeamMemberCount
        self.ParentView.TXT_NeedNum:SetText(self.ParentView.MaxNum)
      end
    end
    UpdateVisibility(self.ParentView.Overlay_Prompt, false)
  else
    UpdateVisibility(self.ParentView.Overlay_Prompt, true)
    self.ParentView.LockText:SetText(UE.FTextFormat(LockText(), self:GetDependName(self.LevelInfo.dependIDs[1])))
  end
  if Result then
    local TeamMemberCount = DataMgr.GetTeamMemberCount()
    self.ParentView.TXT_NeedNum:SetText(RowInfo.costResources[1].value * TeamMemberCount)
  end
end
function WBP_SurvivalInfoItem_C:OnBtnSelectHovered()
  self:PlayAnimation(self.Ani_hover_in)
end
function WBP_SurvivalInfoItem_C:OnBtnSelectUnhovered()
  self:PlayAnimation(self.Ani_hover_out)
end
function WBP_SurvivalInfoItem_C:GetDependName(DependLevelID)
  local result, rowinfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGameFloorUnlock, DependLevelID)
  if result then
    return rowinfo.Name
  end
  return "Error"
end
function WBP_SurvivalInfoItem_C:IsUnlock()
  if self.LevelInfo.initUnlock then
    return true
  end
  for RoleId, ModeInfo in pairs(LogicTeam.RolesGameFloorInfo) do
    if RoleId == DataMgr.GetUserId() then
      if not ModeInfo[tostring(self.ModeId)] then
        return false
      elseif not ModeInfo[tostring(self.ModeId)][tostring(self.LevelInfo.gameWorldID)] then
        return false
      else
        return ModeInfo[tostring(self.ModeId)][tostring(self.LevelInfo.gameWorldID)] >= self.LevelInfo.floor
      end
    end
  end
end
return WBP_SurvivalInfoItem_C
