require("Tables.Types")
UnLua.PackagePath = UnLua.PackagePath .. ";Saved/PersistentDownloadDir/Script/Tables/?.lua"
LuaTableMgr = LuaTableMgr or {}
local TablePathPrefix = "Tables."
function LuaTableMgr.GetLuaTableByName(TableName)
  local Path = LuaTableMgr.GetLuaTablePath(TableName)
  if Path then
    return require(Path)
  end
  return nil
end
function LuaTableMgr.GetLuaTableRowInfo(TableName, RowName)
  local Result, RowInfo = false
  local Table = LuaTableMgr.GetLuaTableByName(TableName)
  if not Table then
    print("LuaTableMgr.GetLuaTableRowInfo not found table:", TableName)
    return Result, RowInfo
  end
  RowInfo = Table[RowName]
  if RowInfo then
    Result = true
  else
    print(string.format("LuaTableMgr.GetLuaTableRowInfo not found RowInfo, Table: %s, RowName: %s", TableName, RowName))
  end
  return Result, RowInfo
end
function LuaTableMgr.GetLuaTablePath(TableName)
  if not TableName then
    return nil
  end
  local Path = TablePathPrefix .. TableName
  return Path
end
function LuaTableMgr.RemoveRequiredByName(TableName)
  for key, value in pairs(package.preload) do
    if string.find(tostring(key), TableName) then
      package.preload[key] = nil
    end
  end
  for key, value in pairs(package.loaded) do
    if string.find(tostring(key), TableName) then
      package.loaded[key] = nil
    end
  end
end
