local ListContainer = require("Rouge.UI.Common.ListContainer")
local rapidjson = require("rapidjson")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local ViewBase = require("Framework.UIMgr.ViewBase")
local WBP_RoleMain_C = UnLua.Class(ViewBase)
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local HeroIsLockedWaveId = 1141
local LuaCurveNames = {}
local PauseKey = "PauseGame"

function WBP_RoleMain_C:Construct()
  LuaCurveNames = self.CurveNames:ToTable()
end

function WBP_RoleMain_C:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("RoleMainViewModel")
end

function WBP_RoleMain_C:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_RoleMain_C:BindClickHandler()
  EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, WBP_RoleMain_C.BindOnChangeRoleItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.RoleSkillTip, WBP_RoleMain_C.BindOnShowSkillTips)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo)
  EventSystem.AddListenerNew(EventDef.Lobby.OnChangeCanDirectChangedStatus, self, self.OnChangeCanDirectChangedStatus)
  self.Btn_Choose.OnClicked:Add(self, self.BindOnChooseButtonClicked)
  self.Btn_Choose.OnHovered:Add(self, self.BindOnChooseButtonHovered)
  self.Btn_Choose.OnUnhovered:Add(self, self.BindOnChooseButtonUnhovered)
  self.Btn_Go.OnClicked:Add(self, self.BindOnLinkButtonClicked)
  self.Button_waiguan.OnClicked:Add(self, self.BindOnOpenAppearance)
  self.Button_waiguan.OnHovered:Add(self, self.BindOnAppearanceButtonHovered)
  self.Button_waiguan.OnUnhovered:Add(self, self.BindOnAppearanceButtonUnhovered)
  self.Btn_DetailAttribute.OnClicked:Add(self, self.BindOnDetailAttributeButtonClicked)
  self.Btn_DetailAttribute.OnHovered:Add(self, self.BindOnDetailAttributeButtonHovered)
  self.Btn_DetailAttribute.OnUnhovered:Add(self, self.BindOnDetailAttributeButtonUnhovered)
  self.Btn_AuthorizedProgram.OnHovered:Add(self, self.BindOnAuthorizedProgramButtonHovered)
  self.Btn_AuthorizedProgram.OnUnhovered:Add(self, self.BindOnAuthorizedProgramButtonUnhovered)
  self.BP_ButtonWithSoundProficiency.OnClicked:Add(self, self.BindOnProficiencyClicked)
  self.BP_ButtonWithSoundChip.OnClicked:Add(self, self.BindOnChipClicked)
  self.Btn_Puzzle.OnClicked:Add(self, self.BindOnPuzzleButtonClicked)
  self.FetterSlotUnLockClickTime = 0
end

function WBP_RoleMain_C:UnBindClickHandler()
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, WBP_RoleMain_C.BindOnChangeRoleItemClicked)
  EventSystem.RemoveListener(EventDef.Lobby.RoleSkillTip, WBP_RoleMain_C.BindOnShowSkillTips)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, self.BindOnUpdateMyHeroInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, WBP_RoleMain_C.BindOnEquippedWeaponInfoChanged, self)
  EventSystem.RemoveListener(EventDef.Lobby.WeaponSlotSelected, WBP_RoleMain_C.BindOnWeaponSlotSelected, self)
  EventSystem.RemoveListener(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, WBP_RoleMain_C.BindOnLobbyWeaponSlotHoverStatusChanged, self)
  EventSystem.RemoveListenerNew(EventDef.Lobby.OnChangeCanDirectChangedStatus, self, self.OnChangeCanDirectChangedStatus)
end

function WBP_RoleMain_C:OnAnimationFinished(Animation)
  if Animation == self.ani_rolemain_out then
    self:BindOnOutAnimationFinished()
  elseif Animation == self.Ani_Btn_chuzhan then
    UpdateVisibility(self.CanvasPanel_Cz, false)
  end
end

function WBP_RoleMain_C:BindOnOutAnimationFinished()
  UIMgr:Hide(ViewID.UI_WeaponSub)
  UIMgr:Hide(ViewID.UI_WeaponMain)
  self.IsPlayOutAnimation = true
  EventSystem.Invoke(EventDef.Lobby.OnLobbyLabelSelected, LogicLobby.GetPendingSelectedLabelTagName())
end

function WBP_RoleMain_C:CanDirectSwitch(NextTabWidget)
  if not self.IsPlayOutAnimation then
    if not self:IsAnimationPlaying(self.ani_rolemain_out) then
      self:PlayAnimation(self.ani_rolemain_out, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1, false)
    end
    self.RoleChangeList:PlayOutAnimation()
  end
  return self.IsPlayOutAnimation
end

function WBP_RoleMain_C:BindOnOpenAppearance()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.HERO_SKIN) then
    return
  end
  UIMgr:Show(ViewID.UI_Apearance, true, self.CurHeroId)
end

function WBP_RoleMain_C:BindOnAppearanceButtonHovered()
  self.AppearanceButtonHoverPanel:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
end

function WBP_RoleMain_C:BindOnAppearanceButtonUnhovered()
  self.AppearanceButtonHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_RoleMain_C:BindOnDetailAttributeButtonClicked()
  self:ExpandAttr()
end

function WBP_RoleMain_C:BindOnDetailAttributeButtonHovered()
  self.Img_DetailAttributeHover:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_RoleMain_C:BindOnDetailAttributeButtonUnhovered()
  self.Img_DetailAttributeHover:SetVisibility(UE.ESlateVisibility.Hidden)
end

function WBP_RoleMain_C:BindOnAuthorizedProgramButtonHovered()
  self.AuthorizedProgramButtonHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_RoleMain_C:BindOnAuthorizedProgramButtonUnhovered()
  self.AuthorizedProgramButtonHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_RoleMain_C:BindOnProficiencyClicked()
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.HERO_MASTERY) then
    return
  end
  if not DataMgr.IsOwnHero(self.CurHeroId) then
    ShowWaveWindow(HeroIsLockedWaveId, {})
    return
  end
  UIMgr:Show(ViewID.UI_DevelopMain, true, 3, self.CurHeroId)
end

function WBP_RoleMain_C:BindOnChipClicked()
  if not DataMgr.IsOwnHero(self.CurHeroId) then
    ShowWaveWindow(HeroIsLockedWaveId, {})
    return
  end
  UIMgr:Show(ViewID.UI_DevelopMain, true, 2, self.CurHeroId)
end

function WBP_RoleMain_C:BindOnPuzzleButtonClicked(...)
  local PuzzelSystemID = 3
  local SystemUnlockModule = ModuleManager:Get("SystemUnlockModule")
  if SystemUnlockModule and not SystemUnlockModule:CheckIsSystemUnlock(PuzzelSystemID) then
    local result, row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBSystemUnlock, PuzzelSystemID)
    if result then
      if CheckNSLocTbIsValid(row.UnlockTips) then
        ShowWaveWindow(1407, {
          row.UnlockTips
        })
      else
        ShowWaveWindow(1401)
      end
    end
    return
  end
  local SystemOpenMgr = ModuleManager:Get("SystemOpenMgr")
  if SystemOpenMgr and not SystemOpenMgr:IsSystemOpen(SystemOpenID.MATRIX) then
    return
  end
  if not DataMgr.IsOwnHero(self.CurHeroId) then
    ShowWaveWindow(HeroIsLockedWaveId, {})
    return
  end
  UIMgr:Show(ViewID.UI_DevelopMain, true, 4, self.CurHeroId)
end

function WBP_RoleMain_C:ExpandAttr()
  EventSystem.Invoke(EventDef.RoleMain.OnTotalAttributeTipsVisChanged, true, self.CurHeroId)
end

function WBP_RoleMain_C:ShowByLobbyPanel()
  self.IsShowByLobbyPanel = true
end

function WBP_RoleMain_C:OnShow()
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  self:BindClickHandler()
  if not self.TargetRoleActor or not self.TargetRoleActor:IsValid() then
    local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(self, "RoleMainHero", nil)
    for i, SingleRoleActor in pairs(RoleActorList) do
      self.TargetRoleActor = SingleRoleActor
      break
    end
  end
  if not self.IsShowByLobbyPanel then
    LogicRole.SetCurSelectRoleId(-1)
  end
  self:Show()
  LogicLobby:ChangeLobbyBGVis(true)
  self.WBP_ChatView:FocusInput()
  EventSystem.Invoke(EventDef.Lobby.LobbyWeaponSlotHoverStatusChanged, false)
  self:PlayAnimation(self.Ani_loop_chuzhan, 0.0, 0)
end

function WBP_RoleMain_C:OnHide()
  self.IsShowByLobbyPanel = false
  self:Hide()
  self.WBP_ChatView:UnfocusInput()
  if UE.URGGameplayStatics.TryGetWorld(self.TargetRoleActor) then
    self.TargetRoleActor:GlitchAniEnd()
    self.TargetRoleActor:EnableInputActor(false)
  end
  EventSystem.Invoke(EventDef.RoleMain.OnTotalAttributeTipsVisChanged, false, self.CurHeroId)
  self:UnBindClickHandler()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
end

function WBP_RoleMain_C:OnHideByOther()
  if UE.URGGameplayStatics.TryGetWorld(self.TargetRoleActor) then
    self.TargetRoleActor:GlitchAniEnd()
    self.TargetRoleActor:EnableInputActor(false)
  end
  self:UnBindClickHandler()
end

function WBP_RoleMain_C:FocusPanel()
end

function WBP_RoleMain_C:UpdateChip()
  if not DataMgr.IsOwnHero(self.CurHeroId) then
    UpdateVisibility(self.CanvasPanelChip, false)
    return
  end
  UpdateVisibility(self.CanvasPanelChip, true)
  local chipViewModel = UIModelMgr:Get("ChipViewModel")
  local equipChipMap = chipViewModel:GetEquipedSlotToChipByHeroId(self.CurHeroId)
  local tbChipSlot = LuaTableMgr.GetLuaTableByName(TableNames.TBChipSlots)
  if not tbChipSlot then
    return
  end
  local idx = 1
  for i, v in ipairs(tbChipSlot) do
    local bUnLock = chipViewModel:CheckSlotIsUnLock(i)
    if bUnLock then
      local item = GetOrCreateItem(self.HorizontalBoxChipSlot, idx, self.WBP_RoleMainChipSlotItem:GetClass())
      item:InitRoleMainChipSlotItem(equipChipMap[v.ID])
      idx = idx + 1
    end
  end
  HideOtherItem(self.HorizontalBoxChipSlot, idx)
end

function WBP_RoleMain_C:BindOnEquippedWeaponInfoChanged(HeroId)
  print("WBP_RoleMain_C:BindOnEquippedWeaponInfoChanged", HeroId, self.CurHeroId)
  if self.CurHeroId ~= HeroId then
    return
  end
  self:RefreshWeaponSlotList()
  if self.TargetRoleActor then
    self.TargetRoleActor:ChangeWeaponMesh(self.CurHeroId)
  end
  if self.IsSelectWeapon then
    self:RefreshWeaponSelectList()
  end
  self:RefreshWeaponSkillInfo()
  self.IsNeedPlayWeaponAnimByChangeHero = false
end

function WBP_RoleMain_C:BindOnWeaponSlotSelected(IsSelect, SlotId)
  if not DataMgr.IsOwnHero(self.CurHeroId) then
    if IsSelect then
      ShowWaveWindow(HeroIsLockedWaveId, {})
    end
    return
  end
  self.IsSelectWeapon = IsSelect
  if IsSelect then
    self.CurSelectWeaponSlotId = SlotId
    self:ShowWeapon(true)
  else
  end
end

function WBP_RoleMain_C:ShowWeapon(bIsWeaponSub, SlotIdx)
  local UserClickStatisticsMgr = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(GameInstance, UE.URGUserClickStatistics:StaticClass())
  if UserClickStatisticsMgr then
    UserClickStatisticsMgr:AddClickStatistics("CharacterWeapon")
  end
  UIMgr:Show(ViewID.UI_DevelopMain, true, 1, self.CurHeroId)
end

function WBP_RoleMain_C:BindOnWeaponListChanged()
  if self.TargetRoleActor then
    self.TargetRoleActor:ChangeWeaponMesh(self.CurHeroId)
  end
  self:RefreshWeaponSelectList()
end

function WBP_RoleMain_C:BindOnLobbyWeaponItemHovered(IsHover, WeaponInfo, IsEquipped)
  if IsHover then
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshWeaponDisplayInfoTip(WeaponInfo, IsEquipped)
  else
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_RoleMain_C:BindOnLobbyWeaponSlotHoverStatusChanged(IsHover, WeaponInfo)
  if IsHover then
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    ShowCommonTips(nil, self.FirstWeaponItem, self.WeaponItemDisplayInfo, nil, nil)
    self.WeaponItemDisplayInfo:SetIsSelected(true)
    self:RefreshWeaponDisplayInfoTip(WeaponInfo, true)
  else
    self.WeaponItemDisplayInfo:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_RoleMain_C:OnChangeCanDirectChangedStatus(bCanDirectChanged)
  self.IsPlayOutAnimation = bCanDirectChanged
end

function WBP_RoleMain_C:RefreshWeaponDisplayInfoTip(WeaponInfo, IsEquipped)
  local AccessoryList = {}
  local TipText
  local IsShowOperateIcon = false
  if IsEquipped then
    TipText = nil
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
  self.WeaponItemDisplayInfo:InitInfo(WeaponInfo.resourceId, AccessoryList, false, WeaponInfo)
  if IsEquipped then
  elseif TipText then
    self.WeaponItemDisplayInfo:ShowTipPanel(TipText, IsShowOperateIcon)
  end
end

function WBP_RoleMain_C:RefreshWeaponSelectList()
end

function WBP_RoleMain_C:RefreshProfyData()
  if not self.CurHeroId then
    return
  end
  local maxReceiveLv = ProficiencyData:GetMaxUnlockProfyLevel(self.CurHeroId)
  self.TextProfyLv:SetText(maxReceiveLv)
  local curProfyExp = ProficiencyData:GetCurProfyExp(self.CurHeroId)
  local nextLevelProfyMaxExp = math.max(ProficiencyData:GetNextLevelProfyMaxExp(self.CurHeroId), 1)
  local matInst = self.Img_ExpProgress:GetDynamicMaterial()
  if matInst then
    matInst:SetScalarParameterValue("CirclePrecent", curProfyExp / nextLevelProfyMaxExp)
  end
  local tbProfy = LuaTableMgr.GetLuaTableByName(TableNames.TBProfyLevel)
  if tbProfy and tbProfy[maxReceiveLv] then
    self.TextProfyName:SetText(tbProfy[maxReceiveLv].Name)
    SetImageBrushByPath(self.pro_level, tbProfy.IconPath)
  end
end

function WBP_RoleMain_C:BindOnLinkButtonClicked()
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, self.CurHeroId)
  if Result and RowInfo.LinkId and RowInfo.LinkId ~= "" then
    local ExtraData = {}
    ExtraData.HeroId = self.CurHeroId
    ComLinkForParam(RowInfo.LinkId, nil, RowInfo.ParamList, ExtraData)
  end
end

function WBP_RoleMain_C:BindOnChooseButtonClicked()
  LogicRole.RequestEquipHeroToServer(self.CurHeroId, function()
    self:PlayAnimationForward(self.Ani_Btn_chuzhan, 1, true)
    UpdateVisibility(self.CanvasPanel_Cz, true)
    if self and DataMgr.IsOwnHero(self.CurHeroId) and DataMgr.GetMyHeroInfo().equipHero == self.CurHeroId then
      if self.Txt_ChooseStatusAni then
        self.Txt_ChooseStatusAni:SetText(self.EquipText)
        self.Txt_ChooseStatusAni:SetColorAndOpacity(self.EquippedButtonTextColor)
      end
      UpdateVisibility(self.Txt_ChooseStatusAni, true)
    end
  end)
end

function WBP_RoleMain_C:BindOnChooseButtonHovered()
  self.ChooseButtonHoverPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
end

function WBP_RoleMain_C:BindOnChooseButtonUnhovered()
  self.ChooseButtonHoverPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_RoleMain_C:BindOnRoleInfoButtonClicked()
  LogicRole.RequestMyHeroInfoToServer()
  if DataMgr.IsOwnHero(self.CurHeroId) then
    LogicOutsideWeapon.RequestEquippedWeaponInfo(self.CurHeroId)
  end
  self.RoleWidgetSwitcher:SetActiveWidgetIndex(0)
  self.RoleMainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.FetterMainPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.IsShowFetterPanel = false
end

function WBP_RoleMain_C:ShowFetterHeroPanel()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Role/Fetter/WBP_FetterMain.WBP_FetterMain_C")
  ChangeLobbyCamera(self, "Fetter")
  UIManager:Switch(WidgetClass, true)
  local Widget = UIManager:K2_GetUI(WidgetClass, nil)
  if Widget then
    Widget:InitInfo(self.CurHeroId)
  end
end

function WBP_RoleMain_C:Show()
  self:BindOnRoleInfoButtonClicked()
  LogicRole.IsRoleMainShow = true
  LogicRole.ShowOrHideRoleChangeList(true, LogicRole.CurSelectHeroId, self.RoleChangeList)
  self.Img_DetailAttributeHover:SetVisibility(UE.ESlateVisibility.Hidden)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      if UE.RGUtil.IsUObjectValid(self) and UE.RGUtil.IsUObjectValid(self.TargetRoleActor) then
        self.TargetRoleActor:EnableInputActor(true)
      end
    end
  }, 0.2, false)
  if not self:IsAnimationPlaying(self.ani_rolemain_in) then
    self:PlayAnimation(self.ani_rolemain_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1, false)
  end
  self.RoleChangeList:PlayInAnimation()
  self.IsPlayOutAnimation = false
  BeginnerGuideData:UpdateWidget("RoleChangeList", self.RoleChangeList.RoleList)
  BeginnerGuideData:UpdateWBP("WBP_RoleMain", self)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnRoleMainShow)
end

function WBP_RoleMain_C:BindOnEscKeyPressed()
end

function WBP_RoleMain_C:OnBindUIInput()
  self.WBP_InteractTipWidgetWaiguan:BindInteractAndClickEvent(self, self.BindOnOpenAppearance)
  self.WBP_InteractTipWidgetPuzzel:BindInteractAndClickEvent(self, self.BindOnPuzzleButtonClicked)
end

function WBP_RoleMain_C:OnUnBindUIInput()
  if IsListeningForInputAction(self, PauseKey) then
    StopListeningForInputAction(self, PauseKey, UE.EInputEvent.IE_Pressed)
  end
  self.WBP_InteractTipWidgetWaiguan:UnBindInteractAndClickEvent(self, self.BindOnOpenAppearance)
  self.WBP_InteractTipWidgetPuzzel:UnBindInteractAndClickEvent(self, self.BindOnPuzzleButtonClicked)
end

function WBP_RoleMain_C:OnRollback()
  if not IsListeningForInputAction(self, PauseKey) then
    ListenForInputAction(PauseKey, UE.EInputEvent.IE_Pressed, true, {
      self,
      self.BindOnEscKeyPressed
    })
  end
  self:BindClickHandler()
  LogicRole.IsRoleMainShow = true
  LogicRole.ShowOrHideRoleChangeList(true, LogicRole.CurSelectHeroId, self.RoleChangeList)
  self.Img_DetailAttributeHover:SetVisibility(UE.ESlateVisibility.Hidden)
  if UE.UKismetSystemLibrary.K2_IsValidTimerHandle(self.TimerHanle) then
    UE.UKismetSystemLibrary.K2_ClearAndInvalidateTimerHandle(GameInstance, self.TimerHanle)
  end
  self.TimerHanle = UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    self,
    function()
      if self.TargetRoleActor and self.TargetRoleActor:IsValid() then
        self.TargetRoleActor:EnableInputActor(true)
      end
      if self and IsListeningForInputAction(self, PauseKey) then
        StopListeningForInputAction(self, PauseKey, UE.EInputEvent.IE_Pressed)
      end
    end
  }, 0.2, false)
  if not self:IsAnimationPlaying(self.ani_rolemain_in) then
    self:PlayAnimation(self.ani_rolemain_in, 0.0, 1, UE.EUMGSequencePlayMode.Forward, 1, false)
  end
  self.RoleChangeList:PlayInAnimation()
  self:BindOnChangeRoleItemClicked(self.CurHeroId, true, true)
  self:UpdateChip()
  self.IsPlayOutAnimation = false
  BeginnerGuideData:UpdateWidget("RoleChangeList", self.RoleChangeList.RoleList)
  BeginnerGuideData:UpdateWBP("WBP_RoleMain", self)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnRoleMainShow)
  self:PlayAnimation(self.Ani_loop_chuzhan, 0.0, 0)
end

function WBP_RoleMain_C:LuaTick(deltaSeconds)
  self:AddStandbyTime(deltaSeconds)
end

function WBP_RoleMain_C:EditorMapShow(HeroId)
  self.RoleWidgetSwitcher:SetActiveWidgetIndex(0)
  self.RoleMainPanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.FetterMainPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_RoleMain_C:RefreshWeaponSlotList()
  print("WBP_RoleMain_C:RefreshWeaponSlotList", self.CurHeroId)
  local AllItem = self.WeaponSlotList:GetAllChildren()
  BeginnerGuideData:UpdateWidget("WeaponSlotListItem", AllItem[1])
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
      if self.IsNeedPlayWeaponAnimByChangeHero and SingleItem.PlayAniInAnimation then
        SingleItem:PlayAniInAnimation()
      end
    end
  end
end

function WBP_RoleMain_C:OnResStoneSlotClick(SlotIdx)
  if not DataMgr.IsOwnHero(self.CurHeroId) then
    ShowWaveWindow(HeroIsLockedWaveId, {})
    return
  end
  self:ShowWeapon(false, SlotIdx)
end

function WBP_RoleMain_C:Hide()
  LogicRole.IsRoleMainShow = false
  self.IsPlayOutAnimation = true
  self:BindOnWeaponSlotSelected(false)
  EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false)
  LogicRole.ShowOrHideRoleChangeList(false)
  self.CurHeroId = -1
  LogicAudio.OnLobbyPlayHeroSound(-1)
  self:BindOnShowSkillTips(false)
  if self.PlayingVoiceID then
    UE.URGBlueprintLibrary.StopVoice(self.PlayingVoiceID)
  end
end

function WBP_RoleMain_C:BindOnChangeRoleItemClicked(HeroId, bForceUpdate, bNotShowGlitchMatEffect)
  local bShowGlitchMatEffect = not bNotShowGlitchMatEffect
  if self.CurHeroId and self.CurHeroId == HeroId and not bForceUpdate then
    return
  end
  self.WBP_RedDotViewProfy:ChangeRedDotIdByTag(HeroId)
  self.WBP_RedDotViewAppearance:ChangeRedDotIdByTag(HeroId)
  self.WBP_RedDotViewWeapon:ChangeRedDotIdByTag(HeroId)
  if self.TargetRoleActor then
    local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
    if CharacterRow then
      self.TargetRoleActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
    self.TargetRoleActor:ChangeBodyMesh(HeroId, nil, nil, true, bShowGlitchMatEffect)
    self.TargetRoleActor:ChangeChildActorDefaultRotation(HeroId)
    LogicRole.ShowSkinLightMap(LogicRole.GetHeroDefaultSkinId(HeroId))
  end
  local RowInfo = LogicRole.GetCharacterTableRow(HeroId)
  if not RowInfo then
    print("RoleMain not found character row info, Character Id:", HeroId)
    return
  end
  self.CurHeroId = HeroId
  LogicRole.SetCurSelectRoleId(HeroId)
  self.Txt_Name:SetText(RowInfo.Name)
  self.Txt_BGName:SetText(RowInfo.Name)
  self.Txt_NickName:SetText(RowInfo.NickName)
  self.IsNeedPlayWeaponAnimByChangeHero = true
  if DataMgr.IsOwnHero(self.CurHeroId) then
    local TargetEquippedInfo = DataMgr.GetEquippedWeaponList(self.CurHeroId)
    if not TargetEquippedInfo then
      LogicOutsideWeapon.RequestEquippedWeaponInfo(self.CurHeroId)
    end
  end
  local CommonTalents = DataMgr.GetCommonTalentInfos()
  if not CommonTalents or next(CommonTalents) == nil then
    LogicTalent.RequestGetCommonTalentsToServer()
  end
  self:RefreshSkillInfo(RowInfo)
  self:RefreshRoleTagList(RowInfo)
  self:RefreshWeaponSkillInfo()
  self:StopAnimation(self.Ani_Btn_chuzhan)
  self:RefreshChooseButtonStatus()
  self:RefreshWeaponSlotList()
  self:RefreshProfyData()
  self:UpdateChip()
  if self.IsSelectWeapon then
    if DataMgr.IsOwnHero(self.CurHeroId) then
      self:RefreshWeaponSelectList()
    else
      EventSystem.Invoke(EventDef.Lobby.WeaponSlotSelected, false, 0)
    end
  end
  self.Txt_BGDesc:SetText(RowInfo.Desc)
  local expireAt = DataMgr.IsLimitedHeroe(self.CurHeroId)
  if expireAt then
    self.WBP_CommonExpireAt_69:InitCommonExpireAt(expireAt)
    UpdateVisibility(self.WBP_CommonExpireAt_69, nil ~= expireAt and "0" ~= expireAt and "" ~= expireAt and "1" ~= expireAt)
  else
    UpdateVisibility(self.WBP_CommonExpireAt_69, false)
  end
end

function WBP_RoleMain_C:RefreshRoleTagList(RowInfo)
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

function WBP_RoleMain_C:RefreshChooseButtonStatus()
  self.CanChoosePanel:SetRenderOpacity(1)
  UpdateVisibility(self.Txt_ChooseStatusAni, false)
  self.Btn_Go:SetVisibility(UE.ESlateVisibility.Collapsed)
  if DataMgr.IsOwnHero(self.CurHeroId) then
    self.CanChoosePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanNotChoosePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    UpdateVisibility(self.Txt_ChooseStatus, false)
    if DataMgr.GetMyHeroInfo().equipHero == self.CurHeroId then
      UpdateVisibility(self.CanvasPanel_Equiped, true)
      self.CanNotChoosePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      UpdateVisibility(self.Txt_ChooseStatus, true)
      self.Txt_ChooseStatus:SetText(self.EquipText)
      self.Txt_ChooseStatus:SetColorAndOpacity(self.EquippedButtonTextColor)
      self.Img_CanNotChooseBottom:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      self.CanChoosePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      UpdateVisibility(self.CanvasPanel_Equiped, false)
    end
  else
    self.CanChoosePanel:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanNotChoosePanel:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UpdateVisibility(self.Txt_ChooseStatus, true)
    local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, self.CurHeroId)
    if Result and not UE.UKismetStringLibrary.IsEmpty(RowInfo.UnlockPath) then
      self.Txt_ChooseStatus:SetText(RowInfo.UnlockPath)
      self.Txt_GoStatus:SetText(RowInfo.UnlockPath)
    else
      self.Txt_ChooseStatus:SetText(self.LockText)
      self.Txt_GoStatus:SetText(self.LockText)
    end
    if Result and RowInfo and RowInfo.LinkId and RowInfo.LinkId ~= "" then
      self.Btn_Go:SetVisibility(UE.ESlateVisibility.Visible)
    end
    self.Txt_ChooseStatus:SetColorAndOpacity(self.LockButtonTextColor)
    self.Img_CanNotChooseBottom:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    UpdateVisibility(self.CanvasPanel_Equiped, false)
  end
end

function WBP_RoleMain_C:BindOnShowSkillTips(IsShow, SkillGroupId, KeyName, SkillInputNameAry, inputNameAryPad, SkillItem)
  if IsShow then
    self.NormalSkillTip:RefreshInfo(SkillGroupId, KeyName, nil, SkillInputNameAry, inputNameAryPad)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    ShowCommonTips(nil, SkillItem, self.NormalSkillTip)
  else
    self.NormalSkillTip:Hide()
  end
end

function WBP_RoleMain_C:BindOnUpdateMyHeroInfo()
  self:RefreshChooseButtonStatus()
  self:RefreshProfyData()
  self.TargetRoleActor:ChangeBodyMesh(self.CurHeroId, nil, nil, true)
  local expireAt = DataMgr.IsLimitedHeroe(self.CurHeroId)
  if expireAt then
    self.WBP_CommonExpireAt_69:InitCommonExpireAt(expireAt)
    UpdateVisibility(self.WBP_CommonExpireAt_69, nil ~= expireAt and "0" ~= expireAt and "" ~= expireAt and "1" ~= expireAt)
  else
    UpdateVisibility(self.WBP_CommonExpireAt_69, false)
  end
end

function WBP_RoleMain_C:RefreshSkillInfo(RowInfo)
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

function WBP_RoleMain_C:RefreshWeaponSkillInfo()
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

function WBP_RoleMain_C:Destruct()
  LuaCurveNames = {}
  self.TargetRoleActor = nil
end

function WBP_RoleMain_C:OnMouseMove(MyGeometry, MouseEvent)
  self:ResetStandby()
end

function WBP_RoleMain_C:AddStandbyTime(InDeltaTime)
  if self.StandbyTime == nil then
    self.StandbyTime = 0
  end
  self.StandbyTime = self.StandbyTime + InDeltaTime
  if self.StandbyTime > 15 then
    self.PlayingVoiceID = PlayVoiceByRowName("VO_PlayerStandby", self.TargetRoleActor, SkinData.GetEquipedSkinIdByHeroId(self.CurHeroId))
    self:ResetStandby()
  end
end

function WBP_RoleMain_C:ResetStandby()
  self.StandbyTime = 0
end

return WBP_RoleMain_C
