local ViewBase = require("Framework.UIMgr.ViewBase")
local WBP_InitialRoleSelectionPanel = UnLua.Class(ViewBase)
local GetAppearanceActor = function(self)
  self.AppearanceActor = LogicLobby.GetAppearanceActor(self)
  return self.AppearanceActor
end

function WBP_InitialRoleSelectionPanel:Construct()
end

function WBP_InitialRoleSelectionPanel:OnInit()
  self.DataBindTable = {}
  self.viewModel = UIModelMgr:Get("InitialRoleSelectionViewModel")
end

function WBP_InitialRoleSelectionPanel:OnDestroy()
  self:UnBindClickHandler()
end

function WBP_InitialRoleSelectionPanel:BindClickHandler()
  self.ToggleCompGroup_Role.OnCheckStateChanged:Add(self, self.OnSelectHeroId)
  self.WBP_CommonButton_Select.OnMainButtonClicked:Add(self, self.OnSelectInitialHero)
  self.Btn_Movie.OnClicked:Add(self, self.OnShowMovieClicked)
  EventSystem.AddListener(self, EventDef.Lobby.RoleSkillTip, self.BindOnShowSkillTips)
end

function WBP_InitialRoleSelectionPanel:UnBindClickHandler()
  self.ToggleCompGroup_Role.OnCheckStateChanged:Remove(self, self.OnSelectHeroId)
  self.WBP_CommonButton_Select.OnMainButtonClicked:Remove(self, self.OnSelectInitialHero)
  self.Btn_Movie.OnClicked:Remove(self, self.OnShowMovieClicked)
  EventSystem.RemoveListenerNew(self, EventDef.Lobby.RoleSkillTip, self.BindOnShowSkillTips)
end

function WBP_InitialRoleSelectionPanel:OnShow()
  self.Super:AttachViewModel(self.viewModel, self.DataBindTable, self)
  local myHeroInfo = DataMgr.GetMyHeroInfo()
  if myHeroInfo and (myHeroInfo.hasSelectHero == true or myHeroInfo.equipHero > 0) then
    UIMgr:Hide(ViewID.UI_InitialRoleSelection, true)
    return
  end
  self:BindClickHandler()
  self:InitToggleGroup()
  self:UpdateLevelBgVisble(false)
  self:UpdateLevelBlendColor(self.BlendColor)
  self:PlaySeq(self.SeqCameraSoftObjPath)
  self:SetEnhancedInputActionBlocking(true)
end

function WBP_InitialRoleSelectionPanel:PlaySeq(SoftObjPath)
  if self.SequencePlayerBG and self.SequenceActorBG then
    self.SequenceActorBG:K2_DestroyActor()
    self.SequencePlayerBG:Stop()
    self.SequencePlayerBG = nil
    self.SequenceActorBG = nil
  end
  local LevelSequenceAsset = UE.URGBlueprintLibrary.TryLoadSoftPath(SoftObjPath)
  if not LevelSequenceAsset then
    return
  end
  local setting = UE.FMovieSceneSequencePlaybackSettings()
  setting.bPauseAtEnd = true
  self.SequencePlayerBG, self.SequenceActorBG = UE.ULevelSequencePlayer.CreateLevelSequencePlayer(self, LevelSequenceAsset, setting, nil)
  if self.SequencePlayerBG == nil or self.SequenceActorBG == nil then
    print("[WBP_InitialRoleSelectionPanel::Play] Player or SequenceActor is Empty!")
    return
  end
  self.SequencePlayerBG:Play()
end

function WBP_InitialRoleSelectionPanel:InitToggleGroup()
  self.ToggleCompGroup_Role:ClearGroup()
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  local Index = 1
  local DefaultSelectId
  for i, v in pairs(ConstTable.InitHero) do
    local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, v)
    if Result then
      DefaultSelectId = DefaultSelectId or v
      local Item = GetOrCreateItem(self.VerticalBox_Toggle, Index, self.WBP_InitialRoleSelection_Toggle:GetClass())
      Item:InitRoleSelectionToggle(Row)
      self.ToggleCompGroup_Role:AddWidgetToGroup(v, Item)
      Index = Index + 1
    end
  end
  HideOtherItem(self.VerticalBox_Toggle, Index, true)
  if DefaultSelectId then
    self.ToggleCompGroup_Role:SelectId(DefaultSelectId)
  end
end

function WBP_InitialRoleSelectionPanel:OnSelectHeroId(SelectId)
  self.CurSelectHeroId = tonumber(SelectId)
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, self.CurSelectHeroId)
  if Result then
    if Row.TagIcon then
      SetImageBrushByPath(self.Img_Tag, Row.TagIcon)
    end
    self.Txt_Name:SetText(Row.NickName)
    self.Txt_Desc:SetText(Row.Desc)
    self:RefreshSkillInfo(Row)
    for i, v in ipairs(Row.Tag) do
      local TagItem = GetOrCreateItem(self.HorizontalBox_Tag, i, self.WBP_InitialRoleSelection_Tag:GetClass())
      TagItem:InitRoleSelectionTag(v)
    end
    HideOtherItem(self.HorizontalBox_Tag, #Row.Tag + 1, true)
    local AppearanceActorTemp = GetAppearanceActor(self)
    AppearanceActorTemp:UpdateActived(true)
    AppearanceActorTemp:InitCommonActor(self.CurSelectHeroId, Row.SkinID, Row.WeaponID, "InitialRoleSelection")
    AppearanceActorTemp:InitRoleScaleByHeroId(self.CurSelectHeroId)
  end
  self:PlayAnimation(self.Anim_IN)
end

function WBP_InitialRoleSelectionPanel:OnSelectInitialHero()
  if not self.CurSelectHeroId then
    return
  end
  ShowWaveWindowWithDelegate(1501, {}, {
    GameInstance,
    function()
      if IsValidObj(self) and self.viewModel then
        self.viewModel:SelectHero(self.CurSelectHeroId)
      end
    end
  })
end

function WBP_InitialRoleSelectionPanel:OnShowMovieClicked()
  UpdateVisibility(self.Canvas_Movie, true)
  self.WBP_InteractTipWidget_Esc:BindInteractAndClickEvent(self, self.HideMovie)
  local Result, Row = LuaTableMgr.GetLuaTableRowInfo(TableNames.TBHeroMonster, self.CurSelectHeroId)
  local MovieSubSys = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGMovieSubSystem:StaticClass())
  if MovieSubSys and Result then
    local mediaSrc = MovieSubSys:GetMediaSource(Row.InitialRoleMediaId)
    if mediaSrc then
      self.MediaPlayer:SetLooping(true)
      self.MediaPlayer:OpenSource(mediaSrc)
      self.MediaPlayer:Rewind()
    end
  end
end

function WBP_InitialRoleSelectionPanel:HideMovie()
  UpdateVisibility(self.Canvas_Movie, false)
  self.WBP_InteractTipWidget_Esc:UnBindInteractAndClickEvent(self, self.HideMovie)
end

function WBP_InitialRoleSelectionPanel:RefreshSkillInfo(RowInfo)
  local AllSkillItems = self.HorizontalBox_Skill:GetAllChildren()
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

function WBP_InitialRoleSelectionPanel:BindOnShowSkillTips(IsShow, SkillGroupId, KeyName, SkillInputNameAry, inputNameAryPad, SkillItem)
  if IsShow then
    self.NormalSkillTip:RefreshInfo(SkillGroupId, KeyName, nil, SkillInputNameAry, inputNameAryPad)
    self.NormalSkillTip:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
    ShowCommonTips(nil, SkillItem, self.NormalSkillTip)
    SetHitTestInvisible(self.NormalSkillTip)
  else
    self.NormalSkillTip:Hide()
  end
end

function WBP_InitialRoleSelectionPanel:UpdateLevelBgVisble(bVisible)
  local AllActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "InitialRoleSelection", nil)
  for i, v in pairs(AllActors) do
    if v:IsValid() then
      v:SetActorHiddenInGame(not bVisible)
    end
  end
  local AllNeedInverseVisibleActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "LobbyMain", nil)
  for i, v in pairs(AllNeedInverseVisibleActors) do
    if v:IsValid() then
      v:SetActorHiddenInGame(bVisible)
    end
  end
end

function WBP_InitialRoleSelectionPanel:UpdateLevelBlendColor(LinearColor)
  local AllMatActors = UE.UGameplayStatics.GetAllActorsWithTag(self, "InitialRoleSelectionMat", nil)
  local world = GameInstance:GetWorld()
  for i, v in pairs(AllMatActors) do
    if v:IsValid() and v.StaticMeshComponent:IsValid() then
      local MI = v.StaticMeshComponent:GetMaterial(0)
      local MID
      if not MI:IsA(UE.UMaterialInstanceDynamic.StaticClass()) then
        MID = UE.UKismetMaterialLibrary.CreateDynamicMaterialInstance(world, MI)
        MID:K2_CopyMaterialInstanceParameters(MI, true)
      else
        MID = MI
      end
      MID:SetVectorParameterValue("BlendColor", LinearColor)
      v.StaticMeshComponent:SetMaterial(0, MID)
      break
    end
  end
end

function WBP_InitialRoleSelectionPanel:OnHide()
  local AppearanceActorTemp = GetAppearanceActor(self)
  AppearanceActorTemp:UpdateActived(false)
  self:UnBindClickHandler()
  self.Super:DetachViewModel(self.viewModel, self.DataBindTable, self)
  self:SetEnhancedInputActionBlocking(false)
  self:UpdateLevelBgVisble(true)
  self:UpdateLevelBlendColor(self.BlendColorSource)
  if self.SequencePlayerBG and self.SequenceActorBG then
    self.SequenceActorBG:K2_DestroyActor()
    self.SequencePlayerBG:Stop()
    self.SequencePlayerBG = nil
    self.SequenceActorBG = nil
  end
  EventSystem.Invoke(EventDef.Lobby.PlayInAnimation)
end

function WBP_InitialRoleSelectionPanel:OnHideByOther()
  self:UnBindClickHandler()
end

return WBP_InitialRoleSelectionPanel
