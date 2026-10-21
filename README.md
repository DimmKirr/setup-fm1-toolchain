# setup-fm1-toolchain

GitHub Action that installs the JieLi AC79 SDK and Linux toolchain for FM1 firmware builds.

SDK and toolchain binaries are mirrored as separate pre-release assets on this repo (published automatically by the `vendor-sync` workflow). The action downloads them from the mirror, with a fallback to the upstream sources if a mirror release doesn't exist yet.

## Usage

```yaml
jobs:
  build:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - uses: dimmkirr/setup-fm1-toolchain@v1
      - run: make firmware
```

### Inputs

| Input | Default | Description |
|-------|---------|-------------|
| `sdk-version` | `1.2.14_2026-10-13` | SDK version to install (gitee tag is derived as `AC79NN_SDK_V` + version) |
| `toolchain-version` | `20260730.1` | Toolchain version to install |
| `sdk-url` | `https://gitee.com/Jieli-Tech/fw-AC79_AIoT_SDK` | Upstream SDK repo URL (used only for fallback) |
| `toolchain-url` | `https://pkgman.jieliapp.com/s/linux-toolchain` | Upstream toolchain URL (used only for fallback) |
| `github-token` | `${{ github.token }}` | Token for downloading release assets |

### Outputs

| Output | Description |
|--------|-------------|
| `sdk-version` | SDK version installed |
| `toolchain-version` | Toolchain version installed |
| `toolchain-path` | Absolute path to the toolchain |
| `sdk-path` | Absolute path to the SDK |
| `cache-hit` | Whether the toolchain was restored from cache |

### Environment variables

The action sets:
- `JIELI_TOOLCHAIN` — path to the JieLi Linux toolchain root
- `AC79_SDK` — path to the AC79 SDK
- Adds `$JIELI_TOOLCHAIN/pi32v2/bin` to `PATH`

## Local usage (Taskfile)

The included `Taskfile.yml` is a local equivalent of the GitHub Action. Import it into your firmware project:

```yaml
# Taskfile.yml (your project)
version: '3'

includes:
  fm1-platform:
    taskfile: https://raw.githubusercontent.com/DimmKirr/setup-fm1-toolchain/v1/Taskfile.yml

tasks:
  build:
    deps: [fm1-platform:download]
    cmds:
      - make firmware
    env:
      JIELI_TOOLCHAIN: '{{.HOME}}/.fm1-toolchain/toolchain'
      AC79_SDK: '{{.HOME}}/.fm1-toolchain/AC79_SDK'
```

Commands:

| Command | Description |
|---------|-------------|
| `task fm1-platform:download` | Download SDK, toolchain, and build deps |
| `task fm1-platform:download:sdk` | SDK only |
| `task fm1-platform:download:toolchain` | Toolchain only |
| `task fm1-platform:download:deps` | Build dependencies only |
| `task fm1-platform:remove` | Remove `~/.fm1-toolchain` |

Installs to `~/.fm1-toolchain/` (same location as the GitHub Action). Downloads from the GitHub mirror first, falls back to upstream if the mirror release doesn't exist.

## How it works

1. **vendor-sync.yml** runs weekly (and on manual dispatch) to check upstream for new SDK tags and toolchain versions. New versions are downloaded, repackaged as `.tar.xz`, and published as pre-release mirror releases (`sdk-<ver>`, `toolchain-<ver>`) with SHA256 checksums and build provenance attestation.
2. **action.yml** restores from `actions/cache` or downloads the SDK and toolchain from their respective mirror releases, verifies checksums, and sets environment variables. Falls back to upstream sources with a warning if a mirror release is missing.
3. **release.yml** (Release workflow) tests the action against a version matrix, then creates a GitHub Release on tag push and updates the `v1` major tag.

## License

MIT
