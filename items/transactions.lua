local util = require"util"

local M = {}

function M:create_item (item)
  -- create new item
  item = item or {}
  -- populate required fields
  item.type = item.type or "todo"
  item.id = #self.items + 1
  item.uuid = util.uuid()
  item.created = os.time()
  item.parents = item.parents or {}
  item.children = item.children or {}
end


return M

-- vim:foldmethod=marker
