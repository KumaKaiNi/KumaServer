#!/bin/bash

curl -XPOST \
  -H 'Content-Type: application/json' \
  -H 'Authorization: test' \
  --data-binary '{
    "protocol": "irc",
    "guild": {"id": null, "name":"console"},
    "channel": {"id": null, "name":"curl", "nsfw": true, "private": true},
    "user": {"id": null, "name":"rekyuus", "avatar": null, "moderator": true},
    "message": {"id": null, "text": "'"$1"'", "image": null}
  }' \
  dev.riichi.me/api