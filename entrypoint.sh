#!/bin/sh
echo "VALHEIM DEDICATED GAMESERVER"
echo "https://www.valheimgame.com/"
echo ""
echo "Initalizing container..."

update_files() {
  steamcmd/steamcmd.sh +login anonymous +force_install_dir /home/valheim/server +app_update 896660 +quit
}

if [ ${UPDATE_ON_RESTART} -ne 0 ]; then
  echo "Checking for latest Valheim server updates, this may take a moment..."
  update_files
  echo "Done!"
fi

exec "$@"
