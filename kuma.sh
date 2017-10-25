#!/bin/bash
# Usage: sh kuma.sh "auth" "!command"

curl -XPOST \
  -H 'Content-Type: application/json' \
  -H 'Authorization: '"$1"'' \
  --data-binary '{
    "protocol": "irc",
    "guild": {"id": null, "name":"console"},
    "channel": {"id": null, "name":"curl", "nsfw": true, "private": true},
    "user": {"id": null, "name":"rekyuus", "avatar": null, "moderator": true},
    "message": {"id": null, "text": "'"$2"'", "image": null}
  }' \
  kuma.riichi.me/api