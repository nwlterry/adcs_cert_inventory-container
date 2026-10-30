#!/bin/sh
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
tag=${1:-ca-ledger:0.3.0-beta.1}
docker build -t "$tag" "$root"
mkdir -p "$root/dist"
out="$root/dist/ca-ledger-container.tar.gz"
docker save "$tag" | gzip -1 > "$out"
echo "Saved $out"
echo "On the isolated host: docker load -i ca-ledger-container.tar.gz"
