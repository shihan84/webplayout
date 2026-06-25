#!/bin/sh

if [ ! -f /db/ffplayout.db ]; then
    ffplayout -i -u admin -p admin -m contact@example.com --storage "/tv-media" --playlists "/playlists" --public "/public" --logs "/logging" --smtp-server "mail.example.org" --smtp-user "admin@example.org" --smtp-password "" --smtp-port 465 --smtp-starttls false
fi

/usr/bin/ffplayout -l "0.0.0.0:8787"
