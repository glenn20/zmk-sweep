#!/bin/bash

#  The script is a simple shell script that builds the ZMK firmware for the
#  nice_nano_v2 MCU and the cradio_left and cradio_right shields using the zmk
#  vscode docker container (see https://zmk.dev/docs/development/setup).

#  It uses the west tool to build the firmware and copies the resulting UF2
#  files to the zmk-config/firmware directory.

#  The script takes an optional -c argument to clean the build directory for a
#  clean build before building the firmware.

#  If running outside the zmk docker container - this script will start it and
#  run the script inside the container (requires the vscode devcontainer cli
#  installed
#  - https://code.visualstudio.com/docs/devcontainers/devcontainer-cli).

set -e

# Set the MCU and shields to build
MCU=nice_nano_v2
SHIELDS="cradio_left cradio_right"  # For my Ferris Sweep

# Map device serial numbers reported by lsusb to firmware filenames
# udevadm info --name=/dev/sda | grep SERIAL
declare -A devices=( \
    [Adafruit_nRF_UF2_FD8F9FF134676FF6-0:0]=zmk_cradio_left_nice_nano_v2.uf2 \
    [Adafruit_nRF_UF2_167EB14F64D5C3F6-0:0]=zmk_cradio_right_nice_nano_v2.uf2 \
)

# The location of my zmk config and source directories on the host computer
CONFIGDIR=$PWD  # This will be mounted as the zmk-config volume in the container
FIRMWARE=firmware  # Where to put the resulting UF2 firmware files
ZMKDIR=zmk  # Where to put the zmk source code (subdir of $CONFIGDIR)
ZMKREPO=https://github.com/zmkfirmware/zmk.git  # Where to get the zmk source code

# Directory locations inside the zmk devcontainer
WORKSPACE=/workspaces/zmk
MYCONFIG=/workspaces/zmk-config  # Where the zmk-config volume will be mounted
VOLUME=zmk-config  # The name of the zmk-config docker volume

Usage() {
    echo "Usage: $0 [-c] [-u] [-i] [-f]"
    echo "  -c  Clean the build directory before building the firmware"
    echo "  -u  Update zmk and the build environment (git pull; west update)"
    echo "  -i  (re-)Install the zmk build environment and devcontainer"
    echo "  -f  Flash the firmware to the devices"
    exit 1
}
options="$@"
isopt() { [[ "$options" =~ $1 ]] && echo yes || echo no; }
[[ $(isopt -[^ciuf]) == "yes" ]] && Usage
clean=$(isopt -c)       # Clean the build directory before building
install=$(isopt -i)     # Install zmk and the build environment
update=$(isopt -u)      # Update zmk and the build environment
flash=$(isopt -f)       # Flash the firmware to the devices
build=yes               # Build/compile the firmware

log() { echo -e "\033[0;32m### $@\033[0m"; }
warn() { echo -e "\033[0;31m### $@\033[0m" 1>&2; }

if [ -d "$WORKSPACE" ]; then
    # This part of the script is run inside the devcontainer
    cd "$WORKSPACE"
    if [ "$install" = "yes" ]; then
        log "Install zmk build environment (west init)..."
        west init -l app/  # Initialize the zmk build environment
        west update  # Update the zmk build environment (including zephyr)
    fi
    if [ "$update" = "yes" ]; then
        log "Update the build environment (west update)..."
        west update  # Update the zmk build environment (including zephyr)
    fi
    if [ "$build" == "yes" ]; then
        # Build the firmware for the specified MCU and shields
        pushd ./app
        for shield in $SHIELDS; do
            if [ -d build/$shield -a "$clean" != "yes" ]; then
                # Perform a build without cleaning
                log "Building ${shield}_${MCU}..."
                west build -d build/$shield
            else
                # Perform a full build from clean
                log "Building ${shield}_${MCU}..."
                west build -d build/$shield -p -b $MCU -- -DSHIELD=$shield -DZMK_CONFIG=$MYCONFIG/config
            fi
        done
        popd
    fi
    chown -R $(stat -c %u:%g .) .west app/build  # Set ownership of build files
    exit 0  # Return to the script running on the host computer
fi

# The rest of the script is run on the host computer, outside the container

# Check that the zmk-config directory exists
if [ ! -d "$CONFIGDIR/config" ]; then
    warn "Error: '$CONFIGDIR/config' directory not found." 1>&2
    log "Run '$0' in your zmk config base directory." 1>&2
    log "See https://zmk.dev/docs/user-setup to create a new config." 1>&2
    exit 1
fi

# Create the zmk-config docker volume (delete first if it already exists)
create_docker_volume() {
    volume=$1
    directory=$2
    # Check if the docker volume already exists
    if docker volume inspect "$volume" > /dev/null 2>&1; then
        # Remove the existing docker volume
        log "Deleting existing '$volume' docker volume..."
        id=$(  # Try deleting the volume - get the container id if in use
            docker volume rm "$volume" 2>&1 | \
            sed -n 's/^Error.*: volume is in use - \[\([0-9a-f]*\)\]$/\1/p'
        )
        if [ -n "$id" ]; then
            log "Stopping and removing container using '$volume' docker volume..."
            docker stop $id > /dev/null || /bin/true # Stop the container using the volume
            docker rm $id > /dev/null   # Remove the container using the volume
            docker volume rm "$volume" > /dev/null
        fi
    fi
    log "Creating '$volume' docker volume bound to '$directory'..."
    docker volume create --driver local -o o=bind -o type=none -o device="$directory" "$volume"
}

# Run the script inside the devcontainer
run_devcontainer() {
    # Start the devcontainer (id is empty if the container is already running)
    id=$(devcontainer up | sed -n 's/^.*Start: Run: docker start \([0-9a-f]*\).*$/\1/p')
    devcontainer exec $@
    if [ -n "$id" ]; then
        docker stop $id > /dev/null  # Stop the container if we started it
    fi
}

cd $CONFIGDIR
if [ "$install" = "yes" ]; then
    # Install or re-install the zmk build environment and devcontainer
    # See https://zmk.dev/docs/development/setup/docker
    # Requires docker, vscode and the vscode devcontainer cli
    # Remove the existing zmk source code directory
    if [ -d "$ZMKDIR" ]; then
        log "Removing existing '$ZMKDIR' files..."
        /bin/rm -rf $ZMKDIR
    fi
    # Install the zmk source code
    # Clone the zmk repository
    log "git clone '$ZMKREPO' '$ZMKDIR'"
    git clone "$ZMKREPO" "$ZMKDIR"

    # Create the zmk-config docker volume (will delete first if it already exists)
    create_docker_volume $VOLUME $CONFIGDIR

    # Build the vscode devcontainer
    log "Building the zmk devcontainer..."
    pushd "$ZMKDIR"
    devcontainer build || ( log "Install failed."; exit 1 )
    popd
fi

pushd "$ZMKDIR" || (warn "Error: '$ZMKDIR' directory not found. Run '$0 -i' to install." && exit 1)
if [ "$update" = "yes" ]; then
    log "Update zmk source code..."
    git pull  # Update the zmk source code
fi

# Now re-run this script inside the devcontainer to install/update/build
log "Running build inside the '$ZMKDIR' devcontainer..."
run_devcontainer "$MYCONFIG/build.sh" $@
popd

[ ! -d "$FIRMWARE" ] && mkdir -p "$FIRMWARE"
log "Saving firmware files to '$FIRMWARE'..."
for shield in $SHIELDS; do
    cp -upv "$ZMKDIR/app/build/$shield/zephyr/zmk.uf2" "$FIRMWARE/zmk_${shield}_${MCU}.uf2"
done
ls -lR "$FIRMWARE"

# Flash the correct firmware to a device identified by usb serial number
flash_device() {
    serial=$1  # The usb serial number of the device
    device=$(readlink -e "/dev/disk/by-id/usb-$serial" || true)
    if [ -z "$device" ]; then
        return 1  # Device is not connected
    fi
    # Check if the device is mounted
    mount=$(findmnt -n -o TARGET --source $device 2>/dev/null || true)
    if [ -z "$mount" ]; then
        return 1
    fi
    # $devices is a map from serial number to firmware filename
    filename=${devices[$serial]}
    if [ ! -f "$FIRMWARE/$filename" ]; then
        warn "Error: $FIRMWARE/$filename not found." && exit 1
    fi
    echo
    # Copy new firmware to the device
    log "Flashing $FIRMWARE/$filename..."
    cp -v $FIRMWARE/$filename $mount/$filename
    log "Firmware flashed successfully."
}

flash_device_wait() {
    for i in {20..0}; do  # Wait up to 20 seconds for the devices to be mounted
        for j in {5..1}; do  # Check for devices every 0.2 seconds
            for serial in "${!devices[@]}"; do  # Check each device in the devices list
                # Flash firmware to any device that is connected and mounted
                if flash_device "$serial"; then
                    return 0
                fi
            done
            sleep 0.2
        done
        echo -n "${i}..."
    done
    return 1  # No devices found
}

if [ "$flash" = "yes" ]; then
    # Flash the firmware to the devices
    if [ -z "${!devices[*]}" ]; then
        warn "Error: No devices provided." && exit 1
    fi
    log "Searching for devices to flash firmware..."
    # Search for mounted usb devices which match those in the $devices array
    if flash_device_wait; then
        warn "Timeout waiting for devices to flash firmware." && exit 1
    fi
fi
