#!/bin/sh
set -eu

LISTEN="${CA_LEDGER_LISTEN:-http://+:8787/}"
OUTPUT="${CA_LEDGER_OUTPUT:-/data/cert-inventory.json}"
APP=/opt/ca-ledger/CertInventory

case "$LISTEN" in
  *[!A-Za-z0-9:/._+-]*)
    echo "Listen address is not valid." >&2
    exit 1
    ;;
esac
case "$OUTPUT" in
  *[!A-Za-z0-9:/._-]*)
    echo "Inventory path is not valid." >&2
    exit 1
    ;;
esac
if [ ! -x "$APP" ]; then
  echo "CA Ledger program is missing." >&2
  exit 1
fi
if [ ! -f "$OUTPUT" ]; then
  if [ "${CA_LEDGER_DEMO:-0}" = "1" ]; then
    exec "$APP" --demo --serve --listen "$LISTEN" --output "$OUTPUT"
  fi
  echo "No inventory at $OUTPUT." >&2
  echo "Mount the collector JSON on /data, or set CA_LEDGER_DEMO=1 for the built-in sample." >&2
  exit 1
fi
exec "$APP" --serve --listen "$LISTEN" --output "$OUTPUT"
