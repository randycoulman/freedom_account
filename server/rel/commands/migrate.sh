#!/bin/sh

release_ctl eval --mfa "FreedomAccount.ReleaseTasks.migrate/1" --argv -- "$@"
