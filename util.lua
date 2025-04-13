-- add our own util functions on top of lapis'
local M = require"lapis.util"

local db = require"lapis.db"
function M.uuid() -- {{{ generate a uuid
 return db.select"gen_random_uuid()"[1].gen_random_uuid
end -- }}}

function M.print(...) -- {{{ print to log, orange
  ngx.log(ngx.NOTICE, table.concat({' [33m///', ..., '///[0m '}, ' '))
end -- }}}



return M

-- vim:foldmethod=marker
