#!/usr/bin/env bash

# get the project dir and the name directly from the directory name
DIR=$(dirname "$(realpath "$0")")
NAME=$(basename "$DIR")
# set lua's paths to use luarocks
export LUA_PATH="$DIR/.rocks/share/lua/5.1/?.lua;$DIR/.rocks/share/lua/5.1/?/init.lua;;"
# note ;; is at the front here, so we prefer native libraries-this is primarily for openssl
export LUA_CPATH=";;$DIR/.rocks/lib/lua/5.1/?.so;"
cd "$DIR"


# do one of the things
case "$1" in
  "watch")
    # kill the server on ctrl c
    trap '.rocks/bin/lapis term; echo -e "\e[33m/// watcher: terminated! ///\e[0m"' INT

    # start the server
    .rocks/bin/lapis serve &

    # watch every file the server doesn't touch for changes
    inotifywait -mre modify --exclude "temp|compiled|logs|store" . |
      while read -r change;
      do
        # call the lapis command that refreshes the server in place
        .rocks/bin/lapis build >/dev/null
        echo -e "\e[33m/// watcher: $change changed! /// \e[0m"
      done

    # who watches the watcher
    # inotifywait -me modify "$0" && exec "$0"

    ;;

  "prod")
    # spawn screen and start the 'prod' server inside it for monitoring
    screen -dmS "$NAME" "$(which bash)"
    screen -S "$NAME" -X stuff "cd ${DIR} \n"
    screen -S "$NAME" -X stuff ".rocks/bin/lapis serve testprod \n"
    ;;

  "cert") # todo: switch to lua-resty-acme or lua-resty-letsencrypt
    # ask certbot to grab a cert, and then kills nginx because certbot doesn't
    certbot certonly --nginx --domains "$2"
    sleep 10 # playing it safe beca)use i don't trust certbot to behave, they say to only get it from _snap_
    pkill nginx
    ;;


  "setup")
    mkdir $DIR/.temp
    echo "dependancies: install openresty, lua 5.1, luarocks, openssl, argon2, postgres, postgres17-contrib
     for dev env: inotify-tools
     for prod env: certbot, screen, and after you config certs, run scripts.sh cert
Did you do those? Next I'm gonna reinstall the luarocks."
    read

    # rm -r .rocks
    # instead of setting this up as a rock, just grab luarocks deps manually, we shouldn't have too many......
    luarocks install lapis --lua-version 5.1 --tree .rocks  # the server
    luarocks install argon2-ffi --lua-version 5.1 --tree .rocks  # award winning password hasher, apperently

    echo "Gonna nuke the db now, yeah?"; read

    luajit -e "require'lapis.db.schema'.drop_table'users'"
    luajit users/schema.lua

    echo "Populate the db with random bullshit?"; read
    # start lapis
    .rocks/bin/lapis serve setup &
    sleep 1 # lol
    # make the users
    curl -v -F username=test -F password=bunger localhost:3000/auth/signup
    curl -v -F username=emptylist -F password=bunger localhost:3000/auth/signup
    curl -v -F username=$USER -F password=bunger localhost:3000/auth/signup

    # populate
    curl -X PUT -H "Content-Type: application/json" -d "@$DIR/testing/test.json" localhost:3000/setdata
    curl -X PUT -H "Content-Type: application/json" -d "@$DIR/testing/emptylist.json" localhost:3000/setdata
    # check if '''the dev''' has a local datafile and shove it in
    local_datafile="$HOME/.config/dote/data.json"
    if [[ $USER == "spider" ]];then local_datafile="$HOME/misc/dote.json" ; fi
    if [[ -e "$local_datafile" ]] ; then
      # copy your local datafile and restructure json for what's needed for the request
      echo -n "{\"username\":\"$USER\", \"userdata\":" > $DIR/tmp
      cat "$local_datafile" >> $DIR/tmp
      # echo -n ", \"password\":\"bunger\"" >> $DIR/tmp
      echo -n "}" >> $DIR/tmp
      curl -X PUT -H "Content-Type: application/json" -d "@$DIR/tmp" localhost:3000/setdata
      rm $DIR/tmp
    fi


    # fix missing uuids from dote-cli
    curl -X POST localhost:3000/test/fixuuids/test
    curl -X POST localhost:3000/test/fixuuids/$USER


    #shutdown lapis
    sleep 1
    .rocks/bin/lapis term
    ;;
  *)
  echo "need \$1 from: watch, prod, cert, setup"
esac

