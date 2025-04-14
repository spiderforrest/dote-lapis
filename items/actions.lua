local app = require"app"
local util = require"util"


app:render_get("items", "/items")
app:post("items", "/items", function (self)
  self.render_items = self.user:search_items(self.params.search, 10)
  return { render="itemlist" }
  -- return { util.to_json(self.render_items) }
end)
