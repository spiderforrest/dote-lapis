-- initialize the app
local app = require"lapis".Application()
-- init the db connection
local db = require("lapis.db")

local users = require"users.init"

-- enable templating
app:enable"etlua"

-- set the layout wrapper for every page
app.layout = require "views.layout"


-- {{{bind routes
-- render and serve the etlua view "home.etlua"(from views/) inside the layout wrapper on /
app:get("home", "/", function () return { render = true } end)

-- show a hash for a password to test crypto
app:get("/test/hash/:pass", function (self) return require"users.auth".hash(self.params.pass) end)

app:get("/test/users", function ()
  return tostring(require"users.data".find_user_by_username"test" )
end)

app:post("/api/adduser", users.add_user)
app:get("/api/userdata/:username", users.get_data)

--}}}

-- return lapis your created app with routes etc
return app
-- vim:foldmethod=marker
