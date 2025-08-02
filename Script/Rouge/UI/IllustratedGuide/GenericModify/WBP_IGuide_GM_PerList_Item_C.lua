local WBP_IGuide_GM_PerList_Item_C = UnLua.Class()

function WBP_IGuide_GM_PerList_Item_C:OnListItemObjectSet(ListItemObj)
  self.Data = ListItemObj.Data
  if self.Data then
    SetImageBrushBySoftObjectPath(self.Img_Icon, self.Data.Icon)
    SetImageBrushBySoftObjectPath(self.Image_IconHighlight, self.Data.Icon)
    if Logic_IllustratedGuide.IsLobbyRoom() then
      self:SetMark(true)
      return
    end
    self:SetMark(self.Data.bMark)
  end
end

function WBP_IGuide_GM_PerList_Item_C:SetMark(bMark)
  UpdateVisibility(self.Overlay_Mark, bMark)
end

function WBP_IGuide_GM_PerList_Item_C:BP_OnItemSelectionChanged(IsSelected)
end

function WBP_IGuide_GM_PerList_Item_C:BP_OnEntryReleased()
end

function WBP_IGuide_GM_PerList_Item_C:SetSelect(bSelect)
end

function WBP_IGuide_GM_PerList_Item_C:SetCover(bCover)
  UpdateVisibility(self.Overlay_Cover, bCover)
end

function WBP_IGuide_GM_PerList_Item_C:OnMouseEnter(MyGeometry, MouseEvent)
  self:SetCover(true)
end

function WBP_IGuide_GM_PerList_Item_C:OnMouseLeave(MyGeometry, MouseEvent)
  self:SetCover(false)
end

return WBP_IGuide_GM_PerList_Item_C
