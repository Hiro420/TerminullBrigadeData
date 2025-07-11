local WBP_GloriaRobotItem_C = UnLua.Class()
function WBP_GloriaRobotItem_C:Destruct()
  self.Overridden.Destruct(self)
end
function WBP_GloriaRobotItem_C:Init(IconSoftObjPtr, CurNum, MaxNum)
  if CurNum <= 0 then
    UpdateVisibility(self, false)
    return
  end
  UpdateVisibility(self, true)
  self.URGImageRobotIcon:SetBrushFromSoftTexture(IconSoftObjPtr)
  local Str = ""
  if MaxNum <= CurNum then
    Str = string.format("<GloriaRobotNumFull>%d</>/%d", CurNum, MaxNum)
  else
    Str = string.format("<GloriaRobotNum>%d</>/%d", CurNum, MaxNum)
  end
  self.RGRichTextBlockNum:SetText(Str)
end
return WBP_GloriaRobotItem_C
