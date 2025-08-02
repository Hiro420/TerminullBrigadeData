local VoiceReportID = {
  [12300] = 303015,
  [12294] = 303016
}
local WBP_SingleDamageItem_C = UnLua.Class()
local TeamVoiceModule = require("Modules.TeamVoice.TeamVoiceModule")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local ModifyItemCountPerLine = 4
local ExpandName = "ViewFullAttributeList"

function WBP_SingleDamageItem_C:Construct()
  self.Overridden.Construct(self)
  self.Button_EarphoneInOpen.OnClicked:Add(self, WBP_SingleDamageItem_C.ForbidMemberVoice)
  self.Button_EarphoneInClose.OnClicked:Add(self, WBP_SingleDamageItem_C.ResumeMemberVoice)
  self.Button_MicrophoneInOpen.OnClicked:Add(self, WBP_SingleDamageItem_C.ForbidFreeMicrophone)
  self.Button_MicrophoneInClose.OnClicked:Add(self, WBP_SingleDamageItem_C.ResumeFreeMicrophone)
  self.Button_Report.OnClicked:Add(self, WBP_SingleDamageItem_C.Report)
  self.Button_VoiceReport.OnClicked:Add(self, self.VoiceReport)
  self.Button_EarphoneInOpen.OnHovered:Add(self, self.OnVoicePanelHovered)
  self.Button_EarphoneInClose.OnHovered:Add(self, self.OnVoicePanelHovered)
  self.Button_MicrophoneInOpen.OnHovered:Add(self, self.OnVoicePanelHovered)
  self.Button_MicrophoneInClose.OnHovered:Add(self, self.OnVoicePanelHovered)
  self.Button_Report.OnHovered:Add(self, self.OnReportPanelHovered)
  self.Button_VoiceReport.OnHovered:Add(self, self.OnVoiceReportPanelHovered)
  self.Button_EarphoneInOpen.OnUnhovered:Add(self, self.OnVoicePanelUnHovered)
  self.Button_EarphoneInClose.OnUnhovered:Add(self, self.OnVoicePanelUnHovered)
  self.Button_MicrophoneInOpen.OnUnhovered:Add(self, self.OnVoicePanelUnHovered)
  self.Button_MicrophoneInClose.OnUnhovered:Add(self, self.OnVoicePanelUnHovered)
  self.Button_Report.OnUnhovered:Add(self, self.OnReportPanelUnHovered)
  self.Button_VoiceReport.OnUnhovered:Add(self, self.OnVoiceReportPanelUnHovered)
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceSubSys.VoiceMuteDelegate:Add(self, WBP_SingleDamageItem_C.UpdateMuteTag)
  end
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    UpdateVisibility(self.Canvas_Voice, true)
  else
    UpdateVisibility(self.Canvas_Voice, false)
    UpdateVisibility(self.Canvas_VoiceReport, false)
  end
end

function WBP_SingleDamageItem_C:UpdateMuteTag(Result, RoomName, MemberId)
  if not LogicTeam.CheckIsOwnerVoiceRoom(RoomName) then
    return
  end
  if not self.PS then
    return
  end
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys and 0 == Result then
      local SelfMemberId = LogicTeam.GetVoiceMemberIdByRoleId(tostring(self.PS:GetUserId()))
      if SelfMemberId == MemberId then
        local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
        UpdateVisibility(self.Button_EarphoneInOpen, not bIsMute, true)
        UpdateVisibility(self.Button_EarphoneInClose, bIsMute, true)
        if bIsMute then
          if self.Button_EarphoneInOpen:HasUserFocus(self.Button_EarphoneInOpen:GetOwningPlayer()) then
            self.Button_EarphoneInClose:SetFocus()
          end
        elseif self.Button_EarphoneInClose:HasUserFocus(self.Button_EarphoneInClose:GetOwningPlayer()) then
          self.Button_EarphoneInOpen:SetFocus()
        end
      end
    end
  end
end

function WBP_SingleDamageItem_C:ForbidMemberVoice()
  if not self.PS then
    return
  end
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(tostring(self.PS:GetUserId()))
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys and MemberId > 0 then
      TeamVoiceSubSys:ForbidMemberVoice(MemberId, true)
    end
  end
end

function WBP_SingleDamageItem_C:ResumeMemberVoice()
  if not self.PS then
    return
  end
  local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(tostring(self.PS:GetUserId()))
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys and MemberId > 0 then
      TeamVoiceSubSys:ForbidMemberVoice(MemberId, false)
    end
  end
end

function WBP_SingleDamageItem_C:ForbidFreeMicrophone()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys then
      TeamVoiceModule:SetMicMode(1, true)
      UpdateVisibility(self.Button_MicrophoneInClose, true, true)
      UpdateVisibility(self.Button_MicrophoneInOpen, false, true)
      if self.Button_MicrophoneInOpen:HasUserFocus(self.Button_MicrophoneInOpen:GetOwningPlayer()) then
        self.Button_MicrophoneInClose:SetFocus()
      end
    end
  end
end

function WBP_SingleDamageItem_C:ResumeFreeMicrophone()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys then
      TeamVoiceModule:SetMicMode(0, true)
      UpdateVisibility(self.Button_MicrophoneInClose, false, true)
      UpdateVisibility(self.Button_MicrophoneInOpen, true, true)
      if self.Button_MicrophoneInClose:HasUserFocus(self.Button_MicrophoneInClose:GetOwningPlayer()) then
        self.Button_MicrophoneInOpen:SetFocus()
      end
    end
  end
end

function WBP_SingleDamageItem_C:RefreshInfo(UserId, PS, UpdateScrollSetTips, UpdateGenericModifyTips, ParentView, Index)
  if not UserId then
    return
  end
  self.ParentView = ParentView
  self.UserId = UserId
  self.Index = Index
  local bIsOwner = DataMgr.GetUserId() == tostring(UserId)
  UpdateVisibility(self.Canvas_Report, not bIsOwner)
  print("Canvas_Report", self.Canvas_Report, DataMgr.GetUserId(), tostring(UserId))
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    UpdateVisibility(self.Canvas_VoiceReport, not bIsOwner)
  else
    UpdateVisibility(self.Canvas_VoiceReport, false)
  end
  if bIsOwner then
    UpdateVisibility(self.CanvasPanel_Microphone, true)
    UpdateVisibility(self.CanvasPanel_Earphone, false)
    local bIsFreeMicrophone = self:CheckIsFreeChat()
    UpdateVisibility(self.Button_MicrophoneInClose, not bIsFreeMicrophone, true)
    UpdateVisibility(self.Button_MicrophoneInOpen, bIsFreeMicrophone, true)
  end
  if PS and self.PS ~= PS then
    print("WBP_SingleDamageItem_C:RefreshInfo", DataMgr.GetUserId(), PS:GetUserId())
    if not bIsOwner then
      UpdateVisibility(self.CanvasPanel_Microphone, false)
      UpdateVisibility(self.CanvasPanel_Earphone, true)
      if not UE.URGBlueprintLibrary.IsPlatformConsole() then
        UpdateVisibility(self.Canvas_Voice, true)
        local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
        if TeamVoiceSubSys then
          local MemberId = LogicTeam.GetVoiceMemberIdByRoleId(tostring(PS:GetUserId()))
          local bIsMute = TeamVoiceSubSys:CheckMemberIsMute(MemberId)
          UpdateVisibility(self.Button_EarphoneInOpen, not bIsMute, true)
          UpdateVisibility(self.Button_EarphoneInClose, bIsMute, true)
        end
      else
        UpdateVisibility(self.Canvas_Voice, false)
      end
    end
  end
  self.PS = PS
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  local PlayerInfo = RGTeamSubsystem:GetPlayerInfo(self.UserId)
  local CharacterId = PlayerInfo.hero.id
  local CharacterInfo = LogicRole.GetCharacterTableRow(CharacterId)
  if not CharacterInfo then
    return
  end
  local SoftObjRef = MakeStringToSoftObjectReference(CharacterInfo.ActorIcon)
  if not UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjRef) then
    return
  end
  local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjRef):Cast(UE.UPaperSprite)
  if IconObj then
    local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
    self.Img_Head:SetBrush(Brush)
  end
  local MaxUnLockLevel = PlayerInfo.hero.profy
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(CharacterId)
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
  self.Txt_Name:SetText(PlayerInfo.name)
  if bIsOwner then
    self.Txt_Name:SetColorAndOpacity(self.OwnerNameColor)
  else
    self.Txt_Name:SetColorAndOpacity(self.MemberNameColor)
  end
  local totalDamage = UE.URGStatisticsLibrary.GetTotalDamage(UserId)
  self.Txt_Damage:SetText(tostring(math.ceil(totalDamage)))
  self:UpdateScrollDamageInfoItemList()
  self:UpdateScrollSetList(UpdateScrollSetTips, ParentView)
  self:UpdateScrollGenericModifyItemList(UpdateGenericModifyTips, ParentView)
  local OnlineState = RGTeamSubsystem:GetPlayerOnlineState(self.UserId)
  if OnlineState == UE.ERGPlayerOnlineState.Disconnected then
    UpdateVisibility(self.Canvas_Offline, true)
    UpdateVisibility(self.Canvas_LeaveBattle, false)
    UpdateVisibility(self.Canvas_Online, false)
  elseif OnlineState == UE.ERGPlayerOnlineState.LeaveBattle then
    UpdateVisibility(self.Canvas_Offline, false)
    UpdateVisibility(self.Canvas_LeaveBattle, true)
    UpdateVisibility(self.Canvas_Online, false)
  else
    UpdateVisibility(self.Canvas_Offline, false)
    UpdateVisibility(self.Canvas_LeaveBattle, false)
    UpdateVisibility(self.Canvas_Online, true)
  end
  DataMgr.PrintChannelInfoLog(string.format("ChannelInfo WBP_SingleDamageItem_C self.UserId: %s", tostring(self.UserId)))
  if self.PlatformPanel then
    self.PlatformPanel:UpdateChannelInfo(self.UserId)
  end
  if self.PlatformIconPanel then
    self.PlatformIconPanel:UpdateChannelInfo(self.UserId)
  end
end

function WBP_SingleDamageItem_C:CheckIsFreeChat()
  local GameUserSettings = UE.UGameUserSettings.GetGameUserSettings()
  if not UE.URGBlueprintLibrary.IsPlatformConsole() then
    local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
    if TeamVoiceSubSys then
      local Tag = UE.URGBlueprintLibrary.RequestNameToGameplayTag(TeamVoiceSubSys.FREE_CHAT, nil)
      local FreeMicrophone = GameUserSettings:GetGameSettingByTag(Tag)
      return 0 == FreeMicrophone
    end
  end
  return false
end

function WBP_SingleDamageItem_C:UpdateScrollSetList(UpdateScrollSetTips, ParentView)
  for Index = 1, self.WrapBoxScroll:GetChildrenCount() do
    local SetItem = GetOrCreateItem(self.WrapBoxScroll, Index, self.WBP_TeamDamageActivatedModifyItem:GetClass())
    SetItem:UpdateScrollData(nil, UpdateScrollSetTips, ParentView, self, Index, self.PS)
  end
  if not self.PS then
    UnLua.LogWarn("WBP_SingleDamageItem_C:UpdateScrollSetList self.PS is nil")
    return
  end
  local HeroCharacterCls = UE.ARGHeroCharacterBase:StaticClass()
  local AllHeroCharacter = UE.UGameplayStatics.GetAllActorsOfClass(self, HeroCharacterCls, nil)
  for i, SinglePlayerCharacter in iterator(AllHeroCharacter) do
    if SinglePlayerCharacter.PlayerState == self.PS and SinglePlayerCharacter and SinglePlayerCharacter.AttributeModifyComponent then
      local activatedModifyies = SinglePlayerCharacter.AttributeModifyComponent.ActivatedModifies
      for Index = 1, self.WrapBoxScroll:GetChildrenCount() do
        local SetItem = GetOrCreateItem(self.WrapBoxScroll, Index, self.WBP_TeamDamageActivatedModifyItem:GetClass())
        local v
        if activatedModifyies:IsValidIndex(Index) then
          v = activatedModifyies:Get(Index)
        end
        SetItem:UpdateScrollData(v, UpdateScrollSetTips, ParentView, self, Index, self.PS)
        SetItem.bIsTeamDamage = true
        SetItem.bIsOwner = tonumber(DataMgr.GetUserId()) == tonumber(self.PS:GetUserId())
        local IsOwner = SetItem.bIsOwner
        local LikeUserIdList = UE.URGGameplayLibrary.GetItemRequestUsers(self, tonumber(self.PS:GetUserId()), v)
        local LikeUserIdTable = {}
        for i, UserId in iterator(LikeUserIdList) do
          if IsOwner and tonumber(UserId) ~= tonumber(DataMgr.GetUserId()) then
            table.insert(LikeUserIdTable, UserId)
          end
          if not IsOwner and tonumber(UserId) == tonumber(DataMgr.GetUserId()) then
            table.insert(LikeUserIdTable, UserId)
          end
        end
        for i, UserId in ipairs(LikeUserIdTable) do
          table.insert(ParentView.RequestMsg, {
            FromUserId = UserId,
            TargetUserId = self.PS:GetUserId(),
            AttributeModifyId = v
          })
        end
        SetItem:SetNavigationRuleCustom(UE.EUINavigation.Left, {
          self,
          self.BindOnNavigation
        })
        SetItem:SetNavigationRuleCustom(UE.EUINavigation.Right, {
          self,
          self.BindOnNavigation
        })
        SetItem:SetNavigationRuleCustom(UE.EUINavigation.Up, {
          self,
          self.BindOnNavigation
        })
        SetItem:SetNavigationRuleCustom(UE.EUINavigation.Down, {
          self,
          self.BindOnNavigation
        })
      end
    end
  end
end

function WBP_SingleDamageItem_C:UpdateScrollDamageInfoItemList()
  if not self.UserId then
    UnLua.LogWarn("WBP_SingleDamageItem_C:UpdateScrollDamageInfoItemList self.UserId is nil")
    return
  end
  local DamageInfo_Detail_table = self.DamageInfo_Detail:ToTable()
  table.sort(DamageInfo_Detail_table, function(A, B)
    if A.bIsDamage ~= B.bIsDamage then
      return A.bIsDamage
    end
    local AValue = UE.URGBlueprintLibrary.GetStatisticDataInt64StrUserId(self.UserId, A.DataId)
    local BValue = UE.URGBlueprintLibrary.GetStatisticDataInt64StrUserId(self.UserId, B.DataId)
    return AValue > BValue
  end)
  for index, DamageInfo in pairs(DamageInfo_Detail_table) do
    local Item = GetOrCreateItem(self.ScrollBox_DamageInfo_All, index, self.WBP_ScrollDamageInfoItem:GetClass())
    Item:InitScrollItem(self.UserId, DamageInfo)
  end
  HideOtherItem(self.ScrollBox_DamageInfo_All, self.DamageInfo_Detail:Length() + 1)
  for index, DamageInfo in pairs(self.DamageInfo_Summary) do
    local Item = GetOrCreateItem(self.ScrollBox_DamageInfo_Summary, index, self.WBP_ScrollDamageInfoItem:GetClass())
    Item:InitScrollItem(self.UserId, DamageInfo)
  end
  HideOtherItem(self.ScrollBox_DamageInfo_Summary, self.DamageInfo_Summary:Length() + 1)
end

function WBP_SingleDamageItem_C:UpdateScrollGenericModifyItemList(UpdateGenericModifyTips, ParentView)
  if not self.PS then
    self.RGTileView_GenericModify:ClearListItems()
    UnLua.LogWarn("WBP_SingleDamageItem_C:UpdateScrollGenericModifyItemList self.PS is nil")
    return
  end
  local HeroCharacterCls = UE.ARGHeroCharacterBase:StaticClass()
  local AllHeroCharacter = UE.UGameplayStatics.GetAllActorsOfClass(self, HeroCharacterCls, nil)
  for i, SinglePlayerCharacter in iterator(AllHeroCharacter) do
    if SinglePlayerCharacter.PlayerState == self.PS and SinglePlayerCharacter then
      local GenericModifies = Logic_IllustratedGuide.GetAllGenericModifyDataByCharacter(SinglePlayerCharacter)
      if not self:IsEqualGenericModifies(self.GenericModifies, GenericModifies) then
        print("WBP_SingleDamageItem_C:UpdateScrollGenericModifyItemList ", #GenericModifies)
        self.RGTileView_GenericModify:ClearListItems()
        for Index, Value in pairs(GenericModifies) do
          local Item = self.RGTileView_GenericModify:GetOrCreateDataObj()
          Item.ModifyData = Value
          Item.UpdateGenericModifyTips = UpdateGenericModifyTips
          Item.ParentView = ParentView
          Item.Index = Index
          Item.UserId = self.UserId
          self.RGTileView_GenericModify:AddItem(Item)
        end
      end
      self.GenericModifies = GenericModifies
    end
  end
end

function WBP_SingleDamageItem_C:IsEqualGenericModifies(t1, t2)
  if not t1 or not t2 then
    return false
  end
  if #t1 ~= #t2 then
    return false
  end
  for i, Value in pairs(t1) do
    if t2[i].Level ~= Value.Level or t2[i].ModifyId ~= Value.ModifyId then
      return false
    end
  end
  return true
end

function WBP_SingleDamageItem_C:ListenForExpandInputAction()
  if self.CanvasPanel_DamageDetail.Visibility == UE.ESlateVisibility.Visible then
    self.CanvasPanel_DamageDetail:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_DamageDetail:SetVisibility(UE.ESlateVisibility.Visible)
  end
  if self.CanvasPanel_Summay.Visibility == UE.ESlateVisibility.Visible then
    self.CanvasPanel_Summay:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.CanvasPanel_Summay:SetVisibility(UE.ESlateVisibility.Visible)
  end
end

function WBP_SingleDamageItem_C:Destruct()
  self.PS = nil
  self.Button_EarphoneInOpen.OnClicked:Remove(self, WBP_SingleDamageItem_C.ForbidMemberVoice)
  self.Button_EarphoneInClose.OnClicked:Remove(self, WBP_SingleDamageItem_C.ResumeMemberVoice)
  self.Button_MicrophoneInOpen.OnClicked:Remove(self, WBP_SingleDamageItem_C.ForbidFreeMicrophone)
  self.Button_MicrophoneInClose.OnClicked:Remove(self, WBP_SingleDamageItem_C.ResumeFreeMicrophone)
  self.Button_EarphoneInOpen.OnHovered:Remove(self, self.OnVoicePanelHovered)
  self.Button_EarphoneInClose.OnHovered:Remove(self, self.OnVoicePanelHovered)
  self.Button_MicrophoneInOpen.OnHovered:Remove(self, self.OnVoicePanelHovered)
  self.Button_MicrophoneInClose.OnHovered:Remove(self, self.OnVoicePanelHovered)
  self.Button_Report.OnHovered:Remove(self, self.OnReportPanelHovered)
  self.Button_VoiceReport.OnHovered:Remove(self, self.OnVoiceReportPanelHovered)
  self.Button_EarphoneInOpen.OnUnhovered:Remove(self, self.OnVoicePanelUnHovered)
  self.Button_EarphoneInClose.OnUnhovered:Remove(self, self.OnVoicePanelUnHovered)
  self.Button_MicrophoneInOpen.OnUnhovered:Remove(self, self.OnVoicePanelUnHovered)
  self.Button_MicrophoneInClose.OnUnhovered:Remove(self, self.OnVoicePanelUnHovered)
  self.Button_Report.OnUnhovered:Remove(self, self.OnReportPanelUnHovered)
  self.Button_VoiceReport.OnUnhovered:Remove(self, self.OnVoiceReportPanelUnHovered)
  local TeamVoiceSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGTeamVoiceSubsystem:StaticClass())
  if TeamVoiceSubSys then
    TeamVoiceSubSys.VoiceMuteDelegate:Remove(self, WBP_SingleDamageItem_C.UpdateMuteTag)
  end
  self:UnBindInputHandler()
end

function WBP_SingleDamageItem_C:Report()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.DELATE) then
    return
  end
  local RGTeamSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGTeamSubsystem:StaticClass())
  local PlayerInfo = RGTeamSubsystem:GetPlayerInfo(self.UserId)
  table.Print(PlayerInfo)
  UIMgr:Show(ViewID.UI_ReportView, false, 3, PlayerInfo.roleid, PlayerInfo.name)
end

function WBP_SingleDamageItem_C:VoiceReport()
  if UE.UGVoiceSubsystem ~= nil then
    local GVoice = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UGVoiceSubsystem:StaticClass())
    if GVoice then
      local result = GVoice:ReportPlayer(self.UserId, self.UserId)
      if 0 == result then
        print("WBP_SingleDamageItem_C: VoiceReport successfully!")
      else
        print("WBP_SingleDamageItem_C: VoiceReport Failed!", result)
        if VoiceReportID[result] then
          ShowWaveWindow(VoiceReportID[result])
        end
      end
    end
  end
end

function WBP_SingleDamageItem_C:BindOnNavigation(Type)
  self.ParentView:BindOnNavigation(Type)
end

function WBP_SingleDamageItem_C:BindInputHandler()
  if not IsListeningForInputAction(self, ExpandName) then
    ListenForInputAction(ExpandName, UE.EInputEvent.IE_Pressed, false, {
      self,
      WBP_SingleDamageItem_C.ListenForExpandInputAction
    })
  end
end

function WBP_SingleDamageItem_C:UnBindInputHandler()
  if IsListeningForInputAction(self, ExpandName) then
    StopListeningForInputAction(self, ExpandName, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_SingleDamageItem_C:OnVoicePanelHovered()
  self.Canvas_Voice:SetRenderScale(UE.FVector2D(1.2, 1.2))
end

function WBP_SingleDamageItem_C:OnVoicePanelUnHovered()
  self.Canvas_Voice:SetRenderScale(UE.FVector2D(1, 1))
end

function WBP_SingleDamageItem_C:OnReportPanelHovered()
  self.Canvas_Report:SetRenderScale(UE.FVector2D(1.2, 1.2))
end

function WBP_SingleDamageItem_C:OnReportPanelUnHovered()
  self.Canvas_Report:SetRenderScale(UE.FVector2D(1, 1))
end

function WBP_SingleDamageItem_C:OnVoiceReportPanelHovered()
  self.Canvas_VoiceReport:SetRenderScale(UE.FVector2D(1.2, 1.2))
end

function WBP_SingleDamageItem_C:OnVoiceReportPanelUnHovered()
  self.Canvas_VoiceReport:SetRenderScale(UE.FVector2D(1, 1))
end

function WBP_SingleDamageItem_C:GetFirstFocusWidget()
  local VisibleFuncBtnList = self:GetVisibleFunctionBtnList()
  for Index, Widget in ipairs(VisibleFuncBtnList) do
    if Widget:IsVisible() then
      return Widget
    end
  end
  return self:DoCustomNavigation_ModifyItemFirst()
end

function WBP_SingleDamageItem_C:DoCustomNavigation_FunctionBtnLeft()
  local VisibleFuncBtnList = self:GetVisibleFunctionBtnList()
  if not VisibleFuncBtnList or #VisibleFuncBtnList < 1 then
    return self:DoCustomNavigation_ModifyItemFirst()
  end
  for CurIndex = #VisibleFuncBtnList, 1, -1 do
    local CurWidget = VisibleFuncBtnList[CurIndex]
    if CurWidget:HasUserFocus(CurWidget:GetOwningPlayer()) then
      return self:GetFunctionBtnLeft(CurIndex, false)
    end
  end
  return self:GetFunctionBtnLast()
end

function WBP_SingleDamageItem_C:GetFunctionBtnLeft(ItemIndex, bFromParent)
  local VisibleFuncBtnList = self:GetVisibleFunctionBtnList()
  if not VisibleFuncBtnList or #VisibleFuncBtnList < 1 then
    return self:DoCustomNavigation_ModifyItemFirst()
  end
  if bFromParent then
    return VisibleFuncBtnList[#VisibleFuncBtnList]
  end
  if ItemIndex > 1 then
    return VisibleFuncBtnList[ItemIndex - 1]
  else
    return self.ParentView:GetFunctionBtnLeft(self.Index, ItemIndex)
  end
end

function WBP_SingleDamageItem_C:DoCustomNavigation_FunctionBtnRight()
  local VisibleFuncBtnList = self:GetVisibleFunctionBtnList()
  if not VisibleFuncBtnList or #VisibleFuncBtnList < 1 then
    return self:DoCustomNavigation_ModifyItemFirst()
  end
  local FocusIndex
  for Index, Widget in ipairs(VisibleFuncBtnList) do
    if Widget:HasUserFocus(Widget:GetOwningPlayer()) then
      return self:GetFunctionBtnRight(Index, false)
    end
  end
  return self:DoCustomNavigation_FunctionBtnFirst()
end

function WBP_SingleDamageItem_C:GetFunctionBtnRight(ItemIndex, bFromParent)
  local VisibleFuncBtnList = self:GetVisibleFunctionBtnList()
  if not VisibleFuncBtnList or #VisibleFuncBtnList < 1 then
    return self:DoCustomNavigation_ModifyItemFirst()
  end
  if bFromParent then
    return VisibleFuncBtnList[1]
  end
  if ItemIndex < #VisibleFuncBtnList then
    return VisibleFuncBtnList[ItemIndex + 1]
  else
    return self.ParentView:GetFunctionBtnRight(self.Index, ItemIndex)
  end
end

function WBP_SingleDamageItem_C:DoCustomNavigation_FunctionBtnFirst()
  local VisibleFuncBtnList = self:GetVisibleFunctionBtnList()
  if not VisibleFuncBtnList or #VisibleFuncBtnList < 1 then
    return self:DoCustomNavigation_ModifyItemFirst()
  end
  return VisibleFuncBtnList[1]
end

function WBP_SingleDamageItem_C:GetFunctionBtnLast()
  local VisibleFuncBtnList = self:GetVisibleFunctionBtnList()
  if not VisibleFuncBtnList or #VisibleFuncBtnList < 1 then
    return self:DoCustomNavigation_ModifyItemFirst()
  end
  return VisibleFuncBtnList[#VisibleFuncBtnList]
end

function WBP_SingleDamageItem_C:DoCustomNavigation_ModifyItemFirst()
  local ItemWidget = self.WrapBoxScroll:GetChildAt(0)
  if ItemWidget then
    return ItemWidget.BP_ButtonWithSound
  end
  return self:DoCustomNavigation_FunctionBtnFirst()
end

function WBP_SingleDamageItem_C:DoCustomNavigation_ModifyItemLast()
  local ItemCount = self.WrapBoxScroll:GetChildrenCount()
  if 0 == ItemCount then
    return self:DoCustomNavigation_FunctionBtnFirst()
  end
  local LineMaxCount = math.ceil(ItemCount / ModifyItemCountPerLine)
  local ItemIndex = (LineMaxCount - 1) * ModifyItemCountPerLine
  local ItemWidget = self.WrapBoxScroll:GetChildAt(ItemIndex)
  if ItemWidget then
    return ItemWidget.BP_ButtonWithSound
  end
  return self:DoCustomNavigation_FunctionBtnFirst()
end

function WBP_SingleDamageItem_C:GetModifyItemColunmIndex(ItemIndex)
  local ColumnIndex = ItemIndex % ModifyItemCountPerLine
  if 0 == ColumnIndex then
    ColumnIndex = ModifyItemCountPerLine
  end
  return ColumnIndex
end

function WBP_SingleDamageItem_C:GetModifyItemLeft(ItemIndex, bFromParent)
  local ColumnIndex = self:GetModifyItemColunmIndex(ItemIndex)
  local LineCount = math.ceil(ItemIndex / ModifyItemCountPerLine)
  local NextItemIndex
  if bFromParent then
    NextItemIndex = ModifyItemCountPerLine * LineCount
  elseif ColumnIndex > 1 then
    NextItemIndex = ItemIndex - 1
  else
    return self.ParentView:GetModifyItemLeft(self.Index, ItemIndex)
  end
  local ItemWidget = self.WrapBoxScroll:GetChildAt(NextItemIndex - 1)
  if ItemWidget then
    return ItemWidget.BP_ButtonWithSound
  end
end

function WBP_SingleDamageItem_C:GetModifyItemRight(ItemIndex, bFromParent)
  local ColumnIndex = self:GetModifyItemColunmIndex(ItemIndex)
  local LineCount = math.ceil(ItemIndex / ModifyItemCountPerLine)
  local NextItemIndex
  if bFromParent then
    NextItemIndex = ModifyItemCountPerLine * (LineCount - 1) + 1
  elseif ColumnIndex < ModifyItemCountPerLine then
    NextItemIndex = ItemIndex + 1
  else
    return self.ParentView:GetModifyItemRight(self.Index, ItemIndex)
  end
  local ItemWidget = self.WrapBoxScroll:GetChildAt(NextItemIndex - 1)
  if ItemWidget then
    return ItemWidget.BP_ButtonWithSound
  end
end

function WBP_SingleDamageItem_C:GetModifyItemUp(ItemIndex)
  local ColumnIndex = self:GetModifyItemColunmIndex(ItemIndex)
  local LineCount = math.ceil(ItemIndex / ModifyItemCountPerLine)
  local NextItemIndex
  if LineCount > 1 then
    NextItemIndex = (LineCount - 2) * ModifyItemCountPerLine + ColumnIndex
  else
    return self:DoCustomNavigation_FunctionBtnFirst()
  end
  local ItemWidget = self.WrapBoxScroll:GetChildAt(NextItemIndex - 1)
  if ItemWidget then
    return ItemWidget.BP_ButtonWithSound
  end
end

function WBP_SingleDamageItem_C:GetModifyItemDown(ItemIndex)
  local ColumnIndex = self:GetModifyItemColunmIndex(ItemIndex)
  local LineCount = math.ceil(ItemIndex / ModifyItemCountPerLine)
  local ItemCount = self.WrapBoxScroll:GetChildrenCount()
  local LineMaxCount = math.ceil(ItemCount / ModifyItemCountPerLine)
  local NextItemIndex
  if LineCount < LineMaxCount then
    NextItemIndex = ColumnIndex + ModifyItemCountPerLine
    if ItemCount < NextItemIndex then
      NextItemIndex = ItemCount
    end
  else
    return self:DoCustomNavigation_FunctionBtnFirst()
  end
  local ItemWidget = self.WrapBoxScroll:GetChildAt(NextItemIndex - 1)
  if ItemWidget then
    return ItemWidget.BP_ButtonWithSound
  end
end

function WBP_SingleDamageItem_C:GetVisibleFunctionBtnList()
  if not self.CanvasPanel_Microphone:IsVisible() then
    FuncBtnList = {
      self.Button_EarphoneInOpen,
      self.Button_EarphoneInClose,
      self.Button_Report,
      self.Button_VoiceReport
    }
  else
    FuncBtnList = {
      self.Button_MicrophoneInOpen,
      self.Button_MicrophoneInClose,
      self.Button_Report,
      self.Button_VoiceReport
    }
  end
  local VisibleFuncBtnList = {}
  for Index, Widget in ipairs(FuncBtnList) do
    if Widget:IsVisible() then
      table.insert(VisibleFuncBtnList, Widget)
    end
  end
  return VisibleFuncBtnList
end

return WBP_SingleDamageItem_C
