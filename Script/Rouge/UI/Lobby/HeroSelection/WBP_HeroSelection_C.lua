local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local climbtowerdata = require("UI.View.ClimbTower.ClimbTowerData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local WBP_HeroSelection_C = UnLua.Class()
function WBP_HeroSelection_C:Construct()
  self.Btn_Choose.OnClicked:Add(self, self.BindOnChooseButtonClicked)
  self.Btn_Choose.OnHovered:Add(self, self.BindOnChooseButtonHovered)
  self.Btn_Choose.OnUnhovered:Add(self, self.BindOnChooseButtonUnhovered)
  self.Btn_DetailAttribute.OnClicked:Add(self, self.BindOnDetailAttributeButtonClicked)
  self.Btn_DetailAttribute.OnHovered:Add(self, self.BindOnDetailAttributeButtonHovered)
  self.Btn_DetailAttribute.OnUnhovered:Add(self, self.BindOnDetailAttributeButtonUnhovered)
  self.Btn_CancelPick.OnClicked:Add(self, self.BindOnCancelPickButtonClicked)
  local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(self, "CloseShotHeroSelectRole", nil)
  for i, SingleRoleActor in pairs(RoleActorList) do
    self.TargetRoleActor = SingleRoleActor
    break
  end
end
function WBP_HeroSelection_C:BindOrUnBindEvent(IsBind)
  if IsBind then
    EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, self.BindOnChangeRoleItemClicked)
    EventSystem.AddListener(self, EventDef.Lobby.RoleSkillTip, self.BindOnShowSkillTips)
    EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo)
    EventSystem.AddListener(self, EventDef.Lobby.UpdateHeroTalentInfo, self.BindOnHeroTalentInfoUpdate)
    EventSystem.AddListener(self, EventDef.Lobby.UpdateCommonTalentInfo, self.BindOnUpdateCommonTalentInfo)
    EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, self.BindOnFetterHeroInfoUpdate)
    EventSystem.AddListener(self, EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged)
    EventSystem.AddListener(self, EventDef.Lobby.WeaponSlotSelected, self.BindOnWeaponSlotSelected)
    EventSystem.AddListener(self, EventDef.Lobby.WeaponListChanged, self.BindOnWeaponListChanged)
    EventSystem.AddListener(self, EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, self.BindOnLobbyWeaponSlotHoverStatusChanged)
    EventSystem.AddListener(self, EventDef.HeroSelect.OnWeaponItemHoveredStateChanged, self.BindOnWeaponItemHoveredStateChanged)
    EventSystem.AddListener(self, EventDef.HeroSelect.OnPickHeroStateChanged, self.BindOnPickHeroStateChanged)
    EventSystem.AddListener(self, EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo)
    self.Btn_Debuff.OnClicked:Add(self, self.OnDebuffClicked)
  else
    EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, WBP_HeroSelection_C.BindOnChangeRoleItemClicked, self)
    EventSystem.RemoveListener(EventDef.Lobby.RoleSkillTip, WBP_HeroSelection_C.BindOnShowSkillTips, self)
    EventSystem.RemoveListener(EventDef.Lobby.UpdateHeroTalentInfo, WBP_HeroSelection_C.BindOnHeroTalentInfoUpdate, self)
    EventSystem.RemoveListener(EventDef.Lobby.UpdateCommonTalentInfo, WBP_HeroSelection_C.BindOnUpdateCommonTalentInfo, self)
    EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_HeroSelection_C.BindOnUpdateMyHeroInfo, self)
    EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, WBP_HeroSelection_C.BindOnEquippedWeaponInfoChanged, self)
    EventSystem.RemoveListener(EventDef.Lobby.WeaponSlotSelected, WBP_HeroSelection_C.BindOnWeaponSlotSelected, self)
    EventSystem.RemoveListener(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, WBP_HeroSelection_C.BindOnLobbyWeaponSlotHoverStatusChanged, self)
    EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_HeroSelection_C.BindOnFetterHeroInfoUpdate, self)
    EventSystem.RemoveListener(EventDef.Lobby.WeaponListChanged, self.BindOnWeaponListChanged, self)
    EventSystem.RemoveListener(EventDef.HeroSelect.OnWeaponItemHoveredStateChanged, self.BindOnWeaponItemHoveredStateChanged, self)
    EventSystem.RemoveListener(EventDef.HeroSelect.OnPickHeroStateChanged, self.BindOnPickHeroStateChanged, self)
    EventSystem.RemoveListener(EventDef.Lobby.UpdateMyTeamInfo, self.BindOnUpdateMyTeamInfo, self)
    self.Btn_Debuff.OnClicked:Remove(self, self.OnDebuffClicked)
  end
end
function WBP_HeroSelection_C:BindOnHeroTalentInfoUpdate(HeroId)
  if self.CurHeroId == HeroId then
    self:RefreshHeroAttributeInfo()
  end
end
function WBP_HeroSelection_C:BindOnUpdateCommonTalentInfo()
  self:RefreshHeroAttributeInfo()
end
function WBP_HeroSelection_C:BindOnFetterHeroInfoUpdate()
  self:RefreshHeroAttributeInfo()
end
function WBP_HeroSelection_C:BindOnEquippedWeaponInfoChanged(HeroId)
  if self.CurHeroId ~= HeroId then
    return
  end
  self:RefreshHeroAttributeInfo()
  self:RefreshWeaponSlotList()
  if self.TargetRoleActor then
    self.TargetRoleActor:ChangeWeaponMesh(self.CurHeroId)
  end
end
function WBP_HeroSelection_C:RefreshRoleTagList(RowInfo)
  local AllChildren = self.RoleTagList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  for index, SingleTag in ipairs(RowInfo.Tag) do
    local Item = self.RoleTagList:GetChildAt(index - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.RoleTagItemTemplate:StaticClass())
      local Margin = UE.FMargin()
      Margin.Left = 5.0
      local Slot = self.RoleTagList:AddChild(Item)
      Slot:SetPadding(Margin)
    end
    Item:Show(SingleTag)
    SetImageBrushByPath(Item.Img_TagBottom, RowInfo.TagIcon)
  end
end
function WBP_HeroSelection_C:BindOnWeaponSlotSelected(IsSelect, SlotId)
  self.IsSelectWeapon = IsSelect
  if IsSelect then
    self.CurSelectWeaponSlotId = SlotId
    UIMgr:Show(ViewID.UI_RoleWeaponSelectPanel)
    local WeaponSelectPanel = UIMgr:GetLuaFromActiveView(ViewID.UI_RoleWeaponSelectPanel)
    if WeaponSelectPanel then
      WeaponSelectPanel:InitInfo(self.CurHeroId, self.CurSelectWeaponSlotId)
    end
    EventSystem.Invoke(EventDef.Lobby.WeaponListChanged)
  end
end
function WBP_HeroSelection_C:OnWeaponSelectBGClicked()
  EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false)
end
function WBP_HeroSelection_C:BindOnWeaponListChanged()
end
function WBP_HeroSelection_C:BindOnLobbyWeaponSlotHoverStatusChanged(IsHover, WeaponInfo)
  if IsHover then
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WeaponItemDisplayInfo:SetIsSelected(true)
    self:RefreshWeaponDisplayInfoTip(self.WeaponItemDisplayInfo, WeaponInfo, true)
  else
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_HeroSelection_C:BindOnWeaponItemHoveredStateChanged(IsHover, WeaponInfo)
  if IsHover then
    local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    local TargetWeaponInfo = EquippedWeaponInfo and EquippedWeaponInfo[1] or nil
    if not TargetWeaponInfo then
      return
    end
    if WeaponInfo.uuid ~= TargetWeaponInfo.uuid then
      self.UnEquipWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:RefreshWeaponDisplayInfoTip(self.UnEquipWeaponItemDisplayInfo, WeaponInfo, false)
    end
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshWeaponDisplayInfoTip(self.WeaponItemDisplayInfo, TargetWeaponInfo, true)
  else
    self.UnEquipWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_HeroSelection_C:BindOnPickHeroStateChanged(IsPick, HeroId)
  self:RefreshChooseButtonStatus()
  self:PlayAnimation(self.Ani_Bth_chuzhan)
  if IsPick then
    self.RoleChangeList:UpdateSelectStatusToTargetHero(LogicHeroSelect.GetCurSelectHero())
  end
end
function WBP_HeroSelection_C:BindOnUpdateMyTeamInfo()
  self:RefreshChooseButtonStatus()
end
function WBP_HeroSelection_C:RefreshWeaponDisplayInfoTip(TargetWidget, WeaponInfo, IsEquipped)
  local TipText
  local IsShowOperateIcon = false
  if IsEquipped then
    TipText = nil
  else
    IsShowOperateIcon = true
    TipText = self.NotEquippedText
  end
  TargetWidget:InitInfo(WeaponInfo.resourceId, {}, false, WeaponInfo)
  if TipText then
    TargetWidget:ShowTipPanel(TipText, IsShowOperateIcon)
  end
end
function WBP_HeroSelection_C:RefreshWeaponSelectList()
  local AllChildren = self.WeaponListPanel:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local AllCanEquipWeaponList = LogicOutsideWeapon.GetCurCanEquipWeaponList(self.CurHeroId)
  if not AllCanEquipWeaponList then
    return
  end
  table.sort(AllCanEquipWeaponList, function(a, b)
    return a.uuid < b.uuid
  end)
  local Index = 0
  for i, SingleWeaponInfo in ipairs(AllCanEquipWeaponList) do
    local Item = self.WeaponListPanel:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.WeaponItemTemplate:StaticClass())
      self.WeaponListPanel:AddChild(Item)
    end
    Item:Show(SingleWeaponInfo, self.CurHeroId)
    Index = Index + 1
  end
end
function WBP_HeroSelection_C:BindOnChooseButtonClicked()
  LuaAddClickStatistics("PreparingLockCharacter")
  if LogicHeroSelect.GetCurSelectHero() == self.CurHeroId then
    LogicHeroSelect.RequestPickHeroDoneToServer()
  else
    LogicHeroSelect.RequestPickHeroToServer(self.CurHeroId, {
      self,
      function()
        LogicHeroSelect.RequestPickHeroDoneToServer()
      end
    })
    self:PlayAnimation(self.Ani_Bth_chuzhan)
  end
end
function WBP_HeroSelection_C:BindOnChooseButtonHovered()
  self.ChooseButtonHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_HeroSelection_C:BindOnChooseButtonUnhovered()
  self.ChooseButtonHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_HeroSelection_C:BindOnDetailAttributeButtonClicked()
  self:ExpandAttr()
end
function WBP_HeroSelection_C:BindOnDetailAttributeButtonHovered()
  self.Img_DetailAttributeHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_HeroSelection_C:BindOnDetailAttributeButtonUnhovered()
  self.Img_DetailAttributeHover:SetVisibility(UE.ESlateVisibility.Hidden)
end
function WBP_HeroSelection_C:BindOnCancelPickButtonClicked(...)
  LogicHeroSelect.RequestCancelPickHeroToServer()
end
function WBP_HeroSelection_C:BindOnRoleInfoButtonClicked()
  self.RoleMainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end
function WBP_HeroSelection_C:Show()
  self:StopAllAnimations()
  UpdateVisibility(self, true)
  self:BindOrUnBindEvent(true)
  self:BindOnRoleInfoButtonClicked()
  self.RoleChangeList:PlayInAnimation()
  self:UpdateRoleListStatusToHeroSelectId()
  self:PlayAnimation(self.Ani_in)
  EventSystem.Invoke(EventDef.Lobby.RoleItemClicked, LogicHeroSelect.GetCurSelectHero(), true)
  UpdateVisibility(self.ScaleBox, climbtowerdata.GameMode == LogicTeam.GetModeId())
end
function WBP_HeroSelection_C:RefreshWeaponSlotList()
  local AllItem = self.WeaponSlotList:GetAllChildren()
  local EquippedWeaponInfo
  if not DataMgr.IsOwnHero(self.CurHeroId) then
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, self.CurHeroId)
    if Result then
      EquippedWeaponInfo = {
        {
          resourceId = tostring(RowInfo.WeaponID)
        }
      }
    end
  else
    EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  end
  if EquippedWeaponInfo then
    for i, SingleItem in pairs(AllItem) do
      SingleItem:RefreshInfo(EquippedWeaponInfo[i])
    end
  end
end
function WBP_HeroSelection_C:Hide()
  self:BindOrUnBindEvent(false)
  self.WBP_TotalAttrTips:Hide()
  self:BindOnWeaponSlotSelected(false)
  EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false)
  self:ResetToCurSelectHeroInfo()
  self:PlayAnimation(self.Ani_out)
end
function WBP_HeroSelection_C:ResetToCurSelectHeroInfo()
  local MyHeroInfo = DataMgr.GetMyHeroInfo()
  EventSystem.Invoke(EventDef.Lobby.RoleItemClicked, LogicHeroSelect.GetCurSelectHero())
end
function WBP_HeroSelection_C:BindOnChangeRoleItemClicked(HeroId, bNotShowGlitchMatEffect)
  local bShowGlitchMatEffect = not bNotShowGlitchMatEffect
  if self.TargetRoleActor then
    local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
    if CharacterRow then
      self.TargetRoleActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
    self.TargetRoleActor:ChangeBodyMesh(HeroId, nil, nil, nil, bShowGlitchMatEffect)
    local SkinId = SkinData.GetEquipedSkinIdByHeroId(HeroId)
    LogicRole.SetEffectState(self.TargetRoleActor.ChildActor.ChildActor, SkinId, HeroId)
    if self.TargetRoleActor.ChildActor.ChildActor then
      self.TargetRoleActor.ChildActor.ChildActor:RoleAdjustHeight()
    end
  end
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if not RowInfo then
    print("RoleMain not found character row info, Character Id:", HeroId)
    return
  end
  self.CurHeroId = HeroId
  self.Txt_Name:SetText(RowInfo.Name)
  self.Txt_BGName:SetText(RowInfo.Name)
  self.Txt_NickName:SetText(RowInfo.NickName)
  if DataMgr.IsOwnHero(self.CurHeroId) then
    LogicRole.RequestGetHeroFetterInfoToServer(self.CurHeroId)
    local TargetEquippedInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    if not TargetEquippedInfo then
      LogicOutsideWeapon.RequestEquippedWeaponInfo(self.CurHeroId)
    end
  end
  local CommonTalents = DataMgr.GetCommonTalentInfos()
  if not CommonTalents or next(CommonTalents) == nil then
    LogicTalent.RequestGetCommonTalentsToServer()
  end
  self:RefreshHeroAttributeInfo()
  self:RefreshSkillInfo(RowInfo)
  self:RefreshRoleTagList(RowInfo)
  self:RefreshChooseButtonStatus()
  self:RefreshWeaponSlotList()
  if DataMgr.IsOwnHero(self.CurHeroId) then
  end
  local Text = RowInfo.Desc
  self.Txt_BGDesc:SetText(Text)
end
function WBP_HeroSelection_C:UpdateRoleListStatusToHeroSelectId()
  self.RoleChangeList:UpdateSelectStatusToTargetHero(LogicHeroSelect.GetCurSelectHero())
end
function WBP_HeroSelection_C:RefreshHeroAttributeInfo()
  self:RefreshLobbyHeroAttribtueInfo()
end
local SortAttrRow = function(A, B)
  local ResultA, AAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(A))
  local ResultB, BAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(B))
  return AAttrDisplay.PriorityLevel > BAttrDisplay.PriorityLevel
end
function WBP_HeroSelection_C:GetAttrDisplayNameList()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local DataTableTemp = DTSubsystem:GetDataTable(DT.DT_HeroBasicAttribute)
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(DataTableTemp)
  local RowNameTb = {}
  local Result, RowData = false
  for key, SingleRowName in pairs(RowNames) do
    Result, RowData = GetRowData(DT.DT_HeroBasicAttribute, SingleRowName)
    if Result and RowData.DisplayInUI == UE.EAttributeDisplayPos.Main and RowData.bShowInLobby then
      table.insert(RowNameTb, SingleRowName)
    end
  end
  table.sort(RowNameTb, SortAttrRow)
  return RowNameTb
end
function WBP_HeroSelection_C:RefreshLobbyHeroAttribtueInfo()
end
function WBP_HeroSelection_C:ExpandAttr()
  self.WBP_TotalAttrTips:LobbyShow(self.CurHeroId)
end
function WBP_HeroSelection_C:RefreshChooseButtonStatus()
  local IsPick = false
  local TeamInfo = DataMgr.GetTeamInfo()
  for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
    if SinglePlayerInfo.id == DataMgr.GetUserId() then
      IsPick = 0 ~= SinglePlayerInfo.pickDone
      break
    end
  end
  UpdateVisibility(self.Btn_CancelPick, IsPick)
  if IsPick then
    UpdateVisibility(self.CanChoosePanel, false)
    UpdateVisibility(self.CanNotChoosePanel, false)
  elseif DataMgr.IsOwnHero(self.CurHeroId) then
    self.CanChoosePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CanNotChoosePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  else
    self.CanNotChoosePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CanChoosePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.Img_Lock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Txt_ChooseStatus:SetText(self.LockText)
  end
end
function WBP_HeroSelection_C:BindOnShowSkillTips(IsShow, SkillGroupId, KeyName, SkillInputName, inputNameAryPad, HoverItem)
  if IsShow then
    local Offset = UE.FVector2D(-35, 0)
    ShowCommonTips(nil, HoverItem, self.NormalSkillTip, nil, nil, nil, Offset)
    self.NormalSkillTip:RefreshInfo(SkillGroupId, KeyName, nil, SkillInputName, inputNameAryPad)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.NormalSkillTip:Hide()
  end
end
function WBP_HeroSelection_C:BindOnUpdateMyHeroInfo()
  self:RefreshChooseButtonStatus()
  self:ResetToCurSelectHeroInfo()
end
function WBP_HeroSelection_C:RefreshSkillInfo(RowInfo)
  local AllSkillItems = self.SkillList:GetAllChildren()
  local SkillItemList = {}
  for i, SingleItem in pairs(AllSkillItems) do
    SkillItemList[SingleItem.Type] = SingleItem
  end
  local RoleStar = DataMgr.GetHeroLevelByHeroId(RowInfo.ID)
  for i, SingleSkillId in ipairs(RowInfo.SkillList) do
    local SkillRowInfo = LogicRole.GetSkillTableRow(SingleSkillId)
    if SkillRowInfo then
      local TargetSkillLevelInfo = SkillRowInfo[RoleStar]
      if TargetSkillLevelInfo then
        local Item = SkillItemList[TargetSkillLevelInfo.Type]
        if Item then
          Item:RefreshInfo(TargetSkillLevelInfo)
        end
      elseif SkillRowInfo[1] then
        local Item = SkillItemList[SkillRowInfo[1].Type]
        if Item then
          Item:RefreshInfo(SkillRowInfo[1])
        end
      else
        print("WBP_HeroSelection_C:RefreshSkillInfo not found star1 info, skillgroupid:", SingleSkillId)
      end
    end
  end
  self:RefreshWeaponSkillInfo()
end
function WBP_HeroSelection_C:RefreshWeaponSkillInfo()
  UpdateVisibility(self.WeaponSkill, false)
  local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if not EquippedWeaponInfo or not EquippedWeaponInfo[1] then
    return
  end
  local WeapResId = EquippedWeaponInfo[1].resourceId
  local Result, RowData = GetRowData(DT.DT_Weapon, tostring(WeapResId))
  if not Result or RowData.AbilityConfig.AbilityClasses:Num() <= 0 then
    return
  end
  for k, SingleAbilityClass in pairs(RowData.AbilityConfig.AbilityClasses) do
    if UE.UKismetSystemLibrary.IsValidClass(SingleAbilityClass) then
      local Ability = SingleAbilityClass:GetDefaultObject()
      if Ability and Ability:IsValid() then
        local SkillInfo = LogicRole.GetHeroSkillInfo(tonumber(Ability.AbilityID))
        if SkillInfo then
          UpdateVisibility(self.WeaponSkill, true)
          self.WeaponSkill:RefreshInfo(SkillInfo)
          return
        end
      end
    end
  end
end
function WBP_HeroSelection_C:OnDebuffClicked()
  UpdateVisibility(self.WBP_ClimbTower_DebuffPanle, true, true)
  local TeamInfo = DataMgr.GetTeamInfo()
  local Players = {}
  for index, SinglePlayerInfo in ipairs(TeamInfo.players) do
    if SinglePlayerInfo.id ~= DataMgr.GetUserId() then
      table.insert(Players, SinglePlayerInfo.id)
    end
  end
  table.insert(Players, DataMgr.GetUserId())
  self.WBP_ClimbTower_DebuffPanle:Init(Players, 2)
end
function WBP_HeroSelection_C:Destruct()
  self:BindOrUnBindEvent(false)
end
function WBP_HeroSelection_C:OnAnimationFinished(Animation)
  if Animation == self.Ani_out then
    UpdateVisibility(self, false)
  end
end
return WBP_HeroSelection_C
