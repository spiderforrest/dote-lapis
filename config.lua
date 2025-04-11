local config = require("lapis.config")

config("development", {
  server = "nginx",
  code_cache = "on",
  port = 3000,
  num_workers = 1,
  session_name = "sess",
  secret = "secrmemt!!",
  ssl_eval = '',
  postgres = {
    password = "password",
    database = "dote"
  }
})

config("testprod", {
  server = "nginx",
  code_cache = "on",
  port = 80,
  num_workers = 4,
  session_name = "a0",
  secret = "wouldn't you like to know, weather boy",
  postgres = {
    host = "127.0.0.1",
    user = "postgres",
    password = "",
    database = "dote"
  },
  ssl_eval = [[listen 443 ssl;
    server_name         spood.org;
    ssl_certificate     fullchain.pem;
    ssl_certificate_key privkey.pem;
    ]], -- is treated as eval in nginx.conf. more details there.
})
