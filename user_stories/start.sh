#!/bin/bash

export MIX_ENV=prod
export PORT=4804
export DATABASE_URL=ecto://user_stories:ooToo1ohyo3a@gkriti.art/user_stories_prod

# echo "Stopping old copy of app, if any..."

# _build/prod/rel/bulls/bin/bulls stop || true

echo "Starting app..."

_build/prod/rel/user_stories/bin/user_stories start
