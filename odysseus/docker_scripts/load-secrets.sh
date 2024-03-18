#!/bin/bash

# must be sourced for this to work
eval "$(gpg -d --no-symkey-cache --cipher-algo AES256 /home/odysseus/SECRETS.env.gpg)"
