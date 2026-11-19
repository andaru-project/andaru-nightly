#!/bin/sh
# Prints a nightly's version: <next version>-nightly.<YYYYMMDD>.<N>.g<7-character commit>.
#   nightly-version.sh RELEASE_TAGS NIGHTLY_TAGS DATE COMMIT
# RELEASE_TAGS lists Andaru's tags, one per line: v1.2.3, v1.2.3-a.N, -b.N, -rc.N, and the older -rcN. NIGHTLY_TAGS
# lists the nightly image's tags. The next version is the highest tagged version's core, one patch up once that core
# is released, so a nightly sorts above every release before it. A nightly of a core that is still in prerelease sorts
# below that core's betas and candidates ("nightly" > "b" but < "rc"); nightlies are their own channel, never ordered
# against releases by an updater. N is one above the highest N that day's nightlies of that version have.
# The g keeps the commit an alphanumeric identifier: semver forbids a numeric one with a leading zero.
set -eu

releases=${1:?release tags} nightlies=${2:?nightly tags} date=${3:?date} commit=${4:?commit}
[ -r "$releases" ] && [ -r "$nightlies" ] || { echo "nightly-version.sh: cannot read the tag lists" >&2; exit 1; }
# case, not grep: grep would accept a value with a second line.
case $date in [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;; *) echo "nightly-version.sh: bad date" >&2; exit 1 ;; esac
case ${#commit}:$commit in [7-9]:* | [1-3][0-9]:* | 40:*) ;; *) echo "nightly-version.sh: bad commit" >&2; exit 1 ;; esac
case $commit in *[!0-9a-f]*) echo "nightly-version.sh: bad commit" >&2; exit 1 ;; esac

# At most nine digits a number: arithmetic on more would overflow, and no real version needs them.
n='(0|[1-9][0-9]{0,8})'
core=$(grep -Ex "v$n\.$n\.$n(-(a\.|b\.|rc\.?)[1-9][0-9]*)?" "$releases" | sed -E 's/^v//; s/-.*//' |
	sort -t. -k1,1n -k2,2n -k3,3n | tail -n 1)
if [ -z "$core" ]; then
	next=0.0.1
elif grep -qx "v$core" "$releases"; then
	next=${core%.*}.$((${core##*.} + 1))
else
	next=$core
fi
prefix="$next-nightly.$date."
quoted=$(printf '%s' "$prefix" | sed 's/\./\\./g')
# Only published nightlies count, not their architecture or staging tags.
last=$(grep -Ex -- "${quoted}[1-9][0-9]*\.g[0-9a-f]{7}" "$nightlies" | sed "s/^${quoted}//; s/\..*//" | sort -n | tail -n 1)
printf '%s%d.g%.7s\n' "$prefix" "$((${last:-0} + 1))" "$commit"
