#!/usr/bin/env bash
#
# Copyright (c) 2015-2016 Virtual Open Systems, SAS.
#
# Michele Paolino <m.paolino@virtualopensystems.com>
# Virtual Open Systems devstack-plugin-tar-installer
#
# build_qemu.sh - Install QEMU and its dependencies.
#

# Echo commands
set -o xtrace

# Exit on error to stop unexpected errors
set -o errexit

function usage {
    echo "$0 - Install QEMU from tar releases."
    echo ""
    echo "Usage: $0 <QEMU_VERSION>"
    echo ""
    echo "Example: $0 2.5.0"
}

# Keep track of the current directory
TOOLS_DIR=${TOOLS_DIR:-$(cd $(dirname "$0") && pwd)}
TOP_DIR=${TOP_DIR:-$(cd $TOOLS_DIR/..; pwd)}

# Import common functions and variables
source $TOOLS_DIR/functions
source $TOOLS_DIR/stackrc

# Find the cache dir
SOURCE_FILE=$TOP_DIR/files

# Reclone/configure qemu each time the script is run
RECLONE=$(trueorfalse False $RECLONE)

# If this value is not user defined, use the official link
QEMU_URL_BASE=${QEMU_URL_BASE:-http://wiki.qemu-project.org/download/}

# Getting program version from the bash argument
QEMU_VERSION=$1
# QEMU is released as .tar.bz2
QEMU_FILE=qemu-"$QEMU_VERSION".tar.bz2
QEMU_DIR="$DEST"/qemu-"$QEMU_VERSION"
QEMU_URL="$QEMU_URL_BASE""$QEMU_FILE"

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

if [[ "$1" == remove ]]; then
    echo "Removing QEMU $QEMU_VERSION from the system"
    rm "$QEMU_DIR"/"$QEMU_FILE"
    cd "$DEST"/"$QEMU_DIR"
    sudo make uninstall
    cd ..
    rm -r "$QEMU_DIR"
else
    echo "Installing QEMU $QEMU_VERSION"
    echo "Installing QEMU build dependencies"
    if is_ubuntu; then
        sudo apt-get build-dep qemu -y
        if [[ ${DISTRO} =~ (precise) ]]; then
            sudo apt-get install dh-autoreconf -y
        fi
    elif is_fedora || is_suse; then
        install_package yum-utils
        sudo dnf builddep qemu -y
    fi

    echo "Downloading the QEMU sources"
    wget -N "$QEMU_URL" -P "$SOURCE_FILE"

    if [[ ! -d "$QEMU_DIR" || "$RECLONE" = "True" ]]; then
        echo "Configuring QEMU"
        tar -xf "$SOURCE_FILE"/"$QEMU_FILE" -C "$DEST"
        cd "$QEMU_DIR"
        ./configure --target-list=`uname -m`-softmmu --prefix=/usr
    fi

    echo "Compiling QEMU"
    cd "$QEMU_DIR"
    make -j"$(nproc)"
    sudo make install
fi

cd "$TOOLS_DIR"
