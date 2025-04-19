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
  local res = db.query([[
    SELECT
      JSON_QUERY(items, '$[*] ? (@.uuid == ?)') -- you should be able to use json_value but it doesn't
    FROM (                                      -- let you pull a whole item and i can't figure out
      SELECT items                              -- the correct way to do $[*].id <q mark> $[*].uuid....
      FROM users
      WHERE username = ?
    ) as itemstbl
    LIMIT 1
    ]],
    db.raw'?', db.raw(db.escape_identifier(uuid)), self.username)
  -- fuckin json man - dooo i smell a stink?
  return res[1].json_query.id
end --}}}

function User_meta:search_items(phrase, limit, offset) --{{{ search item tiltles by search term and return [limit] results, paginate by [offset]
  limit = limit or 10
  offset = offset or 0
  local res = db.query([[
    SELECT filtered.id                  -- returns a list like {{id=3},{id=7}}
    FROM (
      SELECT items
      FROM users
      WHERE username = ?
    ) as itemstbl,                      -- get the target user's items as itemstbl

    JSON_TABLE(items, '$[*]'            -- make a table out of items[*]
      COLUMNS(
        id INT PATH '$.id',
        title text PATH '$.title' OMIT QUOTES)      -- keep the titles for parsing
    ) as filtered

    ORDER BY similarity(title, ?) DESC  -- order the titles by trigram similarity
    LIMIT ?                             -- limit and you've got your matches
    OFFSET ?                            -- paginate the lazy way
  ]], self.username, phrase, limit, limit*offset)

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
