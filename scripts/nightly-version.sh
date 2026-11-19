#!/bin/sh
# Prints a nightly's version: <next version>-nightly.<YYYYMMDD>.<N>.g<7-character commit>.
#   nightly-version.sh RELEASE_TAGS NIGHTLY_TAGS DATE COMMIT
# RELEASE_TAGS lists Andaru's tags, one per line: v1.2.3, v1.2.3-a.N, -b.N, -rc.N, and the older -rcN. NIGHTLY_TAGS
# lists this repository's tags, one per published nightly. The next version is the highest tagged version's core, one patch up once that core
# is released, so a nightly sorts above every release before it. A nightly of a core still in prerelease sorts above
# that core's alphas and betas but below its candidates ("a" < "b" < "nightly" < "rc"); nightlies are their own
# channel, never ordered against releases by an updater. N is one above the highest N that day's nightlies of that
# version have.
# The g keeps the commit an alphanumeric identifier: semver forbids a numeric one with a leading zero.
set -eu

releases=${1:?release tags} nightlies=${2:?nightly tags} date=${3:?date} commit=${4:?commit}
die() {
	echo "nightly-version.sh: $*" >&2
	exit 1
}
if [ ! -r "$releases" ] || [ ! -r "$nightlies" ]; then die "cannot read the tag lists"; fi
# case, not grep: grep would accept a value with a second line.
case $date in [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;; *) die "bad date" ;; esac
case $commit in *[!0-9a-f]*) die "bad commit" ;; esac
if [ "${#commit}" -lt 7 ] || [ "${#commit}" -gt 40 ]; then die "bad commit"; fi

# At most nine digits a number: arithmetic on more would overflow, and no real version needs them.
n='(0|[1-9][0-9]{0,8})'
core=$(grep -Ex "v$n\.$n\.$n(-(a\.|b\.|rc\.?)[1-9][0-9]*)?" "$releases" | sed -E 's/^v//; s/-.*//' |
	sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1)
if [ -z "$core" ]; then
	next=0.0.1
elif grep -qxF "v$core" "$releases"; then
	next=${core%.*}.$((${core##*.} + 1))
else
	next=$core
fi
prefix="$next-nightly.$date."
quoted=$(printf '%s' "$prefix" | sed 's/\./\\./g')
# Only whole nightly names count.
last=$(grep -Ex -- "${quoted}[1-9][0-9]{0,8}\.g[0-9a-f]{7}" "$nightlies" | cut -d. -f5 | sort -n | tail -n 1)
printf '%s%d.g%.7s\n' "$prefix" "$((${last:-0} + 1))" "$commit"
