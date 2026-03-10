-- local util = require"util"
local Users = require"users.model"
local app = require"app"

local M = {}

-- M.get_user = function(self) --{{{
--   -- leaving one blank in the request leaves it out of the query bc of how tables work. sick, lapis.
--   return Users:find{username=self.params.username, uuid=self.params.uuid}
-- end --}}}

app:render_get("signup", "/auth/signup") -- {{{ get/post create a user
app:post("signup", "/auth/signup", function(self) -- is respond_to cleaner? TOO BAD.
  local user = Users.add(self.params.username, self.params.password, self.params.useritems)
  -- log them in by setting the uuid
  self.session.uuid = user.uuid
  -- redirect them and clear the wanted url
  local wanted_url = self.session.wanted_url
  self.session.wanted_url = nil
  return {redirect_to = wanted_url or "/"}
end) -- }}}

app:get("login", "/auth/login", function(self) --{{{ get/post to login a user
  if self.session.uuid then -- if already logged in send them on their way
    return {redirect_to = "/"}
  end
  return { render = true}
end)
app:post("login", "/auth/login", function (self)
  local user = Users:find{username=self.params.username}

  if not user then return {"user not found", status = 406} end
  if user:verify(self.params.password) then
    self.session.uuid = user.uuid
    local wanted_url = self.session.wanted_url
    self.session.wanted_url = nil
    return {redirect_to = wanted_url or "/"}
  else
    return {"wrong password", status = 403}
  end
end) -- }}}

app:match("logout", "/auth/logout", function(self) -- destroy session
  return {
    redirect_to = self:url_for"home",
    headers = {
      ["Clear-Site-Data"] = '"cookies"',
    }
  }
end)

-- vim:foldmethod=marker
