#!/bin/sh
# Prints a nightly's version: <next version>-nightly.<YYYYMMDD>.<N>.g<7-character commit>.
#   nightly-version.sh RELEASE_TAGS NIGHTLY_TAGS DATE COMMIT
# RELEASE_TAGS lists Andaru's tags (v1.2.3, v1.2.3-a.N, -b.N, -rc.N), one per line; NIGHTLY_TAGS lists the
# nightly image's tags. The next version is the highest tagged version's core, one patch up once that core is
# released, so a nightly sorts above every release before it. N counts that day's nightlies of that version from 1.
# The g keeps the commit an alphanumeric identifier: semver forbids a numeric one with a leading zero.
set -eu

releases=${1:?release tags} nightlies=${2:?nightly tags} date=${3:?date} commit=${4:?commit}
printf '%s\n' "$date" | grep -Eqx '[0-9]{8}' || { echo "nightly-version.sh: bad date $date" >&2; exit 1; }
printf '%s\n' "$commit" | grep -Eqx '[0-9a-f]{7,40}' || { echo "nightly-version.sh: bad commit $commit" >&2; exit 1; }

n='(0|[1-9][0-9]*)'
cores=$(grep -Ex "v$n\.$n\.$n(-(a|b|rc)\.[1-9][0-9]*)?" "$releases" | sed -E 's/^v//; s/-.*//' | sort -t. -k1,1n -k2,2n -k3,3n -u || true)
core=$(printf '%s\n' "$cores" | tail -n 1)
if [ -z "$core" ]; then
	next=0.0.1
elif grep -qx "v$core" "$releases"; then
	next=$(printf '%s\n' "$core" | awk -F. '{ printf "%d.%d.%d", $1, $2, $3 + 1 }')
else
	next=$core
fi
prefix="$next-nightly.$date."
# Only published nightlies count, not their architecture or staging tags.
count=$(grep -cEx -- "$(printf '%s' "$prefix" | sed 's/\./\\./g')[1-9][0-9]*\.g[0-9a-f]{7}" "$nightlies" || true)
printf '%s%d.g%.7s\n' "$prefix" "$((count + 1))" "$commit"
