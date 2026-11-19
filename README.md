# andaru-nightly

Nightly prerelease images of [Andaru](https://github.com/andaru-project/andaru), published as
`ghcr.io/andaru-project/andaru-nightly`.

Every night at 03:17 UTC, [`nightly.yml`](.github/workflows/nightly.yml) compares Andaru's `main` with the commit the
last nightly was built from (its `org.opencontainers.image.revision` label). If `main` moved, it builds the image
from that commit for x86_64 and aarch64, signs it with the nightly key, and tags it with its version and `nightly`.
Otherwise it builds nothing. `workflow_dispatch` runs the same check on demand.

**Versions** are `<next version>-nightly.<YYYYMMDD>.<N>.g<commit>`, for example `1.3.1-nightly.20261119.2.g0123456`.
The next version is the core of Andaru's highest version tag, one patch up once that core is released. `N` counts that
day's nightlies from 1. [`scripts/nightly-version.sh`](scripts/nightly-version.sh) computes it, and
`tests/nightly-version-test.sh` checks it.

**Signing.** The `nightly-signing` environment, which only `main` can use, holds the nightly cosign key. Andaru's
image trusts that key only for `ghcr.io/andaru-project/andaru-nightly`, so it can never sign something a box would take
as a release. To follow nightlies on a box: `bootc switch --enforce-container-sigpolicy ghcr.io/andaru-project/andaru-nightly:nightly`.
