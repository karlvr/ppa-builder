#!/bin/bash -eu

source /env.sh

SOURCE_DIST=questing

# Get source from unstable so we get the latest available source
echo "deb-src http://archive.ubuntu.com/ubuntu/ $SOURCE_DIST universe restricted" > "/etc/apt/sources.list.d/ubuntu-unstable-sources.list"

# Make available modern meson, required by libvips
if [ "$(lsb_release -cs)" != "noble" ]; then
	add-apt-repository -y ppa:ubuntu-support-team/meson
fi

apt-get update

mkdir -p /tmp/build-cgif && cd /tmp/build-cgif
apt-get -q -y source cgif

SRCDIR=$(find . -mindepth 1 -maxdepth 1 -type d)
cd "$SRCDIR"

if [ "$(lsb_release -cs)" == "focal" ]; then
	# Correct debhelper-compat for focal
	sed --in-place 's/debhelper-compat (= 13)/debhelper-compat (= 12)/' debian/control

	# The DEB_HOST_MULTIARCH variable doesn't appear to work (files not found)
	sed --in-place -e 's/${DEB_HOST_MULTIARCH}/\*/' debian/*.install
elif [ "$(lsb_release -cs)" == "jammy" ]; then
	true
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

# Install so we can build vips with it
dpkg --install *.deb
