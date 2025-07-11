local rapidjson = require("rapidjson")
local WBP_SoulCoreEquipItem_C = UnLua.Class()
function WBP_SoulCoreEquipItem_C:Construct()
  self.ButtonEquip.OnClicked:Add(self, self.EquipFetterHeroByPos)
end
function WBP_SoulCoreEquipItem_C:Destruct()
  self.ButtonEquip.OnClicked:Remove(self, self.EquipFetterHeroByPos)
  self.ParentView = nil
  self.SelectCallback = nil
  self.UnSelectCallback = nil
end
function WBP_SoulCoreEquipItem_C:InitInfo(ParentView, SlotId, MainHeroId, SelectCallback, UnSelectCallback)
  self:SetVisibility(UE.ESlateVisibility.Visible)
  self.SlotId = SlotId
  self.MainHeroId = MainHeroId
  self.ParentView = ParentView
  self.SelectCallback = SelectCallback
  self.UnSelectCallback = UnSelectCallback
  if LogicRole.IsSlotUnlock(self.SlotId) then
    self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.Collapsed)
    local SlotHeroId = LogicRole.GetCurSlotHeroId(MainHeroId, SlotId)
    if SlotHeroId > 0 then
      self.CanvasPanelEmpty:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.CanvasPanelRoot:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      local Lv = DataMgr.GetHeroLevelByHeroId(SlotHeroId)
      self.WBP_LobbyStarWidget.MaxStar = LogicRole.GetMaxHeroStar(SlotHeroId)
      self.WBP_LobbyStarWidget:UpdateStar(Lv)
      self:UpdateItem(SlotHeroId)
    else
      self.CanvasPanelEmpty:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self.CanvasPanelRoot:SetVisibility(UE.ESlateVisibility.Collapsed)
      self.URGImageRareLace:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 1))
    end
  else
    self.CanvasPanelEmpty:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanelRoot:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.CanvasPanelLock:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.URGImageRareLace:SetColorAndOpacity(UE.FLinearColor(1, 1, 1, 1))
  end
end
function WBP_SoulCoreEquipItem_C:UpdateItem(SlotHeroId)
  local DTSubsystem = UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self, UE.URGDataTableSubsystem:StaticClass())
  if not DTSubsystem then
    return
  end
  local CharacterRow = LogicRole.GetCharacterTableRow(SlotHeroId)
  local IconPath = ""
  local ResourceId = -1
  if CharacterRow then
    IconPath = CharacterRow.ActorIcon
    ResourceId = CharacterRow.ResourceId
  end
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if TotalResourceTable and TotalResourceTable[ResourceId] then
    local itemRarityResult, itemRarityData = DTSubsystem:GetItemRarityTableRow(TotalResourceTable[ResourceId].Rare)
    if itemRarityData then
      self.URGImageRareLace:SetColorAndOpacity(itemRarityData.DisplayNameColor.SpecifiedColor)
      local IconObj = UE.UKismetSystemLibrary.LoadAsset_Blocking(itemRarityData.RoleRareFrameStyle1):Cast(UE.UPaperSprite)
      if IconObj then
        local Brush = UE.UPaperSpriteBlueprintLibrary.MakeBrushFromSprite(IconObj, 0, 0)
        self.URGImageRareBg:SetBrush(Brush)
      end
    end
    self.RGTextName:SetText(TotalResourceTable[ResourceId].Name)
  end
  if self.bIsSelectItem then
    self.URGImageSelect:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.URGImageChange:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.URGImageSelect:SetVisibility(UE.ESlateVisibility.Collapsed)
    self.URGImageChange:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  SetImageBrushByPath(self.URGImageIcon, IconPath)
end
function WBP_SoulCoreEquipItem_C:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end
function WBP_SoulCoreEquipItem_C:OnMouseEnter(MyGeometry, MouseEvent)
  self.bIsSelectItem = true
  local SlotHeroId = LogicRole.GetCurSlotHeroId(self.MainHeroId, self.SlotId)
  self.URGImageSelect:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if SlotHeroId > 0 then
    self.URGImageChange:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  else
    self.URGImageChange:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
  if self.SelectCallback then
    self.SelectCallback(self.ParentView, SlotHeroId)
  end
end
function WBP_SoulCoreEquipItem_C:OnMouseLeave(MouseEvent)
  self.bIsSelectItem = false
  self.URGImageSelect:SetVisibility(UE.ESlateVisibility.Collapsed)
  self.URGImageChange:SetVisibility(UE.ESlateVisibility.Collapsed)
  if self.UnSelectCallback then
    self.UnSelectCallback(self.ParentView)
  end
end
function WBP_SoulCoreEquipItem_C:EquipFetterHeroByPos()
  local SlotHeroId = LogicRole.GetCurSlotHeroId(self.MainHeroId, self.SlotId)
  if SlotHeroId ~= LogicSoulCore.CurSelectSoulCoreId or SlotHeroId <= 0 then
    LogicRole.EquipFetterHeroByPos(self.SlotId, self.MainHeroId, LogicSoulCore.CurSelectSoulCoreId)
  elseif not LogicRole.IsSlotUnlock(self.SlotId) then
    LogicRole.UnlockFetterSlot(self.SlotId)
  end
end
function WBP_SoulCoreEquipItem_C:OnGetHeroFetterInfoSuccess(JsonResponse)
  print("OnGetHeroFetterInfoSuccess", JsonResponse.Content)
  LogicRole.InitFetterHeroesMesh(self.MainHeroId)
end
return WBP_SoulCoreEquipItem_C
