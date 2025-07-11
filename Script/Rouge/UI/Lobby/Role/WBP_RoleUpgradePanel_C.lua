local WBP_RoleUpgradePanel_C = UnLua.Class()
local ListContainer = require("Rouge.UI.Common.ListContainer")
function WBP_RoleUpgradePanel_C:Construct()
  self.Btn_Esc.OnClicked:Add(self, WBP_RoleUpgradePanel_C.BindOnEscButtonClicked)
  self.Btn_Upgrade.OnClicked:Add(self, WBP_RoleUpgradePanel_C.BindOnUpgradeButtonClicked)
end
function WBP_RoleUpgradePanel_C:InitInfo(HeroId)
  self.CurHeroId = HeroId
  local HeroRowInfo = LogicRole.GetCharacterTableRow(self.CurHeroId)
  if HeroRowInfo then
    self.Txt_Name:SetText(HeroRowInfo.Name)
    SetImageBrushByPath(self.Img_RoleIcon, HeroRowInfo.UpgradeBGIcon)
  end
  self:RefreshStarButtonStatus()
  local HeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  EventSystem.Invoke(EventDef.Lobby.HeroStarUpgradeItemClicked, HeroStar + 1)
end
function WBP_RoleUpgradePanel_C:RefreshStarButtonStatus()
  local HeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  local MaxHeroStar = LogicRole.GetMaxHeroStar(self.CurHeroId)
  local AllChildren = self.StarPanel:GetAllChildren()
  for i, SingleStarButtonItem in pairs(AllChildren) do
    SingleStarButtonItem:RefreshButtonStatus(HeroStar)
    if MaxHeroStar < SingleStarButtonItem.StarLevel then
      SingleStarButtonItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    else
      SingleStarButtonItem:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
  end
end
function WBP_RoleUpgradePanel_C:Show(SelfHitTestInvisible, Activate)
  self.Overridden.Show(self, SelfHitTestInvisible, Activate)
  EventSystem.AddListener(self, EventDef.Lobby.HeroStarUpgradeItemClicked, WBP_RoleUpgradePanel_C.BindOnHeroStarUpgradeItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, WBP_RoleUpgradePanel_C.BindOnUpdateMyHeroInfo)
  EventSystem.AddListener(self, EventDef.Lobby.UpdateResourceInfo, WBP_RoleUpgradePanel_C.BindOnUpdateResourceInfo)
end
function WBP_RoleUpgradePanel_C:Hide(Collapsed, Activate)
  self.Overridden.Hide(self, Collapsed, Activate)
  EventSystem.RemoveListener(EventDef.Lobby.HeroStarUpgradeItemClicked, WBP_RoleUpgradePanel_C.BindOnHeroStarUpgradeItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_RoleUpgradePanel_C.BindOnUpdateMyHeroInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateResourceInfo, WBP_RoleUpgradePanel_C.BindOnUpdateResourceInfo, self)
end
function WBP_RoleUpgradePanel_C:BindOnEscButtonClicked()
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:Switch(UE.UGameplayStatics.GetObjectClass(self), true)
end
function WBP_RoleUpgradePanel_C:BindOnUpgradeButtonClicked()
  if not self.IsCanUpgrade then
    print("\229\141\135\231\186\167\230\157\144\230\150\153\228\184\141\232\182\179")
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if not RGWaveWindowManager then
      return
    end
    RGWaveWindowManager:ShowWaveWindow(1047, {})
    return
  end
  local Param = {
    heroId = self.CurHeroId,
    star = self.TargetStarLevel
  }
  HttpCommunication.Request("hero/upgradeherostar", Param, {
    self,
    function()
      local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
      if not RGWaveWindowManager then
        return
      end
      RGWaveWindowManager:ShowWaveWindow(1046, {})
    end
  }, {
    self,
    function()
    end
  })
end
function WBP_RoleUpgradePanel_C:BindOnHeroStarUpgradeItemClicked(TargetStarLevel)
  self.TargetStarLevel = TargetStarLevel
  local CurHeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  self.CurStar:RefreshInfo(CurHeroStar, LogicRole.GetMaxHeroStar(self.CurHeroId))
  self.TargetStar:RefreshInfo(TargetStarLevel, LogicRole.GetMaxHeroStar(self.CurHeroId))
  self:RefreshAttributeList(TargetStarLevel)
  self:RefreshSkillList(TargetStarLevel)
  local HeroStarInfoList = LogicRole.GetHeroStarInfo(self.CurHeroId)
  if not HeroStarInfoList then
    print("WBP_RoleUpgradePanel_C:BindOnHeroStarUpgradeItemClicked not hero star info, HeroId:", self.CurHeroId)
    return
  end
  local TargetHeroStarInfo = HeroStarInfoList[TargetStarLevel]
  if TargetHeroStarInfo then
    local CostList = TargetHeroStarInfo.ArrCost
    local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
    local ResourceRow = ResourceTable[CostList[1].key]
    local CurHaveNum = 0
    if ResourceRow then
      if ResourceRow.Type == TableEnums.ENUMResourceType.CURRENCY then
        CurHaveNum = DataMgr.GetOutsideCurrencyNumById(CostList[1].key)
      else
        CurHaveNum = DataMgr.GetPackbackNumById(CostList[1].key)
      end
    end
    self.CurCostInfo = CostList[1]
    SetImageBrushByPath(self.Img_CostIcon, ResourceRow.Icon)
    self.Txt_Cost:SetText(CostList[1].value)
    self.Txt_HaveNum:SetText(CurHaveNum .. "/")
    self:RefreshUpgradeResourceInfo()
  end
end
function WBP_RoleUpgradePanel_C:RefreshUpgradeResourceInfo()
  local ResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  local ResourceRow = ResourceTable[self.CurCostInfo.key]
  local CurHaveNum = 0
  if ResourceRow then
    if ResourceRow.Type == TableEnums.ENUMResourceType.CURRENCY then
      CurHaveNum = DataMgr.GetOutsideCurrencyNumById(self.CurCostInfo.key)
    else
      CurHaveNum = DataMgr.GetPackbackNumById(self.CurCostInfo.key)
    end
  end
  local SlateColor = UE.FSlateColor()
  SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
  self.Txt_HaveNum:SetText(CurHaveNum .. "/")
  if CurHaveNum >= self.CurCostInfo.value then
    SlateColor.SpecifiedColor = UE.FLinearColor(0.023153, 0.318547, 0.558341, 1.0)
    self.IsCanUpgrade = true
  else
    SlateColor.SpecifiedColor = UE.FLinearColor(0.558341, 0.009656, 0.054141, 1.0)
    self.IsCanUpgrade = false
  end
  self.Txt_HaveNum:SetColorAndOpacity(SlateColor)
end
function WBP_RoleUpgradePanel_C:BindOnUpdateMyHeroInfo()
  local HeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  local MaxHeroStar = LogicRole.GetMaxHeroStar(self.CurHeroId)
  if HeroStar >= MaxHeroStar then
    self:BindOnEscButtonClicked()
  else
    self:RefreshStarButtonStatus()
    EventSystem.Invoke(EventDef.Lobby.HeroStarUpgradeItemClicked, HeroStar + 1)
  end
end
function WBP_RoleUpgradePanel_C:BindOnUpdateResourceInfo()
  self:RefreshUpgradeResourceInfo()
end
function WBP_RoleUpgradePanel_C:RefreshAttributeList(TargetStarLevel)
  local AllChildren = self.AttributeList:GetAllChildren()
  for i, SingleChildItem in pairs(AllChildren) do
    SingleChildItem:Hide()
  end
  local HeroStarInfoList = LogicRole.GetHeroStarInfo(self.CurHeroId)
  if not HeroStarInfoList then
    print("WBP_RoleUpgradePanel_C:RefreshAttributeList not hero star info, HeroId:", self.CurHeroId)
    return
  end
  local HeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  local CurHeroStarInfo = HeroStarInfoList[HeroStar]
  local TargetHeroStarInfo = HeroStarInfoList[TargetStarLevel]
  if not TargetHeroStarInfo then
    print("WBP_RoleUpgradePanel_C:RefreshAttributeList not enough info, HeroId:", self.CurHeroId)
    return
  end
  local TargetAttrList = {}
  for i, SingleAttrInfo in ipairs(TargetHeroStarInfo.ArrAttr) do
    local TempTable = {}
    TempTable.TargetValue = SingleAttrInfo.value
    TargetAttrList[SingleAttrInfo.key] = TempTable
  end
  if CurHeroStarInfo then
    for i, SingleAttrInfo in ipairs(CurHeroStarInfo.ArrAttr) do
      local AttrList = TargetAttrList[SingleAttrInfo.key]
      if AttrList then
        AttrList.CurValue = SingleAttrInfo.value
      end
    end
  end
  local Index = 0
  for AttrKey, AttrValueList in pairs(TargetAttrList) do
    local Item = self.AttributeList:GetChildAt(Index)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.AttributeItemTemplate:StaticClass())
      self.AttributeList:AddChild(Item)
    end
    local CurValue = AttrValueList.CurValue
    CurValue = CurValue or 0
    Index = Index + 1
    Item:Show(AttrKey, CurValue, AttrValueList.TargetValue)
  end
end
function WBP_RoleUpgradePanel_C:RefreshSkillList(TargetStarLevel)
  local HeroRowInfo = LogicRole.GetCharacterTableRow(self.CurHeroId)
  if not HeroRowInfo then
    return
  end
  local CurHeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  for index, SingleSkillGroupId in ipairs(HeroRowInfo.SkillList) do
    local SingleSkillGroupInfo = LogicRole.GetSkillTableRow(SingleSkillGroupId)
    if SingleSkillGroupInfo and SingleSkillGroupInfo[1] then
      if SingleSkillGroupInfo[1].Type == TableEnums.ENUMSkillType.Fetter then
        self.FetterSkillItem:RefreshInfo(CurHeroStar, TargetStarLevel, SingleSkillGroupId)
      end
      if SingleSkillGroupInfo[1].Type == TableEnums.ENUMSkillType.Light then
      end
    end
  end
end
function WBP_RoleUpgradePanel_C:FocusInput()
  self.Overridden.FocusInput(self)
end
function WBP_RoleUpgradePanel_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.HeroStarUpgradeItemClicked, WBP_RoleUpgradePanel_C.BindOnHeroStarUpgradeItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_RoleUpgradePanel_C.BindOnUpdateMyHeroInfo, self)
end
return WBP_RoleUpgradePanel_C
