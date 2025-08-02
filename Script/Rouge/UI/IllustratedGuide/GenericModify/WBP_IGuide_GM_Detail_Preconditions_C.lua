local WBP_IGuide_GM_Detail_Preconditions_C = UnLua.Class()

function WBP_IGuide_GM_Detail_Preconditions_C:RefreshPreconditions(ModifyInfo)
  self.Data = ModifyInfo.ModifieConfig
  self:UpdataListPreconditions(self.Data.FrontConditions)
  self.ListPreconditions1.BP_OnItemIsHoveredChanged:Add(self, self.BP_OnItemIsHoveredChanged)
  self.ListPreconditions2.BP_OnItemIsHoveredChanged:Add(self, self.BP_OnItemIsHoveredChanged)
  local Result, RowInfo = GetRowData(DT.DT_GenericModifyGroup, self.Data.GroupId)
  if Result then
    SetImageBrushBySoftObject(self.Icon_God, RowInfo.ChoosePanelIcon)
  end
  UpdateVisibility(self.ShareWin, self.Data.GenericModifyType == UE.ERGGenericModifyType.ShareWin)
  UpdateVisibility(self.Image_Di_Highlight, not Logic_IllustratedGuide.IsLobbyRoom())
end

function WBP_IGuide_GM_Detail_Preconditions_C:UpdataListPreconditions(FrontConditions)
  local Sum = FrontConditions:Num()
  local UnLock1 = 0
  local UnLock2 = 0
  UpdateVisibility(self.jINDU, not Logic_IllustratedGuide.IsLobbyRoom())
  if 0 == FrontConditions:Num() then
    UpdateVisibility(self.Preconditions1, false)
    UpdateVisibility(self.Preconditions2, false)
    UpdateVisibility(self.Title, false)
    return
  end
  UpdateVisibility(self.Title, true)
  local bMark = false
  UpdateVisibility(self.Img_NotMeet, false)
  UpdateVisibility(self.Img_Meet, true)
  if FrontConditions:GetRef(1) then
    Sum = 1
    UpdateVisibility(self.Preconditions1, true)
    UpdateVisibility(self.Image_Di_Highlight_1, false)
    self.ListPreconditions1:ClearListItems()
    for index, value in ipairs(FrontConditions:GetRef(1).SubGroupIds:ToTable()) do
      local SubGenericModify = Logic_IllustratedGuide.GenericModifySubGroup[value]
      local GenericModifyId = 0
      if nil == SubGenericModify then
        Logic_IllustratedGuide.LoadGenericModifyTable()
        SubGenericModify = Logic_IllustratedGuide.GenericModifySubGroup[value]
      end
      for index, GenericModifyIds in ipairs(SubGenericModify) do
        if 0 == GenericModifyId then
          GenericModifyId = GenericModifyIds
        end
        if GenericModifyIds < GenericModifyId then
          GenericModifyId = GenericModifyIds
        end
      end
      bMark = Logic_IllustratedGuide.DoesPlayerHaveGenericModify(tonumber(GenericModifyId), true)
      local DataObj = NewObject(Logic_IllustratedGuide.DataObjCls, GameInstance, nil)
      local Data = Logic_IllustratedGuide.CreateGodListItemData()
      Data.RowName = GenericModifyId
      Data.bMark = bMark
      Data.Id = 0
      local Result, RowInfo = GetRowData(DT.DT_GenericModify, GenericModifyId)
      if Result then
        Data.Icon = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(RowInfo.Icon)
      end
      if DataObj:IsValid() then
        DataObj.Data = Data
        self.ListPreconditions1:AddItem(DataObj)
      end
      if bMark then
        UnLock1 = 1
        UpdateVisibility(self.Img_NotMeet, true)
        UpdateVisibility(self.Img_Meet, false)
        UpdateVisibility(self.Text_Title_Highlight_1, true)
        UpdateVisibility(self.Text_Title_1, false)
        UpdateVisibility(self.Text_Title_Highlight_1, true)
        UpdateVisibility(self.Image_Di_Highlight_1, true)
      end
      self.jINDU:SetText(UnLock2 + UnLock1 .. "/" .. Sum)
    end
  else
    UpdateVisibility(self.Preconditions1, false)
  end
  if 1 == FrontConditions:Num() then
    UpdateVisibility(self.Preconditions2, false)
    if Logic_IllustratedGuide.IsLobbyRoom() then
      UpdateVisibility(self.Img_Meet, false)
      UpdateVisibility(self.Img_NotMeet, false)
      UpdateVisibility(self.Img_Meet_1, false)
      UpdateVisibility(self.Img_NotMeet_1, false)
    end
    return
  end
  bMark = false
  UpdateVisibility(self.Img_NotMeet_1, false)
  UpdateVisibility(self.Img_Meet_1, true)
  if FrontConditions:GetRef(2) then
    Sum = 2
    UpdateVisibility(self.Preconditions2, true)
    UpdateVisibility(self.Image_Di_Highlight_2, false)
    self.ListPreconditions2:ClearListItems()
    for index, value in ipairs(FrontConditions:GetRef(2).SubGroupIds:ToTable()) do
      local SubGenericModify = Logic_IllustratedGuide.GenericModifySubGroup[value]
      local GenericModifyId = 0
      if nil == SubGenericModify then
        SubGenericModify = {}
      end
      for index, GenericModifyIds in ipairs(SubGenericModify) do
        if 0 == GenericModifyId then
          GenericModifyId = GenericModifyIds
        end
        if GenericModifyIds < GenericModifyId then
          GenericModifyId = GenericModifyIds
        end
      end
      bMark = Logic_IllustratedGuide.DoesPlayerHaveGenericModify(GenericModifyId, true)
      local DataObj = NewObject(Logic_IllustratedGuide.DataObjCls, GameInstance, nil)
      local Data = Logic_IllustratedGuide.CreateGodListItemData()
      Data.RowName = GenericModifyId
      Data.bMark = bMark
      Data.Id = 0
      local Result, RowInfo = GetRowData(DT.DT_GenericModify, GenericModifyId)
      if Result then
        Data.Icon = UE.UKismetSystemLibrary.Conv_SoftObjectReferenceToString(RowInfo.Icon)
      end
      if DataObj:IsValid() then
        DataObj.Data = Data
        self.ListPreconditions2:AddItem(DataObj)
      end
      if bMark then
        if PreconditionsNum then
        end
        UnLock2 = 1
        UpdateVisibility(self.Img_NotMeet_1, true)
        UpdateVisibility(self.Img_Meet_1, false)
        UpdateVisibility(self.Text_Title_Highlight_2, true)
        UpdateVisibility(self.Text_Title_2, false)
        UpdateVisibility(self.Image_Di_Highlight_2, true)
      end
      self.jINDU:SetText(UnLock2 + UnLock1 .. "/" .. Sum)
    end
  else
    UpdateVisibility(self.Preconditions2, false)
  end
  if Logic_IllustratedGuide.IsLobbyRoom() then
    UpdateVisibility(self.Img_Meet, false)
    UpdateVisibility(self.Img_NotMeet, false)
    UpdateVisibility(self.Img_Meet_1, false)
    UpdateVisibility(self.Img_NotMeet_1, false)
  end
end

function WBP_IGuide_GM_Detail_Preconditions_C:BP_OnItemIsHoveredChanged(Item, bHovered)
  UpdateVisibility(self.WBP_IGuide_GenericModifyTips, bHovered)
  local GenericModifyInfo = {}
  GenericModifyInfo.Re, GenericModifyInfo.ModifieConfig = GetRowData(DT.DT_GenericModify, Item.Data.RowName)
  if GenericModifyInfo.Re then
    self.WBP_IGuide_GenericModifyTips:RefreshDetailPanel(GenericModifyInfo, false)
  end
end

return WBP_IGuide_GM_Detail_Preconditions_C
