#!/usr/bin/env bash
#
# Copyright (c) 2015-2016 Virtual Open Systems, SAS.
#
# Michele Paolino <m.paolino@virtualopensystems.com>
# Virtual Open Systems devstack-plugin-tar-installer
#
# build_libvirt.sh - Install libvirt and its dependencies.
#


# Echo commands
set -o xtrace

# Exit on error to stop unexpected errors
set -o errexit

function usage {
    echo "$0 - Install libvirt from tar releases."
    echo ""
    echo "To install a specific libvirt version run: $0 <LIBVIRT_VERSION>"
    echo "Example: $0 1.3.3"
    echo ""
    echo "To install remove it from the system run: $0 remove"
    echo "Example: $0 remove"
}

if [[ -z "$1" ]]; then
    usage
    exit 1
fi

# Keep track of the current directory
TOOLS_DIR=${TOOLS_DIR:-$(cd $(dirname "$0") && pwd)}
TOP_DIR=${TOP_DIR:-$(cd $TOOLS_DIR/..; pwd)}

# Import common functions and variables
source $TOOLS_DIR/functions
source $TOOLS_DIR/stackrc

# Find the cache dir
SOURCE_FILE=$TOP_DIR/files

# Reclone/configure libvirt each time the script is run
RECLONE=$(trueorfalse False $RECLONE)

# If this value is not user defined, use the official link
LIBVIRT_URL_BASE=${LIBVIRT_URL_BASE:-https://libvirt.org/sources/}

# Getting program version from the bash argument
LIBVIRT_VERSION=$1

# libvirt is released as .tar.xz below version 2.0.0 (previously using .tar.gz)
VERSION=`echo "$LIBVIRT_VERSION" | tr -d "."`

if [[ "$VERSION" -gt 199 ]]; then
    LIBVIRT_FILE=libvirt-"$LIBVIRT_VERSION".tar.xz
else
    LIBVIRT_FILE=libvirt-"$LIBVIRT_VERSION".tar.gz
fi

LIBVIRT_DIR="$DEST"/libvirt-"$LIBVIRT_VERSION"
LIBVIRT_URL="$LIBVIRT_URL_BASE""$LIBVIRT_FILE"

# libvirtd debug variables
NOW=`date +"%F-%T"`
WHERE=`hostname`
EPOCH=`date +%s`


if [[ "$1" == remove ]]; then
    echo "Removing libvirt $LIBVIRT_VERSION from the system"
    rm "$SOURCE_FILE"/"$LIBVIRT_FILE"
    cd "$LIBVIRT_DIR"
    sudo make uninstall
    cd ..
    rm -r "$LIBVIRT_DIR"
    cd "$TOOLS_DIR"
    exit
fi

echo "Installing libvirt $LIBVIRT_VERSION"
echo "Installing libvirt build dependencies"
if is_ubuntu; then
    sudo apt-get build-dep libvirt -y
    install_package python-guestfs
        if [[ ${DISTRO} =~ (precise) ]]; then
            sudo apt-get install libnl-route-3-dev -y
        fi
elif is_fedora || is_suse; then
    install_package yum-utils
    sudo dnf builddep libvirt -y
    install_package python-libguestfs
fi

echo "Downloading the libvirt sources"
wget -N "$LIBVIRT_URL" -P "$SOURCE_FILE"

if [[ ! -d "$LIBVIRT_DIR" || "$RECLONE" = "True" ]]; then
    echo "Configuring libvirt"
    tar -xf "$SOURCE_FILE"/"$LIBVIRT_FILE" -C "$DEST"
    cd "$LIBVIRT_DIR"
    ./configure --prefix=/ --exec-prefix=/usr \
        --with-packager="OpenStack DevStack $WHERE $NOW" \
        --with-packager_version="$EPOCH"
fi

# Polkit configurations
if is_ubuntu; then
    cat <<EOF | sudo tee /etc/polkit-1/localauthority/50-local.d/50-libvirt-remote-access.pkla
[libvirt Management Access]
Identity=unix-user:$STACK_USER
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes
EOF
fi

echo "Compiling libvirt"
cd "$LIBVIRT_DIR"
make -j"$(nproc)"
sudo make install

cd "$TOOLS_DIR"
