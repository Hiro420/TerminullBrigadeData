local rapidjson = require("rapidjson")
local WBP_SoulCoreEquipPanel_C = UnLua.Class()
local SoulCoreEquipItemClsPath = "/Game/Rouge/UI/Lobby/SoulCore/WBP_SoulCoreEquipItem.WBP_SoulCoreEquipItem_C"
local SoulCoreSkillLevelDescItemPath = "/Game/Rouge/UI/Lobby/SoulCore/WBP_SoulCoreSkillLevelDescItem.WBP_SoulCoreSkillLevelDescItem_C"
local SoulCoreSkillTagPath = "/Game/Rouge/UI/Lobby/SoulCore/WBP_SoulCoreSkillTag.WBP_SoulCoreSkillTag_C"

function WBP_SoulCoreEquipPanel_C:Construct()
end

function WBP_SoulCoreEquipPanel_C:Destruct()
  self.ParentView = nil
end

function WBP_SoulCoreEquipPanel_C:InitInfo(MainHeroId, ParentView)
  self.ParentView = ParentView
  self.MainHeroId = MainHeroId
end

function WBP_SoulCoreEquipPanel_C:UpdateSoulCoreEquipItemList()
  local AllFetterSlotIds = LogicRole.GetAllFetterSlotIds()
  local SoulCoreEquipItemCls = UE.UClass.Load(SoulCoreEquipItemClsPath)
  for i, v in ipairs(AllFetterSlotIds) do
    local SoulCoreEquipItem = GetOrCreateItem(self.ScrollBoxSoulCore, i, SoulCoreEquipItemCls)
    SoulCoreEquipItem:InitInfo(self, v, self.MainHeroId, self.SelectItem, self.UnSelectItem)
  end
  HideOtherItem(self.ScrollBoxSoulCore, #AllFetterSlotIds + 1)
end

function WBP_SoulCoreEquipPanel_C:SelectItem(CharacterId)
  self.CurSelectCharacterId = CharacterId
  self.CanvasPanelTips:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if CharacterId > 0 then
    self.RGTextTips:SetText("\230\155\191\230\141\162\232\175\165\230\160\184\229\191\131")
    self.CanvasPanelEmpty:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:UpdateView(CharacterId)
    self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.RGTextTips:SetText("\232\189\189\229\133\165\232\175\165\230\160\184\229\191\131")
    self.CanvasPanelEmpty:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end

function WBP_SoulCoreEquipPanel_C:UnSelectItem()
  self.CanvasPanelTips:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.CanvasPanelEmpty:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  self.CanvasPanelDetails:SetVisibility(UE.ESlateVisibility.Collapsed)
end

function WBP_SoulCoreEquipPanel_C:UpdateView(CharacterId)
  local SkillGroupId = LogicRole.GetFetterSkillGroupIdByHeroId(CharacterId)
  local SkillList = LogicRole.HeroSkillTable[SkillGroupId]
  if SkillList then
    local Lv = DataMgr.GetHeroLevelByHeroId(CharacterId)
    self.RGTextSkillName:SetText(SkillList[1].Name)
    self.RichTextBlockDesc:SetText(SkillList[1].SimpleDesc)
    self.RGTextEquoped:SetVisibility(UE.ESlateVisibility.Collapsed)
    local AllFetterSlotIds = LogicRole.GetAllFetterSlotIds()
    for i, v in ipairs(AllFetterSlotIds) do
      local SlotHeroId = LogicRole.GetCurSlotHeroId(self.MainHeroId, v)
      if SlotHeroId > 0 and LogicSoulCore.CurSelectSoulCoreId == SlotHeroId then
        self.RGTextEquoped:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
        break
      end
    end
    self.RGTextSkillLevel:SetText(Lv)
    SetImageBrushByPath(self.URGImageSkillIcon, SkillList[1].IconPath)
    self:UpdateSkillTag(SkillList[1].SkillTags)
    self:UpdateSkillDesc(SkillList, Lv)
  end
end

function WBP_SoulCoreEquipPanel_C:UpdateSkillTag(SkillTags)
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

function WBP_SoulCoreEquipPanel_C:UpdateSkillDesc(SkillList, CharacterStar)
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

return WBP_SoulCoreEquipPanel_C
