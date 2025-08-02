local WBP_MonsterMapGuide_C = UnLua.Class()

function WBP_MonsterMapGuide_C:Construct()
  EventSystem.AddListener(self, EventDef.Lobby.LobbyPanelChanged, WBP_MonsterMapGuide_C.OnLobbyActivePanelChanged)
  self:GetMonsterList()
  self:UpdateMonsterList()
  self.SizeBox_Info:SetVisibility(UE.ESlateVisibility.Hidden)
  self.Image_Full:SetVisibility(UE.ESlateVisibility.Hidden)
end

function WBP_MonsterMapGuide_C:Destruct()
  EventSystem.RemoveListener(EventDef.Lobby.LobbyPanelChanged, WBP_MonsterMapGuide_C.OnLobbyActivePanelChanged)
  self.MonsterTable = {}
end

function WBP_MonsterMapGuide_C:OnLobbyActivePanelChanged(LastActiveWidget, CurActiveWidget)
  if CurActiveWidget == self then
    self:UpdateMonsterMapInfo()
  end
end

function WBP_MonsterMapGuide_C:Select(IndexParam, Id, ResourceId)
  self:UpdateMonsterInfo(Id, ResourceId)
  self.CurSelect = IndexParam
end

function WBP_MonsterMapGuide_C:UpdateMonsterMapInfo()
  self:UpdateMonsterList()
end

function WBP_MonsterMapGuide_C:UpdateMonsterList()
  local Index = 0
  local tempTable = {}
  for key, value in pairs(self.MonsterTable) do
    table.insert(tempTable, value)
  end
  table.sort(tempTable, LogicSoulCore.SoulCoreListSort)
  local TileViewAry = UE.TArray(UE.UObject)
  for i, v in pairs(tempTable) do
    local DataObj
    if self.TileViewDataAry:IsValidIndex(self.TileViewDataAry:LastIndex()) then
      DataObj = self.TileViewDataAry:GetRef(self.TileViewDataAry:LastIndex())
      self.TileViewDataAry:Remove(self.TileViewDataAry:LastIndex())
    else
      local DataObjCls = UE.UClass.Load("/Game/Rouge/UI/Lobby/DataBase/MonsterMapGuide/MonsterItemData.MonsterItemData_C")
      DataObj = NewObject(DataObjCls, self, nil)
    end
    DataObj.ResourceId = v.ResourceId
    DataObj.Index = Index
    DataObj.Id = v.ID
    DataObj.Select = {
      self,
      self.Select
    }
    Index = Index + 1
    TileViewAry:Add(DataObj)
  end
  for i, v in iterator(self.TileViewMonsterMap.ListItems) do
    self.TileViewDataAry:Add(v)
  end
  self.TileViewMonsterMap:BP_SetListItems(TileViewAry)
  if -1 ~= self.CurSelect then
    self.TileViewMonsterMap:SetSelectedIndex(self.CurSelect)
  else
    self.TileViewMonsterMap:SetSelectedIndex(0)
  end
end

function WBP_MonsterMapGuide_C:UpdateMonsterInfo(ID, ResourceId)
  local singleInfo = self.MonsterTable[ID]
  if singleInfo then
    self.SizeBox_Info:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.Image_Full:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self.WBP_CardTitle:UpdateCardTitle(ID, ResourceId)
    self.RichTextBlock_Des:SetText(singleInfo.Desc)
    self.RichTextBlock_Solutions:SetText(singleInfo.Solutions)
    self.TextBlock_Level:SetText(singleInfo.LevelDanger)
    SetImageBrushByPath(self.Image_Full, singleInfo.FullPaintingPath)
  end
end

function WBP_MonsterMapGuide_C:GetMonsterList()
  local table_HeroMonster = LuaTableMgr.GetLuaTableByName(TableNames.TBHeroMonster)
  if table_HeroMonster then
    self.MonsterTable = {}
    for key, value in pairs(table_HeroMonster) do
      if value.Type == TableEnums.ENUMHeroType.Monster then
        self.MonsterTable[key] = value
      end
    end
  end
end

return WBP_MonsterMapGuide_C
