#!/bin/bash

set -euo pipefail

# 🏷️ Determine Go version: from env or latest
if [ -z "${GO_VERSION:-}" ]; then
  echo "🔍 GO_VERSION not set, detecting latest stable version..."
  GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1 | sed 's/^go//')
  echo "📌 Using latest version: $GO_VERSION"
else
  echo "📌 Using GO_VERSION from environment: $GO_VERSION"
fi

ARCH=$(uname -m)

# Map system arch to Go + Debian arch
case "$ARCH" in
  x86_64) GOARCH="amd64"; DEBARCH="amd64" ;;
  aarch64 | arm64) GOARCH="arm64"; DEBARCH="arm64" ;;
  armv7l | armv6l) GOARCH="armv6l"; DEBARCH="armhf" ;;
  *) echo "❌ Unsupported architecture: $ARCH" && exit 1 ;;
esac

# Setup filenames and paths
PACKAGE_NAME="golang-custom"
TMPROOT="/dev/shm/go-build-$$"
GO_TARBALL="go${GO_VERSION}.linux-${GOARCH}.tar.gz"
OUTPUT_DEB="${PACKAGE_NAME}_${GO_VERSION}_${GOARCH}.deb"
GO_URL="https://go.dev/dl/${GO_TARBALL}"

echo "📦 Building Go ${GO_VERSION} for ${DEBARCH} using tmpfs at $TMPROOT"
mkdir -p "${TMPROOT}/usr/local"

# Download Go tarball if missing
if [ ! -f "$GO_TARBALL" ]; then
  echo "⬇️  Downloading $GO_TARBALL..."
  echo ""
  curl -LO "$GO_URL"
  echo ""
fi

# Extract Go into build directory
echo "📂 Extracting Go tarball..."
tar -C "${TMPROOT}/usr/local" -xzf "$GO_TARBALL"

# Create DEBIAN control metadata
mkdir -p "${TMPROOT}/DEBIAN"
cat > "${TMPROOT}/DEBIAN/control" <<EOF
Package: ${PACKAGE_NAME}
Version: ${GO_VERSION}
Section: devel
Priority: optional
Architecture: ${DEBARCH}
Maintainer: Custom Builder <builder@example.com>
Description: Custom Go ${GO_VERSION} build installed to /usr/local/go
EOF

# Warn if .deb already exists
if [ -f "$OUTPUT_DEB" ]; then
  echo "⚠️  Warning: $OUTPUT_DEB already exists and will be overwritten."
fi

# Build .deb package
echo ""
dpkg-deb --build "$TMPROOT" "$OUTPUT_DEB"
echo ""

# Clean up tmpfs build directory
rm -rf "$TMPROOT"

# Optionally remove downloaded tarball
if [ -f "$GO_TARBALL" ]; then
  echo "🧹 Removing downloaded archive: $GO_TARBALL"
  rm -f "$GO_TARBALL"
fi

# Final output
echo ""
echo "✅ .deb created: $(realpath "$OUTPUT_DEB")"
echo ""
echo "📥 Install it with:"
echo "    sudo dpkg -i $(basename "$OUTPUT_DEB")"
echo ""
echo "📌 To use Go globally, add this to your shell config (e.g. ~/.bashrc or ~/.zshrc):"
echo "    export PATH=\$PATH:/usr/local/go/bin"
echo ""
echo "🧽 To uninstall this Go package and clean up manually:"
echo "    sudo dpkg -r golang-custom"
echo ""
echo "    # If you added Go to your PATH (e.g. in ~/.bashrc or ~/.zshrc), remove this line:"
echo "    export PATH=\$PATH:/usr/local/go/bin"
echo ""
