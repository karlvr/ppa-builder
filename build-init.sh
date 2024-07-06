#!/bin/bash -eux
# Initialise the build environment

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
