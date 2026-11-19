#!/bin/sh
# Prints the newest published nightly in NIGHTLY_TAGS (one tag per line), or nothing when there is none.
#   nightly-newest.sh NIGHTLY_TAGS
# Newest is the latest date, then the highest version core, then the highest N: N starts again at 1 for each core.
set -eu

tags=${1:?nightly tags}
if [ ! -r "$tags" ]; then
	echo "nightly-newest.sh: cannot read $tags" >&2
	exit 1
fi
n='(0|[1-9][0-9]{0,8})'
# grep finds nothing when no nightly was ever published; that is an answer, not a failure.
{ grep -Ex "$n\.$n\.$n-nightly\.[0-9]{8}\.[1-9][0-9]{0,8}\.g[0-9a-f]{7}" "$tags" || :; } |
	sort -t. -k4,4n -k1,1n -k2,2n -k3,3n -k5,5n | tail -n 1
