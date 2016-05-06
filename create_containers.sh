#!/bin/bash

# Installation directory, default is the current directory, change if needed.
INSTALL_DIR=`pwd`

DOWNLOAD_TEMP=/tmp/sabtemp
INCOMING=/tmp/Incoming
TV_SERIES=/tmp/Series
MOVIES=/tmp/Movies
MUSIC=/tmp/Music
TORRENT_WATCHED_FOLDER=/tmp/watched

GROUP=thuis

SABNZBD_USER=sabnzbd
HEADPHONES_USER=headphones
PLEX_USER=plex
COUCHPOTATO_USER=couchpotato
SONARR_USER=sonarr
TRANSMISSION_USER=transmission

############### DO NOT EDIT BELOW THIS LINE, unless you know how this shit works, then please do, but please commit back upstream :) #############################
if [ ! -z $(getent group ${GROUP}) ]; then
  echo "Group ${GROUP} exists."
else
  echo "Group ${GROUP} DOES NOT exist, creating..."
  groupadd ${GROUP}
fi

if [ ! -z $(getent passwd ${SABNZBD_USER}) ]; then
  echo "User ${SABNZBD_USER} exists."
else
  echo "User ${SABNZBD_USER} DOES NOT exist, creating..."
  adduser ${SABNZBD_USER}
  gpasswd -a ${SABNZBD_USER} ${GROUP}
fi

if [ ! -z $(getent passwd ${HEADPHONES_USER}) ]; then
  echo "User ${HEADPHONES_USER} exists."
else
  echo "User ${HEADPHONES_USER} DOES NOT exist, creating..."
  adduser ${HEADPHONES_USER}
  gpasswd -a ${HEADPHONES_USER} ${GROUP}
fi

if [ ! -z $(getent passwd ${PLEX_USER}) ]; then
  echo "User ${PLEX_USER} exists."
else
  echo "User ${PLEX_USER} DOES NOT exist, creating..."
  adduser ${PLEX_USER}
  gpasswd -a ${PLEX_USER} ${GROUP}
fi

if [ ! -z $(getent passwd ${COUCHPOTATO_USER}) ]; then
  echo "User ${COUCHPOTATO_USER} exists."
else
  echo "User ${COUCHPOTATO_USER} DOES NOT exist, creating..."
  adduser ${COUCHPOTATO_USER}
  gpasswd -a ${COUCHPOTATO_USER} ${GROUP}
fi

if [ ! -z $(getent passwd ${SONARR_USER}) ]; then
  echo "User ${SONARR_USER} exists."
else
  echo "User ${SONARR_USER} DOES NOT exist, creating..."
  adduser ${SONARR_USER}
  gpasswd -a ${SONARR_USER} ${GROUP}
fi

if [ ! -z $(getent passwd ${TRANSMISSION_USER}) ]; then
  echo "User ${TRANSMISSION_USER} exists."
else
  echo "User ${TRANSMISSION_USER} DOES NOT exist, creating..."
  adduser ${TRANSMISSION_USER}
  gpasswd -a ${TRANSMISSION_USER} ${GROUP}
fi

# TODO: Write path test for all users & groups

# TEST_PATHS=(${CURRENT} ${DOWNLOAD_TEMP} ${INCOMING} ${TV_SERIES} ${MOVIES} ${MUSIC})
# for i in "${TEST_PATHS[@]}"; do
#   sudo -u ${SABZNBD_USER} touch ${i}/write_test
#   if [ $? -neq 0 ]; then
#     echo "User ${SABZNBD_USER} has no write access in 1 of your paths!, Go Fix!"
#     exit 1
#   fi
#   #TODO: Cleanup
# fi

###################### ACTUAL INSTALLATION ######################

# SabNZBd
docker create --name="Sabnzbd" -v ${INSTALL_DIR}/sabnzbd:/config -v ${INCOMING}:/downloads -v ${DOWNLOAD_TEMP}:/incomplete-downloads -v /etc/localtime:/etc/localtime:ro -e PGID=${GROUP} -e PUID=${SABNZBD_USER} -p 8080:8080 -p 9090:9090 linuxserver/sabnzbd

# Headphones
docker create --name="Headphones" -v ${INSTALL_DIR}/headphones:/config -v ${INCOMING}:/downloads -v ${MUSIC}:/music -v /etc/localtime:/etc/localtime:ro -p 8181:8181 linuxserver/headphones

# Plex
docker create --name="Plex" --net=host -e VERSION=latest -e PUID=${PLEX_USER} -e PGID=${GROUP} -v ${INSTALL_DIR}/plex:/config -v ${TV_SERIES}:/data/tvshows -v ${MOVIES}:/data/movies linuxserver/plex

# CouchPotato
docker create --name="CouchPotato" -v /etc/localtime:/etc/localtime:ro -v ${INSTALL_DIR}/couchpotato:/config -v ${INCOMING}:/downloads -v ${MOVIES}:/movies -e PGID=${GROUP} -e PUID=${COUCHPOTATO_USER} -p 5050:5050 linuxserver/couchpotato

# Sonarr
docker create --name="Sonarr" -p 8989:8989 -e PUID=${SONARR_USER} -e PGID=${GROUP} -v /dev/rtc:/dev/rtc:ro -v ${INSTALL_DIR}/sonarr:/config -v ${TV_SERIES}:/tv -v ${INCOMING}:/downloads linuxserver/sonarr

# Transmission
docker create --name="Transmission" -v /etc/localtime:/etc/localtime:ro -v ${INSTALL_DIR}/transmission:/config -v ${INCOMING}:/downloads -v ${TORRENT_WATCHED_FOLDER}:/watch -e PGID=${GROUP} -e PUID=${TRANSMISSION_USER} -p 9091:9091 -p 51413:51413 linuxserver/transmission
