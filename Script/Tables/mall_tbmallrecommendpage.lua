local mall_tbmallrecommendpage = {
  [1] = {
    ID = 1,
    NameLocMeta = NSLOCTEXT("mall_TBMallRecommendPage", "Name_1", "\230\181\183\229\155\160\229\133\139\230\150\175"),
    DescLocMeta = NSLOCTEXT("mall_TBMallRecommendPage", "Desc_1", "\230\149\145\228\184\150\228\184\187\239\188\140\233\151\170\228\186\174\231\153\187\229\156\186\239\188\129"),
    ResourceID = 100009,
    PostResource = "/Game/Rouge/UI/Atlas_Alpha/A_DT/Bgimage/bg06.bg06",
    GoodsJump = "1023",
    LinkDescLocMeta = NSLOCTEXT("mall_TBMallRecommendPage", "LinkDesc_1", "\232\182\133\232\189\189\233\128\154\232\161\140\232\175\129\232\142\183\229\143\150"),
    ParamList = {},
    ShowStartTime = "2023-03-01 00:00:00",
    ShowEndTime = "2035-06-01 00:00:00",
    ShowPriority = 10
  }
}
local LinkTb = {
  Name = "NameLocMeta",
  Desc = "DescLocMeta",
  LinkDesc = "LinkDescLocMeta"
}
local LuaTableMeta = {
  __index = function(table, key)
    local keyIdx = LinkTb[key]
    if keyIdx then
      return table[keyIdx]()
    elseif rawget(table, key) then
      return rawget(table, key)
    end
  end
}
IteratorSetMetaTable(mall_tbmallrecommendpage, LuaTableMeta)
return mall_tbmallrecommendpage
