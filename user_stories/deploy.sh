#!/bin/bash

export SECRET_KEY_BASE=.
export MIX_ENV=prod
export PORT=4804
export NODEBIN=`pwd`/assets/node_modules/.bin
export PATH="$PATH:$NODEBIN"

echo "Building..."

mix deps.get
mix compile
(cd assets && npm install)
(cd assets && webpack --mode production)
mix phx.digest

echo "Generating release..."
mix release

echo "Starting app..."

PROD=t ./start.sh
