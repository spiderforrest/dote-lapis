local json_params = require("lapis.application").json_params
-- initialize the app
local app = require"lapis".Application()
-- init the db connection
local db = require"lapis.db"

local users = require"users.init"

-- enable templating
app:enable"etlua"

-- set the layout wrapper for every page
app.layout = require "views.layout"


-- {{{bind routes
-- render and serve the etlua view "home.etlua"(from views/) inside the layout wrapper on /
app:get("home", "/", function () return { render = true } end)

app:get("/uuid", function() return require'lapis.db'.select"gen_random_uuid()"[1].gen_random_uuid end)
app:get("/api/userdata/:username", users.get_data)
app:post("/api/adduser", users.add_user)
app:post("/api/userdata", json_params(users.set_data))

app:get("/api/userdata/:username/:id", function(self) return users.get_by_id(self, self.params.id) end)


-- everything about this is awful and stinky but temp
-- if this ever needs doing again i can write a single db.query to fix it for every item for every user
app:post("/test/fixuuids/:username", function (self)
  local user = users.get_user(self)
  local function uuid() return require'lapis.db'.select"gen_random_uuid()"[1].gen_random_uuid end
  for i,v in ipairs(user.data) do
    user.data[i].uuid = uuid()
  end
  self.params.userdata = user.data
  users.set_data(self)
  return users.get_data(self)
end)

--}}}

-- return lapis your created app with routes etc
return app
-- vim:foldmethod=marker
