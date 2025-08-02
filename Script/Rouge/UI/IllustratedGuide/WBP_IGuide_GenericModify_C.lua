local WBP_IGuide_GenericModify_C = UnLua.Class()

function WBP_IGuide_GenericModify_C:Construct()
end

function WBP_IGuide_GenericModify_C:Destruct()
  EventSystem.RemoveEventAllListener(EventDef.IllustratedGuide.OnFocusModify)
  EventSystem.RemoveEventAllListener(EventDef.IllustratedGuide.OnGenericModifyGodItemClicked)
  EventSystem.RemoveEventAllListener(EventDef.IllustratedGuide.AttributeModifyHoveredTip)
  EventSystem.RemoveEventAllListener(EventDef.IllustratedGuide.OnShowSkillTips)
  EventSystem.RemoveEventAllListener(EventDef.MainPanel.MainPanelChanged)
end

function WBP_IGuide_GenericModify_C:AddBtnEvent()
  self.TileView_GenericModify_1.BP_OnItemClicked:Add(self, function(self, itemObj)
    if nil == itemObj then
      return
    end
    self.TileView_GenericModify_Dual:BP_SetSelectedItem(nil)
    self.TileView_GenericModify_Skill:BP_SetSelectedItem(nil)
    self:OnGenericModifyListItemClicked(itemObj)
  end)
  self.TileView_GenericModify_Skill.BP_OnItemClicked:Add(self, function(self, itemObj)
    if nil == itemObj then
      return
    end
    self.TileView_GenericModify_Dual:BP_SetSelectedItem(nil)
    self.TileView_GenericModify_1:BP_SetSelectedItem(nil)
    self:OnGenericModifyListItemClicked(itemObj)
  end)
  self.TileView_GenericModify_Dual.BP_OnItemClicked:Add(self, function(self, itemObj)
    if nil == itemObj then
      return
    end
    self.TileView_GenericModify_Skill:BP_SetSelectedItem(nil)
    self.TileView_GenericModify_1:BP_SetSelectedItem(nil)
    self:OnGenericModifyListItemClicked(itemObj)
  end)
  self.Btn_Focus.OnClicked:Add(self, WBP_IGuide_GenericModify_C.FocusGenericModify)
  self.TileView_GenericModify_Dual.BP_OnItemIsHoveredChanged:Add(self, self.BP_OnItemIsHoveredChanged)
  self.TileView_GenericModify_1.BP_OnItemIsHoveredChanged:Add(self, self.BP_OnItemIsHoveredChanged)
  self.TileView_GenericModify_Skill.BP_OnItemIsHoveredChanged:Add(self, self.BP_OnItemIsHoveredChanged)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnGenericModifyGodItemClicked, WBP_IGuide_GenericModify_C.OnGodListItemClicked)
  EventSystem.AddListener(self, EventDef.IllustratedGuide.OnShowSkillTips, WBP_IGuide_GenericModify_C.OnShowSkillTips)
  EventSystem.AddListener(self, EventDef.MainPanel.OnExit, WBP_IGuide_GenericModify_C.OnMainPanelExit)
  EventSystem.RemoveListener(EventDef.MainPanel.MainPanelChanged, WBP_IGuide_GenericModify_C.OnMainPanelChanged, self)
  EventSystem.AddListener(self, EventDef.MainPanel.MainPanelChanged, WBP_IGuide_GenericModify_C.OnMainPanelChanged)
  EventSystem.AddListener(self, EventDef.MainPanel.OnEnter, WBP_IGuide_GenericModify_C.OnEnter)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, WBP_IGuide_GenericModify_C.LobbyClose)
    self.WBP_InteractTipWidgetSetting.OnMainButtonClicked:Add(self, WBP_IGuide_GenericModify_C.LobbySettings)
  else
    self.WBP_InteractTipWidgetEsc.OnMainButtonClicked:Add(self, WBP_IGuide_GenericModify_C.GameClose)
  end
end

function WBP_IGuide_GenericModify_C:LobbySettings()
  LogicGameSetting.ShowGameSettingPanel()
end

function WBP_IGuide_GenericModify_C:LobbyClose()
  UIMgr:Hide(ViewID.UI_IllustratedGuide, true)
end

function WBP_IGuide_GenericModify_C:GameClose()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if UIManager and UIManager:IsValid() then
    local PC = UE.UGameplayStatics.GetPlayerController(self, 0)
    if PC then
      PC:SetViewTargetwithBlend(self:GetOwningPlayerPawn())
    end
    local MainPanel = UIManager:GetUIByName("WBP_MainPanel_C")
    if MainPanel then
      MainPanel:Exit()
    end
  end
end

function WBP_IGuide_GenericModify_C:OnGenericModifyGodItemHover(GodId, bHover)
  UpdateVisibility(self.WBP_GenericModifyGodTips, bHover)
  if bHover then
    self.WBP_GenericModifyGodTips:OnHover(GodId)
  end
end

function WBP_IGuide_GenericModify_C:OnExitPanel()
  self:PlayAnimation(self.Ani_out)
  self.WBP_InteractTipWidget:UnBindInteractAndClickEvent(self, WBP_IGuide_GenericModify_C.FocusGenericModify, self.WBP_InteractTipWidget.KeyRowName)
end

function WBP_IGuide_GenericModify_C:OnEnter(Index)
  if 2 == Index then
    self:PlayAnimation(self.Ani_in)
    self.WBP_InteractTipWidget:BindInteractAndClickEvent(self, WBP_IGuide_GenericModify_C.FocusGenericModify, self.WBP_InteractTipWidget.KeyRowName)
  end
end

function WBP_IGuide_GenericModify_C:OnMainPanelExit(Widget)
  if Widget == self then
  end
end

function WBP_IGuide_GenericModify_C:OnMainPanelChanged(a, b, MainPanel)
  print("ListenForIllustratedGuide", "OnMainPanelChanged")
  self.MainPanel = MainPanel
  self:InitGodList()
  if b == self then
  end
end

function WBP_IGuide_GenericModify_C:OnShowSkillTips(bShow, Info)
  UpdateVisibility(self.SizeBox_Tips, bShow)
  local bShowMovie = false
  local bHaveModAdditional = false
  if bShow then
    if nil ~= Info then
      self.MediaPlayer:SetLooping(true)
      if nil ~= Info.MediaSoftPtr and UE.UKismetSystemLibrary.IsValidSoftObjectReference(Info.MediaSoftPtr) then
        self.Obj = UE.UKismetSystemLibrary.LoadAsset_Blocking(Info.MediaSoftPtr)
        UpdateVisibility(self.SizeBox_Movie, true)
        bShowMovie = true
        self.MediaPlayer:OpenSource(self.Obj)
        self.MediaPlayer:Rewind()
      else
        bShowMovie = false
        UpdateVisibility(self.SizeBox_Movie, false)
      end
    end
    local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
    if not DTSubsystem then
      return
    end
    local logicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    if nil == logicCommandDataSubsystem then
      return
    end
    local OutSaveData = GetLuaInscription(Info.Inscription)
    if OutSaveData then
      local Index = 1
      if OutSaveData.ModAdditionalNoteMap then
        local LastNoteItem
        for k, v in pairs(OutSaveData.ModAdditionalNoteMap) do
          local Result, ModAdditionalNoteRow = DTSubsystem:GetModAdditionalNoteTableRow(k, nil)
          if Result then
            local NoteItem = GetOrCreateItem(self.VerticalBoxAdditionNote, Index, self.WBP_IGuide_GenericModifyTip_Item:GetClass())
            NoteItem:InitGenericModifyAdditionNote(ModAdditionalNoteRow)
            Index = Index + 1
            bHaveModAdditional = true
            LastNoteItem = NoteItem
            UpdateVisibility(LastNoteItem.URGImage_192, true)
          end
        end
        if LastNoteItem then
          UpdateVisibility(LastNoteItem.URGImage_192, false)
        end
      end
      HideOtherItem(self.VerticalBoxAdditionNote, Index)
    end
    if not bHaveModAdditional and not bShowMovie then
      UpdateVisibility(self.SizeBox_Tips, false)
    end
  end
end

function WBP_IGuide_GenericModify_C:InitGenericModify()
  self:AddBtnEvent()
  local Player = self:GetOwningPlayerPawn()
  if Player then
    local RGGenericModifyComponent = Player:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
    if RGGenericModifyComponent then
      Logic_IllustratedGuide.CurFocusGenericModifySubGroup = RGGenericModifyComponent.FocusModifySubGroupList:ToTable()
      RGGenericModifyComponent.OnFocusModifySubGroupListChanged:Add(self, WBP_IGuide_GenericModify_C.OnFocusModifySubGroupListChanged)
      RGGenericModifyComponent.OnAddModify:Add(self, WBP_IGuide_GenericModify_C.OnAddModify)
      EventSystem.Invoke(EventDef.IllustratedGuide.OnFocusModify)
    end
  end
  self:InitGodList()
  UpdateVisibility(self.WBP_InteractTipWidgetSetting, Logic_IllustratedGuide.IsLobbyRoom())
end

function WBP_IGuide_GenericModify_C:OnAddModify(Modify)
  self:InitGodList()
  local Result, RowInfo = GetRowData(DT.DT_GenericModify, Modify.ModifyId)
  if Result and 1 == Logic_IllustratedGuide.FocusStatus(RowInfo) then
    Logic_IllustratedGuide.FocusModify(RowInfo)
  end
end

function WBP_IGuide_GenericModify_C:OnFocusModifySubGroupListChanged(SubGroupList)
  Logic_IllustratedGuide.CurFocusGenericModifySubGroup = {}
  for key, SubGroupId in pairs(SubGroupList) do
    table.insert(Logic_IllustratedGuide.CurFocusGenericModifySubGroup, SubGroupId)
  end
  EventSystem.Invoke(EventDef.IllustratedGuide.OnFocusModify)
end

function WBP_IGuide_GenericModify_C:InitGodList()
  if Logic_IllustratedGuide.IsLobbyRoom() then
    self:OnGodListItemClicked(7)
    EventSystem.Invoke(EventDef.IllustratedGuide.OnGenericModifyGodItemClicked, 7)
    return
  end
  local LevelSubSystem = UE.URGGameLevelSystem.GetInstance(GameInstance)
  local WorldId = LevelSubSystem:GetGameMode()
  for i = 0, 6 do
    local Result, RowInfo = GetRowData(DT.DT_GameMode, WorldId)
    if Result then
      for index, value in ipairs(RowInfo.GenericModifyGroups:ToTable()) do
        if value == 7 - i then
          self:OnGodListItemClicked(7 - i)
          EventSystem.Invoke(EventDef.IllustratedGuide.OnGenericModifyGodItemClicked, 7 - i)
          return
        end
      end
    end
  end
end

function WBP_IGuide_GenericModify_C:OnGodListItemClicked(GodId)
  self.WBP_GenericModifyGodTips:OnHover(GodId)
  if Logic_IllustratedGuide.CurGodId == GodId then
    print("ljs Logic_IllustratedGuide.CurGodId == GodId")
  end
  Logic_IllustratedGuide.SetCurGodId(GodId)
  self.NavigationGodId = GodId
  local Result, Row = GetRowData("GenericModifyGroup", tostring(GodId))
  if Result then
    self.Text_GodDesc:SetText(Row.Desc)
    SetImageBrushBySoftObject(self.URGImage_370, Row.IGuideGodPanel)
  end
  self:RefreshGenericModifyListByGodId(GodId)
end

function WBP_IGuide_GenericModify_C:OnGenericModifyListItemClicked(itemObj)
  if itemObj.Data then
    if Logic_IllustratedGuide.CurGenericModifyInfo == itemObj.Data then
      return
    end
    Logic_IllustratedGuide.CurGenericModifyInfo = itemObj.Data
    self:RefreshDetailPanelAndPreconditions(itemObj.Data)
    self:RefreshFocusBtn(itemObj.Data)
    EventSystem.Invoke(EventDef.IllustratedGuide.OnGenericModifyItemSelectionChanged, itemObj.Data.RowName)
  end
end

function WBP_IGuide_GenericModify_C:RefreshGenericModifyListByGodId(GodId)
  self.TileView_GenericModify_Dual:ClearListItems()
  self.TileView_GenericModify_1:ClearListItems()
  self.TileView_GenericModify_Skill:ClearListItems()
  local DualSum = 0
  local PassiveSum = 0
  local InitiativeSum = 0
  local CurDualNum = 0
  local CurPassiveNum = 0
  local CurInitiativeSum = 0
  local DataObjs = Logic_IllustratedGuide.GetAllModifiesDataOfGroup(GodId)
  local ActivePermissions = {}
  for index, value in ipairs(DataObjs) do
    if value then
      local GenericModifyTable = Logic_IllustratedGuide.GetAllGenericModifyFromPlayer()
      if value.Data.bDual then
        self.TileView_GenericModify_Dual:AddItem(value)
        DualSum = DualSum + 1
        if value.Data.bObtained then
          CurDualNum = CurDualNum + 1
        end
        if 1 == DualSum then
          self.TileView_GenericModify_Dual:SetSelectedIndex(0)
          self:OnGenericModifyListItemClicked(value)
        end
      elseif 0 == value.Data.Slot then
        PassiveSum = PassiveSum + 1
        self.TileView_GenericModify_1:AddItem(value)
        if value.Data.bObtained then
          CurPassiveNum = CurPassiveNum + 1
        end
      else
        InitiativeSum = InitiativeSum + 1
        if value.Data.bObtained then
          CurInitiativeSum = CurInitiativeSum + 1
        end
        table.insert(ActivePermissions, value)
      end
    end
  end
  table.sort(ActivePermissions, function(a, b)
    return a.Data.Slot < b.Data.Slot
  end)
  for index, value in ipairs(ActivePermissions) do
    self.TileView_GenericModify_Skill:AddItem(value)
  end
  UpdateVisibility(self.Text_GenericModify_1, not Logic_IllustratedGuide.IsLobbyRoom())
  UpdateVisibility(self.Text_GenericModify_3, not Logic_IllustratedGuide.IsLobbyRoom())
  UpdateVisibility(self.Text_GenericModify_7, not Logic_IllustratedGuide.IsLobbyRoom())
  local Result, RowInfo = GetRowData(DT.DT_GenericModifyGroup, GodId)
  if Result then
    self.Text_GenericModify_2:SetText(RowInfo.Name)
  end
  self.Text_GenericModify_1:SetText(tostring(CurDualNum) .. "/" .. tostring(DualSum))
  self.Text_GenericModify_7:SetText(tostring(CurPassiveNum) .. "/" .. tostring(PassiveSum))
  self.Text_GenericModify_3:SetText(tostring(CurInitiativeSum) .. "/" .. tostring(InitiativeSum))
end

function WBP_IGuide_GenericModify_C:RefreshDetailPanelAndPreconditions(ModifyInfo)
  self.WBP_IGuide_GM_Detail:RefreshDetailPanel(ModifyInfo, true)
  self.WBP_IGuide_GM_Detail_Preconditions:RefreshPreconditions(ModifyInfo)
end

function WBP_IGuide_GenericModify_C:FocusGenericModify()
  if 0 == #self.Data.ModifieConfig.FrontConditions:ToTable() then
    return
  end
  Logic_IllustratedGuide.FocusModify(self.Data.ModifieConfig)
  self:RefreshFocusBtn(self.Data)
  local Status = Logic_IllustratedGuide.FocusStatus(self.Data.ModifieConfig)
  if 1 == Status then
    LuaAddClickStatistics("IguideFocus")
  end
end

function WBP_IGuide_GenericModify_C:RefreshFocusBtn(Data)
  if Logic_IllustratedGuide.IsLobbyRoom() then
    UpdateVisibility(self.Btn_Focus, false)
    return
  end
  self.Data = Data
  local Status = Logic_IllustratedGuide.FocusStatus(Data.ModifieConfig)
  UpdateVisibility(self.Btn_Focus, 0 ~= #Data.ModifieConfig.FrontConditions:ToTable(), true)
  UpdateVisibility(self.Overlay_Focus, false)
  UpdateVisibility(self.Overlay_UnFocus, false)
  UpdateVisibility(self.Overlay_Existed, false)
  if 0 == Status then
    UpdateVisibility(self.Overlay_Focus, true)
  elseif 1 == Status then
    UpdateVisibility(self.Overlay_UnFocus, true)
  elseif 2 == Status then
    UpdateVisibility(self.Overlay_Existed, true)
  end
end

function WBP_IGuide_GenericModify_C:BP_OnItemIsHoveredChanged(Item, bHovered)
end

function WBP_IGuide_GenericModify_C:OnMouseButtonDown(MyGeometry, MouseEvent)
  return UE.UWidgetBlueprintLibrary.Handled()
end

function WBP_IGuide_GenericModify_C:DoCustomNavigation_God(Type)
  if self.NavigationGodId == nil then
    self.NavigationGodId = Logic_IllustratedGuide.CurGodId
  end
  local Index = 0
  if Type == UE.EUINavigation.Up then
    Index = Index + 2
  elseif Type == UE.EUINavigation.Down then
    Index = Index - 2
  elseif Type == UE.EUINavigation.Left then
    Index = Index - 1
  elseif Type == UE.EUINavigation.Right then
    Index = Index + 1
  end
  self.NavigationGodId = self.NavigationGodId + Index
  print("WBP_IGuide_GenericModify_C", self.NavigationGodId, self.NavigationGodId, Index)
  EventSystem.Invoke(EventDef.IllustratedGuide.OnCustomNavigation_God, self.NavigationGodId)
end

return WBP_IGuide_GenericModify_C
