#!/bin/bash

export MIX_ENV=prod
export PORT=4804

# echo "Stopping old copy of app, if any..."

# _build/prod/rel/bulls/bin/bulls stop || true

echo "Starting app..."

_build/prod/rel/user_stories/bin/user_stories start
