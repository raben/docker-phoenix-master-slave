#!/bin/bash

VOLUME_HOME=$HOME/$NAME

echo " -> Installation detected in $VOLUME_HOME"
mix local.hex --force
mix local.rebar --force

echo " -> Installing Phoenix Application"
#mix archive.install /phoenix_new.ez --force
mix archive.install https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez --force


echo " -> Create New Phoenix Application {$NAME}"
mix phoenix.new $VOLUME_HOME --database mysql

echo " -> Open $VOLUME_HOME"
cd $VOLUME_HOME
mix deps.get
npm install
sudo npm install -g brunch


sed -i -r "s/adapter: Ecto.Adapters.MySQL,/adapter: Ecto.Adapters.MySQL,\n  hostname: \"master\",/i" ./config/dev.exs
sed -i -r "s/username: \"root\",/username: \"$DB_RWUSER\",/i" ./config/dev.exs
sed -i -r "s/password: \"\",/password: \"$DB_RWPASS\",/i" ./config/dev.exs

mix ecto.create
mix ecto.migrate

echo " -> Done!"
