#!/bin/sh
# Adapted from Alex Kleissner's post, Running a Phoenix 1.3 project with docker-compose
# https://medium.com/@hex337/running-a-phoenix-1-3-project-with-docker-compose-d82ab55e43cf

set -e

mix deps.get
mix deps.compile

until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER -c '\q' 2>/dev/null; do
  >&2 echo "Postgres is unavailable - sleeping..."
  sleep 1
done

echo "\nPostgres is available; continuing with database setup..."

mix ecto.setup

echo "\nLaunching Phoenix web server..."
mix phx.server
