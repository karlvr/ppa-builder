#!/bin/bash -eux
# Run all of the build-*.sh scripts

/build-init.sh

trap 'status=$? ; if [ $status != 0 ]; then echo ; echo "Script exited with status $status. docker exec into the container to debug and then press return to exit and stop the container." ; read ; fi' EXIT

for s in /build-*.sh ; do
	if [ "$s" != "/build-all.sh" -a "$s" != "/build-init.sh" ]; then
		"$s"
	fi
done
