local util = require"util"
local Users = require"users.model"
local app = require"app"
local json_params = require("lapis.application").json_params

local M = {}

local function gen_item (item, user)
  -- create new item
  item = item or {}
  -- populate required fields
  item.type = item.type or "todo"
  item.id = #user.items + 1
  item.uuid = util.uuid()
  item.created = os.time()
  item.parents = item.parents or {}
  item.children = item.children or {}

  return item
end

app:post("item-add", "/api/items/add", json_params(function(self) --{{{
  local item = gen_item(self.params.newitem, self.user)
  self.user:create_item(item)

  return { json = item, status = 200 }
end)) --}}}

return M

-- vim:foldmethod=marker
