#!/usr/bin/env bash
set -euo pipefail

REPO="dimmkirr/setup-fm1-toolchain"
VERSION="${1:-latest}"
INSTALL_DIR="${FM1_TOOLCHAIN_HOME:-$HOME/.fm1-toolchain}"

if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
    | grep -o '"tag_name": *"[^"]*"' | cut -d'"' -f4)
  echo "Latest version: $VERSION"
fi

BUNDLE_VERSION="${VERSION#v}"
ASSET="fm1-toolchain-${BUNDLE_VERSION}.tar.xz"
URL="https://github.com/$REPO/releases/download/$VERSION/$ASSET"

echo "Installing FM1 toolchain $VERSION to $INSTALL_DIR..."

if [ -d "$INSTALL_DIR" ] && [ -f "$INSTALL_DIR/versions.env" ]; then
  INSTALLED=$(grep '^BUNDLE_VERSION=' "$INSTALL_DIR/versions.env" | cut -d= -f2)
  if [ "$INSTALLED" = "$BUNDLE_VERSION" ]; then
    echo "Already installed: $BUNDLE_VERSION"
    echo ""
    echo "Add to your shell profile:"
    echo "  export JIELI_TOOLCHAIN=$INSTALL_DIR/toolchain"
    echo "  export AC79_SDK=$INSTALL_DIR/AC79_SDK"
    echo "  export PATH=\"\$JIELI_TOOLCHAIN/bin:\$PATH\""
    exit 0
  fi
fi

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Downloading $URL..."
curl -fSL --retry 3 -o "$TMP/$ASSET" "$URL"

echo "Extracting..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xJf "$TMP/$ASSET" --strip-components=1 -C "$INSTALL_DIR"

echo ""
echo "FM1 toolchain installed to $INSTALL_DIR"
echo ""
echo "Add to your shell profile:"
echo "  export JIELI_TOOLCHAIN=$INSTALL_DIR/toolchain"
echo "  export AC79_SDK=$INSTALL_DIR/AC79_SDK"
echo "  export PATH=\"\$JIELI_TOOLCHAIN/bin:\$PATH\""
