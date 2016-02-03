#!/bin/bash

VOLUME_HOME=$HOME/$NAME

echo " -> Installation detected in $VOLUME_HOME"
echo " -> Installing Phoenix Application"
mix local.hex --force
mix archive.install /phoenix_new-1.1.4.ez --force
yes | mix phoenix.new $VOLUME_HOME --database mysql
cd $VOLUME_HOME
npm install
mix deps.get

sed -i -r "s/adapter: Ecto.Adapters.MySQL,/adapter: Ecto.Adapters.MySQL,\n  hostname: \"master\",/i" ./config/dev.exs
sed -i -r "s/username: \"root\",/username: \"$DB_RWUSER\",/i" ./config/dev.exs
sed -i -r "s/password: \"\",/password: \"$DB_RWPASS\",/i" ./config/dev.exs

mix ecto.create
mix ecto.migrate

echo " -> Done!"
