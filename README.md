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

### libvips

The `build-vips.sh` script builds the latest version of [libvips](https://www.libvips.org/) that's available (in the Ubuntu
distribution identified at the top of the script in the `SOURCE_DIST` variable) for Ubuntu 20.04 and 22.04.

You can check the versions by distribution at https://launchpad.net/ubuntu/+source/vips.

## Troubleshooting

The builds don't always go smoothly. You'll see in each build script that I've had to make adjustments to the build scripts in
order to have them succeed on the older distribution.

To troubleshoot you need to be interactive in the docker container. Use `make run:22.04` etc to run the container interactively.
Inside the container, run `/build-init.sh` to setup the gpg daemon and then you can manually run whichever `/build-*.sh`
script you need to troubleshoot. The build output is created in `/tmp/build-*`.

If you run builds manually, such as by manually issuing the commands in the build scripts, remember to import the environment
variables so that signing works.

```shell
source /env.sh
```

Typically builds fail with dependencies that aren't available in the backported system, in which case I've edited the `debian/control`
file to change them and then run `apt-get build-dep -y .` in the source folder (e.g. `/tmp/build-vips/vips-8.15.2`). Finally build the
package to check that it will build. All of these commands are in the `build-*.sh` script.

It can also help to compare to the source for the package in the current distribution. Disable the apt configuration for the
unstable Ubuntu distribution in `/etc/apt/sources.list.d/ubuntu-unstable-sources.list` and then repeat the `apt-get -q -y source ...`
step from the build script in a new directory.

## Updating

Before building, check the name of the latest Ubuntu distribution at http://archive.ubuntu.com/ubuntu/dists/ and update
the `build-*.sh` scripts to use that distribution in the `SOURCE_DIST` variable. This is how we get the latest available
versions to backport.
