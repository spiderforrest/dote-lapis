local util = require("lapis.util")
local cached = require("lapis.cache").cached

-- setup the db model
require"users.model"

local M = {}

loadfile = function (path) -- {{{ loads a file from disk
-- TODO:spider; use ngx to make non blocking, or switch to db.. bit odd schema
   local data, file
   -- try to open
   if not pcall(function() file = assert(io.open(path, "r")) end)
   then
      return 'not found'
   end
   -- try to read
   if not pcall(function() data = util.from_json(file:read'*all') end)
   then
      return 'empty'
      -- data = {}
   end
   file:close()

   return data
end --}}}

M.find_user_by_username = function (user)
   local userdata = cached(loadfile"store/user_store.json")
   return userdata[1].username
end

return M


-- vim:foldmethod=marker
