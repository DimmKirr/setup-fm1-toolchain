# setup-fm1-toolchain

GitHub Action and local installer for the JieLi AC79 SDK and Linux toolchain, used to build FM1 firmware.

Packages the SDK and toolchain from upstream Chinese sources (gitee, pkgman.jieliapp.com) into a single release asset hosted on GitHub. No need to download from gitee on every CI run.

## CI Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: dimmkirr/setup-fm1-toolchain@v1
      - run: make firmware
```

The action sets these environment variables:
- `JIELI_TOOLCHAIN` - path to the JieLi Linux toolchain
- `AC79_SDK` - path to the AC79 SDK
- Adds `$JIELI_TOOLCHAIN/bin` to `PATH`

Pin to a specific release to lock the SDK and toolchain versions:

```yaml
- uses: dimmkirr/setup-fm1-toolchain@v1.0.2
```

### Outputs

| Output | Description |
|--------|-------------|
| `sdk-version` | SDK version included in the installed bundle |
| `toolchain-version` | Toolchain version included in the installed bundle |
| `toolchain-path` | Absolute path to the toolchain |
| `sdk-path` | Absolute path to the SDK |
| `cache-hit` | Whether the bundle was restored from cache |

## Local Install

```bash
curl -fsSL https://raw.githubusercontent.com/dimmkirr/setup-fm1-toolchain/main/install.sh | bash
```

Or a specific version:

```bash
curl -fsSL https://raw.githubusercontent.com/dimmkirr/setup-fm1-toolchain/main/install.sh | bash -s v1.0.0
```

Custom install location:

```bash
FM1_TOOLCHAIN_HOME=/opt/fm1 bash install.sh
```

## How It Works

1. **package.yml** downloads the SDK zip from gitee and toolchain from pkgman.jieliapp.com, bundles them into a `.tar.xz`, and publishes it as a GitHub Release
2. **action.yml** (composite action) restores the bundle from `actions/cache` or downloads from GitHub Releases, extracts, and sets env vars
3. **track.yml** runs weekly to check gitee and pkgman for new versions, creates a draft PR when updates are found

## Versioning

The action tag determines which SDK and toolchain bundle gets installed. Each tag (e.g. `v1.0.2`) has a corresponding GitHub Release with the pre-built bundle. The `@v1` major tag always points to the latest `v1.x.x` release.

Release titles and asset filenames show exactly which SDK and toolchain versions are bundled (e.g. `fm1-toolchain-1.0.2-sdk1.2.14-tc20260730.1.tar.xz`).

Upstream versions are pinned in `versions.env`. The cron workflow (`track.yml`) monitors for updates and creates PRs. After merging a version bump, tag `vX.Y.Z` to trigger packaging and create the release.

## License

MIT
