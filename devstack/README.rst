========================================================
 Enabling qemu and libvirt tar releases in Devstack
========================================================

1. Download Virtual Open Systems DevStack plugin

2. Add Virtual Open Systems' external repository in the local.conf file::

     > cat local.conf
     [[local|localrc]]
     enable_plugin devstack-tar-installer-plugin https://git.virtualopensystems.com/dev/devstack-tar-installer-plugin

3. run ``stack.sh``

