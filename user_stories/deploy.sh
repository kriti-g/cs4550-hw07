#!/bin/bash

export SECRET_KEY_BASE=0DTh2oqJ7a9XcxYz3MPnH6juoN/w11WA0DK56WX0qMGHXWyFntx201pFAa8Jxyi0
export MIX_ENV=prod
export DATABASE_URL=ecto://user_stories:ooToo1ohyo3a@localhost/user_stories_prod
export PORT=4804
export NODEBIN=`pwd`/assets/node_modules/.bin
export PATH="$PATH:$NODEBIN"

echo "Building..."

mix deps.get --only prod
mix compile
(cd assets && npm install)
(cd assets && webpack --mode production)
mix phx.digest

echo "Generating release..."
mix release

echo "Starting app..."

PROD=t ./start.sh
