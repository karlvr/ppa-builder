#!/bin/bash -eu

SOURCE_DIST=oracular

# Get source from unstable so we get the latest available source
echo "deb-src http://archive.ubuntu.com/ubuntu/ $SOURCE_DIST universe restricted" > "/etc/apt/sources.list.d/ubuntu-unstable-sources.list"
apt-get update

# Make available modern meson, required by libvips
add-apt-repository -y ppa:ubuntu-support-team/meson

mkdir -p /tmp/build-vips && cd /tmp/build-vips
apt-get -q -y source vips

SRCDIR=$(find . -mindepth 1 -maxdepth 1 -type d)
cd "$SRCDIR"

if [ "$(lsb_release -cs)" == "focal" ]; then
	# Correct debhelper-compat for focal
	sed --in-place 's/debhelper-compat (= 13)/debhelper-compat (= 12)/' debian/control

	# Remove unsupported dependencies
	# Note: we build and install libcgif-dev ourselves in build-cgif.sh
	sed --in-place 's/libjxl-dev,//' debian/control
	sed --in-place 's/1.22.5/1.19.7/' debian/control # dpkg-dev
	sed --in-place 's/gobject-introspection-bin,/gobject-introspection,/' debian/control
	sed --in-place 's/gir1.2-gobject-2.0-dev,//' debian/control
	sed --in-place 's/libspng-dev,//' debian/control
	sed --in-place 's/libhwy-dev,//' debian/control
	sed --in-place 's/--timeout-multiplier=10//' debian/rules
elif [ "$(lsb_release -cs)" == "jammy" ]; then
	sed --in-place 's/libjxl-dev,//' debian/control
	sed --in-place 's/1.22.5/1.21.1/' debian/control # dpkg-dev
	sed --in-place 's/gobject-introspection-bin,/gobject-introspection,/' debian/control
	sed --in-place 's/gir1.2-gobject-2.0-dev,//' debian/control
	sed --in-place 's/libspng-dev,//' debian/control
fi

apt-get build-dep -y .
dch --local "~$(lsb_release -sc)$(date +%Y%m%d%H%M)" --distribution $(lsb_release -sc) 'New upstream release backported.'

# Test that we can actually build it, it's easier to do that locally than wait for launchpad to do it
# even though it makes this take longer
debuild

# Build the source
debuild -S -sd

cd ..
dput ppa:$PPANAME/vips $(find . -type f -name '*source.changes')
