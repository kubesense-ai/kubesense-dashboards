#!/usr/bin/env bash
# Checks every dashboard file against .schema/dashboard.schema.json, then the
# schema against its own fixtures. Run from anywhere; CI runs this script.
set -euo pipefail

cd "$(dirname "$0")/.."
SCHEMA=.schema/dashboard.schema.json
VERSION=0.33.3

if command -v check-jsonschema >/dev/null 2>&1; then
  validate() { check-jsonschema --schemafile "$SCHEMA" "$@"; }
elif command -v uvx >/dev/null 2>&1; then
  validate() { uvx --from "check-jsonschema==$VERSION" check-jsonschema --schemafile "$SCHEMA" "$@"; }
else
  echo "need check-jsonschema (pip install check-jsonschema==$VERSION) or uvx" >&2
  exit 2
fi

# Same selection as kubeapi's IsDashboardPath: *.json with no dot-prefixed segment.
files=()
while IFS= read -r f; do files+=("$f"); done < <(find . -name '*.json' -not -path '*/.*' | sed 's|^\./||' | sort)
[ "${#files[@]}" -gt 0 ] || { echo "no dashboard files found" >&2; exit 1; }

fail=0

echo "== \$schema reference in ${#files[@]} dashboard files"
for f in "${files[@]}"; do
  depth=$(awk -F/ '{print NF-1}' <<<"$f")
  want=$(printf '../%.0s' $(seq 1 "$depth"))${SCHEMA#./}
  [ "$depth" -gt 0 ] || want=$SCHEMA
  got=$(python3 -I -c 'import json,sys; print(json.load(open(sys.argv[1])).get("$schema",""))' "$f")
  first=$(python3 -I -c 'import json,sys; print(next(iter(json.load(open(sys.argv[1])))))' "$f")
  if [ "$got" != "$want" ] || [ "$first" != '$schema' ]; then
    echo "FAIL $f: \$schema must be the first key and equal \"$want\" (got \"$got\")"
    fail=1
  fi
done

echo "== schema validation of dashboard files"
if validate "${files[@]}"; then echo "ok: ${#files[@]} dashboard files"; else fail=1; fi

echo "== fixtures"
for f in .schema/tests/valid/*.json; do
  if validate "$f" >/dev/null 2>&1; then echo "ok   valid   $f"; else echo "FAIL valid fixture rejected: $f"; fail=1; fi
done
for f in .schema/tests/invalid/*.json; do
  if validate "$f" >/dev/null 2>&1; then echo "FAIL invalid fixture accepted: $f"; fail=1; else echo "ok   invalid $f"; fi
done

exit "$fail"
