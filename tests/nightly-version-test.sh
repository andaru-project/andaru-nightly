#!/bin/sh
# Checks scripts/nightly-version.sh: run from the repository root.
set -eu

dir=$(mktemp -d)
trap 'rm -rf -- "$dir"' EXIT
failed=0
check() {
	want=$1
	shift
	got=$(sh scripts/nightly-version.sh "$dir/tags" "$@" 2>/dev/null) || got="(refused)"
	if [ "$got" != "$want" ]; then
		echo "FAIL: $* gave $got, want $want" >&2
		failed=1
	fi
}
tags() { printf '%s\n' "$@" >"$dir/tags"; }

# The first of the day, from a full commit.
tags
check v2026-11-19.1.0123abc 2026-11-19 0123abc89abcdef0123456789abcdef01234567
# Another day's nightlies do not count; that day's highest N does, as a number, even after a deletion.
tags v2026-11-18.7.aaaaaaa v2026-11-19.2.bbbbbbb v2026-11-19.10.ccccccc
check v2026-11-19.11.abcdef0 2026-11-19 abcdef0
tags v2026-11-19.2.bbbbbbb
check v2026-11-19.3.abcdef0 2026-11-19 abcdef0
# Only whole nightly names count.
tags v2026-11-19.5.bbbbbbb-x xv2026-11-19.6.bbbbbbb v2026-11-19.0.bbbbbbb v2026-11-19.7.bbbbbb \
	v2026-11-19.99999999999.bbbbbbb nightly README
check v2026-11-19.1.abcdef0 2026-11-19 abcdef0
check "(refused)" 20261119 abcdef0
check "(refused)" 2026-11-19x abcdef0
check "(refused)" 2026-21-19 abcdef0
check "(refused)" 2026-13-19 abcdef0
check "(refused)" 2026-00-19 abcdef0
check "(refused)" 2026-11-00 abcdef0
check "(refused)" 2026-11-32 abcdef0
check v2026-12-31.1.abcdef0 2026-12-31 abcdef0
check "(refused)" 2026-11-19 abcdef
check "(refused)" 2026-11-19 0123456789abcdef0123456789abcdef012345678
check "(refused)" 2026-11-19 ABCDEF0
check "(refused)" 2026-11-19 "$(printf 'abcdef0\n1234567')"
rm "$dir/tags"
check "(refused)" 2026-11-19 abcdef0
exit "$failed"
