local app = require"app"
local util = require"util"


app:render_get("items", "/items")

app:get("item-search", "/items/search", function (self)
  self.render_items = self.user:search_items(self.params.search, 10)
  return { render="itemlist" }
end)


app:get("item-uuid", "/api/items/uuid/:uuid", function(self) --{{{
  local id = self.user:get_item_by_uuid(self.params.uuid)
  return {json=self.user.items[id]}
end) --}}}


-- vim:foldmethod=marker
