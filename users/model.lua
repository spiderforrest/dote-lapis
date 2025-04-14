local Model = require"lapis.db.model".Model
local db = require"lapis.db"
local argon = require"argon2"

local Users, User_meta = Model:extend("users", {
  primary_key = {"uuid", "username"}
})


-- instance functions

function User_meta:verify(password) --{{{
  return argon.verify(self.password, password)
end --}}}

-- {{{ queries

function User_meta:get_item_by_uuid(uuid) --{{{ returns id of item with uuid
  -- query the json via SQL i fucking guess
  -- postgres' docs for JSON_TABLE are good, if you're trying to parse any of this
  -- actually this should use JSON_VALUE but this is a good template for more specific queries
  local res = db.query([[
    SELECT itemlist.*
    FROM users,
    JSON_TABLE(items, '$[*] ? (@.uuid == ?)'   -- $ is items column, [*] is array contents, @.uuid is those contents .uuid
      COLUMNS(id INT PATH '$.id')             -- just return the id
    ) as itemlist                                -- we have to create a table for query
    WHERE username = ?                        -- i would like to make this run first, checking every user's items first rn is comically bad
    LIMIT 1]],                                -- JSON_VALUE does this, I'll switch when TODO:spider; nest queries for performance
    -- ?'s are replaced, and the first needs to get replaced with a literal, unescaped ?. via db.raw.
    db.raw'?',
    -- the uuid for a json filter needs to be in double quotes as an identifier, and if you don't wrap
    -- that in db.raw it'll do '"uuid"'. Both uses of db.raw here are safe.
    db.raw(db.escape_identifier(uuid)), self.username)
  -- matches one, so deconstruct
  return type(res[1].id)
end --}}}

function User_meta:search_items(phrase, limit) --{{{
  return db.query([[
 SELECT itemlist.*
  FROM users,
  JSON_TABLE(items, '$[*]'
    COLUMNS(
    id INT PATH '$.id',
    title text PATH '$.title')
  ) as itemlist
  WHERE username = ?
  ORDER BY distance(title, ?) DESC
  LIMIT ?
  ]],self.username, phrase,  limit)
end --}}}

-- }}}

-- {{{ transactions

function User_meta:create_item(item)
  db.query([[
    SELECT

    (SELECT items.* FROM users WHERE username = ? LIMIT 1) as items

    ]])
end

-- }}}

-- {{{ validation

-- }}}


return Users

-- vim:foldmethod=marker
