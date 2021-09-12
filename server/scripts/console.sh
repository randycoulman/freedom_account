#!/usr/bin/env bash

export ERL_AFLAGS="-kernel shell_history enabled"
SUFFIX=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)

iex --sname console-$SUFFIX --remsh server
