local BattleLagacyData = require("Modules.BattleLagacy.BattleLagacyData")
local BattleLagacyModule = require("Modules.BattleLagacy.BattleLagacyModule")
local WBP_BattleRoleInfo_C = UnLua.Class()
local MaxGenericModifyNum = 22
local GenericModifyItemScale = 0.84
local SortAttrRow = function(A, B)
  local ResultA, AAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(A))
  local ResultB, BAttrDisplay = GetRowData(DT.DT_HeroBasicAttribute, tostring(B))
  return AAttrDisplay.PriorityLevel > BAttrDisplay.PriorityLevel
end
local SortModifyAttrRow = function(A, B)
  local ResultA, AAttrDisplay = GetRowData(DT.DT_HeroModifyAttribute, tostring(A))
  local ResultB, BAttrDisplay = GetRowData(DT.DT_HeroModifyAttribute, tostring(B))
  return AAttrDisplay.PriorityLevel > BAttrDisplay.PriorityLevel
end

function WBP_BattleRoleInfo_C:Construct()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if Character then
    self:RefreshInfo(Character:GetTypeID())
    self:InitBuffList()
    local heroId = Character:GetTypeID()
    local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    if EquippedWeaponInfo and EquippedWeaponInfo[1] then
    else
      LogicOutsideWeapon.RequestEquippedWeaponInfo(heroId)
    end
  end
  self.SkillTips:HideChangeFetterPanel()
  EventSystem.AddListener(self, EventDef.Lobby.RoleSkillTip, WBP_BattleRoleInfo_C.BindOnShowSkillTips)
  EventSystem.AddListener(self, EventDef.Lobby.RoleFetterSkillTip, WBP_BattleRoleInfo_C.BindOnShowFetterSkillTips)
  EventSystem.AddListener(self, EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, WBP_BattleRoleInfo_C.BindOnLobbyWeaponSlotHoverStatusChanged)
  EventSystem.AddListener(self, EventDef.MainPanel.MainPanelChanged, WBP_BattleRoleInfo_C.BindOnMainPanelChanged)
  EventSystem.AddListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnEquipedWeaponInfoChanged)
  ListenObjectMessage(nil, GMP.MSG_World_GenericModify_OnUpdateTeamSpirit, self, self.OnUpdateTeamSpirit)
  self.WBP_OperatingHintsFour.Btn_Main.OnClicked:Add(self, WBP_BattleRoleInfo_C.OnEscClick)
end

function WBP_BattleRoleInfo_C:InitBuffList()
  if not self:GetOwningPlayerPawn() then
    return
  end
  local BuffComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.UBuffComponent)
  if not BuffComp then
    print("BuffComp is nil")
    return
  end
  self.AllBuffInfos = {}
  self.AllBuffIds = {}
  self:InitBuffInfo()
  self:InitElementInfo()
  self:RefreshBuffList()
  BuffComp.OnBuffAdded:Add(self, WBP_BattleRoleInfo_C.BindOnBuffChanged)
  BuffComp.OnBuffRemove:Add(self, WBP_BattleRoleInfo_C.BindOnBuffRemoved)
  BuffComp.OnBuffChanged:Add(self, WBP_BattleRoleInfo_C.BindOnBuffChanged)
  EventSystem.AddListener(self, EventDef.Battle.ElementChanged, WBP_BattleRoleInfo_C.BindOnElementChanged)
  local InscriptionComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGInscriptionComponent:StaticClass())
  if InscriptionComp then
    InscriptionComp.OnClientUpdateInscriptionCD:Add(self, WBP_BattleRoleInfo_C.BindOnClientUpdateInscriptionCD)
  end
  local InscriptionCompV2 = self:GetOwningPlayerPawn():GetComponentByClass(UE.URGInscriptionComponentV2:StaticClass())
  if InscriptionCompV2 then
    InscriptionCompV2.OnInscriptionCooldown:Add(self, WBP_BattleRoleInfo_C.BindOnClientUpdateInscriptionCD)
  end
  EventSystem.AddListener(self, EventDef.Battle.RemoveInscriptionItem, WBP_BattleRoleInfo_C.BindOnRemoveInscriptionItem)
end

function WBP_BattleRoleInfo_C:OnOpen(MainPanel)
  self.MainPanel = MainPanel
  if self:IsAnimationPlaying(self.Ani_in_switch) then
    self:StopAnimation(self.Ani_in_switch)
  end
  self:PlayAnimation(self.Ani_in)
  local OkGamePadFocus, ErrorsGamePadFocus = pcall(self.GamePadFocus, self)
  if not OkGamePadFocus then
    UnLua.LogError("WBP_BattleRoleInfo_C:OnOpen GamePadFocus Error:", ErrorsGamePadFocus)
  end
end

function WBP_BattleRoleInfo_C:GamePadFocus()
  if CheckIsVisility(self.WBP_TotalAttrTips) then
    self.WBP_TotalAttrTips.WBP_InteractTipWidget:SetFocus()
  else
    self.WBP_BattleRoleEquipedWeaponItem:SetFocus()
  end
end

function WBP_BattleRoleInfo_C:InitElementInfo()
  local ElementList = LogicElement.AllActorElementList[self:GetOwningPlayerPawn()]
  if ElementList then
    for index, SingleId in ipairs(ElementList) do
      local BuffInfo = {}
      BuffInfo.ID = SingleId
      BuffInfo.IsElement = true
      self.AllBuffInfos[SingleId] = BuffInfo
      table.insert(self.AllBuffIds, SingleId)
    end
  end
end

function WBP_BattleRoleInfo_C:RefreshBuffList()
  local BuffIndex = 0
  self:HoverBuffTips(false)
  for i, SingleBuffId in ipairs(self.AllBuffIds) do
    local BuffInfo = self.AllBuffInfos[SingleBuffId]
    if BuffInfo then
      local Index = 0
      local IsShowOmitIcon = false
      if BuffInfo.IsElement then
        BuffIndex = BuffIndex + 1
        Index = BuffIndex
      else
        BuffIndex = BuffIndex + 1
        Index = BuffIndex
      end
      local Item = GetOrCreateItem(self.WrapBoxBuffList, Index, self.WBP_BagRoleBuffIcon:GetClass(), false)
      if Item then
        UpdateVisibility(self, true)
        Item:Show(BuffInfo, IsShowOmitIcon, self:GetOwningPlayerPawn(), self)
      end
    end
  end
  HideOtherItem(self.WrapBoxBuffList, BuffIndex + 1)
end

function WBP_BattleRoleInfo_C:HoverBuffTips(bIsShow, BuffInfo, Item)
  UpdateVisibility(self.WBP_BagRoleBuffToolTip, bIsShow)
  if bIsShow then
    print("WBP_BattleRoleInfo_C:HoverBuffTips Buff Id", BuffInfo.ID)
    self.WBP_BagRoleBuffToolTip:InitInfo(BuffInfo)
    ShowCommonTips(nil, Item, self.WBP_BagRoleBuffToolTip)
  end
end

function WBP_BattleRoleInfo_C:BindOnBuffChanged(AddedBuff)
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local BuffData = BuffDataSubsystem:GetDataFormID(AddedBuff.ID)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if BuffData and BuffData.IsNeedShowOnHUD then
    local BuffInfo = {}
    BuffInfo.ID = AddedBuff.ID
    BuffInfo.CurrentCount = AddedBuff.CurrentCount
    BuffInfo.BuffData = BuffData
    BuffInfo.IsElement = false
    BuffInfo.Target = Character
    if not self.AllBuffInfos[AddedBuff.ID] then
      table.insert(self.AllBuffIds, AddedBuff.ID)
    end
    self.AllBuffInfos[AddedBuff.ID] = BuffInfo
    self:RefreshBuffList()
  end
end

function WBP_BattleRoleInfo_C:BindOnBuffRemoved(RemovedBuff)
  table.RemoveItem(self.AllBuffIds, RemovedBuff.ID)
  self.AllBuffInfos[RemovedBuff.ID] = nil
  self:RefreshBuffList()
end

function WBP_BattleRoleInfo_C:InitBuffInfo()
  local BuffComp = self:GetOwningPlayerPawn():GetComponentByClass(UE.UBuffComponent)
  if not BuffComp then
    return
  end
  local BuffDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.UBuffDataGISubsystem:StaticClass())
  if not BuffDataSubsystem then
    return
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  for i, SingleBuffInfo in iterator(BuffComp.AllBuffInfo.AllBuffInfo) do
    local BuffData = BuffDataSubsystem:GetDataFormID(SingleBuffInfo.ID)
    if BuffData and BuffData.IsNeedShowOnHUD then
      local BuffInfo = {}
      BuffInfo.ID = SingleBuffInfo.ID
      BuffInfo.CurrentCount = SingleBuffInfo.CurrentCount
      BuffInfo.BuffData = BuffData
      BuffInfo.IsElement = false
      BuffInfo.Target = Character
      self.AllBuffInfos[SingleBuffInfo.ID] = BuffInfo
      table.insert(self.AllBuffIds, SingleBuffInfo.ID)
    end
  end
end

function WBP_BattleRoleInfo_C:BindOnClientUpdateInscriptionCD(InscriptionId, RemainTime)
  local LogicCommandSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
  if not LogicCommandSubsystem then
    return
  end
  local DataAssest = GetLuaInscription(InscriptionId)
  if not DataAssest then
    return
  end
  if not DataAssest.InscriptionCDData.bIsShowCD then
    print(InscriptionId, "\228\184\141\230\152\190\231\164\186")
    return
  end
  if not DataAssest.InscriptionCDData.bIsShowCDInBuff then
    print(InscriptionId, "\228\184\141\230\152\190\231\164\186")
    return
  end
  if RemainTime > 0 then
    local BuffInfo = {}
    BuffInfo.ID = InscriptionId
    BuffInfo.IsElement = false
    BuffInfo.IsInscription = true
    local GS = UE.UGameplayStatics.GetGameState(self)
    BuffInfo.StartTime = GS:GetServerWorldTimeSeconds()
    BuffInfo.RemainTime = RemainTime
    if not table.Contain(self.AllBuffIds, InscriptionId) then
      BuffInfo.Duration = RemainTime
      table.insert(self.AllBuffIds, InscriptionId)
      self.AllBuffInfos[InscriptionId] = BuffInfo
    else
      local TempInfo = self.AllBuffInfos[InscriptionId]
      TempInfo.StartTime = GS:GetServerWorldTimeSeconds()
      TempInfo.RemainTime = RemainTime
    end
  else
    self.AllBuffInfos[InscriptionId] = nil
    table.RemoveItem(self.AllBuffIds, InscriptionId)
  end
  self:RefreshBuffList()
end

function WBP_BattleRoleInfo_C:BindOnRemoveInscriptionItem(InscriptionId)
  self.AllBuffInfos[InscriptionId] = nil
  table.RemoveItem(self.AllBuffIds, InscriptionId)
  self:RefreshBuffList()
end

function WBP_BattleRoleInfo_C:BindOnMainPanelChanged(LastActiveWidget, CurActiveWidget, MainPanel)
  self.MainPanel = MainPanel
  if CurActiveWidget == self then
    local OkRefreshGenericList, ErrorsRefreshGenericList = pcall(self.RefreshGenericList, self)
    if not OkRefreshGenericList then
      UnLua.LogError("WBP_BattleRoleInfo_C:BindOnMainPanelChanged RefreshGenericList Error:", ErrorsRefreshGenericList)
    end
    local OkRefreshAttrDisplay, ErrorsRefreshAttrDisplay = pcall(self.RefreshAttrDisplay, self)
    if not OkRefreshAttrDisplay then
      UnLua.LogError("WBP_BattleRoleInfo_C:BindOnMainPanelChanged RefreshAttrDisplay Error:", ErrorsRefreshAttrDisplay)
    end
    local OkTotalAttrTipsHide, ErrorsTotalAttrTipsHide = pcall(self.WBP_TotalAttrTips.Hide, self.WBP_TotalAttrTips)
    if not OkTotalAttrTipsHide then
      UnLua.LogError("WBP_BattleRoleInfo_C:BindOnMainPanelChanged WBP_TotalAttrTips.Hide Error:", ErrorsTotalAttrTipsHide)
    end
    self:PlayAnimation(self.Ani_in_switch)
    self.WBP_AbridgeAttrTips:PlayAnimation(self.WBP_AbridgeAttrTips.Ani_in)
    local OkGamePadFocus, ErrorsGamePadFocus = pcall(self.GamePadFocus, self)
    if not OkGamePadFocus then
      UnLua.LogError("WBP_BattleRoleInfo_C:BindOnMainPanelChanged GamePadFocus Error:", ErrorsGamePadFocus)
    end
  elseif LastActiveWidget == self and CurActiveWidget ~= self then
    self.WBP_TotalAttrTips:Hide()
  end
end

function WBP_BattleRoleInfo_C:RefreshInfo(HeroId)
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if not RowInfo then
    print("BattleRoleInfo not found character row info, Character Id:", HeroId)
    return
  end
  self.CurHeroId = HeroId
  self.Txt_Name:SetText(RowInfo.Name)
  self.Txt_NickName:SetText(RowInfo.NickName)
  local OkRefreshSkillInfo, ErrorsRefreshSkillInfo = pcall(self.RefreshSkillInfo, self, RowInfo)
  if not OkRefreshSkillInfo then
    UnLua.LogError("WBP_BattleRoleInfo_C:RefreshInfo RefreshSkillInfo Error:", ErrorsRefreshSkillInfo)
  end
  local OkRefreshWeaponSlotList, ErrorsRefreshWeaponSlotList = pcall(self.RefreshWeaponSlotList, self)
  if not OkRefreshWeaponSlotList then
    UnLua.LogError("WBP_BattleRoleInfo_C:RefreshInfo RefreshWeaponSlotList Error:", ErrorsRefreshWeaponSlotList)
  end
  local OkRefreshGenericList, ErrorsRefreshGenericList = pcall(self.RefreshGenericList, self)
  if not OkRefreshGenericList then
    UnLua.LogError("WBP_BattleRoleInfo_C:RefreshInfo RefreshGenericList Error:", ErrorsRefreshGenericList)
  end
  local OkRefreshAttrDisplay, ErrorsRefreshAttrDisplay = pcall(self.RefreshAttrDisplay, self)
  if not OkRefreshAttrDisplay then
    UnLua.LogError("WBP_BattleRoleInfo_C:RefreshInfo RefreshAttrDisplay Error:", ErrorsRefreshAttrDisplay)
  end
  local Text = RowInfo.Desc
  self.Txt_BGDesc:SetText(Text)
end

function WBP_BattleRoleInfo_C:OnUpdateTeamSpirit(UserID)
  if UserID == tonumber(DataMgr.GetUserId()) then
    return
  end
  self:RefreshGenericList()
end

function WBP_BattleRoleInfo_C:RefreshGenericList()
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return
  end
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  local RGSpecificModifyComponent = Character:GetComponentByClass(UE.URGSpecificModifyComponent:StaticClass())
  if RGGenericModifyComponent and RGSpecificModifyComponent then
    local BagRoleGenericItemCls = self.WBP_BagRoleGenericItem:StaticClass()
    local Index = 1
    for i, v in iterator(self.SlotList) do
      local Result, RGGenericModifyData = RGGenericModifyComponent:TryGetModifyBySlot(v)
      local GenericModifyItem = GetOrCreateItem(self.WrapBoxGenericList, Index, BagRoleGenericItemCls)
      if Result then
        local bIsLagacy = false
        if BattleLagacyModule:CheckBattleLagacyIsActive() then
          bIsLagacy = tonumber(BattleLagacyData.CurBattleLagacyData.BattleLagacyId) == tonumber(RGGenericModifyData.ModifyId)
        end
        GenericModifyItem:InitBagRoleGenericItem(RGGenericModifyData, v, self.UpdateGenericModifyTipsFunc, self, bIsLagacy)
      else
        GenericModifyItem:InitBagRoleGenericItem(nil, v, self.UpdateGenericModifyTipsFunc, self)
      end
      Index = Index + 1
    end
    HideOtherItem(self.WrapBoxGenericList, Index)
    local passiveIndex = 1
    local AllPassiveModifies = LogicGenericModify:GetAllPassiveModifies()
    local AllSpecificModifies = RGSpecificModifyComponent:GetActivatedModifies()
    for i, v in iterator(AllPassiveModifies) do
      local GenericModifyItem = GetOrCreateItem(self.WrapBoxGenericPassiveList, passiveIndex, BagRoleGenericItemCls)
      local bIsLagacy = false
      if BattleLagacyModule:CheckBattleLagacyIsActive() then
        bIsLagacy = tonumber(BattleLagacyData.CurBattleLagacyData.BattleLagacyId) == tonumber(v.ModifyId)
      end
      GenericModifyItem:InitBagRoleGenericItem(v, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self, bIsLagacy)
      GenericModifyItem:SetRenderScale(UE.FVector2D(GenericModifyItemScale))
      passiveIndex = passiveIndex + 1
    end
    for i, v in iterator(AllSpecificModifies) do
      local GenericModifyItem = GetOrCreateItem(self.WrapBoxGenericPassiveList, passiveIndex, BagRoleGenericItemCls)
      GenericModifyItem:InitSpecificModifyItem(v, UE.ERGGenericModifySlot.None, self.UpdateGenericModifyTipsFunc, self)
      GenericModifyItem:SetRenderScale(UE.FVector2D(GenericModifyItemScale))
      passiveIndex = passiveIndex + 1
    end
    for i = passiveIndex, MaxGenericModifyNum do
      local GenericModifyItem = GetOrCreateItem(self.WrapBoxGenericPassiveList, passiveIndex, BagRoleGenericItemCls)
      GenericModifyItem:InitBagRoleGenericItem(nil, UE.ERGGenericModifySlot.None)
      GenericModifyItem:SetRenderScale(UE.FVector2D(GenericModifyItemScale))
      passiveIndex = passiveIndex + 1
    end
    HideOtherItem(self.WrapBoxGenericPassiveList, passiveIndex)
  end
end

function WBP_BattleRoleInfo_C:UpdateGenericItemHightLight(GenricModifyDataList, bIsHightLight)
  if bIsHightLight then
    for i = 1, self.WrapBoxGenericList:GetChildrenCount() do
      local GenericModifyItem = self.WrapBoxGenericList:GetChildAt(i - 1)
      if GenericModifyItem.ModifyData then
        for i, v in ipairs(GenricModifyDataList) do
          if v.ModifyId == GenericModifyItem.ModifyData.ModifyId then
            GenericModifyItem:HightLight(true)
            break
          end
        end
      else
        GenericModifyItem:HightLight(false)
      end
    end
  else
    for i = 1, self.WrapBoxGenericList:GetChildrenCount() do
      local GenericModifyItem = self.WrapBoxGenericList:GetChildAt(i - 1)
      GenericModifyItem:HightLight(false)
    end
  end
end

function WBP_BattleRoleInfo_C:UpdateGenericModifyTipsFunc(bIsShow, Data, ModifyChooseTypeParam, Slot, Item)
  if bIsShow then
    if ModifyChooseTypeParam == ModifyChooseType.GenericModify then
      self.WBP_GenericModifyBagTips:InitGenericModifyTips(Data.ModifyId, false, Slot)
    elseif ModifyChooseTypeParam == ModifyChooseType.SpecificModify then
      self.WBP_GenericModifyBagTips:InitSpecificModifyTips(Data.ModifyId, false)
    end
    ShowCommonTips(nil, Item, self.WBP_GenericModifyBagTips)
  else
    self.WBP_GenericModifyBagTips:Hide()
  end
end

function WBP_BattleRoleInfo_C:GetMaxAttributeValue(MaxAttribute)
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return 0
  end
  local ASC = UE.UAbilitySystemBlueprintLibrary.GetAbilitySystemComponent(Character)
  if not ASC then
    return 0
  end
  local MaxAttributeValue = UE.UAbilitySystemBlueprintLibrary.GetFloatAttributeFromAbilitySystemComponent(ASC, MaxAttribute, nil)
  return MaxAttributeValue
end

function WBP_BattleRoleInfo_C:RefreshSkillInfo(RowInfo)
  local a
  local RoleStar = 1
  for iSkillType, vSkillType in iterator(self.SkillQueue) do
    for i, SingleSkillId in ipairs(RowInfo.SkillList) do
      local SkillRowInfo = LogicRole.GetSkillTableRow(SingleSkillId)
      if SkillRowInfo then
        local nameStr = "WBP_BattleRoleSkillItem" .. iSkillType
        local TargetSkillLevelInfo = SkillRowInfo[RoleStar]
        if TargetSkillLevelInfo then
          if vSkillType == TargetSkillLevelInfo.Type then
            local Item = self[nameStr]
            if Item then
              Item:RefreshInfo(TargetSkillLevelInfo)
            end
            break
          end
        elseif SkillRowInfo[1] then
          if vSkillType == SkillRowInfo[1].Type then
            local Item = self[nameStr]
            if Item then
              Item:RefreshInfo(SkillRowInfo[1])
            end
            break
          end
        else
          print("WBP_BattleRoleInfo_C:RefreshSkillInfo not found star1 info, skillgroupid:", SingleSkillId)
        end
      end
    end
  end
end

function WBP_BattleRoleInfo_C:OnEquipedWeaponInfoChanged(HeroId)
  if self.CurHeroId == HeroId then
    self:RefreshWeaponSlotList()
  end
end

function WBP_BattleRoleInfo_C:RefreshWeaponSlotList()
  local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  if EquippedWeaponInfo and EquippedWeaponInfo[1] then
    self.WBP_BattleRoleEquipedWeaponItem:InitWeaponItem(EquippedWeaponInfo[1], true, self)
  else
    LogicOutsideWeapon.RequestEquippedWeaponInfo(self.CurHeroId)
  end
end

function WBP_BattleRoleInfo_C:RefreshAttrDisplay()
  self.WBP_AbridgeAttrTips:InitAbridgeAttrTips(self:GetAttrDisplayList(), self)
end

function WBP_BattleRoleInfo_C:ExpandAttr()
  local EquippedWeaponInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
  local resId = -1
  if EquippedWeaponInfo and EquippedWeaponInfo[1] then
    resId = EquippedWeaponInfo[1].resourceId
  end
  self.WBP_TotalAttrTips:Show(self:GetAttrDisplayList(), resId, self:GetModifyAttrList(), self)
  self.WBP_TotalAttrTips:SetFocus()
end

function WBP_BattleRoleInfo_C:BackToParentView()
  self.WBP_AbridgeAttrTips.BP_ButtonExpand:SetFocus()
end

function WBP_BattleRoleInfo_C:GetAttrDisplayList()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local DataTableTemp = DTSubsystem:GetDataTable(DT.DT_HeroBasicAttribute)
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(DataTableTemp)
  local RowNameTb = RowNames:ToTable()
  table.sort(RowNameTb, SortAttrRow)
  return RowNameTb
end

function WBP_BattleRoleInfo_C:GetModifyAttrList()
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return {}
  end
  local DataTableTemp = DTSubsystem:GetDataTable(DT.DT_HeroModifyAttribute)
  local RowNames = UE.TArray(UE.FName)
  RowNames = UE.UDataTableFunctionLibrary.GetDataTableRowNames(DataTableTemp)
  local RowNameTb = RowNames:ToTable()
  table.sort(RowNameTb, SortModifyAttrRow)
  return RowNameTb
end

function WBP_BattleRoleInfo_C:BindOnShowSkillTips(IsShow, SkillGroupId, KeyName, bIsWeaponSkill, Item)
  if IsShow then
    local GenricModifyDataList = self:GetGenericListBySkillGroupId(SkillGroupId)
    self:UpdateGenericItemHightLight(GenricModifyDataList, true)
    self.NormalSkillTip:RefreshInfo(SkillGroupId, KeyName, GenricModifyDataList)
    if 302 == SkillGroupId then
      ShowCommonTips(nil, Item, self.NormalSkillTip, nil, nil, nil, nil, LogicCommonTips.ENUMTipsPosType.RIGHTDOWN)
    else
      ShowCommonTips(nil, Item, self.NormalSkillTip)
    end
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:UpdateGenericItemHightLight({}, false)
  end
end

function WBP_BattleRoleInfo_C:BindOnShowFetterSkillTips(IsShow, SkillGroupId, HeroId)
  if IsShow then
    local GenricModifyDataList = self:GetGenericListBySkillGroupId(SkillGroupId)
    self:UpdateGenericItemHightLight(GenricModifyDataList, true)
    self.SkillTips:RefreshInfo(SkillGroupId, HeroId, GenricModifyDataList)
    self.SkillTips:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  else
    self.SkillTips:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:UpdateGenericItemHightLight({}, false)
  end
end

function WBP_BattleRoleInfo_C:GetGenericListBySkillGroupId(SkillGroupId)
  local SkillGroupInfo = LogicRole.GetSkillTableRow(SkillGroupId)
  if not SkillGroupInfo then
    print("WBP_BattleRoleInfo_C GetGenericListBySkillGroupId not found skill group info,SkillGroupId:", SkillGroupId)
    return {}
  end
  local TargetSkillInfo = SkillGroupInfo[1]
  if not TargetSkillInfo then
    return {}
  end
  local Character = UE.UGameplayStatics.GetPlayerCharacter(self, 0)
  if not Character then
    return {}
  end
  local GenericNameList = {}
  local SkillId = TargetSkillInfo.ID
  local RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
  local RGSpecificModifyComponent = Character:GetComponentByClass(UE.URGSpecificModifyComponent:StaticClass())
  local OutGenericAry = UE.TArray(UE.FRGGenericModify)
  RGGenericModifyComponent:GetAllSlotModifies(OutGenericAry)
  local passiveGenericModifyList = LogicGenericModify:GetAllPassiveModifies()
  OutGenericAry:Append(passiveGenericModifyList)
  for i, v in pairs(OutGenericAry) do
    local ResultGenericModify, RowDataGenericModify = GetRowData(DT.DT_GenericModify, tostring(v.ModifyId))
    if ResultGenericModify and RowDataGenericModify.SkillId == SkillId then
      local RicTextTag = self.GenericGroupToRichText:Find(RowDataGenericModify.GroupId)
      local Name = GetInscriptionName(v.ModifyId)
      if RicTextTag then
        Name = string.format("<%s>%s</>", RicTextTag, Name)
      end
      local GenericData = {
        Name = Name,
        ModifyId = v.ModifyId,
        Type = ModifyChooseType.GenericModify
      }
      table.insert(GenericNameList, GenericData)
    end
  end
  local AllSpecificModifies = RGSpecificModifyComponent:GetActivatedModifies()
  for i, v in pairs(AllSpecificModifies) do
    local ResultGenericModify, RowDataGenericModify = GetRowData(DT.DT_ModRefresh, tostring(v.ModifyId))
    if ResultGenericModify and RowDataGenericModify.SkillId == SkillId then
      local RicTextTag = self.ModRichText
      local Name = string.format("<%s>%s</>", RicTextTag, GetInscriptionName(v.ModifyId))
      local GenericData = {
        Name = Name,
        ModifyId = v.ModifyId,
        Type = ModifyChooseType.SpecificModify
      }
      table.insert(GenericNameList, GenericData)
    end
  end
  return GenericNameList
end

function WBP_BattleRoleInfo_C:Hover(IsHover, WeaponInfo)
  self:BindOnLobbyWeaponSlotHoverStatusChanged(IsHover, WeaponInfo)
end

function WBP_BattleRoleInfo_C:OnEscClick()
  if UE.RGUtil.IsUObjectValid(self.MainPanel) then
    self.MainPanel:ExitMainPanel()
  end
end

function WBP_BattleRoleInfo_C:BindOnLobbyWeaponSlotHoverStatusChanged(IsHover, WeaponInfo)
  if IsHover then
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    ShowCommonTips(nil, self.WBP_BattleRoleEquipedWeaponItem, self.WeaponItemDisplayInfo)
    self.WeaponItemDisplayInfo:SetIsSelected(true)
    self:RefreshWeaponDisplayInfoTip(WeaponInfo, true)
    self.WeaponItemDisplayInfo.Priority = 2
    self.WeaponItemDisplayInfo:PushInputAction()
  else
    self.WeaponItemDisplayInfo.Priority = 0
    self.WeaponItemDisplayInfo:PopSelfInputAction()
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_BattleRoleInfo_C:RefreshWeaponDisplayInfoTip(WeaponInfo, IsEquipped)
  self.WeaponItemDisplayInfo:InitInfo(WeaponInfo.resourceId, {}, true, WeaponInfo)
end

function WBP_BattleRoleInfo_C:OnExitPanel()
  self:PlayAnimation(self.Ani_out)
end

function WBP_BattleRoleInfo_C:OnClose()
  LogicRole.HideAllHeroLight()
  LogicRole.ChangeRoleSkyLight(false)
  self:BindOnLobbyWeaponSlotHoverStatusChanged(false, nil)
end

function WBP_BattleRoleInfo_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.RoleSkillTip, WBP_BattleRoleInfo_C.BindOnShowSkillTips, self)
  EventSystem.RemoveListener(EventDef.Lobby.RoleFetterSkillTip, WBP_BattleRoleInfo_C.BindOnShowFetterSkillTips, self)
  EventSystem.RemoveListener(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, WBP_BattleRoleInfo_C.BindOnLobbyWeaponSlotHoverStatusChanged, self)
  EventSystem.RemoveListener(EventDef.MainPanel.MainPanelChanged, WBP_BattleRoleInfo_C.BindOnMainPanelChanged, self)
  EventSystem.RemoveListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.OnEquipedWeaponInfoChanged)
  UnListenObjectMessage(GMP.MSG_World_GenericModify_OnUpdateTeamSpirit, self)
end

return WBP_BattleRoleInfo_C
