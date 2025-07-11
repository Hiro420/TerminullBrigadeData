local WBP_SingleQTESectionItem = UnLua.Class()
function WBP_SingleQTESectionItem:Show(Index)
  self.Index = Index
  self.Img_Bottom:SetColorAndOpacity(self.NormalColor)
end
function WBP_SingleQTESectionItem:UpdateStatus(IsSuccess)
  if IsSuccess then
    self.Img_Bottom:SetColorAndOpacity(self.SuccessColor)
  else
    self.Img_Bottom:SetColorAndOpacity(self.FailColor)
  end
end
return WBP_SingleQTESectionItem
