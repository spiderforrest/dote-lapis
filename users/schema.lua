local db = require"lapis.db"
local schema = require"lapis.db.schema"

local types = schema.types

schema.create_table("users", {
   "uuid UUID PRIMARY KEY",
   "username VARCHAR(64) NOT NULL UNIQUE",
   "password VARCHAR(256) NOT NULL", -- current pw 244 chars
   "data JSONB", -- ?????? amazingly cursed
   "settings JSONB",
   "ctime INT", -- postgres has JSON but not fucking UINT lmao
})

db.query("CREATE INDEX idxgin ON users USING GIN (data)") -- what

-- enable fuzzy search
-- TODO:all; pick algos, maybe just use LEVENSHTEIN
db.query("CREATE EXTENSION pg_trgm")
db.query("CREATE EXTENSION fuzzystrmatch;")
