#!/bin/sh
# Checks scripts/nightly-newest.sh: run from the repository root.
set -eu

dir=$(mktemp -d)
trap 'rm -rf -- "$dir"' EXIT
failed=0
check() {
	want=$1
	shift
	printf '%s\n' "$@" >"$dir/tags"
	got=$(sh scripts/nightly-newest.sh "$dir/tags" 2>/dev/null) || got="(refused)"
	if [ "$got" != "$want" ]; then
		echo "FAIL: $* gave $got, want $want" >&2
		failed=1
	fi
}

# None yet: nothing, and success.
check ""
check "" README v1.2.3
# The latest date wins, then N as a number.
check v2026-11-19.10.ccccccc v2026-11-18.12.aaaaaaa v2026-11-19.2.bbbbbbb v2026-11-19.10.ccccccc
check v2027-01-02.1.ddddddd v2026-12-31.9.aaaaaaa v2027-01-02.1.ddddddd
# Only whole nightly names count.
check v2026-11-19.1.aaaaaaa v2026-11-19.1.aaaaaaa xv2099-12-31.1.abcdef0 v2099-12-31.1.abcdef0-amd64 \
	staging-v2099-12-31.1.abcdef0 v2099-12-31.0.abcdef0
# -c gives the newest nightly's commit, which the workflow compares with main's; nothing when there is none.
printf '%s\n' v2026-11-18.12.aaaaaaa v2026-11-19.2.0123abc >"$dir/tags"
if [ "$(sh scripts/nightly-newest.sh -c "$dir/tags")" != 0123abc ]; then
	echo "FAIL: -c did not give the newest nightly's commit" >&2
	failed=1
fi
: >"$dir/tags"
# Not even an empty line: no output at all.
if [ "$({ sh scripts/nightly-newest.sh -c "$dir/tags"; sh scripts/nightly-newest.sh "$dir/tags"; } | wc -c)" -ne 0 ]; then
	echo "FAIL: -c gave a commit with no nightly" >&2
	failed=1
fi
rm "$dir/tags"
if sh scripts/nightly-newest.sh "$dir/tags" >/dev/null 2>&1; then
	echo "FAIL: a missing tag list was accepted" >&2
	failed=1
fi
exit "$failed"
