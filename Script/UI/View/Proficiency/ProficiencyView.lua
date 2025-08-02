local DataBinding = require("Framework.UIMgr.DataBinding")
local ViewBase = require("Framework.UIMgr.ViewBase")
local UKismetTextLibrary = UE.UKismetTextLibrary
local UIUtil = require("Framework.UIMgr.UIUtil")
local ProficiencyData = require("Modules.Proficiency.ProficiencyData")
local SkinData = require("Modules.Appearance.Skin.SkinData")
local BeginnerGuideData = require("Modules.Beginner.BeginnerGuideData")
local EscName = "PauseGame"
local ProficiencyView = Class(ViewBase)
local MinLevel = 2

function ProficiencyView:OnBindUIInput()
  self.WBP_InteractTipWidgetSynopsis:BindInteractAndClickEvent(self, self.BindOnSynopsisButtonClicked)
end

function ProficiencyView:OnUnBindUIInput()
  self.WBP_InteractTipWidgetSynopsis:UnBindInteractAndClickEvent(self, self.BindOnSynopsisButtonClicked)
end

function ProficiencyView:BindClickHandler()
  self.Btn_Synopsis.OnClicked:Add(self, self.BindOnSynopsisButtonClicked)
  self.Btn_Synopsis.OnHovered:Add(self, self.BindOnSynopsisButtonHovered)
  self.Btn_Synopsis.OnUnhovered:Add(self, self.BindOnSynopsisButtonUnhovered)
  self.Btn_Tips.OnHovered:Add(self, self.BindOnTipButtonHovered)
  self.Btn_Tips.OnUnhovered:Add(self, self.BindOnTipButtonUnhovered)
  EventSystem.AddListener(self, EventDef.Proficiency.OnProficiencyAwardItemHoverStatusChanged, self.BindOnProficiencyAwardItemHoverStatusChanged)
  EventSystem.AddListener(self, EventDef.Proficiency.OnProficiencySynopsisDetailPanelVisChanged, self.BindOnProficiencySynopsisDetailPanelVisChanged)
end

function ProficiencyView:UnBindClickHandler()
  self.Btn_Synopsis.OnClicked:Remove(self, self.BindOnSynopsisButtonClicked)
  self.Btn_Synopsis.OnHovered:Remove(self, self.BindOnSynopsisButtonHovered)
  self.Btn_Synopsis.OnUnhovered:Remove(self, self.BindOnSynopsisButtonUnhovered)
  self.Btn_Tips.OnHovered:Remove(self, self.BindOnTipButtonHovered)
  self.Btn_Tips.OnUnhovered:Remove(self, self.BindOnTipButtonUnhovered)
  EventSystem.RemoveListener(EventDef.Proficiency.OnProficiencyAwardItemHoverStatusChanged, self.BindOnProficiencyAwardItemHoverStatusChanged, self)
  EventSystem.RemoveListener(EventDef.Proficiency.OnProficiencySynopsisDetailPanelVisChanged, self.BindOnProficiencySynopsisDetailPanelVisChanged)
end

function ProficiencyView:OnInit()
  self.DataBindTable = {}
  self.ViewModel = UIModelMgr:Get("ProficiencyViewModel")
  self:BindClickHandler()
end

function ProficiencyView:OnDestroy()
  self:UnBindClickHandler()
end

function ProficiencyView:OnShow(...)
  if self.ViewModel then
    self.Super:AttachViewModel(self.ViewModel, self.DataBindTable, self)
  end
  self.ViewModel:UpdateCurHeroId(...)
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.ViewModel.CurHeroId)
  LogicRole.ShowOrHideRoleMainHero(true)
  local SkinId = self.ViewModel:GetEquippedSkinIdByHeroId(self.ViewModel.CurHeroId)
  LogicRole.ShowSkinLightMap(SkinId)
  ChangeLobbyCamera(self, "Proficiency")
  local HeroSkinRowInfo
  local HeroSkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  for key, SingleRowInfo in pairs(HeroSkinTable) do
    if SingleRowInfo.SkinID == SkinId then
      HeroSkinRowInfo = SingleRowInfo
      break
    end
  end
  EventSystem.AddListenerNew(EventDef.Lobby.EquippedWeaponInfoChanged, self, self.BindOnEquippedWeaponInfoChanged)
  local targetActor = self:GetMainRoleActor()
  if UE.RGUtil.IsUObjectValid(targetActor) then
    targetActor:EnableInputActor(true)
    local HeroId = self.ViewModel:GetCurHeroId()
    local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
    if CharacterRow then
      targetActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
    targetActor:ChangeBodyMesh(HeroId)
    targetActor:ChangeChildActorDefaultRotation(HeroId)
    if HeroSkinRowInfo then
      LogicRole.PlayCharacterActionByHeroSkinId(targetActor.ChildActor.ChildActor, HeroSkinRowInfo.ProfyCharacterAction)
    end
  end
  UpdateVisibility(self.CanvasPanelRoot, true)
  self:RefreshInfo()
  UpdateVisibility(self.WBP_ProficiencyTip, false)
  EventSystem.Invoke(EventDef.BeginnerGuide.OnProficiencyViewShow)
end

function ProficiencyView:UpdateViewByHeroId(HeroId)
  self.ViewModel:UpdateCurHeroId(HeroId)
  self.WBP_RedDotView:ChangeRedDotIdByTag(self.ViewModel.CurHeroId)
  local targetRoleActor = self:GetMainRoleActor()
  if targetRoleActor then
    local CharacterRow = LogicRole.GetCharacterTableRow(HeroId)
    if CharacterRow then
      targetRoleActor.ChildActor:SetWorldScale3D(UE.FVector(CharacterRow.RoleModelScale))
    end
    targetRoleActor:ChangeBodyMesh(HeroId)
    targetRoleActor:ChangeChildActorDefaultRotation(HeroId)
  end
  if DataMgr.IsOwnHero(HeroId) then
    local TargetEquippedInfo = DataMgr.GetEquippedWeaponList(HeroId)
    if not TargetEquippedInfo then
      LogicOutsideWeapon.RequestEquippedWeaponInfo(HeroId)
    end
  end
  LogicRole.ShowOrHideRoleMainHero(true)
  local SkinId = self.ViewModel:GetEquippedSkinIdByHeroId(self.ViewModel.CurHeroId)
  LogicRole.ShowSkinLightMap(SkinId)
  ChangeLobbyCamera(self, "Proficiency")
  local HeroSkinRowInfo
  local HeroSkinTable = LuaTableMgr.GetLuaTableByName(TableNames.TBCharacterSkin)
  for key, SingleRowInfo in pairs(HeroSkinTable) do
    if SingleRowInfo.SkinID == SkinId then
      HeroSkinRowInfo = SingleRowInfo
      break
    end
  end
  if HeroSkinRowInfo then
    local RoleMainActor = LogicRole.GetRoleMainActor()
    LogicRole.PlayCharacterActionByHeroSkinId(RoleMainActor.ChildActor.ChildActor, HeroSkinRowInfo.ProfyCharacterAction)
  end
  local targetActor = self:GetMainRoleActor()
  if UE.RGUtil.IsUObjectValid(targetActor) then
    targetActor:EnableInputActor(true)
  end
  UpdateVisibility(self.CanvasPanelRoot, true)
  self:RefreshInfo()
end

function ProficiencyView:BindOnEquippedWeaponInfoChanged(HeroId)
  print("ProficiencyView:BindOnEquippedWeaponInfoChanged", HeroId, self.ViewModel:GetCurHeroId())
  if self.ViewModel:GetCurHeroId() ~= HeroId then
    return
  end
  local targetRoleActor = self:GetMainRoleActor()
  if targetRoleActor then
    targetRoleActor:ChangeWeaponMesh(self.ViewModel:GetCurHeroId())
  end
end

function ProficiencyView:OnRollback()
  local skinId = self.ViewModel:GetEquippedSkinIdByHeroId(self.ViewModel.CurHeroId)
  LogicRole.ShowSkinLightMap(skinId)
  LogicRole.ShowOrHideRoleMainHero(true)
  ChangeLobbyCamera(self, "Proficiency")
  self:RefreshCurSynopsisInfo()
end

function ProficiencyView:OnHideByOther(...)
  LogicRole.ShowOrHideRoleMainHero(false)
end

function ProficiencyView:RefreshInfo()
  self:RefreshLevelAwardList()
  self:RefreshLevelAndExpInfo()
end

function ProficiencyView:RefreshLevelAwardList()
  local AllProficiencyInfo = ProficiencyData:GetAllProficiencyInfoByHeroId(self.ViewModel:GetCurHeroId())
  local Item
  local Index = 1
  local TemplateSlot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(self.ProficiencyAwardItemTemplate)
  local Padding = TemplateSlot.Padding
  local LastItem
  if not AllProficiencyInfo then
    HideOtherItem(self.LevelAwardList, Index)
    return
  end
  local AllLevelList = {}
  for Level, ProficiencyGeneralRowId in pairs(AllProficiencyInfo) do
    table.insert(AllLevelList, Level)
  end
  table.sort(AllLevelList, function(A, B)
    return A < B
  end)
  for i, Level in pairs(AllLevelList) do
    local ProficiencyGeneralRowId = AllProficiencyInfo[Level]
    Item = self.LevelAwardList:GetChildAt(Index - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.ProficiencyAwardItemTemplate:StaticClass())
      local Slot = self.LevelAwardList:AddChild(Item)
      Slot:SetPadding(Padding)
      Slot:SetVerticalAlignment(UE.EVerticalAlignment.VAlign_Bottom)
      Slot:SetHorizontalAlignment(UE.EHorizontalAlignment.HAlign_Fill)
    end
    if Item.Show then
      Item:Show(Level, ProficiencyGeneralRowId, self.ViewModel:GetCurHeroId())
    end
    LastItem = Item
    if 2 == Level then
      BeginnerGuideData:UpdateWidget("FirstProficiencyAwardItem", Item.img_guide)
    elseif 3 == Level then
      BeginnerGuideData:UpdateWidget("SecondProficiencyAwardItem", Item.img_guide)
    end
    Index = Index + 1
  end
  local Slot = UE.UWidgetLayoutLibrary.SlotAsHorizontalBoxSlot(LastItem)
  Padding.Right = 0
  Slot:SetPadding(Padding)
  HideOtherItem(self.LevelAwardList, Index)
end

function ProficiencyView:RefreshLevelAndExpInfo()
  local CurHeroId = self.ViewModel:GetCurHeroId()
  local CurUnlockLevel = ProficiencyData:GetMaxUnlockProfyLevel(CurHeroId)
  local MaxLevel = ProficiencyData:GetMaxProfyLevel(CurHeroId)
  self:RefreshCurSynopsisInfo()
  UpdateVisibility(self.Img_CircleFX, false)
  UpdateVisibility(self.Img_StarFX, false)
  if CurUnlockLevel == MaxLevel then
    UpdateVisibility(self.Img_StarFX, true)
  else
    UpdateVisibility(self.Img_CircleFX, true)
  end
  self.Txt_Level:SetText(tostring(CurUnlockLevel))
  local Result, LevelRowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyLevel, CurUnlockLevel)
  if not Result then
    print("ProficiencyView:RefreshLevelAndExpInfo not found level row info", CurUnlockLevel)
    return
  end
  self.Txt_LevelName:SetText(LevelRowInfo.Name)
end

function ProficiencyView:RefreshCurSynopsisInfo()
  local CurHeroId = self.ViewModel:GetCurHeroId()
  local CurUnlockLevel = ProficiencyData:GetMaxUnlockProfyLevel(CurHeroId)
  self.MinUnReadSynopsisLevel = MinLevel
  self.IsUnReadSynopsis = false
  for index = MinLevel, CurUnlockLevel do
    if not ProficiencyData:IsCurProfyStoryRewardReceived(CurHeroId, index) then
      self.MinUnReadSynopsisLevel = index
      break
    end
  end
  if self.MinUnReadSynopsisLevel < MinLevel then
    local MaxLevel = ProficiencyData:GetMaxProfyLevel(CurHeroId)
    self.MinUnReadSynopsisLevel = math.min(CurUnlockLevel, MaxLevel)
    if self.MinUnReadSynopsisLevel <= MinLevel then
      self.MinUnReadSynopsisLevel = MinLevel
    end
  else
    self.IsUnReadSynopsis = true
  end
  local AllProficiencyInfo = ProficiencyData:GetAllProficiencyInfoByHeroId(CurHeroId)
  if not AllProficiencyInfo then
    print("ProficiencyView:RefreshCurSynopsisInfo not found proficiency info", CurHeroId)
  end
  local GeneralRowId = AllProficiencyInfo[self.MinUnReadSynopsisLevel]
  local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBProfyGeneral, GeneralRowId)
  if Result then
    self.Txt_SynopsisName:SetText(RowInfo.Name)
    SetImageBrushByPath(self.Img_SynopsisIcon, RowInfo.IconPath)
  end
  self.Txt_SynopsisLevel:SetText(UE.FTextFormat(self.SynopsisLevelText, NumToTxt(self.MinUnReadSynopsisLevel)))
end

function ProficiencyView:BindOnProficiencyAwardItemHoverStatusChanged(IsShow, RewardId, IsInscriptionReward, Level, IsUnlock)
  if IsShow then
    local Item = self.LevelAwardList:GetChildAt(Level - MinLevel)
    local PixelPosition, ViewportPosition = UE.USlateBlueprintLibrary.LocalToViewport(self, Item:GetCachedGeometry(), UE.FVector2D(), nil, nil)
    if not IsInscriptionReward then
      local Result, RowInfo = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBGeneral, RewardId)
      if Result and RowInfo.Type == TableEnums.ENUMResourceType.Weapon then
        self.WBP_LobbyWeaponDisplayInfo:InitInfo(RewardId, nil, false, nil)
        ShowCommonTips(nil, Item, self.WBP_LobbyWeaponDisplayInfo)
        return
      end
    end
    self.WBP_ProficiencyAwardNormalTips:Show(RewardId, IsInscriptionReward, Level, IsUnlock)
    ShowCommonTips(nil, Item, self.WBP_ProficiencyAwardNormalTips)
  else
    self.WBP_ProficiencyAwardNormalTips:Hide()
    UpdateVisibility(self.WBP_LobbyWeaponDisplayInfo, false)
  end
end

function ProficiencyView:BindOnProficiencySynopsisDetailPanelVisChanged(IsShow, HeroId, Level)
  if IsShow then
    UIMgr:Show(ViewID.UI_ProficiencySynopsisDetailPanel, true, HeroId, Level)
  else
    UIMgr:Hide(ViewID.UI_ProficiencySynopsisDetailPanel, true)
  end
end

function ProficiencyView:BindOnSynopsisButtonClicked()
  UIMgr:Show(ViewID.UI_ProficiencyLegendSynopsis, true, self.ViewModel:GetCurHeroId(), self.MinUnReadSynopsisLevel)
end

function ProficiencyView:BindOnSynopsisButtonHovered()
  UpdateVisibility(self.Img_Synopsis_Hovered, true)
end

function ProficiencyView:BindOnSynopsisButtonUnhovered(...)
  UpdateVisibility(self.Img_Synopsis_Hovered, false)
end

function ProficiencyView:BindOnTipButtonHovered()
  UpdateVisibility(self.WBP_ProficiencyTip, true)
  ShowCommonTips(nil, self.Btn_Tips, self.WBP_ProficiencyTip)
end

function ProficiencyView:BindOnTipButtonUnhovered(...)
  UpdateVisibility(self.WBP_ProficiencyTip, false)
end

function ProficiencyView:OnShowLink()
  self.bShowLink = true
end

function ProficiencyView:OnPreHide()
  ChangeLobbyCamera(self, "Role")
  local targetActor = self:GetMainRoleActor()
  if UE.RGUtil.IsUObjectValid(targetActor) then
    targetActor:EnableInputActor(false)
  end
  LogicRole.ShowOrHideRoleMainHero(false)
  LogicRole.HideAndUnloadAllBgStreamLevel()
  local RoleMainActor = LogicRole.GetRoleMainActor()
  RoleMainActor.ChildActor.ChildActor:ResetAnimation()
  if self.bShowLink then
    local skinView = UIMgr:GetLuaFromActiveView(ViewID.UI_Skin)
    if skinView then
      skinView:RebackView()
    end
  end
  self.bShowLink = false
  EventSystem.RemoveListener(EventDef.Lobby.EquippedWeaponInfoChanged, self.BindOnEquippedWeaponInfoChanged, self)
  print("ProficiencyView:OnPreHide()")
  if self.ViewModel then
    self.Super:DetachViewModel(self.ViewModel, self.DataBindTable, self)
  end
end

function ProficiencyView:OnHide()
  print("ProficiencyView:OnHide()")
  if UIMgr:IsShow(ViewID.UI_ProficiencyLegendSynopsis) then
    UIMgr:Hide(ViewID.UI_ProficiencyLegendSynopsis, true)
  end
  self.ViewModel:ResetData()
end

function ProficiencyView:GetMainRoleActor()
  local RoleActorList = UE.UGameplayStatics.GetAllActorsWithTag(self, "RoleMainHero", nil)
  for i, SingleRoleActor in pairs(RoleActorList) do
    self.TargetRoleActor = SingleRoleActor
    break
  end
  return self.TargetRoleActor
end

function ProficiencyView:HideViewByViewSet(...)
  self.CanvasPanelRoot:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
  UIMgr:Hide(ViewID.UI_ProficiencyView, false)
end

function ProficiencyView:GetCurHeroId()
  return self.ViewModel.CurHeroId
end

return ProficiencyView
