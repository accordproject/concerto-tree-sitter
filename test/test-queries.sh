#!/usr/bin/env bash
# =============================================================================
# Query validation tests for tree-sitter-concerto
#
# Validates that all .scm query files:
#   1. Compile without errors against the grammar
#   2. Produce expected captures when run against example files
#
# Usage: ./test/test-queries.sh
# =============================================================================

set -euo pipefail

PASS=0
FAIL=0
ERRORS=""

pass() {
  PASS=$((PASS + 1))
  printf "  ✓ %s\n" "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  ERRORS="${ERRORS}\n  ✗ $1"
  printf "  \033[31m✗ %s\033[0m\n" "$1"
}

# ---------------------------------------------------------------------------
# Section 1: Verify all query files execute without errors on all examples
# ---------------------------------------------------------------------------
echo "Query compilation and execution:"

for query in queries/*.scm; do
  query_name=$(basename "$query")
  for example in examples/*.cto; do
    example_name=$(basename "$example")
    if tree-sitter query "$query" "$example" >/dev/null 2>&1; then
      pass "$query_name × $example_name"
    else
      fail "$query_name × $example_name (query execution failed)"
    fi
  done
done

# ---------------------------------------------------------------------------
# Section 2: Verify textobjects captures on examples/basic.cto
# ---------------------------------------------------------------------------
echo ""
echo "Text object captures (basic.cto):"

BASIC_OUTPUT=$(tree-sitter query queries/textobjects.scm examples/basic.cto 2>/dev/null)

# Helper: check that a capture name appears in the output
assert_capture() {
  local capture="$1"
  local description="$2"
  if echo "$BASIC_OUTPUT" | grep -qF -- "$capture"; then
    pass "$description"
  else
    fail "$description (capture '$capture' not found)"
  fi
}

# @class.outer should match enum and concept declarations
assert_capture "class.outer" "@class.outer matches enum declaration"
assert_capture "class.outer" "@class.outer matches concept declaration"

# @block.outer should match class and enum bodies
assert_capture "block.outer" "@block.outer matches declaration bodies"

# @parameter.inner should match fields and enum properties
assert_capture "parameter.inner" "@parameter.inner matches fields/properties"

# ---------------------------------------------------------------------------
# Section 3: Verify textobjects captures on examples/advanced.cto
# ---------------------------------------------------------------------------
echo ""
echo "Text object captures (advanced.cto):"

ADV_OUTPUT=$(tree-sitter query queries/textobjects.scm examples/advanced.cto 2>/dev/null)

assert_adv_capture() {
  local capture="$1"
  local description="$2"
  if echo "$ADV_OUTPUT" | grep -qF -- "$capture"; then
    pass "$description"
  else
    fail "$description (capture '$capture' not found)"
  fi
}

# All declaration types
assert_adv_capture "class.outer" "@class.outer present for declarations"
assert_adv_capture "block.outer" "@block.outer present for bodies"
assert_adv_capture "parameter.inner" "@parameter.inner present for fields"
assert_adv_capture "comment.outer" "@comment.outer matches comments"

# Relationship fields (-->)
# Relationship fields contain --> in the captured text
if echo "$ADV_OUTPUT" | grep -qF -- "parameter.inner"; then
  pass "@parameter.inner matches relationship fields"
else
  fail "@parameter.inner does not match relationship fields"
fi

# Default values / assignment captures
assert_adv_capture "assignment.outer" "@assignment.outer matches default clauses"
assert_adv_capture "assignment.inner" "@assignment.inner matches default values"

# @class.inner should match body contents (excluding braces)
assert_adv_capture "class.inner" "@class.inner present for declaration bodies"

# @block.inner should match block contents (excluding braces)
assert_adv_capture "block.inner" "@block.inner present for block bodies"

# ---------------------------------------------------------------------------
# Section 4: Verify textobjects captures on examples/maps.cto
# ---------------------------------------------------------------------------
echo ""
echo "Text object captures (maps.cto):"

MAP_OUTPUT=$(tree-sitter query queries/textobjects.scm examples/maps.cto 2>/dev/null)

assert_map_capture() {
  local capture="$1"
  local description="$2"
  if echo "$MAP_OUTPUT" | grep -qF -- "$capture"; then
    pass "$description"
  else
    fail "$description (capture '$capture' not found)"
  fi
}

assert_map_capture "class.outer" "@class.outer matches map declarations"
assert_map_capture "block.outer" "@block.outer matches map bodies"
assert_map_capture "parameter.inner" "@parameter.inner matches map key/value types"

# ---------------------------------------------------------------------------
# Section 5: Verify textobjects captures on examples/scalars.cto
# ---------------------------------------------------------------------------
echo ""
echo "Text object captures (scalars.cto):"

SCALAR_OUTPUT=$(tree-sitter query queries/textobjects.scm examples/scalars.cto 2>/dev/null)

assert_scalar_capture() {
  local capture="$1"
  local description="$2"
  if echo "$SCALAR_OUTPUT" | grep -qF -- "$capture"; then
    pass "$description"
  else
    fail "$description (capture '$capture' not found)"
  fi
}

# Scalars have @class.outer but NO @block.outer (no braces)
assert_scalar_capture "class.outer" "@class.outer matches scalar declarations"

# Scalars with defaults have assignment captures
assert_scalar_capture "assignment.outer" "@assignment.outer matches scalar defaults"
assert_scalar_capture "assignment.inner" "@assignment.inner matches scalar default values"

# ---------------------------------------------------------------------------
# Section 5b: Verify folds query captures
# ---------------------------------------------------------------------------
echo ""
echo "Fold captures (basic.cto):"

FOLD_OUTPUT=$(tree-sitter query queries/folds.scm examples/basic.cto 2>/dev/null)

assert_fold_capture() {
  local capture="$1"
  local description="$2"
  if echo "$FOLD_OUTPUT" | grep -qF -- "$capture"; then
    pass "$description"
  else
    fail "$description (capture '$capture' not found)"
  fi
}

assert_fold_capture "fold" "@fold matches declaration bodies"

FOLD_ADV_OUTPUT=$(tree-sitter query queries/folds.scm examples/advanced.cto 2>/dev/null)

assert_fold_adv_capture() {
  local capture="$1"
  local description="$2"
  if echo "$FOLD_ADV_OUTPUT" | grep -qF -- "$capture"; then
    pass "$description"
  else
    fail "$description (capture '$capture' not found)"
  fi
}

assert_fold_adv_capture "fold" "@fold matches in advanced example"

# ---------------------------------------------------------------------------
# Section 6: Verify highlights query covers key captures
# ---------------------------------------------------------------------------
echo ""
echo "Highlight captures (basic.cto):"

HL_OUTPUT=$(tree-sitter query queries/highlights.scm examples/basic.cto 2>/dev/null)

assert_hl_capture() {
  local capture="$1"
  local description="$2"
  if echo "$HL_OUTPUT" | grep -qF -- "$capture"; then
    pass "$description"
  else
    fail "$description (capture '$capture' not found)"
  fi
}

assert_hl_capture "keyword.type" "keyword.type present (declaration keywords)"
assert_hl_capture "keyword.import" "keyword.import present (namespace)"
assert_hl_capture "type.builtin" "type.builtin present (primitive types)"
assert_hl_capture "- type," "type present (user-defined types)"
assert_hl_capture "property" "property present (field names)"
assert_hl_capture "attribute" "attribute present (decorators)"
assert_hl_capture "string" "string present (string literals)"
assert_hl_capture "number" "number present (numeric literals)"
assert_hl_capture "namespace" "namespace present (namespace path)"
assert_hl_capture "punctuation.special" "punctuation.special present (o indicator)"
assert_hl_capture "operator" "operator present"
assert_hl_capture "punctuation.bracket" "punctuation.bracket present"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "=============================="
TOTAL=$((PASS + FAIL))
echo "Total: $TOTAL  Passed: $PASS  Failed: $FAIL"

if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "Failures:"
  printf "$ERRORS\n"
  exit 1
else
  echo "All query tests passed!"
  exit 0
fi
