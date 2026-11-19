#!/bin/sh
# Checks scripts/nightly-version.sh: run from the repository root.
set -eu

dir=$(mktemp -d)
trap 'rm -rf -- "$dir"' EXIT
failed=0
check() {
	want=$1
	shift
	got=$(sh scripts/nightly-version.sh "$dir/releases" "$dir/nightlies" "$@" 2>/dev/null) || got="(refused)"
	if [ "$got" != "$want" ]; then
		echo "FAIL: $* gave $got, want $want" >&2
		failed=1
	fi
}
tags() { printf '%s\n' "$@" >"$dir/releases"; }
nightlies() { printf '%s\n' "$@" >"$dir/nightlies"; }

nightlies
tags
check 0.0.1-nightly.20261119.1.g0123456 20261119 0123456789abcdef
tags v1.2.3 v1.10.0 v1.9.9 keyring-2026.11.14
check 1.10.1-nightly.20261119.1.gabcdef0 20261119 abcdef0123
tags v1.2.3 v1.3.0-b.2 v1.3.0-rc.1
check 1.3.0-nightly.20261119.1.gabcdef0 20261119 abcdef0
# The older -rcN tags, which the Debian releases used, count too.
tags v0.4.0-rc1 v0.4.0-rc2
check 0.4.0-nightly.20261119.1.gabcdef0 20261119 abcdef0
tags v0.4.0-rc2 v0.4.0
check 0.4.1-nightly.20261119.1.gabcdef0 20261119 abcdef0
tags v1.2.3 v1.3.0-rc.1 v1.3.0
nightlies 1.3.1-nightly.20261119.1.g1111111 1.3.1-nightly.20261119.2.g2222222 1.3.1-nightly.20261118.1.g3333333 nightly \
	1.3.1-nightly.20261119.2.g2222222-amd64 1.3.1-nightly.20261119.2.g2222222-arm64 staging-1.3.1-nightly.20261119.2.g2222222 \
	1.3.1-nightly.20261119.3.g4444444-amd64
check 1.3.1-nightly.20261119.3.gabcdef0 20261119 abcdef0
# A pruned nightly does not let N collide with one still published.
nightlies 1.3.1-nightly.20261119.2.g2222222
check 1.3.1-nightly.20261119.3.gabcdef0 20261119 abcdef0
nightlies 1.3.1-nightly.20261119.9.g2222222 1.3.1-nightly.20261119.10.g3333333
check 1.3.1-nightly.20261119.11.gabcdef0 20261119 abcdef0
# Patch numbers compare as numbers.
tags v1.2.9 v1.2.10
nightlies
check 1.2.11-nightly.20261119.1.gabcdef0 20261119 abcdef0
# The highest core in beta, or in candidates only, is the version.
tags v1.2.3 v1.3.0-b.1
check 1.3.0-nightly.20261119.1.gabcdef0 20261119 abcdef0
tags v1.2.3 v1.3.0-rc.4
check 1.3.0-nightly.20261119.1.gabcdef0 20261119 abcdef0
# Tags outside the grammar, and numbers too long to count, do not move it.
tags v1.2.3 xv9.0.0 v9.0 v9.0.0-c.1 v9.0.0-rc.0 v1000000000.0.0
check 1.2.4-nightly.20261119.1.gabcdef0 20261119 abcdef0
# A nightly tag outside the grammar, N 0 or a short commit, does not count.
nightlies 1.2.4-nightly.20261119.0.g1111111 1.2.4-nightly.20261119.5.g111111 x1.2.4-nightly.20261119.7.g1111111
check 1.2.4-nightly.20261119.1.gabcdef0 20261119 abcdef0
# A full commit, as the workflow passes, and lengths up to 40.
check 1.2.4-nightly.20261119.1.g0123456 20261119 0123456789abcdef0123456789abcdef01234567
check 1.2.4-nightly.20261119.1.g0123456 20261119 0123456789abcdef0123456789abcdef0123
# An N too long to count does not overflow.
nightlies 1.2.4-nightly.20261119.99999999999999999999.g1111111
check 1.2.4-nightly.20261119.1.gabcdef0 20261119 abcdef0
# A released core is matched literally: v1-2-4 does not release 1.2.4.
tags v1.2.3 v1.2.4-rc.1 v1-2-4
nightlies
check 1.2.4-nightly.20261119.1.gabcdef0 20261119 abcdef0
check "(refused)" 2026111 abcdef0
check "(refused)" 202611190 abcdef0
check "(refused)" 20261119 abcdef
check "(refused)" 20261119 0123456789abcdef0123456789abcdef012345678
check "(refused)" 20261119 "$(printf 'abcdef0\n1234567')"
check "(refused)" 20261119 xyz
rm "$dir/nightlies"
check "(refused)" 20261119 abcdef0
nightlies
rm "$dir/releases"
check "(refused)" 20261119 abcdef0
exit "$failed"
