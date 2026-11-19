#!/bin/sh
# Prints the newest published nightly in NIGHTLY_TAGS (one tag per line), or nothing when there is none; with -c, only
# the 7-character commit it was built from.
#   nightly-newest.sh [-c] NIGHTLY_TAGS
# Newest is the latest date, then the highest N. Nightlies are v<YYYY-MM-DD>.<N>.<7-character commit>.
set -eu

commit=false
if [ "${1-}" = -c ]; then
	commit=true
	shift
fi
tags=${1:?nightly tags}
if [ ! -r "$tags" ]; then
	echo "nightly-newest.sh: cannot read $tags" >&2
	exit 1
fi
# grep finds nothing when no nightly was ever published; that is an answer, not a failure.
# C collation: the dates compare byte for byte, whatever the runner's locale.
newest=$({ grep -Ex 'v[0-9]{4}-[0-9]{2}-[0-9]{2}\.[1-9][0-9]{0,8}\.[0-9a-f]{7}' "$tags" || :; } |
	LC_ALL=C sort -t. -k1,1 -k2,2n | tail -n 1)
if [ "$commit" = true ]; then
	printf '%s\n' "${newest##*.}"
else
	printf '%s\n' "$newest"
fi
