local WBP_GMCustom_BatchCheatPanel_C = UnLua.Class()

function WBP_GMCustom_BatchCheatPanel_C:Construct()
  self.Overridden.Construct(self)
  self.Btn_AddSpecific.OnClicked:Add(self, self.AddSpecificClick)
  self.Btn_AddGeneric.OnClicked:Add(self, self.AddGenericClick)
  self.Btn_AddAttribute.OnClicked:Add(self, self.AddAttributeClick)
  self.Button_submit.OnClicked:Add(self, self.SubmitClick)
end

function WBP_GMCustom_BatchCheatPanel_C:Destruct()
  self.Overridden.Destruct(self)
  self.Btn_AddSpecific.OnClicked:Remove(self, self.AddSpecificClick)
  self.Btn_AddGeneric.OnClicked:Remove(self, self.AddGenericClick)
  self.Btn_AddAttribute.OnClicked:Remove(self, self.AddAttributeClick)
  self.Button_submit.OnClicked:Remove(self, self.SubmitClick)
end

function WBP_GMCustom_BatchCheatPanel_C:InitWidget()
  self.Overridden.InitWidget(self)
end

function WBP_GMCustom_BatchCheatPanel_C:OnOpen()
  self.Overridden.OnOpen(self)
  self:UpdateSpecificList()
  self:UpdateGenericList()
  self:UpdateAttributeList()
end

function WBP_GMCustom_BatchCheatPanel_C:AddSpecificClick()
  LobbyModule = ModuleManager:Get("LobbyModule")
  table.insert(LobbyModule.SpecificList, {SpecificId = nil})
  self:UpdateSpecificList()
end

function WBP_GMCustom_BatchCheatPanel_C:AddGenericClick()
  LobbyModule = ModuleManager:Get("LobbyModule")
  table.insert(LobbyModule.GenericList, {GenericId = nil, Lv = 1})
  self:UpdateGenericList()
end

function WBP_GMCustom_BatchCheatPanel_C:AddAttributeClick()
  local LobbyModule = ModuleManager:Get("LobbyModule")
  table.insert(LobbyModule.AttributeList, {AttributeId = nil})
  self:UpdateAttributeList()
end

function WBP_GMCustom_BatchCheatPanel_C:SubmitClick()
  LobbyModule = ModuleManager:Get("LobbyModule")
  local Character = UE.UGameplayStatics.GetPlayerCharacter(GameInstance, 0)
  local RGGenericModifyComponent, RGSpecificModifyComponent, RGAttributeModifyComponent
  if Character then
    RGGenericModifyComponent = Character:GetComponentByClass(UE.URGGenericModifyComponent:StaticClass())
    RGSpecificModifyComponent = Character:GetComponentByClass(UE.URGSpecificModifyComponent:StaticClass())
    RGAttributeModifyComponent = Character:GetComponentByClass(UE.URGAttributeModifyComponent:StaticClass())
  end
  for i = 1, #LobbyModule.SpecificList do
    local item = self.RGScrollBox_Specific:GetChildAt(i - 1)
    if CheckIsVisility(item) then
      LobbyModule.SpecificList[i].SpecificId = tonumber(item.EditableTextBox_SpecificModifyId:GetText())
      if RGSpecificModifyComponent then
        RGSpecificModifyComponent:ServerAddModify(LobbyModule.SpecificList[i].SpecificId)
      end
    end
  end
  for i = 1, #LobbyModule.GenericList do
    local item = self.RGScrollBox_Generic:GetChildAt(i - 1)
    if CheckIsVisility(item) then
      LobbyModule.GenericList[i].GenericId = tonumber(item.EditableTextBox_GenericModifyId:GetText())
      LobbyModule.GenericList[i].Lv = tonumber(item.EditableTextBox_GenericModifyLv:GetText())
      if RGGenericModifyComponent then
        RGGenericModifyComponent:ServerAddModify(LobbyModule.GenericList[i].GenericId)
        RGGenericModifyComponent:ServerUpgradeModify(LobbyModule.GenericList[i].GenericId, LobbyModule.GenericList[i].Lv)
      end
    end
  end
  for i = 1, #LobbyModule.AttributeList do
    local item = self.RGScrollBox_Attribute:GetChildAt(i - 1)
    if CheckIsVisility(item) then
      LobbyModule.AttributeList[i].AttributeId = tonumber(item.EditableTextBox_AttributeModifyId:GetText())
      if RGAttributeModifyComponent then
        RGAttributeModifyComponent:ServerAddModify(LobbyModule.AttributeList[i].AttributeId)
      end
    end
  end
end

function WBP_GMCustom_BatchCheatPanel_C:UpdateSpecificList()
  LobbyModule = ModuleManager:Get("LobbyModule")
  for i, v in ipairs(LobbyModule.SpecificList) do
    local item = GetOrCreateItem(self.RGScrollBox_Specific, i, self.WBP_GM_Custom_BatchSpecificItem:GetClass())
    UpdateVisibility(item, true)
    item.EditableTextBox_SpecificModifyId:SetText(v.SpecificId)
    local idx = i
    item.Index = idx
    item.EditableTextBox_SpecificModifyId.OnTextCommitted:Clear()
    item.EditableTextBox_SpecificModifyId.OnTextCommitted:Add(self, function(obj, text, commitMethod)
      LobbyModule.GenericList[idx].SpecificId = tonumber(text)
    end)
    item.Btn_Delete.OnClicked:Clear()
    item.Btn_Delete.OnClicked:Add(self, function()
      table.remove(LobbyModule.SpecificList, idx)
      self:UpdateSpecificList()
    end)
  end
  HideOtherItem(self.RGScrollBox_Specific, #LobbyModule.SpecificList + 1, true)
end

function WBP_GMCustom_BatchCheatPanel_C:UpdateGenericList()
  LobbyModule = ModuleManager:Get("LobbyModule")
  for i, v in ipairs(LobbyModule.GenericList) do
    local item = GetOrCreateItem(self.RGScrollBox_Generic, i, self.WBP_GM_Custom_BatchGenericItem:GetClass())
    UpdateVisibility(item, true)
    item.EditableTextBox_GenericModifyId:SetText(v.GenericId)
    item.EditableTextBox_GenericModifyLv:SetText(v.Lv)
    local idx = i
    item.EditableTextBox_GenericModifyId.OnTextCommitted:Clear()
    item.EditableTextBox_GenericModifyId.OnTextCommitted:Add(self, function(obj, text, commitMethod)
      LobbyModule.GenericList[idx].GenericId = tonumber(text)
    end)
    item.EditableTextBox_GenericModifyLv.OnTextCommitted:Clear()
    item.EditableTextBox_GenericModifyLv.OnTextCommitted:Add(self, function(obj, text, commitMethod)
      LobbyModule.GenericList[idx].Lv = tonumber(text)
    end)
    item.Index = i
    item.Btn_Delete.OnClicked:Clear()
    item.Btn_Delete.OnClicked:Add(self, function()
      table.remove(LobbyModule.GenericList, idx)
      self:UpdateGenericList()
    end)
  end
  HideOtherItem(self.RGScrollBox_Generic, #LobbyModule.GenericList + 1, true)
end

function WBP_GMCustom_BatchCheatPanel_C:UpdateAttributeList()
  local LobbyModule = ModuleManager:Get("LobbyModule")
  for i, v in ipairs(LobbyModule.AttributeList) do
    local item = GetOrCreateItem(self.RGScrollBox_Attribute, i, self.WBP_GM_Custom_BatchAttributeItem:GetClass())
    UpdateVisibility(item, true)
    local idx = i
    item.EditableTextBox_AttributeModifyId:SetText(v.AttributeId)
    item.EditableTextBox_AttributeModifyId.OnTextCommitted:Clear()
    item.EditableTextBox_AttributeModifyId.OnTextCommitted:Add(self, function(obj, text, commitMethod)
      LobbyModule.AttributeList[idx].AttributeId = tonumber(text)
    end)
    item.Index = i
    item.Btn_Delete.OnClicked:Clear()
    item.Btn_Delete.OnClicked:Add(self, function()
      table.remove(LobbyModule.AttributeList, idx)
      self:UpdateAttributeList()
    end)
  end
  HideOtherItem(self.RGScrollBox_Attribute, #LobbyModule.AttributeList + 1, true)
end

return WBP_GMCustom_BatchCheatPanel_C
