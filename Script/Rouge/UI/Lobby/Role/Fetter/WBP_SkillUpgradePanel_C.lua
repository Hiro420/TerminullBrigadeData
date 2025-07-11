local rapidjson = require("rapidjson")
local WBP_SkillUpgradePanel_C = UnLua.Class()
function WBP_SkillUpgradePanel_C:Construct()
  self:Hide()
  self.Btn_Upgrade.OnClicked:Add(self, WBP_SkillUpgradePanel_C.BindOnUpgradeButtonClicked)
end
function WBP_SkillUpgradePanel_C:BindOnUpgradeButtonClicked()
  local Param = {
    heroId = self.FetterHeroId,
    type = UE.ERoleSkillType.RST_FetterSkill
  }
  HttpCommunication.Request("hero/strengthenheroskill", Param, {
    self,
    function()
      HttpCommunication.RequestByGet("hero/getmyheroinfo", {
        self,
        function(self, JsonResponse)
          print("GetMyHeroInfoSuccess", JsonResponse.Content)
          local JsonTable = rapidjson.decode(JsonResponse.Content)
          DataMgr.SetMyHeroInfo(JsonTable)
          self:Hide()
        end
      }, {
        self,
        function()
          print("GetMyHeroInfoFail")
        end
      })
    end
  }, {
    self,
    function()
    end
  })
end
function WBP_SkillUpgradePanel_C:Show(FetterHeroId)
  self.FetterHeroId = FetterHeroId
  self:SetVisibility(UE.ESlateVisibility.Visible)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local Result, CharacterRow = GetRowDataForCharacter(FetterHeroId)
  if not Result then
    return
  end
  local FetterId = CharacterRow.SkillList:Find(UE.ERoleSkillType.RST_FetterSkill)
  if FetterId then
    local Result, FetterSkillRow = DTSubsystem:GetFetterSkillRowInfoByID(FetterId)
    if not Result then
      return
    end
    self.Txt_Desc:SetText(FetterSkillRow.FetterSkillType)
    local AllLevelItems = self.SkillLevelDescList:GetAllChildren()
    for i, SingleItem in iterator(AllLevelItems) do
      SingleItem:SetVisibility(UE.ESlateVisibility.Collapsed)
    end
    local SkillLevelInfo = FetterSkillRow.SkillLevelInfo
    self:UpdateUpgradeButtonStatus(SkillLevelInfo)
    for i, SingleSkillLevelInfo in iterator(SkillLevelInfo) do
      local Item = self.SkillLevelDescList:GetChildAt(i - 1)
      if not Item then
        Item = self:SpawnLevelInfoItem()
      else
        Item:SetVisibility(UE.ESlateVisibility.Visible)
      end
      Item:SetText("LV:" .. SingleSkillLevelInfo.SkillLevel .. "  " .. SingleSkillLevelInfo.SkillDesc)
      local SlateColor = UE.FSlateColor()
      SlateColor.ColorUseRule = UE.ESlateColorStylingMode.UseColor_Specified
      local CurSkillLevel = DataMgr.GetSkillLevelByType(self.FetterHeroId, UE.ERoleSkillType.RST_FetterSkill)
      if SingleSkillLevelInfo.SkillLevel == CurSkillLevel then
        SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 0.736161, 0.0, 1.0)
        Item:SetColorAndOpacity(SlateColor)
        local Result, OutsideCurrencyRow = DTSubsystem:GetOutsideCurrencyRowInfoByID(SingleSkillLevelInfo.UnlockMaterialIndex)
        if Result then
          local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(OutsideCurrencyRow.Icon)
          if IconObj then
            local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
            self.Img_CostIcon:SetBrush(Brush)
          end
        end
        local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(SingleSkillLevelInfo.Icon)
        if IconObj then
          local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
          self.Img_Icon:SetBrush(Brush)
        end
        self.Txt_RemainCurrency:SetText(tostring(DataMgr.GetOutsideCurrencyNumById(SingleSkillLevelInfo.UnlockMaterialIndex)))
        self.Txt_CostNum:SetText(tostring(SingleSkillLevelInfo.UnlockMaterialNum))
      else
        SlateColor.SpecifiedColor = UE.FLinearColor(1.0, 1.0, 1.0, 1.0)
        Item:SetColorAndOpacity(SlateColor)
      end
    end
  end
end
function WBP_SkillUpgradePanel_C:UpdateUpgradeButtonStatus(SkillLevelInfo)
  local CurSkillLevel = DataMgr.GetSkillLevelByType(self.FetterHeroId, UE.ERoleSkillType.RST_FetterSkill)
  local MaxLevel = 1
  for i, SingleSkillLevelInfo in iterator(SkillLevelInfo) do
    if MaxLevel < SingleSkillLevelInfo.SkillLevel then
      MaxLevel = SingleSkillLevelInfo.SkillLevel
    end
  end
  if CurSkillLevel >= MaxLevel then
    self.Btn_Upgrade:SetIsEnabled(false)
  else
    self.Btn_Upgrade:SetIsEnabled(true)
  end
end
function WBP_SkillUpgradePanel_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
return WBP_SkillUpgradePanel_C
