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


return M

-- vim:foldmethod=marker
