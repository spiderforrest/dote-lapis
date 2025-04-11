local argon2 = require "argon2"
local ffi = require "ffi"
local store = require"users.data"

-- {{{ pull in openssl's RAND_bytes
ffi.cdef([[
   typedef unsigned char u_char;
   int RAND_bytes(u_char *buf, int num);
]])
--}}}

--this module handles logging in users, hashing passwords, etc
local M = {}

M.hash = function (pass) -- {{{ hash a password
   local salt_s = 128 -- we want a few teaspoons of salt
   local salt_t = ffi.new(ffi.typeof"uint8_t[?]", salt_s) -- get out the teaspoons
   ffi.C.RAND_bytes(salt_t, salt_s) -- scoop it from openssl's rand function
   local salt = ffi.string(salt_t, salt_s) -- smooth the top of the scoop(stringify) so argon can take it

   -- add to taste
   return assert(argon2.hash_encoded(pass, salt))
end --}}}

local check = function (pass, hash) -- check a password against a hash
  return argon2.verify(hash, pass)
end

M.filter = function (self) -- {{{ the filter function to authenticate requests
   if self.session.uuid then
   else
      -- either validate new auth or send to log/sign in
   end

end --}}}

return M

-- vim:foldmethod=marker
