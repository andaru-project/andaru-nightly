#!/bin/sh
# Prints a nightly's version: v<YYYY-MM-DD>.<N>.<7-character commit>, for example v2026-11-19.2.0123abc.
#   nightly-version.sh NIGHTLY_TAGS DATE COMMIT
# NIGHTLY_TAGS lists this repository's tags, one per published nightly. DATE is the UTC date, YYYY-MM-DD. N is one
# above the highest N that day's nightlies have, so a deleted nightly never lets two share one.
set -eu

die() {
	echo "nightly-version.sh: $*" >&2
	exit 1
}
tags=${1:?nightly tags} date=${2:?date} commit=${3:?commit}
if [ ! -r "$tags" ]; then die "cannot read $tags"; fi
# case, not grep: grep would accept a value with a second line.
case $date in [0-9][0-9][0-9][0-9]-0[1-9]-?? | [0-9][0-9][0-9][0-9]-1[0-2]-??) ;; *) die "bad date" ;; esac
case $date in *-0[1-9] | *-[12][0-9] | *-3[01]) ;; *) die "bad date" ;; esac
case $commit in *[!0-9a-f]*) die "bad commit" ;; esac
if [ "${#commit}" -lt 7 ] || [ "${#commit}" -gt 40 ]; then die "bad commit"; fi

# Only whole nightly names of that day count. grep finding none is an answer, not a failure.
last=$({ grep -Ex "v$date\.[1-9][0-9]{0,8}\.[0-9a-f]{7}" "$tags" || :; } | cut -d. -f2 | sort -n | tail -n 1)
printf 'v%s.%d.%.7s\n' "$date" "$((${last:-0} + 1))" "$commit"
