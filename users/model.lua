local Model = require"lapis.db.model".Model
local db = require"lapis.db"
local util = require"util"

local Users, User_meta = Model:extend("users", {
  primary_key = {"uuid", "username"}
})

-- helper functions
local function to_ids(items) -- {{{ flattens a list of items into a list of item ids
  local ids = {}
  for i,item in ipairs(items) do
    ids[i] = item.id
  end
  return ids
end -- }}}


-- class functions
function Users.add(username, password, items) -- {{{
  return Users:create{
    uuid = util.uuid();
    username = username,
    password = util.crypto.hash(password),
    -- does it assume array? does it care? it should switch to an array as soon as data's added.
    -- Jank Serialized Object Notation
    items = util.to_json(items or {}),
    config = util.to_json{},
    ctime = os.time()
  }
end -- }}}


-- instance functions

function User_meta:verify(password) --{{{
  return util.crypto.verify(self.password, password)
end --}}}

-- {{{ queries

function User_meta:get_item_by_uuid(uuid) --{{{ returns id of item with uuid
  -- query the json via SQL i fucking guess
  -- postgres' docs for JSON_TABLE are good, if you're trying to parse any of this
  -- actually this should use JSON_VALUE but this is a good template for more specific queries
  local res = db.query([[
    SELECT itemstbl.*
    FROM users,
    JSON_TABLE(items, '$[*] ? (@.uuid == ?)'  -- $ is items column, [*] is array contents, @.uuid is those contents .uuid
      COLUMNS(id INT PATH '$.id')             -- just return the id
    ) as itemstbl                             -- we have to create a table for query
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

function User_meta:search_items(phrase, limit) --{{{ search item tiltles by search term and return limit results
  local res = db.query([[
    SELECT filtered.id                  -- returns a list like {{id=3},{id=7}}
    FROM (
      SELECT items
      FROM users
      WHERE username = ?) as itemstbl,  -- get the user's items as itemstbl

    JSON_TABLE(items, '$[*]'            -- make a table out of items[*]
      COLUMNS(
        id INT PATH '$.id',
        title text PATH '$.title')      -- keep the titles for parsing
    ) as filtered

    ORDER BY similarity(title, ?) DESC  -- order the titles by trigram similarity
    LIMIT ?                             -- limit and you've got your matches
  ]], self.username, phrase, limit)

  return to_ids(res) -- flatten the response list
end --}}}

-- }}}

-- {{{ transactions

function User_meta:create_item(item)
  db.query([[
    SELECT
    jsonb_insert(itemstbl, ?,
      jsonb_array_length(itemlist), false)  -- insert before the end of the array

    FROM (SELECT items.*
          FROM users
          WHERE username = ?
          LIMIT 1) as itemstbl              -- only look inside the matched user
    ]])
end

-- }}}

-- {{{ validation

-- }}}


return Users

-- vim:foldmethod=marker
