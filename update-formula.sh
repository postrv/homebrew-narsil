#!/bin/bash
#
# Helper script to update Formula/narsil-mcp.rb with new version and SHA256 checksums
#
# Usage: ./update-formula.sh v1.1.2
#

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: ./update-formula.sh v1.1.2"
  exit 1
fi

REPO="postrv/narsil-mcp"
FORMULA="Formula/narsil-mcp.rb"

echo "Updating formula for $VERSION..."

# Fetch SHA256s from GitHub releases
echo ""
echo "Fetching SHA256 checksums from GitHub releases..."

# macOS Intel
echo -n "  macOS Intel (x86_64)... "
MAC_X64_SHA=$(curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/narsil-mcp-$VERSION-x86_64-apple-darwin.tar.gz.sha256" | awk '{print $1}')
echo "$MAC_X64_SHA"

# macOS ARM
echo -n "  macOS ARM (aarch64)... "
MAC_ARM_SHA=$(curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/narsil-mcp-$VERSION-aarch64-apple-darwin.tar.gz.sha256" | awk '{print $1}')
echo "$MAC_ARM_SHA"

# Linux x86_64
echo -n "  Linux (x86_64)... "
LINUX_SHA=$(curl -fsSL "https://github.com/$REPO/releases/download/$VERSION/narsil-mcp-$VERSION-x86_64-unknown-linux-gnu.tar.gz.sha256" | awk '{print $1}')
echo "$LINUX_SHA"

echo ""
echo "Creating updated formula..."

# Create backup
cp "$FORMULA" "${FORMULA}.bak"

# Update version (remove 'v' prefix)
VERSION_NUM="${VERSION#v}"
sed -i '' "s/version \".*\"/version \"$VERSION_NUM\"/" "$FORMULA"

# Update URLs
sed -i '' "s|/download/v[^/]*/|/download/$VERSION/|g" "$FORMULA"

# Update SHA256s (using temporary markers to avoid conflicts)
# 1. Replace macOS Intel SHA256
sed -i '' "/x86_64-apple-darwin/,/sha256/ s/sha256 \".*\"/sha256 \"$MAC_X64_SHA\"/" "$FORMULA"

# 2. Replace macOS ARM SHA256
sed -i '' "/aarch64-apple-darwin/,/sha256/ s/sha256 \".*\"/sha256 \"$MAC_ARM_SHA\"/" "$FORMULA"

# 3. Replace Linux SHA256
sed -i '' "/x86_64-unknown-linux-gnu/,/sha256/ s/sha256 \".*\"/sha256 \"$LINUX_SHA\"/" "$FORMULA"

echo ""
echo "✅ Formula updated successfully!"
echo ""
echo "Changes:"
git diff "$FORMULA"

echo ""
echo "To publish:"
echo "  1. Review changes above"
echo "  2. git add Formula/narsil-mcp.rb"
echo "  3. git commit -m \"chore: update to $VERSION\""
echo "  4. git push"
echo ""
echo "To restore backup if needed:"
echo "  mv ${FORMULA}.bak $FORMULA"
