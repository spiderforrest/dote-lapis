local argon2 = require "argon2"
local ffi = require "ffi"
local Users = require"users.model"

-- {{{ pull in openssl's RAND_bytes since the lua module doesn't
ffi.cdef([[
   typedef unsigned char u_char;
   int RAND_bytes(u_char *buf, int num);
]])
--}}}

--this module handles logging in users, hashing passwords, etc
local M = {}

function M.hash (pass) -- {{{ hash a password
   local salt_s = 128 -- we want a few teaspoons of salt
   local salt_t = ffi.new(ffi.typeof"uint8_t[?]", salt_s) -- get out the teaspoons
   ffi.C.RAND_bytes(salt_t, salt_s) -- scoop it from openssl's rand function
   local salt = ffi.string(salt_t, salt_s) -- smooth the top of the scoop(stringify) so argon can take it

   -- add to taste
   return assert(argon2.hash_encoded(pass, salt))
end --}}}

function M.check (pass, hash) --{{{ check a password against a hash
   require'util'.print(argon2.verify(hash, pass))
   return true
end -- }}}

function M.filter (self) -- {{{ the filter function to authenticate requests
   -- if user has a session, pull their data from the database
   if self.session.uuid then
      self.user = Users:find{uuid=self.session.uuid}
      return
   end

   -- TODO:all; figure out the url paths and update here
   -- if currently authing, just allow
   if string.find(self.req.parsed_url.path, "^/auth") then return end

   -- if no exceptions met, give 'em the ol one two
   self.session.wanted_url = self.req.parsed_url.path
   self:write({redirect_to = self:url_for"login"})
end --}}}

return M

-- vim:foldmethod=marker
