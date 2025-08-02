local WBP_AvatarItem_C = UnLua.Class()

function WBP_AvatarItem_C:Construct()
  self.Btn_Main.OnClicked:Add(self, WBP_AvatarItem_C.BindOnMainButtonClicked)
  EventSystem.AddListener(self, EventDef.Avatar.OnPreAvatarInfoChanged, WBP_AvatarItem_C.BindOnPreAvatarInfoChanged)
end

function WBP_AvatarItem_C:Show(Id)
  self.Txt_Name:SetText("")
  local Result, AvatarRowInfo = GetDataLibraryObj().GetAvatarItemRowInfo(Id)
  if not Result then
    return
  end
  self.Txt_Name:SetText(AvatarRowInfo.Name)
end

function WBP_AvatarItem_C:BindOnMainButtonClicked()
  EventSystem.Invoke(EventDef.Avatar.OnAvatarItemClicked, true, self.Type)
end

function WBP_AvatarItem_C:BindOnPreAvatarInfoChanged(Type, Id)
  if Type == self.Type then
    self:Show(Id)
  end
end

function WBP_AvatarItem_C:Destruct()
  EventSystem.RemoveListener(EventDef.Avatar.OnPreAvatarInfoChanged, WBP_AvatarItem_C.BindOnPreAvatarInfoChanged, self)
end

return WBP_AvatarItem_C
