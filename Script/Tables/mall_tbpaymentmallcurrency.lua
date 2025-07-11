local mall_tbpaymentmallcurrency = {
  [1] = {
    ID = 1,
    Quantity = 60,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_1", ""),
    Comment = ""
  },
  [2] = {
    ID = 2,
    Quantity = 300,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_2", ""),
    Comment = ""
  },
  [3] = {
    ID = 3,
    Quantity = 680,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_3", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>20</>"),
    Comment = ""
  },
  [4] = {
    ID = 4,
    Quantity = 1180,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_4", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>100</>"),
    Comment = ""
  },
  [5] = {
    ID = 5,
    Quantity = 3280,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_5", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>370</>"),
    Comment = ""
  },
  [6] = {
    ID = 6,
    Quantity = 5980,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_6", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>870</>"),
    Comment = ""
  },
  [7] = {
    ID = 7,
    Quantity = 60,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_7", ""),
    Comment = ""
  },
  [8] = {
    ID = 8,
    Quantity = 300,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_8", ""),
    Comment = ""
  },
  [9] = {
    ID = 9,
    Quantity = 680,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_9", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>20</>"),
    Comment = ""
  },
  [10] = {
    ID = 10,
    Quantity = 1180,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_10", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>100</>"),
    Comment = ""
  },
  [11] = {
    ID = 11,
    Quantity = 3280,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_11", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>370</>"),
    Comment = ""
  },
  [12] = {
    ID = 12,
    Quantity = 5980,
    PresentedContentLocMeta = NSLOCTEXT("mall_TBPaymentMallCurrency", "PresentedContent_12", "<Topup_Word>\233\162\157\229\164\150\232\181\160\233\128\129</>  <img id=\"PureData\" width=\"30\" height=\"30\"></><Topup_Num>870</>"),
    Comment = ""
  }
}
local LinkTb = {
  PresentedContent = "PresentedContentLocMeta"
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
IteratorSetMetaTable(mall_tbpaymentmallcurrency, LuaTableMeta)
return mall_tbpaymentmallcurrency
