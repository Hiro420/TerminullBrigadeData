local WBP_MODPanel_C = UnLua.Class()
function WBP_MODPanel_C:Construct()
  self.PlayerBox.OnClicked:Add(self, WBP_MODPanel_C.OnClicked_PlayerBox)
  self.CompanionBox.OnClicked:Add(self, WBP_MODPanel_C.OnClicked_CompanionBox)
  self.CloseButton.OnClicked:Add(self, WBP_MODPanel_C.OnClicked_CloseButton)
end
function WBP_MODPanel_C:OnOpenUI(InMODList_ArrayName)
  self.MODList = InMODList_ArrayName
  self:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
  if self.MODList:Length() <= 3 then
    self.CompanionBox:SetVisibility(UE.ESlateVisibility.Collapsed)
    self:RefreshPanel(0)
  else
    local modchooseArray = self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass()).MODChooseList
    if modchooseArray:Get(2) then
    else
      self.CompanionBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    end
    if modchooseArray:Get(1) then
      self:RefreshPanel(1)
    else
      self.PlayerBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:RefreshPanel(0)
    end
  end
end
function WBP_MODPanel_C:RefreshPanel(InType_Int)
  local index = InType_Int * 3
  local switch = {
    [0] = function()
      self.ChooseTxt:SetText(self.PlayerBox.ButtonText:GetText())
      self.PlayerBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:RefreshPanelFun(InType_Int, index)
    end,
    [1] = function()
      self.ChooseTxt:SetText(self.CompanionBox.ButtonText:GetText())
      self.CompanionBox:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
      self:RefreshPanelFun(InType_Int, index)
    end
  }
  local fSwitch = switch[InType_Int]
  local Result = fSwitch()
end
function WBP_MODPanel_C:RefreshPanelFun(InType_Int, InIndex_Int)
  if self.MODList:Length() >= 3 then
    local table = {
      self.MODList:Get(InIndex_Int + 1),
      self.MODList:Get(InIndex_Int + 2),
      self.MODList:Get(InIndex_Int + 3)
    }
    local World = self:GetWorld()
    local RGLogicCommandDataSubsystem = UE.USubsystemBlueprintLibrary.GetEngineSubsystem(UE.ULogicCommandDataSubSystem:StaticClass())
    for index, value in ipairs(table) do
      local modData = RGLogicCommandDataSubsystem:GetMODItemDataById(UE.UKismetStringLibrary.Conv_StringToInt(UE.UKismetStringLibrary.Conv_NameToString(value)))
      local switchFun = {
        [1] = function()
          self.WBP_MODItem_1:RefreshMODItem(modData, InType_Int, self)
        end,
        [2] = function()
          self.WBP_MODItem_2:RefreshMODItem(modData, InType_Int, self)
        end,
        [3] = function()
          self.WBP_MODItem_3:RefreshMODItem(modData, InType_Int, self)
        end
      }
      local fSwitchFun = switchFun[index]
      local result = fSwitchFun()
    end
  else
    print("\230\149\176\233\135\143\229\176\143\228\186\1423")
  end
end
function WBP_MODPanel_C:HandleUpgrade(InUpgradeType_Int)
  print(self.MODList:Length())
  if self.MODList:Length() <= 3 then
    self:OnClose()
  else
    local switchFun = {
      [0] = function()
        if self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass()).MODChooseList:Get(2) then
          self:OnClose()
        else
          self:RefreshPanel(1)
          self.PlayerBox:SetVisibility(UE.ESlateVisibility.Collapsed)
        end
      end,
      [1] = function()
        if self:GetOwningPlayerPawn():GetComponentByClass(UE.UMODComponent.StaticClass()).MODChooseList:Get(1) then
          self:OnClose()
        else
          self:RefreshPanel(0)
          self.CompanionBox:SetVisibility(UE.ESlateVisibility.Collapsed)
        end
      end
    }
    local fSwitchFun = switchFun[InUpgradeType_Int]
    local result = fSwitchFun()
  end
end
function WBP_MODPanel_C:OnClose()
  UE.USubsystemBlueprintLibrary.GetGameInstanceSubsystem(self:GetWorld(), UE.URGUIManager:StaticClass()):Switch(self:StaticClass())
end
function WBP_MODPanel_C:OnClicked_PlayerBox(InButton)
  self:RefreshPanel(0)
end
function WBP_MODPanel_C:OnClicked_CompanionBox(InButton)
  self:RefreshPanel(1)
end
function WBP_MODPanel_C:OnClicked_CloseButton()
  self:OnClose()
end
return WBP_MODPanel_C
