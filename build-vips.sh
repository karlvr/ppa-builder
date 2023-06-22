#!/bin/bash -eu

# Get source from unstable so we get the latest available source
echo "deb-src http://archive.ubuntu.com/ubuntu/ mantic universe restricted" > "/etc/apt/sources.list.d/ubuntu-unstable-sources.list"
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
elif [ "$(lsb_release -cs)" == "jammy" ]; then
	sed --in-place 's/libjxl-dev,//' debian/control
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
