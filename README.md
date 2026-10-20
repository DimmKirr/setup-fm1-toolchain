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

### Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `version` | `v1.0.0` | Bundle version (GitHub Release tag) |
| `github-token` | `github.token` | Token for downloading release assets |

### Outputs

| Output | Description |
|--------|-------------|
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

Upstream versions are pinned in `versions.env`. The cron workflow (`track.yml`) monitors for updates and creates PRs. After merging a version bump, tag `vX.Y.Z` to trigger packaging.

## License

MIT
