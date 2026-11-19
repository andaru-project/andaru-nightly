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
check 1.3.1-nightly.20261119.10.gccccccc 1.3.1-nightly.20261118.12.gaaaaaaa 1.3.1-nightly.20261119.2.gbbbbbbb \
	1.3.1-nightly.20261119.10.gccccccc
# On one day, a newer core wins over an older core's higher N, and cores compare as numbers.
check 0.0.10-nightly.20261119.1.gccccccc 0.0.9-nightly.20261119.2.gbbbbbbb 0.0.10-nightly.20261119.1.gccccccc
check 0.0.2-nightly.20261119.1.gccccccc 0.0.1-nightly.20261119.2.gbbbbbbb 0.0.2-nightly.20261119.1.gccccccc
# Only whole nightly names count: no prefix, suffix, architecture or staging tag.
check 1.3.1-nightly.20261119.1.gaaaaaaa 1.3.1-nightly.20261119.1.gaaaaaaa test-nightly.20991231.1.gabcdef0 \
	1.3.1-nightly.20991231.1.gabcdef0-amd64 staging-1.3.1-nightly.20991231.1.gabcdef0 1.3.1-nightly.20991231.0.gabcdef0
rm "$dir/tags"
if sh scripts/nightly-newest.sh "$dir/tags" >/dev/null 2>&1; then
	echo "FAIL: a missing tag list was accepted" >&2
	failed=1
fi
exit "$failed"
