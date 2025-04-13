local util = require"util"
local Users = require"users.model"
local auth = require"users.auth"
local app = require"app"

local function uuid() -- {{{ generate a uuid, maybe belongs in a util file
 return require'lapis.db'.select"gen_random_uuid()"[1].gen_random_uuid
end -- }}}

local M = {}

-- M.get_user = function(self) --{{{
--   -- leaving one blank in the request leaves it out of the query bc of how tables work. sick, lapis.
--   return Users:find{username=self.params.username, uuid=self.params.uuid}
-- end --}}}

app:render_get("signup", "/auth/signup") -- {{{ get/post create a user
app:post("signup", "/auth/signup", function(self)
  Users:create({
    uuid = util.uuid();
    username = self.params.username,
    password = auth.hash(self.params.password),
    -- does it assume array? does it care? it should switch to an array as soon as data's added.
    -- Jank Serialized Object Notation
    data = util.to_json(self.params.userdata or {}),
    config = util.to_json{}
  })
  return {redirect_to = self.session.wanted_url or "/"}
end) -- }}}

app:get("login", "/auth/login", function(self) --{{{ get/post to login a user
  if self.session.uuid then -- if already logged in send them on their way
    return {status = 200, redirect_to = "/"}
  end
  return { render = true}
end)
app:post("login", "/auth/login", function (self)
   local user = Users:find{username=self.params.username}
   if auth.check(user.password, self.params.password) then
      self.session.uuid = user.uuid
      -- return {status = 204, render = false}
      return {redirect_to = self.session.wanted_url or "/"}
  else
    return {status = 403, render = false}
   end
end) -- }}}

app:match("logout", "/auth/logout", function(self) -- destroy session
  return({
    redirect_to = self:url_for"home",
    headers = {
      ["Clear-Site-Data"] = '"*"',
    }
  })
end)
return app

-- vim:foldmethod=marker
