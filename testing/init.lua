local app = require 'app' -- files that use app must return it for class inhertance reasons (despite me not using the class system)

local Users = require"users.model"
local util = require'util'
local json_params = require"lapis.application".json_params

local function add_user (self) -- {{{
  Users:create{
    uuid = util.uuid();
    username = self.params.username,
    password = util.crypto.hash(self.params.password),
    -- does it assume array? does it care? it should switch to an array as soon as items's added.
    -- Jank Serialized Object Notation
    items = util.to_json(self.params.useritems or {}),
    config = util.to_json{self.params.config or {}},
    ctime = os.time()
  }
  return {status=200, layout=false}
end -- }}}

local function set_items (self) --{{{
  local user = Users:find{username=self.params.username}
  local ok = user:update{items=util.to_json(self.params.useritems), ctime=os.time()} -- or this
  local status
  if ok then status = 200 else status=402 end
  return {status=status, layout=false}
end --}}}

-- everything about this is awful and stinky but temp
-- if this ever needs doing again i can write a single db.query to fix it for every item for every user
local function fix_uuids (self)
  local user = Users:find{username=self.params.username}
  for i,v in ipairs(user.items) do
    user.items[i].uuid = util.uuid()
  end
  user.items = util.to_json(user.items)
  user:update("items")
  return {status=status, layout=false}
end
--}}}

app:post("/auth/signup", add_user)
app:put("/setitems", json_params(set_items))
app:post("/test/fixuuids/:username", fix_uuids)


return app
-- vim:foldmethod=marker
