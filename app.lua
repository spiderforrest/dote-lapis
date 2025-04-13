local app = require"lapis".Application()
-- this file is an alternative to using app:include, so I can
-- overload app with shorthand functions which I suspect I will want to do more later

function app:render_get(name, path) -- render a route by name
  app:get(name, path, function (self) return { render = true } end)
end

return app
