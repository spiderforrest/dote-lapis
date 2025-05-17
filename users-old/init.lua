local util = require'lapis.util'
local Users = require"users.model"
local auth = require"users.auth"

local function uuid()
 return require'lapis.db'.select"gen_random_uuid()"[1].gen_random_uuid
end

local M = {}

M.get_user = function(self)
  -- leaving one blank in the request leaves it out of the query bc of how tables work. sick, lapis.
  return Users:find{username=self.params.username, uuid=self.params.uuid}
end

-- all of this should probably be moved, not sure of file structure yet

M.add_user = function(self) -- {{{ create a user
  Users:create({
    uuid = uuid();
    username = self.params.username,
    password = auth.hash(self.params.password),
    -- does it assume array? does it care? it should switch to an array as soon as data's added.
    -- Jank Serialized Object Notation
    data = util.to_json(self.params.userdata or {}),
    settings = util.to_json{}
  })
  return {status=200, layout=false}
end -- }}}

M.set_data = function(self) --{{{
  local user = M.get_user(self)
  user.data = util.to_json(self.params.userdata) -- you can modify the table
  local ok = user:update("data") -- and then just tell the db to sync to it
  -- local ok = user:update{data=util.to_json(self.params.userdata)} -- or this

  local status
  if ok then status = 200 else status=402 end
  return {status=status, layout=false}
end --}}}

M.get_data = function(self) --{{{
  local user = M.get_user(self)
  return {json=user.data}
end --}}}

M.get_by_id = function(self) --{{{
  local user = M.get_user(self)
  local item = user:get_item_by_id(self.params.id)
  return {json=item}
end --}}}

M.get_by_uuid = function(self) --{{{
  local user = M.get_user(self)
  local item = user:get_item_by_uuid(self.params.item_uuid)
  return {json=item}
end --}}}

return M

-- vim:foldmethod=marker
