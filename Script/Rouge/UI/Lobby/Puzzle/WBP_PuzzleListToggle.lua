local WBP_PuzzleListToggle = UnLua.Class()

function WBP_PuzzleListToggle:Construct()
  SetImageBrushBySoftObject(self.Img_SelectBottom, self.SelectBottomImage)
  SetImageBrushBySoftObject(self.Img_UnSelectBottom, self.UnSelectBottomImage)
  SetImageBrushBySoftObject(self.Img_Hovered, self.HoveredImg)
  SetImageBrushBySoftObject(self.Img_Icon, self.IconSoftObj)
  local Brush = self.Img_Hovered.Brush
  Brush.DrawAs = UE.ESlateBrushDrawType.Box
  local Margin = UE.FMargin()
  Margin.Bottom = 0.5
  Margin.Left = 0.5
  Margin.Right = 0.5
  Margin.Top = 0.5
  Brush.Margin = Margin
  self.Img_Hovered:SetBrush(Brush)
  self.Txt_BtnName:SetText(self.Name)
end

function WBP_PuzzleListToggle:SetCurHaveNum(CurHaveNum)
  local ConstTable = LuaTableMgr.GetLuaTableByName(TableNames.TBConsts)
  self.Txt_Num:SetText(string.format("%d/%d", CurHaveNum, ConstTable.MartrixPuzzleMaxPackageNum))
end

function WBP_PuzzleListToggle:OnMouseEnter()
  self:PlayAnimation(self.Ani_hover_in)
end

function WBP_PuzzleListToggle:OnMouseLeave()
  self:PlayAnimation(self.Ani_hover_out)
end

function WBP_PuzzleListToggle:Destruct()
  self:StopAllAnimations()
end

return WBP_PuzzleListToggle
