local schema = require("lapis.db.schema")

local types = schema.types

schema.create_table("users", {
   "uuid UUID PRIMARY KEY",
   "username VARCHAR(64) NOT NULL UNIQUE",
   "password VARCHAR(256) NOT NULL", -- current pw 244 chars
   "data JSON", -- ?????? amazingly cursed
   "settings JSON",
   "ctime INT", -- postgres has JSON but not fucking UINT lmao
})
