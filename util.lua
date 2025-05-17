-- add our own util functions on top of lapis'
local M = require"lapis.util"

local db = require"lapis.db"
function M.uuid() -- {{{ generate a uuid
 return db.select"gen_random_uuid()"[1].gen_random_uuid
end -- }}}

function M.print(...) -- {{{ print to log, orange
  ngx.log(ngx.ALERT, table.concat({' [33m///', ..., '///[0m '}, ' '))
end -- }}}

M.crypto = {} -- {{{

local ffi = require "ffi"
-- {{{ pull in openssl's RAND_bytes since the luarock module doesn't
ffi.cdef([[
   typedef unsigned char u_char;
   int RAND_bytes(u_char *buf, int num);
]]) --}}}

-- technically there isn't much reason to true random salt, I'm being careful. TODO:spider; pepper, maybe
function M.crypto.salt (bytes) -- {{{ returns a crypographically random string
   local salt_t = ffi.new(ffi.typeof"uint8_t[?]", bytes) -- get out a measuring cup (mm, salt-t bites)
   ffi.C.RAND_bytes(salt_t, bytes) -- scoop it from openssl's rand function
   return ffi.string(salt_t, bytes) -- smooth the top of the scoop(stringify) so argon etc can take it
end -- }}}

local argon = require"argon2"
function M.crypto.hash (pass) -- {{{ hash a password
   return assert(argon.hash_encoded(pass, M.crypto.salt(16)))
end --}}}

M.crypto.verify = argon.verify

--}}}


M.tbl = {}
M.tbl.ensure_present = function(tbl, item) -- {{{ add something to a table, if it's not already there. returns bool if tbl modified
    -- oh sometimes tbl will be part of a bigger table and nil
    if not tbl then tbl = {} end
    -- go thru and check if the thing is in the table
    for _,v in pairs(tbl) do
        if v == item then
            return false
        end
    end
    -- if not, toss er in!
    table.insert(tbl, item)
    return true
end -- }}}

M.tbl.remove = function(tbl, val) -- {{{ remove an item from a table. returns bool if table modified
   if not tbl then return false end -- quit on nil (like if you do remove(tbl.not_real_tbl))
    -- go thru and check if the thing is in the table
    for k,v in pairs(tbl) do
        if v == val then
            table.remove(tbl, k)
            return true
        end
    end
    return false
end -- }}}

return M

-- vim:foldmethod=marker
