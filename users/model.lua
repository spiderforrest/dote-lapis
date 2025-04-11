local Model = require("lapis.db.model").Model

local Users, User_meta = Model:extend("users", {
  primary_key = {"uuid", "username"}
})




return Users
