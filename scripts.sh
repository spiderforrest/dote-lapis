#!/usr/bin/env bash

# get the project dir and the name directly from the directory name
DIR=$(dirname "$(realpath "$0")")
NAME=$(basename "$DIR")


# do one of the things
case "$1" in
  "watch")
    # kill the server on ctrl c
    trap 'lapis term; echo -e "\e[33m/// watcher: terminated! ///\e[0m"' INT

    # start the server
    lapis serve &

    # watch every file the server doesn't touch for changes
    inotifywait -mre modify --exclude "temp|compiled|logs|store" . |
      while read -r change;
      do
        # call the lapis command that refreshes the server in place
        lapis build >/dev/null
        echo -e "\e[33m/// watcher: $change changed! /// \e[0m"
      done

    # who watches the watcher
    # inotifywait -me modify "$0" && exec "$0"

    ;;

  "prod")
    # spawn screen and start the prod server inside it for monitoring
    screen -dmS "$NAME" "$(which bash)"
    screen -S "$NAME" -X stuff "cd ${DIR} \n"
    screen -S "$NAME" -X stuff "lapis serve prod \n"
    ;;

  "cert")
    # ask certbot to grab a cert, and then kills nginx because certbot doesn't
    certbot certonly --nginx --domains "$2"
    sleep 10 # playing it safe because i don't trust certbot to behave, they say to only get it from _snap_
    pkill nginx
    ;;
  *)
  echo "need \$1 from: watch, prod, cert"
esac

