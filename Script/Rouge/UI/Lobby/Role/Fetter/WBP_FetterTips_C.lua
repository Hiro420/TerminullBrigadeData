local WBP_FetterTips_C = UnLua.Class()

function WBP_FetterTips_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotItemClicked, WBP_FetterTips_C.BindOnFetterSlotItemClicked)
  EventSystem.AddListener(self, EventDef.Lobby.FetterHeroInfoUpdate, WBP_FetterTips_C.BindOnFetterHeroInfoUpdate)
  self.Btn_EquipStatus.OnClicked:Add(self, WBP_FetterTips_C.BindOnEquipStatusClicked)
  self.Btn_Upgrade.OnClicked:Add(self, WBP_FetterTips_C.BindOnUpgradeButtonClicked)
end

function WBP_FetterTips_C:BindOnEquipStatusClicked()
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if not self:IsSlotUnlock() then
    if WaveWindowManager then
      WaveWindowManager:ShowWaveWindow(self.SlotLockId, {})
    end
    return
  end
  if self.CurHeroId == self.MainHeroId then
    if WaveWindowManager then
      WaveWindowManager:ShowWaveWindow(self.CanNotEquipId, {})
    end
    return
  end
  local CurSlotHeroId = self:GetCurSlotHeroId()
  if CurSlotHeroId == self.CurHeroId then
    HttpCommunication.Request("hero/unequipfetterhero", {
      slot = self.CurSlotId,
      heroId = self.MainHeroId
    }, {
      self,
      function(self)
        LogicRole.RequestGetHeroFetterInfoToServer(self.MainHeroId, {
          self,
          function(self)
          end
        })
      end
    }, {
      self,
      function()
      end
    })
  else
    LogicRole.RequestEquipFetterHeroToServer(self.CurSlotId, self.CurHeroId, self.MainHeroId)
  end
end

function WBP_FetterTips_C:BindOnUpgradeButtonClicked()
  local CurLevel = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  local MaxLevel = LogicRole.GetMaxHeroStar(self.CurHeroId)
  if CurLevel >= MaxLevel then
    local RGWaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
    if RGWaveWindowManager then
      RGWaveWindowManager:ShowWaveWindow(self.CanNotUpgradeId, {})
    end
    return
  end
  local WidgetClass = UE.UClass.Load("/Game/Rouge/UI/Lobby/Role/WBP_RoleUpgradePanel.WBP_RoleUpgradePanel_C")
  local UIManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGUIManager:StaticClass())
  if not UIManager then
    return
  end
  UIManager:Switch(WidgetClass, true)
  local Widget = UIManager:K2_GetUI(WidgetClass)
  if Widget then
    Widget:InitInfo(self.CurHeroId)
  end
end

function WBP_FetterTips_C:RefreshInfo(SkillGroupId, CurHeroId, MainHeroId)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.CurHeroId = CurHeroId
  self.MainHeroId = MainHeroId
  self.SkillGroupId = SkillGroupId
  EventSystem.AddListener(self, EventDef.Lobby.UpdateMyHeroInfo, WBP_FetterTips_C.BindOnUpdateMyHeroInfo)
  EventSystem.AddListener(self, EventDef.Lobby.FetterSlotStatusUpdate, WBP_FetterTips_C.BindOnFetterSlotStatusUpdate)
  local SkillGroupInfo = LogicRole.GetSkillTableRow(SkillGroupId)
  if not SkillGroupInfo then
    print("not found skill group info,SkillGroupId:", SkillGroupId)
    return
  end
  local CurLevel = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  local TargetSkillInfo = SkillGroupInfo[CurLevel]
  if not TargetSkillInfo then
    TargetSkillInfo = SkillGroupInfo[1]
    if not TargetSkillInfo then
      return
    end
  end
  self.SkillLevelPanel:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.Img_Line:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Txt_SkillName:SetText(TargetSkillInfo.Name)
  local DescParams = {}
  for i, SingleParam in ipairs(TargetSkillInfo.DescParams) do
    table.insert(DescParams, self.DescRichTextName .. SingleParam .. "</>")
  end
  local FinalText = TargetSkillInfo.Desc
  local WaveWindowManager = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGWaveWindowManager:StaticClass())
  if WaveWindowManager then
    FinalText = WaveWindowManager:FormatTextByOrder(FinalText, DescParams)
  end
  self.Txt_SkillLevel:SetText(tostring(CurLevel))
  self.Txt_SkillDesc:SetText(FinalText)
  self:UpdateSkillTag(TargetSkillInfo.SkillTags)
  self:SetUpgradeButtonVisibility()
  self:UpdateEquipStatus()
  local SoftObjReference = MakeStringToSoftObjectReference(TargetSkillInfo.IconPath)
  if UE.UKismetSystemLibrary.IsValidSoftObjectReference(SoftObjReference) then
    local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SoftObjReference):Cast(UE.UPaperSprite)
    if IconObj then
      local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
      self.Img_Icon:SetBrush(Brush)
    end
  end
end

function WBP_FetterTips_C:UpdateSkillLevelInfo(SkillGroupInfo)
  local AllLevelItems = self.SkillLevelPanel:GetAllChildren()
  for i, SingleItem in iterator(AllLevelItems) do
    SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local HeroStar = 1
  if DataMgr then
    HeroStar = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  end
  local Index = 1
  for Level, SingleSkillLevelInfo in pairs(SkillGroupInfo) do
    if 1 ~= SingleSkillLevelInfo.Star and HeroStar >= SingleSkillLevelInfo.Star then
      local Item = self.SkillLevelPanel:GetChildAt(Index - 1)
      if not Item then
        Item = self:SpawnSkillLevelInfoItem()
      else
        Item:SetVisibility(UE.ESlateVisibility.Visible)
      end
      Item:SetText("LV:" .. SingleSkillLevelInfo.Star .. "  " .. SingleSkillLevelInfo.SimpleDesc)
      local SlateColor = UE.FSlateColor()
      SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
      if SingleSkillLevelInfo.Star == HeroStar then
        SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
        Item:SetColorAndOpacity(SlateColor)
      elseif HeroStar < SingleSkillLevelInfo.Star then
        SlateColor.SpecifiedColor = UE.FLinearColor(0.323143, 0.323143, 0.323143, 1.0)
        Item:SetColorAndOpacity(SlateColor)
      else
        SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
        Item:SetColorAndOpacity(SlateColor)
      end
    end
    Index = Index + 1
  end
end

function WBP_FetterTips_C:UpdateSkillTag(SkillTagList)
  local TagItemList = self.SkillTagList:GetAllChildren()
  for i, SingleTagItem in iterator(TagItemList) do
    SingleTagItem:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  local SkillTagInfo = LuaTableMgr.GetLuaTableByName(TableNames.TBSkillTag)
  for i, SingleTagId in ipairs(SkillTagList) do
    local Item = self.SkillTagList:GetChildAt(i - 1)
    if not Item then
      Item = UE.UWidgetBlueprintLibrary.Create(self, self.TagItemTemplate:StaticClass())
      local Slot = self.SkillTagList:AddChild(Item)
      local Padding = UE.FMargin()
      Padding.Right = 5.0
      Slot:SetPadding(Padding)
    else
      Item:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    local TargetSkillTagInfo = SkillTagInfo[SingleTagId]
    if TargetSkillTagInfo then
      Item:RefreshInfo(TargetSkillTagInfo.Name)
    else
      Item:RefreshInfo("")
    end
  end
end

function WBP_FetterTips_C:SetUpgradeButtonVisibility()
  local CurLevel = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  local MaxLevel = LogicRole.GetMaxHeroStar(self.CurHeroId)
  if CurLevel < MaxLevel then
  else
  end
end

function WBP_FetterTips_C:UpdateEquipStatus()
  self.Txt_Equipped:SetVisibility(UE.ESlateVisibility.Collapsed)
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(self.MainHeroId)
  if FetterHeroInfo then
    for i, SingleFetterInfo in ipairs(FetterHeroInfo) do
      if SingleFetterInfo.id == self.CurHeroId then
        self.Txt_Equipped:SetVisibility(UE.ESlateVisibility.HitTestInvisible)
        break
      end
    end
  end
  if self.CurHeroId == self.MainHeroId then
    self.Txt_EquipStatus:SetText(self.CanNotEquipText)
    return
  end
  if self:IsSlotUnlock() then
    self.Btn_EquipStatus:SetIsEnabled(true)
    local CurSlotId = self:GetCurSlotHeroId()
    if 0 == CurSlotId then
      self.Txt_EquipStatus:SetText(self.CanEquipText)
    elseif CurSlotId == self.CurHeroId then
      self.Txt_EquipStatus:SetText(self.UnEquipText)
    else
      self.Txt_EquipStatus:SetText(self.ChangeText)
    end
  else
    self.Txt_EquipStatus:SetText(self.LockText)
  end
end

function WBP_FetterTips_C:GetCurSlotHeroId()
  local FetterHeroInfo = DataMgr.GetFetterHeroInfoById(self.MainHeroId)
  local SlotHeroId = 0
  if FetterHeroInfo then
    for i, SingleFetterHeroInfo in ipairs(FetterHeroInfo) do
      if SingleFetterHeroInfo.slot == self.CurSlotId then
        SlotHeroId = SingleFetterHeroInfo.id
      end
    end
  end
  return SlotHeroId
end

function WBP_FetterTips_C:IsSlotUnlock()
  local HeroInfo = DataMgr.GetMyHeroInfo()
  local SlotStatus = HeroInfo.slots[self.CurSlotId]
  return SlotStatus and SlotStatus == TableEnums.ENUMSlotStatus.Open or false
end

function WBP_FetterTips_C:BindOnFetterSlotItemClicked(SlotId)
  self.CurSlotId = SlotId
  if self:IsVisible() then
    self:UpdateEquipStatus()
  end
end

function WBP_FetterTips_C:BindOnFetterHeroInfoUpdate()
  if self.CurHeroId then
    self:UpdateEquipStatus()
  end
end

function WBP_FetterTips_C:BindOnUpdateMyHeroInfo()
  if not self.CurHeroId then
    return
  end
  local CurLevel = DataMgr.GetHeroLevelByHeroId(self.CurHeroId)
  self.Txt_SkillLevel:SetText(tostring(CurLevel))
  local SkillGroupInfo = LogicRole.GetSkillTableRow(self.SkillGroupId)
  if SkillGroupInfo then
    self:UpdateSkillLevelInfo(SkillGroupInfo)
  end
  self:SetUpgradeButtonVisibility()
end

function WBP_FetterTips_C:BindOnFetterSlotStatusUpdate()
  self:UpdateEquipStatus()
end

function WBP_FetterTips_C:HidePanel()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.RemoveListener(EventDef.Lobby.UpdateMyHeroInfo, WBP_FetterTips_C.BindOnUpdateMyHeroInfo, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotStatusUpdate, WBP_FetterTips_C.BindOnFetterSlotStatusUpdate, self)
end

function WBP_FetterTips_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.FetterSlotItemClicked, WBP_FetterTips_C.BindOnFetterSlotItemClicked, self)
  EventSystem.RemoveListener(EventDef.Lobby.FetterHeroInfoUpdate, WBP_FetterTips_C.BindOnFetterHeroInfoUpdate, self)
  self:HidePanel()
end

return WBP_FetterTips_C
