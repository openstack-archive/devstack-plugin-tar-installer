===============================
devstack-plugin-tar-installer
===============================

By default DevStack installs all the software needed to run OpenStack from the
OS' repository, however sometimes there is a need to test OpenStack against
the latest (or custom) versions of specific software programs (e.g., qemu and
libvirt).

* Free software: Apache license
* Documentation: http://docs.openstack.org/developer/devstack-plugin-tar-installer
* Source: http://git.openstack.org/cgit/openstack/devstack-plugin-tar-installer
* Bugs: http://bugs.launchpad.net/devstack-plugin-tar-installer

Virtual Open Systems devstack-plugin-tar-installer plugin
=========================================================

By default DevStack installs QEMU and libvirt from the OS' repository,
however sometimes there is a need to test OpenStack against the latest
version of these two programs.
The definition of the variables *LIBVIRT_VERSION* and *QEMU_VERSION*
in the devstack **local.conf** file will result in the compilation and
installation of libvirt and QEMU. E.g.,:

        QEMU_VERSION=2.1.5
        LIBVIRT_VERSION=1.2.9

The sources of the version pointed by these variables are downloaded
from the official libvirt and QEMU project websites, if not otherwise
specified by the variables *LIBVIRT_URL_BASE* and *QEMU_URL_BASE*
in the same file. E.g.,:

        LIBVIRT_URL_BASE="http://www.virtualopensystems.com/sources/"
        QEMU_URL_BASE="http://www.virtualopensystems.com/sources/" 


If none of these variables will be defined, the standard plugin values,
will be taken from the file **devstack/settings**.

*Note: OpenStack and its components (e.g. Nova) are mainly tested with the
repository version of both libvirt and QEMU.
Thus be aware that the use of a different version may lead to an unstable
or not working OpenStack environment.*

Enabling the plugin
===================

1 Download devstack::

     git clone https://git.openstack.org/openstack-dev/devstack

2. Add devstack-plugin-tar-installer external repository in the local.conf file::

     > cat local.conf
     [[local|localrc]]
     enable_plugin devstack-tar-installer-plugin git@git.virtualopensystems.com:sesame/devstack-qemu-libvirt-from-tar-plugin.git

3. Configure the plugin by definig the variables as described above::
     QEMU_VERSION=2.1.5
     LIBVIRT_VERSION=1.2.9

3. run ``stack.sh``

References
==========

Blueprint:
https://blueprints.launchpad.net/devstack/+spec/devstack-tar-installer-plugin

Old spec:
https://review.openstack.org/#/c/108714/

Features
--------

* Installs QEMU and/or libvirt from tar

Acknowledgements
---------------------
This work has been supported by the FP7 TRESCCA and H2020 SESAME projects,
under the grant numbers 318036 and 671596.


