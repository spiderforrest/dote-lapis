-- if running the testing setup, use a different init
if require"lapis.config".get()._name == "setup" then
  return require"testing.init"
end

-- initialize the app
local app = require"app"

-- grab modules
local Users = require"users.model"
local util = require"util"


-- this runs code on EVERY route before the action applies, and loads the session data or redirects to login
app:before_filter(function(self) -- {{{ the filter function to authenticate requests
   -- if user has a session, pull their data from the database
   if self.session.uuid then
      self.user = Users:find{uuid=self.session.uuid}
      return
   end

   -- TODO:all; figure out the url paths and update here
   if string.find(self.req.parsed_url.path, "^/$") then return end
   -- if currently authing, just allow
   if string.find(self.req.parsed_url.path, "^/auth") then return end

   -- if no exceptions met, give 'em the ol' one-two
   self.session.wanted_url = self.req.parsed_url.path
   self:write({redirect_to = self:url_for"login"})
end) --}}}


-- enable templating
app.views_prefix = "client.views" -- where we keep etlua files
app:enable"etlua" -- let us access them
app.layout = "layout" -- set the layout wrapper for every page


-- this function handles json requests, see /api/useritems for usage
local json_params = require"lapis.application".json_params

-- render and serve the etlua view "home.etlua"(from client/views/) inside the layout wrapper on /
app:get("home", "/", function ()
  return { render = true }
end)
-- typing function()return{render=true}end annoys me slightly so here's a shorthand
--app:render_get("home", "/")

-- you can also pass a callback function, if it returns text it will get rendered inside the layout html escaped (gr8 for debugging)
app:get("/test/uuid", function() return require'lapis.db'.select"gen_random_uuid()"[1].gen_random_uuid end)

-- of course, we do most of the binding in other files
require"users.actions"
require"items.actions"





-- this is testing setup junk i will delete eventually
-- app:get("/api/useritems/:username", users.get_items)
-- app:post("/api/adduser", users.add_user)
-- app:post("/api/useritems", json_params(users.set_items))

-- app:get("/api/useritems/:username/:id", function(self) return users.get_by_id(self) end)
-- app:get("/api/useritems/:username/:item_uuid", function(self) return users.get_by_uuid(self) end)
-- app:get("/api/useritems/:username/:phrase", function(self) return users.get_by_uuid(self) end)


-- return lapis your created app with routes etc
return app
-- vim:foldmethod=marker
