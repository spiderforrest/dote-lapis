local Model = require"lapis.db.model".Model
local db = require"lapis.db"

local Users, User_meta = Model:extend("users", {
  primary_key = {"uuid", "username"}
})


function User_meta:get_item_by_id(id) --pretty pointless
  -- query the json via SQL i fucking guess
  return db.select("data[?] FROM users WHERE username = ?", id-1, self.username) -- data is 1-index...
end

--TODO:all; decide if these should return items or ids (kinda minor syntax difference)
function User_meta:get_item_by_uuid(id)
  return db.select("data[?] FROM users WHERE '{\"uuid\": ?}' :: jsonb <@ data;", id-1, self.username) -- data is 1-index...
end
function User_meta:search_items(phrase, limit)
  return db.select("data... FROM users WHERE username = ?", self.username)
end



return Users
