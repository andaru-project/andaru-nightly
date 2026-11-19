#!/bin/sh
# Checks scripts/nightly-version.sh: run from the repository root.
set -eu

dir=$(mktemp -d)
trap 'rm -rf -- "$dir"' EXIT
script=scripts/nightly-version.sh
failed=0
check() {
	want=$1
	shift
	got=$(sh "$script" "$@" 2>/dev/null) || got="(refused)"
	if [ "$got" != "$want" ]; then
		echo "FAIL: $* gave $got, want $want" >&2
		failed=1
	fi
}
tags() { printf '%s\n' "$@" >"$dir/releases"; }
nightlies() { printf '%s\n' "$@" >"$dir/nightlies"; }

nightlies
tags
check 0.0.1-nightly.20261119.1.g0123456 "$dir/releases" "$dir/nightlies" 20261119 0123456789abcdef
tags v1.2.3 v1.10.0 v1.9.9 keyring-2026.11.14
check 1.10.1-nightly.20261119.1.gabcdef0 "$dir/releases" "$dir/nightlies" 20261119 abcdef0123
tags v1.2.3 v1.3.0-b.2 v1.3.0-rc.1
check 1.3.0-nightly.20261119.1.gabcdef0 "$dir/releases" "$dir/nightlies" 20261119 abcdef0
tags v1.2.3 v1.3.0-rc.1 v1.3.0
nightlies 1.3.1-nightly.20261119.1.g1111111 1.3.1-nightly.20261119.2.g2222222 1.3.1-nightly.20261118.1.g3333333 nightly \
	1.3.1-nightly.20261119.2.g2222222-amd64 1.3.1-nightly.20261119.2.g2222222-arm64 staging-1.3.1-nightly.20261119.2.g2222222 \
	1.3.1-nightly.20261119.3.g4444444-amd64
check 1.3.1-nightly.20261119.3.gabcdef0 "$dir/releases" "$dir/nightlies" 20261119 abcdef0
check "(refused)" "$dir/releases" "$dir/nightlies" 2026111 abcdef0
check "(refused)" "$dir/releases" "$dir/nightlies" 20261119 xyz
exit "$failed"
