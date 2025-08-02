local WBP_HeroSelectionRoleName_C = UnLua.Class()
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")

function WBP_HeroSelectionRoleName_C:Show(PlayerInfo)
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if self.PlayerInfo and self.PlayerInfo.roleid == PlayerInfo.roleid then
    return
  end
  self.PlayerInfo = PlayerInfo
  self.Txt_Name:SetText(self.PlayerInfo.nickname)
  self:ChangePickStateVis()
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
  if self.PlayerInfo.roleid == DataMgr.GetUserId() then
    self:BindOnRoleItemClicked(LogicHeroSelect.GetCurSelectHero())
    EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, self.BindOnRoleItemClicked)
  end
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_HeroSelectionRoleName_C self.PlayerInfo.roleid: %s", tostring(self.PlayerInfo.roleid)))
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_HeroSelectionRoleName_C self.PlayerInfo.channelUID: %s", tostring(self.PlayerInfo.channelUID)))
  if self.PlatformPanel then
    self.PlatformPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(self.PlayerInfo.roleid, true, self.PlayerInfo.channelUID)
  end
end

function WBP_HeroSelectionRoleName_C:BindOnUpdateMyTeamInfo()
  self:ChangePickStateVis()
end

function WBP_HeroSelectionRoleName_C:BindOnRoleItemClicked(HeroId)
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if RowInfo then
    SetImageBrushByPath(self.Img_HeroIcon, RowInfo.ActorIcon)
  end
  local MaxUnLockLevel = ProficiencyData:GetMaxUnlockProfyLevel(HeroId)
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(HeroId)
  self:UpdateProfyInfo(MaxUnLockLevel, MaxLevel)
end

function WBP_HeroSelectionRoleName_C:UpdateProfyInfo(MaxUnLockLevel, MaxLevel)
  self.RGTextProfyLv:SetText(MaxUnLockLevel)
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, MaxUnLockLevel)
  if Result and not UE.UKismetStringLibrary.IsEmpty(RowInfo.HeadFrameIconPath) then
    UpdateVisibility(self.Img_ProfyHeadFrame, true)
    SetImageBrushByPath(self.Img_ProfyHeadFrame, RowInfo.HeadFrameIconPath, self.ProfyHeadFrameIconSize)
  else
    UpdateVisibility(self.Img_ProfyHeadFrame, false)
  end
  if MaxUnLockLevel == MaxLevel then
    UpdateVisibility(self.Bg_BigAward_Recieved, true)
    UpdateVisibility(self.URGImage_BigAward_Recieved, true)
  else
    UpdateVisibility(self.Bg_BigAward_Recieved, false)
    UpdateVisibility(self.URGImage_BigAward_Recieved, false)
  end
end

function WBP_HeroSelectionRoleName_C:ChangePickStateVis()
  local TeamInfo = DataMgr.GetTeamInfo()
  for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
    if SinglePlayerInfo.id == self.PlayerInfo.roleid then
      if 0 == SinglePlayerInfo.pickDone then
        self.Txt_Status:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        self.Txt_HeroName:SetVisibility(UE.ESlateVisibility.Collapsed)
      else
        self.Txt_Status:SetVisibility(UE.ESlateVisibility.Collapsed)
        self.Txt_HeroName:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      end
      local RowInfo = LogicRole.GetCharacterTableRow(SinglePlayerInfo.pickHeroInfo.id)
      if RowInfo then
        self.Txt_HeroName:SetText(RowInfo.Name)
        SetImageBrushByPath(self.Img_HeroIcon, RowInfo.ActorIcon)
      end
      local MaxUnLockLevel = SinglePlayerInfo.pickHeroInfo.profy
      local MaxLevel = ProficiencyData:GetMaxProfyLevel(SinglePlayerInfo.pickHeroInfo.id)
      self:UpdateProfyInfo(MaxUnLockLevel, MaxLevel)
    end
  end
end

function WBP_HeroSelectionRoleName_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  if not self.PlayerInfo then
    return
  end
  self.PlayerInfo = nil
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, self.BindOnRoleItemClicked, self)
end

function WBP_HeroSelectionRoleName_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, self.BindOnRoleItemClicked, self)
end

return WBP_HeroSelectionRoleName_C
