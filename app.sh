#!/usr/bin/env bash

# Server user
# Default: "server"
SERVER_USER=${SERVER_USER:=server}

function SetupContainer() {
    # User may not exist yet or the container is
    # configured to use a different user.
    id -u "$SERVER_USER" >/dev/null 2>&1 || {
        echo "Creating user '$SERVER_USER'"
        useradd --create-home "$SERVER_USER"
    }

    # We may get permission issues when the volume is
    # mounted to a host folder. We'll give ownership
    # to the server user and open up rwx permissions.
    sudo -u "$SERVER_USER" test -w "$PWD" || {
        echo "Updating folder permissions for '$PWD'"
        chown "$SERVER_USER" "$PWD"
        chmod 777 "$PWD"
    }
}

function StartServer() {
    /app/DepotDownloader -app 2857200 -os windows -dir "$PWD" || exit
    wine64 AbioticFactor/Binaries/Win64/AbioticFactorServer-Win64-Shipping.exe \
        -log  \
        -useperfthreads  \
        -NoAsyncLoadingThread  \
        -tcp  \
        -PORT=7777  \
        -QUERYPORT=27015  \
        -MaxServerPlayers="$MAX_PLAYERS" \
        -SteamServerName="$SERVER_NAME" \
        -ServerPassword="$SERVER_PASSWORD" \
        -WorldSaveName="$WORLD_SAVE_NAME" \
        $@

}

# We shouldn't run the server as root. Instead
# we'll setup a user to run the server, setup
# folder permissions, and rerun this script as
# our server user.
[ "$EUID" = 0 ] && {
    SetupContainer

    echo "Switching to user $SERVER_USER"
    sudo -u "$SERVER_USER" \
        MAX_PLAYERS="$MAX_PLAYERS" \
        SERVER_NAME="$SERVER_NAME" \
        SERVER_PASSWORD="$SERVER_PASSWORD" \
        WORLD_SAVE_NAME="$WORLD_SAVE_NAME" \
        /app/run.sh $@

    exit
}

StartServer $@
