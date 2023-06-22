# PPA Builder

This is a collection of scripts to build PPAs using Docker.

## Setup

Create a file `env.sh` with the following contents:

```
export DEBFULLNAME="..."
export DEBEMAIL="..."
export PPANAME="..."
```

Where these are the values required for code-signing packages and uploading to the appropriate
PPA on [launchpad.net](https://launchpad.net).

Note that the `PPANAME` does not include the part after the `/`, as that is specified by the build
scripts.

## Building

To build images and run all of the `build-*.sh` scripts:

```shell
make
```

## libvips

The `build-vips.sh` script builds the latest version of [libvips](https://www.libvips.org/) that's available in Ubuntu unstable
for Ubuntu 20.04 and 22.04.
