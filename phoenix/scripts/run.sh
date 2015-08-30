#!/bin/bash
VOLUME_HOME=$HOME/$NAME
VOLUME_HOME=/home/docker/rabe
echo " -> $VOLUME_HOME"

if [ ! -e $VOLUME_HOME ]; then
    /init.sh
fi

cd $VOLUME_HOME
mix phoenix.server
