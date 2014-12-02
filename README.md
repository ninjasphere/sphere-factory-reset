NAME
=====
sphere-factory-reset - builds factory reset components

DESCRIPTION
===========
This package build a debian package containing all the NAND image components required to support the factory reset process. These are
extracted from the various source projects that contain the components.

The contents of this package are fed into the yocto NAND image build process using manual methods.

RESERVED NAMESPACE
==================
This package reserves /opt/ninjablocks/factory-reset for its own purposes both in the NAND and SDCARD images.

