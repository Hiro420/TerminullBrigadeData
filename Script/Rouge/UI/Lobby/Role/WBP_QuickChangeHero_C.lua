local ListContainer = require("Rouge.UI.Common.ListContainer")
local rapidjson = require("rapidjson")
local WBP_QuickChangeHero_C = UnLua.Class()

function WBP_QuickChangeHero_C:Construct()
  self.ListContainer = ListContainer.New(self.RoleItemTemplate:StaticClass())
  table.insert(self.ListContainer.AllWidgets, self.RoleItemTemplate)
  self.WeaponListContainer = ListContainer.New(self.WeaponItemTemplate:StaticClass())
  table.insert(self.WeaponListContainer.AllWidgets, self.WeaponItemTemplate)
  self.WeaponItemTemplate:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Btn_Confirm.OnClicked:Add(self, WBP_QuickChangeHero_C.BindOnConfirmButtonClicked)
  self:BindToAnimationFinished(self.ani_quickchangehero_out, {
    self,
    WBP_QuickChangeHero_C.BindOnOutAnimationFinished
  })
  local HeroInfo = DataMgr.GetMyHeroInfo()
  
  function self.EscFunctionalBtn.MainButtonClicked()
    self:Hide()
  end
  
  EventSystem.AddListener(self, EventDef.LobbyPanel.OnShow, WBP_QuickChangeHero_C.BindOnLobbyPanelShow)
  EventSystem.AddListener(self, EventDef.LobbyPanel.OnHide, WBP_QuickChangeHero_C.BindOnLobbyPanelHide)
end

function WBP_QuickChangeHero_C:BindOnConfirmButtonClicked()
  LogicRole.RequestEquipHeroToServer(self.CurHeroId)
  self:Hide()
end

function WBP_QuickChangeHero_C:BindOnOutAnimationFinished()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.Invoke(EventDef.Lobby.QuickChangeHeroPanelHide)
end

function WBP_QuickChangeHero_C:Show()
  EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, WBP_QuickChangeHero_C.BindOnChangeRoleItemClicked)
  self:RefreshHeroList()
  self:RefreshWeaponSlotPanel()
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self:PlayAnimation(self.ani_quickchangehero_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  LogicAudio.OnPageOpen()
  self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.FetterSkillTip:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.AddListener(self, EventDef.Lobby.RoleSkillTip, WBP_QuickChangeHero_C.BindOnShowNormalSkillTip)
  EventSystem.AddListener(self, EventDef.Lobby.RoleFetterSkillTip, WBP_QuickChangeHero_C.BindOnShowFetterSkillTip)
  EventSystem.AddListener(self, EventDef.Lobby.EquippedWeaponInfoChanged, WBP_QuickChangeHero_C.BindOnEquippedWeaponInfoChanged)
  EventSystem.AddListener(self, EventDef.Lobby.WeaponSlotSelected, WBP_QuickChangeHero_C.BindOnWeaponSlotSelected)
  EventSystem.AddListener(self, EventDef.Lobby.WeaponListChanged, WBP_QuickChangeHero_C.BindOnWeaponListChanged)
  EventSystem.AddListener(self, EventDef.Lobby.WeaponItemSelected, WBP_QuickChangeHero_C.BindOnWeaponItemSelected)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, WBP_QuickChangeHero_C.BindOnUpdateMyHeroInfo)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, WBP_QuickChangeHero_C.BindOnFetterHeroInfoUpdate)
  EventSystem.AddListener(self, EventDef.Lobby.LobbyWeaponItemHoverStatusChanged, WBP_QuickChangeHero_C.BindOnLobbyWeaponItemHoverStatusChanged)
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotItemClicked, WBP_QuickChangeHero_C.BindOnFetterSlotItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, WBP_QuickChangeHero_C.BindOnLobbyWeaponSlotHoverStatusChanged)
  ListenForInputAction(self.EscKeyName, UE.EInputEvent.IE_Pressed, true, {
    self,
    WBP_QuickChangeHero_C.BindOnEscKeyPressed
  })
end

function WBP_QuickChangeHero_C:OnBGMouseButtonDown(MyGeometry, MouseEvent)
  if UE.UKismetInputLibrary.PointerEvent_IsMouseButtonDown(MouseEvent, self.LeftMouseKey) then
    self:BindOnEscKeyPressed()
  end
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_QuickChangeHero_C:BindOnEscKeyPressed()
  self:Hide()
end

function WBP_QuickChangeHero_C:Hide()
  self:PlayAnimation(self.ani_quickchangehero_out, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1.0, false)
  LogicAudio.OnPageClose()
  EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false)
  self:RemoveListener()
end

function WBP_QuickChangeHero_C:RemoveListener()
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, WBP_QuickChangeHero_C.BindOnChangeRoleItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.RoleSkillTip, WBP_QuickChangeHero_C.BindOnShowNormalSkillTip, self)
  EventSystem.RemoveListener(EventDef.Lobby.RoleFetterSkillTip, WBP_QuickChangeHero_C.BindOnShowFetterSkillTip)
  EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, WBP_QuickChangeHero_C.BindOnEquippedWeaponInfoChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponSlotSelected, WBP_QuickChangeHero_C.BindOnWeaponSlotSelected, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponListChanged, WBP_QuickChangeHero_C.BindOnWeaponListChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponItemSelected, WBP_QuickChangeHero_C.BindOnWeaponItemSelected, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_QuickChangeHero_C.BindOnUpdateMyHeroInfo)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_QuickChangeHero_C.BindOnFetterHeroInfoUpdate, self)
  EventSystem.RemoveListener(EventDef.Lobby.LobbyWeaponItemHoverStatusChanged, WBP_QuickChangeHero_C.BindOnLobbyWeaponItemHoverStatusChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotItemClicked, WBP_QuickChangeHero_C.BindOnFetterSlotItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, WBP_QuickChangeHero_C.BindOnLobbyWeaponSlotHoverStatusChanged, self)
  if IsListeningForInputAction(self, self.EscKeyName) then
    StopListeningForInputAction(self, self.EscKeyName, UE.EInputEvent.IE_Pressed)
  end
end

function WBP_QuickChangeHero_C:BindOnChangeRoleItemClicked(HeroId)
  if self.CurHeroId == HeroId then
    return
  end
  self.CurHeroId = HeroId
  local MyHeroInfo = DataMgr.GetMyHeroInfo()
  if MyHeroInfo.equipHero ~= self.CurHeroId then
    LogicRole.RequestEquipHeroToServer(self.CurHeroId)
    local TargetEquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    if not TargetEquippedWeaponInfo then
    end
  end
  LogicRole.RequestGetHeroFetterInfoToServer(self.CurHeroId)
  self:RefreshFetterSlotInfo()
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if not RowInfo then
    print("RoleMain not found character row info, Character Id:", HeroId)
    return
  end
  self:RefreshSkillInfo(RowInfo)
  self:RefreshBasicInfo()
  EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false)
end

function WBP_QuickChangeHero_C:BindOnShowNormalSkillTip(IsShow, SkillGroupId, KeyName)
  if IsShow then
    self.NormalSkillTip:RefreshInfo(SkillGroupId, KeyName)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_QuickChangeHero_C:BindOnShowFetterSkillTip(IsShow, SkillGroupId, HeroId)
  if IsShow then
    self.FetterSkillTip:RefreshInfo(SkillGroupId, HeroId)
    self.FetterSkillTip:HideChangeFetterPanel()
    self.FetterSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.FetterSkillTip:SetVisibility(UE.ESlateVisibility.Hidden)
  end
end

function WBP_QuickChangeHero_C:BindOnWeaponSlotSelected(IsSelect, SlotId)
  self.IsSelectWeapon = IsSelect
  if IsSelect then
    self.LobbyWeaponList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CurSelectWeaponSlotId = SlotId
  else
    self.LobbyWeaponList:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_QuickChangeHero_C:BindOnWeaponItemSelected(WeaponInfo)
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  local TargetWeaponInfo = EquippedWeaponList[self.CurSelectWeaponSlotId + 1]
  if TargetWeaponInfo.uuid == WeaponInfo.uuid then
    print("\228\184\142\229\189\147\229\137\141\230\173\166\229\153\168\233\128\137\230\139\169\228\184\128\230\160\183")
    return
  end
  LogicOutsideWeapon.RequestEquipWeapon(self.CurHeroId, WeaponInfo.uuid, self.CurSelectWeaponSlotId, WeaponInfo.resourceId)
end

function WBP_QuickChangeHero_C:BindOnWeaponListChanged()
  self:RefreshWeaponList()
end

function WBP_QuickChangeHero_C:BindOnUpdateMyHeroInfo()
  local AllHeroItems = self.ListContainer:GetAllUseWidgetsList()
  for i, SingleHeroItem in pairs(AllHeroItems) do
    SingleHeroItem:UpdateSelectStatus()
  end
  self:RefreshWeaponSlotPanel()
end

function WBP_QuickChangeHero_C:BindOnFetterHeroInfoUpdate()
  self:RefreshFetterSlotInfo()
end

function WBP_QuickChangeHero_C:BindOnLobbyWeaponItemHoverStatusChanged(IsHover, WeaponInfo, IsEquipped)
  if IsHover then
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshWeaponDisplayInfoTip(self.WeaponItemDisplayInfo, WeaponInfo, IsEquipped)
    local HeroInfo = DataMgr.GetMyHeroInfo()
    local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(HeroInfo.equipHero)
    self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshWeaponDisplayInfoTip(self.CurWeaponItemDisplayInfo, EquippedWeaponInfo[1], true, true)
  else
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_QuickChangeHero_C:BindOnLobbyWeaponSlotHoverStatusChanged(IsHover, WeaponInfo)
  if IsHover then
    self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshWeaponDisplayInfoTip(self.CurWeaponItemDisplayInfo, WeaponInfo, true)
  else
    self.CurWeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_QuickChangeHero_C:BindOnFetterSlotItemClicked(SlotId, IsUnLock)
  self:JumpToRoleMain()
  EventSystem.Invoke(EventDef.Lobby.FetterSlotItemClicked, SlotId, IsUnLock)
end

function WBP_QuickChangeHero_C:JumpToRoleMain()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local LobbyPanelClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/MainLobby/WBP_LobbyPanel.WBP_LobbyPanel_C")
  if not LobbyPanelClass then
    return
  end
  local LobbyPanelObj = UIManager:K2_GetUI(LobbyPanelClass)
  if not LobbyPanelObj then
    return
  end
  local PageTabAssetClass = UE.UClass.Load("/Game/Rouge/Gameplay/Data/UI/Tab/Tab_Config/Lobby/First/BP_LobbyRoleTabConfig.BP_LobbyRoleTabConfig_C")
  local TargetButton = LobbyPanelObj:GetTargetPageButton(PageTabAssetClass)
  self:BindOnEscKeyPressed()
  if TargetButton then
    TargetButton:ActivateTabWidget()
  end
end

function WBP_QuickChangeHero_C:RefreshWeaponDisplayInfoTip(TargetTipWidget, WeaponInfo, IsEquipped, IsShowCurEquip)
  local AccessoryList = {}
  local TipText
  local IsShowOperateIcon = false
  if IsEquipped then
    TipText = self.EquippedText
  else
    IsShowOperateIcon = true
    TipText = self.NotEquippedText
  end
  local AllAccessoryList = DataMgr.GetAccessoryList()
  for i, SingleAccessoryInfo in ipairs(AllAccessoryList) do
    if WeaponInfo.uuid == SingleAccessoryInfo.equip then
      table.insert(AccessoryList, SingleAccessoryInfo.resourceId)
    end
  end
  TargetTipWidget:InitInfo(WeaponInfo.resourceId, AccessoryList)
  if IsEquipped and not IsShowCurEquip then
    TargetTipWidget:ShowCurrentEquipTipPanel()
  elseif TipText then
    TargetTipWidget:ShowTipPanel(TipText, IsShowOperateIcon)
  end
end

function WBP_QuickChangeHero_C:RefreshWeaponList()
  self.WeaponListContainer:ClearAllUseWidgets()
  local AllCanEquipWeaponList = LogicOutsideWeapon.GetCurCanEquipWeaponList(self.CurHeroId)
  local EquippedWeaponList = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if not EquippedWeaponList then
    return
  end
  local TargetWeaponInfo
  for i, SingleEquippedInfo in ipairs(EquippedWeaponList) do
    if i ~= self.CurSelectWeaponSlotId + 1 then
      TargetWeaponInfo = SingleEquippedInfo
      break
    end
  end
  table.sort(AllCanEquipWeaponList, function(a, b)
    return a.uuid < b.uuid
  end)
  local CurWeaponInfo = EquippedWeaponList[self.CurSelectWeaponSlotId + 1]
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  for i, SingleWeaponInfo in ipairs(AllCanEquipWeaponList) do
    local Item = self.WeaponListContainer:GetOrCreateItem()
    if not self.LobbyWeaponList:HasChild(Item) then
      self.LobbyWeaponList:AddChild(Item)
    end
    self.WeaponListContainer:ShowItem(Item, SingleWeaponInfo, CurWeaponInfo.uuid == SingleWeaponInfo.uuid)
  end
end

function WBP_QuickChangeHero_C:RefreshHeroList()
  self.ListContainer:ClearAllUseWidgets()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  local HeroList = HeroInfo.heros
  table.sort(HeroList, function(A, B)
    return A.id < B.id
  end)
  for index, SingleHeroInfo in ipairs(HeroList) do
    local HeroRowInfo = LogicRole.GetCharacterTableRow(SingleHeroInfo.id)
    if HeroRowInfo and HeroRowInfo.CanChoose and HeroRowInfo.Type == TableEnums.ENUMHeroType.Hero then
      local Item = self.ListContainer:GetOrCreateItem()
      self.ListContainer:ShowItem(Item, SingleHeroInfo.id)
      if not self.HeroList:HasChild(Item) then
        local Slot = self.HeroList:AddChild(Item)
        Slot:SetPadding(self.HeroListPadding)
      end
    end
  end
  EventSystem.Invoke(EventDef.Lobby.RoleItemClicked, HeroInfo.equipHero)
end

function WBP_QuickChangeHero_C:RefreshFetterSlotInfo()
  local AllChildren = self.FetterSlotPanel:GetAllChildren()
  for i, SingleItem in pairs(AllChildren) do
    SingleItem:Show(i, self.CurHeroId, true)
  end
end

function WBP_QuickChangeHero_C:RefreshSkillInfo(RowInfo)
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
        print("WBP_RoleMain_C:RefreshSkillInfo not found star1 info, skillgroupid:", SingleSkillId)
      end
    end
  end
end

function WBP_QuickChangeHero_C:RefreshWeaponSlotPanel()
  local AllItem = self.WeaponSlotPanel:GetAllChildren()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(HeroInfo.equipHero)
  for i, SingleItem in pairs(AllItem) do
    SingleItem:RefreshInfo(EquippedWeaponInfo[i])
  end
end

function WBP_QuickChangeHero_C:RefreshBasicInfo()
  local RowInfo = LogicRole.GetCharacterTableRow(self.CurHeroId)
  if not RowInfo then
    return
  end
  self.Txt_Name:SetText(RowInfo.Name)
  self.Txt_NickName:SetText(RowInfo.NickName)
  self:RefreshAttributeInfo(RowInfo)
end

function WBP_QuickChangeHero_C:RefreshAttributeInfo(RowInfo)
  if RowInfo.ArrSkill[1] then
    self.HealthItem:RefreshInfo(RowInfo.ArrSkill[1])
  end
  if RowInfo.ArrSkill[2] then
    self.ShieldItem:RefreshInfo(RowInfo.ArrSkill[2])
  end
  if RowInfo.ArrSkill[3] then
    self.MobilityItem:RefreshInfo(RowInfo.ArrSkill[3])
  end
  if RowInfo.ArrSkill[4] then
    self.OperateItem:RefreshInfo(RowInfo.ArrSkill[4])
  end
end

function WBP_QuickChangeHero_C:BindOnEquippedWeaponInfoChanged()
  self:RefreshWeaponSlotPanel()
end

function WBP_QuickChangeHero_C:Destruct()
  self:RemoveListener()
  self:UnbindFromAnimationFinished(self.ani_quickchangehero_out, {
    self,
    WBP_QuickChangeHero_C.BindOnOutAnimationFinished
  })
end

return WBP_QuickChangeHero_C
