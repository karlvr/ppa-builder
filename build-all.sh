#!/bin/bash -eux
# Run all of the build-*.sh scripts

source /env.sh

cat > $HOME/.gnupg/gpg.conf <<EOF
use-agent
EOF
cat > $HOME/.gnupg/gpg-agent.conf <<EOF
pinentry-timeout 0
pinentry-program /usr/bin/pinentry-curses
default-cache-ttl 31536000
max-cache-ttl     31536000
EOF

gpg-agent --daemon

# Prompt user for their password and add it to the agent
echo test | gpg -e -a -r $DEBEMAIL --trust-model always | gpg -d
# A second time to prove that it has been added to the agent
echo test | gpg -e -a -r $DEBEMAIL --trust-model always | gpg -d

trap 'status=$? ; if [ $status != 0 ]; then echo ; echo "Script exited with status $status. docker exec into the container to debug and then press return to exit and stop the container." ; read ; fi' EXIT

for s in /build-*.sh ; do
	if [ "$s" != "/build-all.sh" ]; then
		"$s"
	fi
done
