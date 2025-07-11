local rapidjson = require("rapidjson")
local WBP_AvatarMain_C = UnLua.Class()
function WBP_AvatarMain_C:Construct()
  self.Btn_Save.OnClicked:Add(self, WBP_AvatarMain_C.BindOnSaveButtonClicked)
end
function WBP_AvatarMain_C:FocusInput()
  self.Overridden.FocusInput(self)
  self.SaveButtonFunction = nil
  LogicAvatar.SetPreAvatarInfo(DataMgr.GetAvatarInfo())
  LogicAvatar.RefreshAvatarRoleAllMesh()
  self:RefreshItemInfo()
  self.AvatarChooseList:SetVisibility(UE.ESlateVisibility.Collapsed)
  EventSystem.AddListener(self, EventDef.Avatar.OnAvatarItemClicked, WBP_AvatarMain_C.BindOnAvatarItemClicked)
end
function WBP_AvatarMain_C:UnfocusInput()
  self.Overridden.UnfocusInput(self)
  EventSystem.RemoveListener(EventDef.Avatar.OnAvatarItemClicked, WBP_AvatarMain_C.BindOnAvatarItemClicked, self)
end
function WBP_AvatarMain_C:BindOnSaveButtonClicked()
  LogicAvatar.RequestSetAvatarInfoToServer(self.SaveButtonFunction)
end
function WBP_AvatarMain_C:SetSaveButtonFunction(SaveButtonFunction)
  self.SaveButtonFunction = SaveButtonFunction
end
function WBP_AvatarMain_C:RefreshItemInfo()
  local AllChildren = self.ItemList:GetAllChildren()
  local PreAvatarInfo = LogicAvatar.GetPreAvatarInfo()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Show(PreAvatarInfo[SingleItem.Type])
  end
end
function WBP_AvatarMain_C:BindOnAvatarItemClicked(IsShow, Type)
  if IsShow then
    self.AvatarChooseList:SetVisibility(UE.ESlateVisibility.SelfHitTestInvisible)
    self:RefreshChooseItemList(Type)
  else
    self.AvatarChooseList:SetVisibility(UE.ESlateVisibility.Collapsed)
  end
end
function WBP_AvatarMain_C:RefreshChooseItemList(Type)
  local AllChildren = self.AvatarChooseList:GetAllChildren()
  for key, SingleItem in pairs(AllChildren) do
    SingleItem:Hide()
  end
  local AllCanChooseList = LogicAvatar.GetAllItemListByType(Type)
  local Index = 0
  local CurGenderMeshList = LogicAvatar.GetCurGenderMeshList()
  if not AllCanChooseList then
    self.AvatarChooseList:SetVisibility(UE.ESlateVisibility.Collapsed)
    return
  end
  for index, SingleItemId in ipairs(AllCanChooseList) do
    if Type == UE.EAvatarPartType.MainBody or table.Contain(CurGenderMeshList, SingleItemId) then
      local Item = self.AvatarChooseList:GetChildAt(Index)
      if not Item then
        Item = UE.UWidgetBlueprintLibrary.Create(self, self.AvatarChooseItemTemplate:StaticClass())
        self.AvatarChooseList:AddChild(Item)
      end
      Item:Show(SingleItemId)
      Index = Index + 1
    end
  end
end
return WBP_AvatarMain_C
