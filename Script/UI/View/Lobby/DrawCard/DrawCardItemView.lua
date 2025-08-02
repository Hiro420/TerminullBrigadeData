local DrawCardData = require("Modules.DrawCard.DrawCardData")
local DrawCardItemView = UnLua.Class()
local MultiDrawTimes = 10

function DrawCardItemView:OnListItemObjectSet(ListItemObj)
  local ResourceTemp = {}
  ResourceTemp.resourceId = ListItemObj.ResourceId
  ResourceTemp.amount = ListItemObj.Amount
  ResourceTemp.decompose = ListItemObj.bDecompose
  self.bIsLastCard = ListItemObj.bIsLastCard
  self.Index = ListItemObj.Index
  self.AniFinishedFunc = ListItemObj.AniFinished
  self.ParentView = ListItemObj.ParentView
  self:InitInfo(ResourceTemp)
end

function DrawCardItemView:Construct()
  self.ParentView = nil
  self.Resource = nil
  self.AniFinishedFunc = nil
  self.AniOnceFinishedFunc = nil
end

function DrawCardItemView:Destruct()
  self.ParentView = nil
  self.Resource = nil
  self.AniFinishedFunc = nil
  self.AniOnceFinishedFunc = nil
end

function DrawCardItemView:AniFinished()
  if self.AniFinishedFunc then
    self.AniFinishedFunc:Broadcast(self.Index)
  end
  if self.AniOnceFinishedFunc then
    self.AniOnceFinishedFunc(self.ParentView)
  end
end

function DrawCardItemView:InitInfoOnceDraw(Resource, AniFinished, ParentView)
  self.ParentView = ParentView
  self.AniOnceFinishedFunc = AniFinished
  self:InitInfo(Resource)
end

function DrawCardItemView:InitInfo(Resource)
  self.Resource = Resource
  if not Resource then
    return
  end
  self.WBP_Item:InitItem(Resource.resourceId)
  self.WBP_Item:ShowSpecialTag(Resource.resourceId)
  local TotalResourceTable = LuaTableMgr.GetLuaTableByName(TableNames.TBGeneral)
  if not TotalResourceTable[Resource.resourceId] then
    return
  end
  local DecomposeId, DecomposeNum = DrawCardData:GetDecomposeInfoById(Resource.resourceId)
  if not DecomposeId or not DecomposeNum then
    Resource.decompose = false
  end
  self.WBP_Item:SetDecompose(Resource.decompose, DecomposeNum, DecomposeId)
  local Rarity = self.WBP_Item.Rare
  if type(Rarity) ~= "number" then
    Rarity = 1
  end
  Rarity = math.min(Rarity, 5)
  Rarity = math.max(Rarity, 1)
  self.RGStateController_Rarity:ChangeStatus(tostring(Rarity))
  print("ywtao, rarity = ", Rarity)
  UpdateVisibility(self, false)
  UE.UKismetSystemLibrary.K2_SetTimerDelegate({
    GameInstance,
    function()
      UpdateVisibility(self, true)
      self:PlayAnimation(self.Anim_In)
    end
  }, self.Index * 0.1, false)
end

function DrawCardItemView:Hide()
  self:SetVisibility(UE.ESlateVisibility.Collapsed)
end

return DrawCardItemView
