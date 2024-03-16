#!/bin/bash

eval "$(gpg -d --cipher-algo AES256 /home/odysseus/PASSWORDS.env.gpg)"
