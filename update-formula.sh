#!/bin/bash
# Update the four release URLs/checksums without regenerating the formula body.
# Usage: ./update-formula.sh v1.7.2
set -euo pipefail

if [ "$#" -ne 1 ] || [[ ! "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Usage: $0 vMAJOR.MINOR.PATCH" >&2
  exit 1
fi

version=$1
repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
formula="$repo_dir/Formula/narsil-mcp.rb"
base_url="https://github.com/postrv/narsil-mcp/releases/download"
targets=(macos-x86_64 macos-aarch64 linux-x86_64 linux-aarch64)

if [ ! -f "$formula" ] || [ -L "$formula" ]; then
  echo "Expected a regular formula file: $formula" >&2
  exit 1
fi

# Stage on the same filesystem so the final rename is atomic. Never reuse a backup.
work=$(mktemp -d "${formula}.update.XXXXXX")
trap 'rm -rf "$work"' EXIT
trap 'exit 1' HUP INT TERM
cp -p "$formula" "$work/original"
: > "$work/hashes"
for target in "${targets[@]}"; do
  asset="narsil-mcp-${version}-${target}.tar.gz"
  echo "Fetching checksum for $asset..."
  curl --fail --silent --show-error --location \
    --proto '=https' --proto-redir '=https' \
    --connect-timeout 10 --max-time 60 --max-filesize 4096 \
    "$base_url/$version/$asset.sha256" -o "$work/$target.sha256"
  # Release sidecars are shasum output: exactly one hash and the exact asset name.
  hash=$(awk -v asset="$asset" '
    NR != 1 || NF != 2 || length($1) != 64 || $1 ~ /[^0-9A-Fa-f]/ || $2 != asset { bad = 1 }
    NR == 1 { hash = tolower($1) }
    END { if (bad || NR != 1) exit 1; print hash }
  ' "$work/$target.sha256") || {
    echo "Invalid SHA256 sidecar for $asset; formula unchanged." >&2
    exit 1
  }
  printf '%s %s\n' "$target" "$hash" >> "$work/hashes"
done

# Read the checked hashes as data, then replace only the four paired URL/hash lines.
# Reject unexpected formula shapes instead of silently producing a partial update.
cp -p "$work/original" "$work/updated"
awk -v version="$version" -v base="$base_url" '
  FNR == NR { hashes[$1] = $2; next }
  function fail(message) { print message > "/dev/stderr"; bad = 1; exit 1 }
  /^[[:space:]]*version[[:space:]]+"/ { fail("Formula must infer its version from release URLs") }
  pending != "" {
    if ($0 !~ /^[[:space:]]+sha256 "[0-9A-Fa-f]+"[[:space:]]*$/) fail("Expected SHA256 immediately after release URL")
    value = $0; sub(/^[^"]*"/, "", value); sub(/".*/, "", value)
    if (length(value) != 64) fail("Invalid existing formula SHA256")
    sub(/"[^"]*"/, "\"" hashes[pending] "\"")
    pending = ""; print; next
  }
  /^[[:space:]]+url[[:space:]]/ {
    if ($0 !~ /^[[:space:]]+url "[^"]+"[[:space:]]*$/) fail("Unexpected formula URL syntax")
    url = $0; sub(/^[^"]*"/, "", url); sub(/".*/, "", url)
    if (index(url, base "/") != 1) fail("Unexpected release URL")
    rest = substr(url, length(base) + 2)
    tag = rest; sub(/\/.*/, "", tag)
    if (tag !~ /^v[0-9]+\.[0-9]+\.[0-9]+$/) fail("Unexpected existing release tag")
    if (previous != "" && previous != tag) fail("Formula release tags differ")
    previous = tag
    found = ""
    for (target in hashes) {
      if (rest == tag "/narsil-mcp-" tag "-" target ".tar.gz") found = target
    }
    if (found == "" || seen[found]++) fail("Unexpected or duplicate release asset")
    sub(/"[^"]*"/, "\"" base "/" version "/narsil-mcp-" version "-" found ".tar.gz\"")
    pending = found; count++
  }
  { print }
  END { if (!bad && (pending != "" || count != 4)) fail("Expected four complete release URL/checksum pairs") }
' "$work/hashes" "$work/original" > "$work/updated"

# Detect manual edits made during fetching; do not create backups for a no-op.
if ! cmp -s "$formula" "$work/original"; then
  echo "Formula changed during update; refusing to overwrite it." >&2
  exit 1
fi
if cmp -s "$work/original" "$work/updated"; then
  echo "Formula already matches $version."
  exit 0
fi
backup=$(mktemp "${formula}.bak.XXXXXX")
cp -p "$work/original" "$backup"
mv "$work/updated" "$formula"
echo "Updated $formula to $version. Review the changes before committing."
echo "Previous formula retained at $backup"
