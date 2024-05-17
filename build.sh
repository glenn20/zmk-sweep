#!/bin/bash

#  The script is a simple shell script that builds the ZMK firmware for the
#  nice_nano_v2 MCU and the cradio_left and cradio_right shields using the zmk
#  vscode docker container (see https://zmk.dev/docs/development/setup).

#  It uses the west tool to build the firmware and copies the resulting UF2
#  files to the zmk-config/firmware directory.

#  The script takes an optional -p argument to prune the build directory for a
#  clean build before building the firmware.

#  If running outside the zmk docker container - start it and run the script
#  inside the container (requires the vscode devcontainer cli installed
#  - https://code.visualstudio.com/docs/devcontainers/devcontainer-cli).

set -e

# The location of the zmk source code
ZMKDIR=zmk

# The location of the folders inside the zmk devcontainer
WORKSPACE=/workspaces
APP=$WORKSPACE/zmk/app
CONFIG=$WORKSPACE/zmk-config/config
FIRMWARE=$WORKSPACE/zmk-config/firmware

MCU=nice_nano_v2
SHIELDS="cradio_left cradio_right"

prune=no
if [ "$1" = "-p" ]; then
    prune=yes
fi

if [ ! -d $APP ]; then
    # We are running outside the container - start it and run the script inside
    cd $ZMKDIR
    id=""
    if ! devcontainer exec /bin/true > /dev/null; then
        id=`devcontainer up | sed -n 's/^.*containerId":"\([0-9a-f]*\)".*$/\1/p'`
    fi
    devcontainer exec $WORKSPACE/zmk-config/build.sh $@
    if [ -n "$id" ]; then
        docker stop $id
    fi
    exit $?
fi

cd $APP

for shield in $SHIELDS; do
    if [ -d build/$shield -a "$prune" != "yes" ]; then
        west build -d build/$shield
    else
        west build -d build/$shield -p -b $MCU -- -DSHIELD=$shield -DZMK_CONFIG=$CONFIG
    fi
    cp -v $APP/build/$shield/zephyr/zmk.uf2 $FIRMWARE/zmk_${shield}_${MCU}.uf2
done

ls -l $FIRMWARE/zmk_*

