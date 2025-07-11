local WBP_SoulCoreView_C = UnLua.Class()
local SoulCoreItemDataPath = "/Game/Rouge/UI/Lobby/SoulCore/SoulCoreItemData.SoulCoreItemData_C"
local SoulCoreSkillLevelDescItemPath = "/Game/Rouge/UI/Lobby/SoulCore/WBP_SoulCoreSkillLevelDescItem.WBP_SoulCoreSkillLevelDescItem_C"
local SoulCoreSkillTagPath = "/Game/Rouge/UI/Lobby/SoulCore/WBP_SoulCoreSkillTag.WBP_SoulCoreSkillTag_C"
local ESoulCoreViewType = {SoulCoreView = 1, EquipView = 2}
function WBP_SoulCoreView_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.LobbyPanelChanged, WBP_SoulCoreView_C.BindOnLobbyActivePanelChanged)
  EventSystem.AddListener(self, EventDef.Lobby.RoleItemClicked, WBP_SoulCoreView_C.BindOnChangeRoleItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, WBP_SoulCoreView_C.UpdateSoulCoreList)
  EventSystem.AddListener(self, EventDef.Lobby.EquipFetterHeroByPosSuccess, WBP_SoulCoreView_C.EquipSoulCoreSucc)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, WBP_SoulCoreView_C.OnFetterHeroInfoUpdate)
  self.EscActionName = "PauseGame"
  self.WBP_LobbyEsc:InitInfo(self, self.EscEquip)
  self.BP_ButtonWithSoundLevelUp.OnClicked:Add(self, WBP_SoulCoreView_C.BindOnUpgradeButtonClicked)
  self.BP_ButtonWithSoundEquip.OnClicked:Add(self, WBP_SoulCoreView_C.BindOnEquipButtonClicked)
  self.ButtonTipConfirm.OnClicked:Add(self, WBP_SoulCoreView_C.BindOnTipsConfirm)
  self.ButtonTipCancel.OnClicked:Add(self, WBP_SoulCoreView_C.BindOnTipsCancel)
  self.NextTabList = {}
end
function WBP_SoulCoreView_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.LobbyPanelChanged, WBP_SoulCoreView_C.BindOnLobbyActivePanelChanged)
  EventSystem.RemoveListener(EventDef.Lobby.RoleItemClicked, WBP_SoulCoreView_C.BindOnChangeRoleItemClicked)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_SoulCoreView_C.UpdateSoulCoreList, self)
  EventSystem.RemoveListener(EventDef.Lobby.EquipFetterHeroByPosSuccess, WBP_SoulCoreView_C.EquipSoulCoreSucc)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_SoulCoreView_C.OnFetterHeroInfoUpdate)
  StopListeningForInputAction(self, self.EscActionName, UE.EInputEvent.IE_Pressed)
  self.BP_ButtonWithSoundLevelUp.OnClicked:Remove(self, WBP_SoulCoreView_C.BindOnUpgradeButtonClicked)
  self.BP_ButtonWithSoundEquip.OnClicked:Remove(self, WBP_SoulCoreView_C.BindOnEquipButtonClicked)
  self.ButtonTipConfirm.OnClicked:Remove(self, WBP_SoulCoreView_C.BindOnTipsConfirm)
  self.ButtonTipCancel.OnClicked:Remove(self, WBP_SoulCoreView_C.BindOnTipsCancel)
  LogicSoulCore.CurSelectSoulCoreId = -1
end
function WBP_SoulCoreView_C:BindOnLobbyActivePanelChanged(LastActiveWidget, CurActiveWidget)
  if LastActiveWidget == CurActiveWidget then
    if CurActiveWidget == self then
      self.bNeedPlayFadeOutAni = true
      self:PlayAnimation(self.FadeIn)
      self.CurMainHeroId = 1004
      self.ViewType = ESoulCoreViewType.SoulCoreView
      self:UpdateSoulCoreList()
      return
    end
    return
  end
  if CurActiveWidget == self then
    self.bNeedPlayFadeOutAni = true
    self:PlayAnimation(self.FadeIn)
    self.CurMainHeroId = 1004
    self.ViewType = ESoulCoreViewType.SoulCoreView
    self:UpdateSoulCoreList()
    if not IsListeningForInputAction(self, self.EscActionName) then
      ListenForInputAction(self.EscActionName, UE.EInputEvent.IE_Pressed, true, {
        self,
        WBP_SoulCoreView_C.EscEquip
      })
    end
  end
  if LastActiveWidget == self then
    self.bNeedPlayFadeOutAni = false
    self:StopAnimation(self.FadeIn)
    self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.Collapsed)
    if IsListeningForInputAction(self, self.EscActionName) then
      StopListeningForInputAction(self, self.EscActionName, UE.EInputEvent.IE_Pressed)
    end
  end
end
function WBP_SoulCoreView_C:CanDirectSwitch(NextTabWidget)
  if NextTabWidget and not table.Contain(self.NextTabList, NextTabWidget) then
    table.insert(self.NextTabList, NextTabWidget)
  end
  if self.bNeedPlayFadeOutAni and not self:IsAnimationPlaying(self.FadeOut) then
    self:PlayAnimation(self.FadeOut)
  end
  return not self.bNeedPlayFadeOutAni
end
function WBP_SoulCoreView_C:ChangeNextTab()
  self.bNeedPlayFadeOutAni = false
  for i, NextTabWidget in ipairs(self.NextTabList) do
    NextTabWidget:ActivateTabWidget()
  end
  self.NextTabList = {}
end
function WBP_SoulCoreView_C:OnAnimationFinished(Animation)
  if Animation == self.FadeOut then
    self:ChangeNextTab()
  end
end
function WBP_SoulCoreView_C:BindOnChangeRoleItemClicked(CharacterId)
  self.CurMainHeroId = CharacterId
  self.CanvasPanelEquip:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.WBP_SoulCoreEquipPanel:InitInfo(CharacterId, self)
  self.WBP_RoleChangeList:RefreshRoleList()
end
function WBP_SoulCoreView_C:InitInfo()
end
function WBP_SoulCoreView_C:BindOnUpgradeButtonClicked()
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Role/WBP_RoleUpgradePanel.WBP_RoleUpgradePanel_C")
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:Switch(WidgetClass, true)
  local Widget = UIManager:K2_GetUI(WidgetClass)
  if Widget then
    Widget:InitInfo(LogicSoulCore.CurSelectSoulCoreId)
  end
end
function WBP_SoulCoreView_C:BindOnEquipButtonClicked()
  local bIsUnLock = LogicRole.CheckCharacterUnlock(LogicSoulCore.CurSelectSoulCoreId)
  if bIsUnLock then
    self:UpdateEquipPanel(true)
  else
    self.CanvasPanelNotEnoughTips:SetVisibility(UE.ESlateVisibility.Visible)
  end
end
function WBP_SoulCoreView_C:BindOnTipsCancel()
  self.CanvasPanelNotEnoughTips:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_SoulCoreView_C:BindOnTipsConfirm()
  self.CanvasPanelNotEnoughTips:SetVisibility(UE.ESlateVisibility.Collapsed)
  UIMgr:Show(ViewID.UI_DrawCard)
end
function WBP_SoulCoreView_C:UpdateEquipPanel(bIsShowEquipPanel, bNotIsSelectChangeList)
  if bIsShowEquipPanel then
    self.ViewType = ESoulCoreViewType.EquipView
    self:RequestAllHeroFetterInfo()
    if not bNotIsSelectChangeList then
      self.WBP_RoleChangeList:ShowPanelByIndex(1, self.EliminateFunc, self.RoleListSort, true)
    end
    self.CanvasPanelSoulCoreList:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.WBP_RoleChangeList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_LobbyEsc:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_RoleChangeList:StopAnimation(self.WBP_RoleChangeList.ani_rolechangelist_out)
    self.WBP_RoleChangeList:PlayAnimation(self.WBP_RoleChangeList.ani_rolechangelist_in)
  else
    self.ViewType = ESoulCoreViewType.SoulCoreView
    self.CanvasPanelSoulCoreList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_RoleChangeList:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanelEquip:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.WBP_LobbyEsc:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.WBP_RoleChangeList:StopAnimation(self.WBP_RoleChangeList.ani_rolechangelist_in)
    self.WBP_RoleChangeList:PlayAnimation(self.WBP_RoleChangeList.ani_rolechangelist_out)
  end
end
function WBP_SoulCoreView_C:RequestAllHeroFetterInfo()
  local AllCharacterList = LogicRole.GetAllCanSelectCharacterList()
  for i, v in ipairs(AllCharacterList) do
    LogicRole.RequestGetHeroFetterInfoToServer(v)
  end
end
function WBP_SoulCoreView_C.EliminateFunc(CharacterId)
  return not DataMgr.IsOwnHero(CharacterId)
end
function WBP_SoulCoreView_C.RoleListSort(A, B)
  if LogicSoulCore:CheckCantEquipSoulCore(A) then
    return false
  end
  if LogicSoulCore:CheckCantEquipSoulCore(B) then
    return true
  end
  return A < B
end
function WBP_SoulCoreView_C:EquipSoulCoreSucc()
  LogicRole.RequestGetHeroFetterInfoToServer(self.CurMainHeroId, {
    self,
    self.OnGetHeroFetterInfoSuccess
  })
end
function WBP_SoulCoreView_C:OnFetterHeroInfoUpdate()
  self.WBP_SoulCoreEquipPanel:UpdateSoulCoreEquipItemList()
  self.WBP_RoleChangeList:RefreshRoleList(-1)
end
function WBP_SoulCoreView_C:EscEquip()
  if self.ViewType == ESoulCoreViewType.EquipView then
    self:UpdateEquipPanel(false)
  else
    LogicLobby.JumpToLobbyDefaultPanel()
  end
end
function WBP_SoulCoreView_C:OnGetHeroFetterInfoSuccess(JsonResponse)
  print("OnGetHeroFetterInfoSuccess", JsonResponse.Content)
  self:UpdateSoulCoreList()
  LogicRole.InitFetterHeroesMesh(self.CurMainHeroId)
end
function WBP_SoulCoreView_C:UpdateSoulCoreList()
  if self.ViewType == ESoulCoreViewType.SoulCoreView then
    self.CanvasPanelSoulCoreList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    local SoulCoreList = LogicSoulCore:GetSoulCoreList()
    if not SoulCoreList then
      for i, v in iterator(self.TileViewSoulCore.ListItems) do
        self.TileViewDataAry:Add(v)
      end
      self.TileViewSoulCore:ClearListItems()
      return
    end
    local Index = 0
    local TileViewAry = UE.TArray(UE.UObject)
    for i, v in ipairs(SoulCoreList) do
      local CharacterTb = LogicSoulCore:GetCharacterTableRow(v.ID)
      if CharacterTb.CanChoose then
        local DataObj
        if self.TileViewDataAry:IsValidIndex(self.TileViewDataAry:LastIndex()) then
          DataObj = self.TileViewDataAry:GetRef(self.TileViewDataAry:LastIndex())
          self.TileViewDataAry:Remove(self.TileViewDataAry:LastIndex())
        else
          local DataObjCls = UE.UClass.Load(SoulCoreItemDataPath)
          DataObj = NewObject(DataObjCls, self, nil)
        end
        DataObj.ResourceId = v.ResourceId
        DataObj.Index = Index
        DataObj.CharacterId = v.ID
        DataObj.Select = {
          self,
          self.Select
        }
        DataObj.ParentView = self
        Index = Index + 1
        TileViewAry:Add(DataObj)
      end
    end
    for i, v in iterator(self.TileViewSoulCore.ListItems) do
      self.TileViewDataAry:Add(v)
    end
    self.TileViewSoulCore:BP_SetListItems(TileViewAry)
    if -1 ~= self.CurSelect then
      self.TileViewSoulCore:SetSelectedIndex(self.CurSelect)
    else
      self.TileViewSoulCore:SetSelectedIndex(0)
    end
    self:UpdateEquipPanel(false)
  elseif self.ViewType == ESoulCoreViewType.EquipView then
    self.CanvasPanelSoulCoreList:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:UpdateEquipPanel(true, true)
  end
end
function WBP_SoulCoreView_C:Select(IndexParam, CharacterId, ResourceId)
  self:UpdateView(CharacterId, ResourceId)
  self.CurSelect = IndexParam
  LogicSoulCore.CurSelectSoulCoreId = CharacterId
  local Lv = DataMgr.GetHeroLevelByHeroId(CharacterId)
  local MaxStar = LogicRole.GetMaxHeroStar(CharacterId)
  local bIsUnLock = LogicRole.CheckCharacterUnlock(CharacterId)
  local bIsDisable = Lv < MaxStar and MaxStar > 0 and bIsUnLock
  self.BP_ButtonWithSoundLevelUp:SetIsEnabled(bIsDisable)
end
function WBP_SoulCoreView_C:UpdateView(CharacterId, ResourceId)
  self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  local CharacterTb = LogicSoulCore:GetCharacterTableRow(CharacterId)
  if CharacterTb then
    if self.URGImageVerticleDraw1:GetVisibility() == UE.ESlateVisibility.Collapsed then
      SetImageBrushByPath(self.URGImageVerticleDraw1, CharacterTb.FullPaintingPath)
      self.URGImageVerticleDraw1:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.URGImageVerticleDraw:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      SetImageBrushByPath(self.URGImageVerticleDraw, CharacterTb.FullPaintingPath)
      self.URGImageVerticleDraw:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.URGImageVerticleDraw1:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
  end
  self.WBP_CardTitle:UpdateCardTitle(CharacterId, ResourceId)
  local SkillGroupId = LogicRole.GetFetterSkillGroupIdByHeroId(CharacterId)
  local SkillList = LogicRole.HeroSkillTable[SkillGroupId]
  if SkillList then
    local Lv = DataMgr.GetHeroLevelByHeroId(CharacterId)
    self.RGTextSkillName:SetText(SkillList[1].Name)
    self.RichTextBlockDesc:SetText(SkillList[1].SimpleDesc)
    self.RGTextSkillLevel:SetText(Lv)
    SetImageBrushByPath(self.URGImageSkillIcon, SkillList[1].IconPath)
    self:UpdateSkillTag(SkillList[1].SkillTags)
    self:UpdateSkillDesc(SkillList, Lv)
  end
end
function WBP_SoulCoreView_C:UpdateSkillTag(SkillTags)
  local SoulCoreSkillTagCls = UE.UClass.Load(SoulCoreSkillTagPath)
  for i, v in ipairs(SkillTags) do
    local SkillTagInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBSkillTag)
    if SkillTagInfo and SkillTagInfo[v] then
      local SkillTagItem = GetOrCreateItem(self.HorizontalBoxSkillTag, i, SoulCoreSkillTagCls)
      SkillTagItem:Show(SkillTagInfo[v].Name)
    end
  end
  HideOtherItem(self.HorizontalBoxSkillTag, #SkillTags + 1)
end
function WBP_SoulCoreView_C:UpdateSkillDesc(SkillList, CharacterStar)
  local LevelDescItemCls = UE.UClass.Load(SoulCoreSkillLevelDescItemPath)
  for index, value in ipairs(SkillList) do
    local SkillDescItem = GetOrCreateItem(self.VerticalBoxSkillDesc, index, LevelDescItemCls)
    if value.Star > 1 then
      SkillDescItem:Show(value, CharacterStar)
    else
      SkillDescItem:Hide()
    end
  end
  HideOtherItem(self.VerticalBoxSkillDesc, #SkillList + 1)
end
function WBP_SoulCoreView_C:OnLobbyActivePanelChanged(LastActiveWidget, CurActiveWidget)
  if CurActiveWidget == self then
  end
end
return WBP_SoulCoreView_C
