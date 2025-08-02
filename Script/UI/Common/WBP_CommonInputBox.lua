local WBP_CommonInputBox = UnLua.Class()

function WBP_CommonInputBox:Construct()
  self.Btn_Add.OnMainButtonClicked:Add(self, self.BindOnAddButtonClicked)
  self.Btn_Reduce.OnMainButtonClicked:Add(self, self.BindOnReduceButtonClicked)
  self.TXT_SelectNum.OnTextCommitted:Add(self, self.OnTextCommitted)
  self.TXT_SelectNum.OnTextChanged:Add(self, self.OnTextChanged)
  self.SelectNum = 0
end

function WBP_CommonInputBox:BindOnReduceButtonClicked(...)
  if 0 == self.SelectNum then
    return
  end
  self:UpdateSelectNum(self.SelectNum - 1)
  self.OnReduceButtonClicked:Broadcast(self.SelectNum)
end

function WBP_CommonInputBox:BindOnAddButtonClicked(...)
  if self:CheckCanAdd() then
    self:UpdateSelectNum(self.SelectNum + 1)
    self.OnAddButtonClicked:Broadcast(self.SelectNum)
  end
end

function WBP_CommonInputBox:Destruct(...)
  self.Btn_Add.OnMainButtonClicked:Remove(self, self.BindOnAddButtonClicked)
  self.Btn_Reduce.OnMainButtonClicked:Remove(self, self.BindOnReduceButtonClicked)
end

function WBP_CommonInputBox:UpdateSelectNum(Num)
  self.SelectNum = Num
  self.TXT_SelectNum:SetText(Num)
  self:RefreshButtonState()
end

function WBP_CommonInputBox:RefreshButtonState()
  self.Btn_Reduce:SetStyleByBottomStyleRowName(0 ~= self.SelectNum and "FrenzyVirus_Btn_Changes_0" or "FrenzyVirus_Btn_Changes_enable")
end

function WBP_CommonInputBox:SetCheckFun(Parent, Fun)
  self.Parent = Parent
  self.CheckCanAddFun = Fun
end

function WBP_CommonInputBox:SetMaxNum(Num)
  self.MaxNum = Num
end

function WBP_CommonInputBox:CheckCanAdd()
  if self.Parent and self.CheckCanAdd then
    return self.CheckCanAddFun(self.Parent, self.SelectNum)
  end
end

function WBP_CommonInputBox:OnTextChanged(Text)
  print(Text)
  local str = ""
  if #Text > 3 then
    str = string.sub(Text, 1, 3)
    self.TXT_SelectNum:SetText(str)
    return
  end
  for i = 1, #Text do
    local char = string.sub(Text, i, i)
    if tonumber(char) then
      str = str .. char
    end
  end
  if str ~= Text then
    self.TXT_SelectNum:SetText(str)
  end
end

function WBP_CommonInputBox:OnTextCommitted(Text, CommitMethod)
  local CurNum = self.SelectNum
  local CanChange = false
  local Num = tonumber(Text)
  if not Num then
    self.TXT_SelectNum:SetText(CurNum)
    self:UpdateSelectNum(CurNum)
    return
  end
  if self.Parent and self.CheckCanChangeFun then
    CanChange = self.CheckCanChangeFun(self.Parent, Num)
  end
  if CanChange then
    if not DataMgr.IsInTeam() then
      LogicTeam.RequestCreateTeamToServer({
        self,
        function()
          LogicTeam.RequestPreDeductTicket(Num)
        end
      })
    else
      LogicTeam.RequestPreDeductTicket(Num)
    end
    self:UpdateSelectNum(Num)
  else
    self.TXT_SelectNum:SetText(CurNum)
    self:UpdateSelectNum(CurNum)
  end
end

function WBP_CommonInputBox:SetCheckChangeFun(CheckCanChangeFun)
  self.CheckCanChangeFun = CheckCanChangeFun
end

return WBP_CommonInputBox
