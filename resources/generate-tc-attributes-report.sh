#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$REPO_ROOT/build/attribute-report"
CLASS_DIR="$BUILD_DIR/classes"
BASE_JSON_DIR="$BUILD_DIR/base-json"
TECHCOMM_JSON_DIR="$BUILD_DIR/techcomm-json"
OUTPUT="$SCRIPT_DIR/tc-attributes-a-to-z.dita"
BASE_SPEC_DIR="$REPO_ROOT/specification/baseSpec"

mkdir -p "$CLASS_DIR" "$BASE_JSON_DIR" "$TECHCOMM_JSON_DIR"

javac -d "$CLASS_DIR" "$BASE_SPEC_DIR/.github/resources/RngToJson.java"

java -cp "$CLASS_DIR" RngToJson \
  --catalog "$BASE_SPEC_DIR/doctypes/catalog.xml" \
  -o "$BASE_JSON_DIR/rng-basetopic.json" \
  "$BASE_SPEC_DIR/doctypes/rng/base/basetopic.rng"

java -cp "$CLASS_DIR" RngToJson \
  --catalog "$BASE_SPEC_DIR/doctypes/catalog.xml" \
  -o "$BASE_JSON_DIR/rng-basemap.json" \
  "$BASE_SPEC_DIR/doctypes/rng/base/basemap.rng"

java -cp "$CLASS_DIR" RngToJson \
  --catalog "$BASE_SPEC_DIR/doctypes/catalog.xml" \
  -o "$BASE_JSON_DIR/rng-subjectScheme.json" \
  "$BASE_SPEC_DIR/doctypes/rng/subjectScheme/subjectScheme.rng"

generate_techcomm_json() {
  local name="$1"
  local rng_path="$2"
  java -cp "$CLASS_DIR" RngToJson \
    --catalog "$BASE_SPEC_DIR/doctypes/catalog.xml" \
    --catalog "$REPO_ROOT/doctypes/catalog.xml" \
    -o "$TECHCOMM_JSON_DIR/rng-${name}.json" \
    "$rng_path"
}

generate_techcomm_json bookmap "$REPO_ROOT/doctypes/rng/bookmap/bookmap.rng"
generate_techcomm_json concept "$REPO_ROOT/doctypes/rng/technicalContent/concept.rng"
generate_techcomm_json glossentry "$REPO_ROOT/doctypes/rng/technicalContent/glossentry.rng"
generate_techcomm_json glossgroup "$REPO_ROOT/doctypes/rng/technicalContent/glossgroup.rng"
generate_techcomm_json map "$REPO_ROOT/doctypes/rng/technicalContent/map.rng"
generate_techcomm_json reference "$REPO_ROOT/doctypes/rng/technicalContent/reference.rng"
generate_techcomm_json task "$REPO_ROOT/doctypes/rng/technicalContent/task.rng"
generate_techcomm_json topic "$REPO_ROOT/doctypes/rng/technicalContent/topic.rng"
generate_techcomm_json troubleshooting "$REPO_ROOT/doctypes/rng/technicalContent/troubleshooting.rng"

python3 "$BASE_SPEC_DIR/resources/rng_json_attribute_report.py" \
  --spec techcomm \
  --exclude-json "$BASE_JSON_DIR/rng-basetopic.json" \
  --exclude-json "$BASE_JSON_DIR/rng-basemap.json" \
  --exclude-json "$BASE_JSON_DIR/rng-subjectScheme.json" \
  --exclude-element dita \
  "$TECHCOMM_JSON_DIR/rng-bookmap.json" \
  "$TECHCOMM_JSON_DIR/rng-concept.json" \
  "$TECHCOMM_JSON_DIR/rng-glossentry.json" \
  "$TECHCOMM_JSON_DIR/rng-glossgroup.json" \
  "$TECHCOMM_JSON_DIR/rng-map.json" \
  "$TECHCOMM_JSON_DIR/rng-reference.json" \
  "$TECHCOMM_JSON_DIR/rng-task.json" \
  "$TECHCOMM_JSON_DIR/rng-topic.json" \
  "$TECHCOMM_JSON_DIR/rng-troubleshooting.json" \
  > "$OUTPUT"

echo "Wrote $OUTPUT"
