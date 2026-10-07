#!/bin/bash
# Offline, portable regression: no release requests and no checkout mutation.
set -euo pipefail
repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/narsil-formula-test.XXXXXX")
cleanup() {
  local status=$?
  if [ "$status" -ne 0 ] && [ -f "$work/output" ]; then cat "$work/output" >&2; fi
  rm -rf "$work"
  exit "$status"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
mkdir -p "$work/bin" "$work/repo/Formula" "$work/sidecars"
cp "$repo_dir/update-formula.sh" "$work/repo/update-formula.sh"
export FIXTURE_SIDECARS="$work/sidecars" FIXTURE_CALLS="$work/calls"
export PATH="$work/bin:$PATH"
cat > "$work/bin/curl" <<'CURL'
#!/bin/bash
set -euo pipefail
url= output=
while [ "$#" -gt 0 ]; do
  case "$1" in
    -o) output=$2; shift 2 ;;
    --proto|--proto-redir|--connect-timeout|--max-time|--max-filesize) shift 2 ;;
    --fail|--silent|--show-error|--location) shift ;;
    https://github.com/postrv/narsil-mcp/releases/download/v1.7.2/*) url=$1; shift ;;
    *) echo "Unexpected curl argument: $1" >&2; exit 90 ;;
  esac
done
[ -n "$url" ] && [ -n "$output" ]
asset=${url##*/}
printf '%s\n' "$asset" >> "$FIXTURE_CALLS"
[ -f "$FIXTURE_SIDECARS/$asset" ] || exit 22
cp "$FIXTURE_SIDECARS/$asset" "$output"
CURL
chmod +x "$work/bin/curl"

targets=(macos-x86_64 macos-aarch64 linux-x86_64 linux-aarch64)
hashes=(
  1111111111111111111111111111111111111111111111111111111111111111
  2222222222222222222222222222222222222222222222222222222222222222
  3333333333333333333333333333333333333333333333333333333333333333
  abcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcdefabcd
)
old_hash=0000000000000000000000000000000000000000000000000000000000000000
make_formula() {
  local version=$1 use_new=$2 i=0 hash
  # shellcheck disable=SC2016 # The fixture must preserve literal shell/Ruby interpolation.
  printf '%s\n' 'class NarsilMcp < Formula' '  # Preserve this body, including arbitrary interpolation: #{bin} and $PATH'
  for target in "${targets[@]}"; do
    hash=$old_hash
    if [ "$use_new" = yes ]; then hash=${hashes[$i]}; fi
    printf '  url "https://github.com/postrv/narsil-mcp/releases/download/%s/narsil-mcp-%s-%s.tar.gz"\n' "$version" "$version" "$target"
    printf '  sha256 "%s"\n' "$hash"
    i=$((i + 1))
  done
  printf '%s\n' '  def install' '    bin.install "narsil-mcp"' '  end' '  test do' '    assert_match version.to_s, shell_output("#{bin}/narsil-mcp --version")' '  end' 'end'
}
reset_case() {
  rm -f "$work/repo/Formula/"* "$work/sidecars/"*
  : > "$work/calls"
  make_formula v1.7.1 no > "$work/repo/Formula/narsil-mcp.rb"
  cp "$work/repo/Formula/narsil-mcp.rb" "$work/original"
  local i=0
  for target in "${targets[@]}"; do
    printf '%s  narsil-mcp-v1.7.2-%s.tar.gz\n' "${hashes[$i]}" "$target" > "$work/sidecars/narsil-mcp-v1.7.2-$target.tar.gz.sha256"
    i=$((i + 1))
  done
}
run_update() { bash "$work/repo/update-formula.sh" v1.7.2 > "$work/output" 2>&1; }
unchanged_failure() {
  if run_update; then echo "Unexpected success: $1" >&2; exit 1; fi
  cmp "$work/original" "$work/repo/Formula/narsil-mcp.rb"
  local files=("$work/repo/Formula/"*)
  [ "${#files[@]}" -eq 1 ]
  printf 'PASS %s\n' "$1"
}

reset_case
run_update
make_formula v1.7.2 yes > "$work/expected"
cmp "$work/expected" "$work/repo/Formula/narsil-mcp.rb"
backups=("$work/repo/Formula/"*.bak.*)
[ "${#backups[@]}" -eq 1 ]
cmp "$work/original" "${backups[0]}"
[ "$(wc -l < "$work/calls" | tr -d ' ')" -eq 4 ]
for target in "${targets[@]}"; do
  [ "$(grep -Fxc "narsil-mcp-v1.7.2-$target.tar.gz.sha256" "$work/calls")" -eq 1 ]
done
printf 'PASS four-platform update changes tag, basename and checksum only; backup preserved\n'
run_update
backups=("$work/repo/Formula/"*.bak.*)
[ "${#backups[@]}" -eq 1 ]
cmp "$work/expected" "$work/repo/Formula/narsil-mcp.rb"
printf 'PASS identical update is a no-op without another backup\n'

reset_case
rm "$work/sidecars/narsil-mcp-v1.7.2-linux-aarch64.tar.gz.sha256"
unchanged_failure 'last sidecar download fails atomically'
reset_case
printf '%s\n' 'not-a-hash  narsil-mcp-v1.7.2-linux-aarch64.tar.gz' > "$work/sidecars/narsil-mcp-v1.7.2-linux-aarch64.tar.gz.sha256"
unchanged_failure 'malformed checksum rejected atomically'
reset_case
printf '%s  wrong-asset.tar.gz\n' "${hashes[3]}" > "$work/sidecars/narsil-mcp-v1.7.2-linux-aarch64.tar.gz.sha256"
unchanged_failure 'mismatched asset name rejected atomically'
reset_case
cat "$work/sidecars/narsil-mcp-v1.7.2-macos-x86_64.tar.gz.sha256" >> "$work/sidecars/narsil-mcp-v1.7.2-linux-aarch64.tar.gz.sha256"
unchanged_failure 'multiple checksum records rejected atomically'
reset_case
# A valid sidecar set must not mask a formula whose four assets are no longer present.
sed 's/linux-aarch64/unknown-target/' "$work/original" > "$work/repo/Formula/narsil-mcp.rb"
cp "$work/repo/Formula/narsil-mcp.rb" "$work/original"
unchanged_failure 'unexpected formula asset rejected atomically'
reset_case
if bash "$work/repo/update-formula.sh" v1.7.2/invalid > "$work/output" 2>&1; then exit 1; fi
cmp "$work/original" "$work/repo/Formula/narsil-mcp.rb"
[ ! -s "$work/calls" ]
printf 'PASS invalid version rejected before network dispatch\n'
