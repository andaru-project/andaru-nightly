# andaru-nightly

Nightly prerelease images of [Andaru](https://github.com/andaru-project/andaru), published as
`ghcr.io/andaru-project/andaru-nightly`.

Every night at 03:17 UTC, [`nightly.yml`](.github/workflows/nightly.yml) compares Andaru's `main` with the commit the
last nightly was built from. Each published nightly is a tag of this repository named by its version, which ends in
that commit, created just before the image is tagged and deleted again if that fails; git, not the registry, is the
record. If `main` moved, it builds the image
from that commit for x86_64 and aarch64, signs it with the nightly key, and tags it with its version and `nightly`.
Otherwise it builds nothing. `workflow_dispatch` runs the same check on demand; its `force` input builds anyway, for
example to pick up a new Fedora CoreOS base. A `FCOS_BASE` variable pins the base digest, as for releases.

It builds nothing until Andaru's `main` ships `image/cosign-nightly.pub`, the key the image trusts for nightlies.

**Versions** are `v<YYYY-MM-DD>.<N>.<commit>`, for example `v2026-11-19.2.0123abc`: the UTC date, the day's build
number, and the first 7 characters of Andaru's commit. `N` is one above the highest `N` that day's nightlies have.
[`scripts/nightly-version.sh`](scripts/nightly-version.sh) computes it, and `tests/nightly-version-test.sh` checks it.

**Signing.** The `nightly-signing` environment, which only `main` can use, holds the nightly cosign key. Andaru's
image trusts that key only for `ghcr.io/andaru-project/andaru-nightly`, so it can never sign something a box would take
as a release. To follow nightlies on a box: `bootc switch --enforce-container-sigpolicy ghcr.io/andaru-project/andaru-nightly:nightly`.
