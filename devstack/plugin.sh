# Copyright (c) 2016 Virtual Open Systems, SAS.
#
# Michele Paolino <m.paolino@virtualopensystems.com>
# Virtual Open Systems devstack plugin for installing qemu and libvirt
# from tar releases - plugin.sh 

env | sort

# Save trace setting
XTRACE=$(set +o | grep xtrace)
set -o xtrace

# Set up default directories
VOSYS_PLUGIN_DIR=$DEST/devstack-tar_installer_plugin/devstack


function install_tar_installer_plugin {

    if [[ -n "$QEMU_VERSION" ]]; then
	source $VOSYS_PLUGIN_DIR/build_qemu.sh "$QEMU_VERSION"
    fi
    if [[ -n "$LIBVIRT_VERSION" ]]; then
	source $VOSYS_PLUGIN_DIR/build_libvirt.sh "$LIBVIRT_VERSION"
    fi
}

function remove_tar_installer_plugin {

    if [[ -n "$QEMU_VERSION" ]]; then
        source $VOSYS_PLUGIN_DIR/build_qemu.sh remove
    fi
    if [[ -n "$LIBVIRT_VERSION" ]]; then
        source $VOSYS_PLUGIN_DIR/build_libvirt.sh remove
    fi

}


# check for service enabled
if is_service_enabled devstack-tar_installer_plugin; then

    if [[ "$1" == "stack" && "$2" == "pre-install" ]]; then
        # Configure after the other layer 1 and 2 services have been configured
        # no-op
        :

    elif [[ "$1" == "stack" && "$2" == "install" ]]; then
        # Perform installation of service source
        echo_summary "install phase - Virtual Open Systems plugin for installing \
		qemu/libvirt from tar releases"
	install_tar_installer_plugin

    elif [[ "$1" == "stack" && "$2" == "post-config" ]]; then
        # Configure after the other layer 1 and 2 services have been configured
        # no-op
        :

    elif [[ "$1" == "stack" && "$2" == "extra" ]]; then
        # Initialize and start the tar_installer_plugin service
        # no-op
        :
    fi

    if [[ "$1" == "unstack" ]]; then
        # Shut down tar_installer_plugin services
        # no-op
        :
    fi

    if [[ "$1" == "clean" ]]; then
        # Remove state and transient data
        # Remember clean.sh first calls unstack.sh
        echo_summary "clean phase - Virtual Open Systems plugin for installing \
		qemu/libvirt from tar releases"
	remove_tar_installer_plugin
    fi
fi
