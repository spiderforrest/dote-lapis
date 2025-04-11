local util = require'lapis.util'
local Users = require"users.model"
local auth = require"users.auth"

local M = {}

M.get_user = function(self)
  return Users:find{ username=self.params.username }
end

M.add_user = function(self) -- {{{ create a user
  Users:create({
    uuid = require"resty.jit-uuid"(), -- TODO:spider; can do this with postgres
    username = self.params.username,
    password = auth.hash(self.params.password),
    data = util.to_json{bunger=true}, -- probably wrong? does it assume array? does it care?
    settings = util.to_json{}
  })
  return {status=200, layout=false}
end -- }}}

M.set_data = function(self)
end

M.get_data = function(self)
  local user=M.get_user(self)
  return { status=200, json=user.data }
end

return M

-- vim:foldmethod=marker
