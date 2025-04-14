local db = require"lapis.db"
local schema = require"lapis.db.schema"

local types = schema.types

schema.create_table("users", {
   "uuid UUID PRIMARY KEY",
   "username VARCHAR(64) NOT NULL UNIQUE",
   "password VARCHAR(256) NOT NULL", -- current pw 244 chars
   "items JSONB", -- ?????? amazingly cursed
   "config JSONB",
   "ctime INT", -- postgres has JSON but not fucking UINT lmao
})

db.query("CREATE INDEX idxgin ON users USING GIN (items)") -- what.

-- enable fuzzy search
-- levenshtein does not work when your search term is much shorter than the target string
-- soundex and metaphone are not the kind of searches people want, probably, typing?
-- db.query("CREATE EXTENSION fuzzystrmatch;")
-- trigrams might work the best, at least for now
db.query("CREATE EXTENSION pg_trgm")
