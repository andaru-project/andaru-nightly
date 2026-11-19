#!/bin/sh
# Prints the newest published nightly in NIGHTLY_TAGS (one tag per line), or nothing when there is none.
#   nightly-newest.sh NIGHTLY_TAGS
# Newest is the latest date, then the highest N. Nightlies are v<YYYY-MM-DD>.<N>.<7-character commit>.
set -eu

tags=${1:?nightly tags}
if [ ! -r "$tags" ]; then
	echo "nightly-newest.sh: cannot read $tags" >&2
	exit 1
fi
# grep finds nothing when no nightly was ever published; that is an answer, not a failure.
{ grep -Ex 'v[0-9]{4}-[0-9]{2}-[0-9]{2}\.[1-9][0-9]{0,8}\.[0-9a-f]{7}' "$tags" || :; } |
	sort -t. -k1,1 -k2,2n | tail -n 1
