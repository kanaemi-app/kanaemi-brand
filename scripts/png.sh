#!/usr/bin/env bash
# Renders every SVG in logo/ into png/ as <name>-<width>x<height>.png.
# Needs rsvg-convert and oxipng; the Nix dev shell has both:
#   nix develop -c scripts/png.sh
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/png"
rm -rf "$out"
mkdir -p "$out"

# render <svg> <width> <height>
render() {
  local name
  name="$(basename "$1" .svg)"
  rsvg-convert -w "$2" -h "$3" -o "$out/$name-$2x$3.png" "$1"
}

for svg in "$root"/logo/kanaemi-icon-small*.svg; do
  for size in 16 24 32 48; do
    render "$svg" "$size" "$size"
  done
done

for svg in "$root"/logo/kanaemi-icon.svg "$root"/logo/kanaemi-icon-{dark,mono-black,mono-white}.svg; do
  for size in 32 64 128 256 512 1024; do
    render "$svg" "$size" "$size"
  done
done

# The wordmark logos at half, one, two and four times their SVG size.
for svg in "$root"/logo/kanaemi-logo-horizontal*.svg; do
  for size in 263x100 526x200 1052x400 2104x800; do
    render "$svg" "${size%x*}" "${size#*x}"
  done
done
for svg in "$root"/logo/kanaemi-logo-vertical*.svg; do
  for size in 180x165 360x330 720x660 1440x1320; do
    render "$svg" "${size%x*}" "${size#*x}"
  done
done

# Lossless; keeps the files the same pixels, only smaller.
oxipng --quiet --opt max --strip safe "$out"/*.png
