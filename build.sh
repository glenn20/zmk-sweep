#!/bin/bash

#  The script is a simple shell script that builds the ZMK firmware for the
#  nice_nano_v2 MCU and the cradio_left and cradio_right shields using the zmk
#  vscode docker container (see https://zmk.dev/docs/development/setup).

#  It uses the west tool to build the firmware and copies the resulting UF2
#  files to the zmk-config/firmware directory.

#  The script takes an optional -c argument to clean the build directory for a
#  clean build before building the firmware.

#  If running outside the zmk docker container - this script will start and
#  run the script inside the container (requires the vscode devcontainer cli
#  installed:
#  - https://code.visualstudio.com/docs/devcontainers/devcontainer-cli).

set -e  # Exit on any error

# Set the MCU and shields to build
MCU=nice_nano_v2
SHIELDS="cradio_left cradio_right"  # For my Ferris Sweep

# Map device usb serial numbers reported by lsusb to firmware filenames
# These serial numbers are available when the device is connected by
# usb and in bootloader mode.
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

log() { echo -e "\033[0;33m### $@\033[0m"; }
alert() { echo -e "\033[0;35m### $@\033[0m"; }
warn() { echo -e "\033[0;31m### $@\033[0m" 1>&2; }

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


# Process command line options
[[ $(isopt -[^ciuf]) == "yes" ]] && Usage  # Unknow option
clean=$(isopt -c)       # Clean the build directory before building
install=$(isopt -i)     # Install zmk software and the build environment
update=$(isopt -u)      # Update zmk software and the build environment
flash=$(isopt -f)       # Flash the firmware to the devices
build=yes               # Build/compile the firmware


# Create the zmk-config docker volume (delete first if it already exists)
# The current directory will be mounted as the "zmk-config" volume
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
            docker stop $id > /dev/null || /bin/true  # Stop the container using the volume
            docker rm $id > /dev/null   # Remove the container using the volume
            docker volume rm "$volume" > /dev/null  # Remove the volume
        fi
    fi
    log "Creating '$volume' docker volume bound to '$directory'..."
    docker volume create --driver local -o o=bind -o type=none -o device="$directory" "$volume"
}


# Install or re-install the zmk build environment and devcontainer
install_zmk_devcontainer() {
    # See https://zmk.dev/docs/development/setup/docker
    # Requires docker, vscode and the vscode devcontainer cli
    # Remove the existing zmk source code directory
    if [ -d "$ZMKDIR" ]; then
        log "Removing existing '$ZMKDIR' files..."
        /bin/rm -rf $ZMKDIR
    fi
    # Install the zmk source code - clone the zmk repo
    log "git clone '$ZMKREPO' '$ZMKDIR'"
    git clone "$ZMKREPO" "$ZMKDIR"

    # Create the zmk-config docker volume (will delete first if it already exists)
    create_docker_volume $VOLUME $CONFIGDIR

    # Build the vscode devcontainer
    log "Building the zmk devcontainer..."
    pushd "$ZMKDIR"
    devcontainer build || (warn "Install failed."; exit 2)
    popd
}


update_zmk_software() {
    pushd "$ZMKDIR" || (warn "Error: '$ZMKDIR' directory not found. Run '$0 -i' to install." && exit 1)
    log "Update zmk source code..."
    git pull  # Update the zmk source code
    popd
}


# Run this script again inside the devcontainer
run_devcontainer() {
    # Now re-run this script inside the devcontainer to install/update/build
    pushd "$ZMKDIR" || (warn "Error: '$ZMKDIR' directory not found. Run '$0 -i' to install." && exit 1)
    alert "Running build inside the '$ZMKDIR' devcontainer..."
    # Start the devcontainer (id is empty if the container is already running)
    id=$(devcontainer up | sed -n 's/^.*Start: Run: docker start \([0-9a-f]*\).*$/\1/p')
    # Run this script again inside the devcontainer
    devcontainer exec $@
    if [ -n "$id" ]; then
        docker stop $id > /dev/null  # Stop the container if we started it
    fi
    alert "Leaving the zmk devcontainer."
    popd
}


# Build the zmk firmware inside the devcontainer
build_firmware_in_devcontainer() {
    # This function must be run INSIDE the devcontainer
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
                west build -d build/$shield -p -b $MCU -- \
                    -DSHIELD=$shield -DZMK_CONFIG=$MYCONFIG/config
            fi
        done
        popd
    fi
    chown -R $(stat -c %u:%g .) .west app/build  # Set ownership of build files
}

# Save a copy of the built firmware files to the $FIRMWARE directory, eg:
# - cp zmk/app/build/cradio_left/zephyr/zmk.uf2 firmware/zmk_cradio_left_nice_nano_v2.uf2
# - cp zmk/app/build/cradio_right/zephyr/zmk.uf2 firmware/zmk_cradio_right_nice_nano_v2.uf2
save_firmware_files() {
    [ ! -d "$FIRMWARE" ] && mkdir -p "$FIRMWARE"
    log "Saving firmware files to '$FIRMWARE'..."
    for shield in $SHIELDS; do
        cp -upv \
            "$ZMKDIR/app/build/$shield/zephyr/zmk.uf2" \
            "$FIRMWARE/zmk_${shield}_${MCU}.uf2"
    done
    ls -lR "$FIRMWARE"
}


# Flash the correct firmware to a device identified by usb serial number
# The device must be in bootloader mode and found at /dev/disk/by-id/usb-<serial>
# Relies on the device being automatically mounted by the system
flash_device() {
    serial=$1  # The usb serial number of the device
    device=$(readlink -e "/dev/disk/by-id/usb-$serial" || true)  # eg. /dev/sda
    if [ -z "$device" ]; then
        return 1  # Device is not connected
    fi
    # Check if the device is mounted
    mount=$(findmnt -n -o TARGET --source $device 2>/dev/null || true)
    if [ -z "$mount" ]; then
        return 1
    fi
    # Find the right firmware file for this device
    filename=${devices[$serial]}
    if [ ! -f "$FIRMWARE/$filename" ]; then
        warn "Error: $FIRMWARE/$filename not found." && exit 1
    fi
    echo
    log "Found device $serial at $device mounted at $mount"
    # Copy the firmware to the device
    log "Copying $FIRMWARE/$filename to device..."
    cp -v $FIRMWARE/$filename $mount/$filename
    # The device will automatically reboot after the new firmware is copied.
    log "Firmware flashed successfully."
    log "Your keyboard is now automatically rebooting into your new firmware."
    return 0
}


# Wait for the device to be mounted and flash the firmware
flash_device_wait() {
    if [ -z "${!devices[*]}" ]; then
        warn "Error: No devices provided." && exit 1
    fi
    log "Connect your keyboard to the computer and activate bootloader mode."
    log "Searching for devices to flash firmware..."
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
    warn "Timeout waiting for devices to flash firmware."
    exit 1  # No devices found
}


if [ -d "$WORKSPACE" ]; then
    # The script is running in the devcontainer: just run the firmware build
    build_firmware_in_devcontainer
else
    # The script is running on the host computer to setup the build
    # environment, before running the build function
    # in the devcontainer.

    # Check that the zmk-config directory exists
    if [ ! -d "$CONFIGDIR/config" ]; then
        warn "Error: '$CONFIGDIR/config' directory not found." 1>&2
        log "Run '$0' in your zmk config base directory." 1>&2
        log "See https://zmk.dev/docs/user-setup to create a new config." 1>&2
        exit 1
    fi
    cd $CONFIGDIR

    [ "$install" = "yes" ] && install_zmk_devcontainer

    [ "$update" = "yes" ] && update_zmk_software

    # Run this script again inside the devcontainer
    run_devcontainer "$MYCONFIG/build.sh" $@

    save_firmware_files

    [ "$flash" = "yes" ] && flash_device_wait
fi
