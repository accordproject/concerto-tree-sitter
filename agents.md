# AI Agent Development Log

This document records the AI-assisted development process used to create the `tree-sitter-concerto` parser. It serves as a reference for the methodology, decisions, and tooling involved.

## Project Goal

Create a complete tree-sitter parser for the **Concerto Modelling Language** (`.cto` files) by the Accord Project, including grammar, tests, syntax highlighting queries, and documentation.

## Development Methodology

The project was built using an AI-assisted architecture-led development approach, with a senior architect agent orchestrating specialized sub-agents for parallel workstreams.

### Phase 1: Research & Understanding

**Objective**: Understand the Concerto language specification and tree-sitter grammar authoring.

**Actions**:
1. Retrieved and analyzed the [official PEG grammar](https://github.com/accordproject/concerto/blob/main/packages/concerto-cto/lib/parser.pegjs) (~1800 lines) from the Concerto repository
2. Studied the Concerto documentation at concerto.accordproject.org
3. Fetched real-world `.cto` model files from the Accord Project model repository and template library
4. Researched tree-sitter grammar authoring best practices from official docs and community guides

**Key insights gathered**:
- Concerto has 8 declaration types: concept, asset, participant, transaction, event, enum, scalar, map
- 6 primitive types: String, Boolean, DateTime, Integer, Long, Double
- Complex features: decorators with typed arguments, relationships (`-->`), validators (regex, range, length), imports with versioned namespaces and aliasing
- The `@` symbol is overloaded: used for both version tags in namespaces and decorator prefixes

### Phase 2: Project Scaffolding

**Objective**: Set up the tree-sitter project structure and tooling.

**Actions**:
1. Created `package.json` with tree-sitter-cli and concerto-cli as dev dependencies
2. Created `tree-sitter.json` configuration for ABI version 15
3. Set up directory structure: `queries/`, `test/corpus/`, `examples/`, `src/`
4. Installed tree-sitter CLI globally (`v0.26.7`) and concerto-cli (`v3.18.2`)

### Phase 3: Grammar Development

**Objective**: Translate the PEG grammar into tree-sitter's JavaScript DSL.

**Approach**: Iterative translation with immediate feedback from `tree-sitter generate`.

**Key design decisions**:

| Decision | Rationale |
|---|---|
| Namespace/import paths as single regex tokens | Avoids ambiguity between `@` in version tags and `@` in decorators. PEG's ordered alternation handles this naturally but tree-sitter's GLR parser needs explicit disambiguation. |
| Separate field nodes per primitive type | Enables type-specific syntax highlighting and allows validators to be structurally restricted to appropriate types (e.g., `range` only on numeric fields). |
| `word` rule set to `_identifier_token` | Ensures keywords are matched with word boundaries, preventing false keyword matches within identifiers. |
| No precedence/associativity declarations | The grammar is deliberately unambiguous — tree-sitter generates with zero conflicts. |
| `token.immediate(".{")` for multi-type imports | Prevents the parser from inserting whitespace between the namespace path and `.{`, which would misparse as a single-type import followed by a decorator. |

**Challenges encountered and resolved**:

1. **Regex lookahead not supported**: Tree-sitter's regex engine doesn't support lookahead (`(?!...)`). The PEG grammar used `0(?![0-9])` for null escape sequences — resolved by simplifying to `/['"\\bfnrtv0]/`.

2. **Character class escaping**: The PEG regex literal rule used nested character classes that tree-sitter couldn't parse. Simplified to a flat regex pattern: `/\/[^\/\n]+\/[gimsuy]*/`.

3. **Import path ambiguity**: `import org.example@1.0.0.Foo` was ambiguous because tree-sitter couldn't decide where the namespace ended and the type name began. Resolved by making the full dotted-versioned path a single token, then parsing the final `.TypeName` as separate tokens.

4. **`identified` vs `identified by` ambiguity**: Initially added as a conflict, but tree-sitter resolved it automatically via its keyword matching, so the explicit conflict was removed.

### Phase 4: Test Corpus Creation

**Objective**: Comprehensive test coverage for all language constructs.

**Approach**: A specialized implementation agent created 120 tests across 12 test files, with each test verified against actual `tree-sitter parse` output.

**Test distribution**:

| Test File | Count | Coverage |
|---|---|---|
| `namespace.txt` | 7 | Simple, dotted, deeply nested, versioned, prerelease |
| `imports.txt` | 8 | Single, wildcard, multi-type, aliased, with URI |
| `concepts.txt` | 9 | Basic, abstract, identified, extends, all field types |
| `enums.txt` | 5 | Basic, empty, decorated |
| `scalars.txt` | 17 | All 6 primitive types, defaults, validators |
| `maps.txt` | 9 | All key/value type combinations, relationships |
| `assets_participants.txt` | 12 | All 4 declaration types with modifiers |
| `fields.txt` | 24 | All 8 field types with all modifiers |
| `decorators.txt` | 11 | All argument types, multiple decorators |
| `comments.txt` | 5 | Line, block, doc comments |
| `concerto_version.txt` | 3 | String variants |
| `validators.txt` | 10 | Regex, length, range with edge cases |

**Result**: All 120 tests pass on first run.

### Phase 5: Example Validation

**Objective**: Cross-validate parser output against the official Concerto parser.

**Actions**:
1. Created 6 example `.cto` files covering all language features
2. Validated each file with `npx concerto parse --model <file>` (official parser)
3. Verified each file with `tree-sitter parse <file>` (our parser)
4. Confirmed zero errors in both parsers for all files

### Phase 6: Syntax Highlighting & Editor Support

**Objective**: Create query files for editor integration.

**Files created**:
- `queries/highlights.scm` — Full syntax highlighting with semantic token types
- `queries/locals.scm` — Scope, definition, and reference tracking
- `queries/indents.scm` — Auto-indentation rules
- `queries/textobjects.scm` — Text object queries for structural editing

**Highlighting categories mapped**:
- `@keyword.type` — Declaration keywords (concept, asset, enum, etc.)
- `@keyword.import` — namespace, import, from
- `@keyword.modifier` — abstract, optional
- `@type.builtin` — Primitive types (String, Integer, etc.)
- `@type` — User-defined type names
- `@property` — Field/property names
- `@attribute` — Decorator names and `@` prefix
- `@string` — String literals
- `@number` — Numeric literals
- `@comment` — Line and block comments
- `@operator` — `-->`, `=`, `*`
- `@string.regex` — Regular expression literals

### Phase 7: Text Object Query Validation & Rewrite

**Objective**: Validate and fix the text object queries for correctness and nvim-treesitter-textobjects compatibility.

**Issues found in the initial `textobjects.scm`**:

| Issue | Severity | Resolution |
|---|---|---|
| `.inner` captures included braces (`{` and `}`) | High | Replaced with `#make-range!` pattern using `(_) @_start @_end (_)? @_end` between anchored `"{"` and `"}"`, matching the canonical C textobjects pattern from nvim-treesitter-textobjects |
| `@block` had no `.inner` counterpart | Medium | Added `@block.inner` via `#make-range!` with the same brace-excluding pattern |
| `@function.outer/inner` was redundant alias of `@class` | Medium | Removed entirely — Concerto is a schema language with no functions; aliasing declarations as functions is misleading |
| `scalar_declaration` missing from all captures | Low | Added as `@class.outer` only (scalars have no body braces) |
| No `@parameter.inner` for fields | Medium | Added for all 8 field types, enum properties, and map key/value types |
| No `@assignment` for default values | Low | Added `@assignment.outer` (whole clause) and `@assignment.inner` (just the value) |

**Text object captures implemented**:

| Capture | Description |
|---|---|
| `@class.outer` | Entire declaration (concept, asset, participant, transaction, event, enum, map, scalar) including decorators |
| `@class.inner` | Body contents between `{` and `}`, excluding the braces themselves |
| `@block.outer` | Entire `{ }` block (class, enum, or map body) |
| `@block.inner` | Block contents excluding braces |
| `@parameter.inner` | Individual field declarations, enum values, map key/value entries |
| `@assignment.outer` | Entire `default = <value>` clause |
| `@assignment.inner` | Just the default value (string, boolean, integer, or real literal) |
| `@comment.outer` | Line or block comment |

**Key design decisions**:
- Used `#make-range!` directive (supported by nvim-treesitter-textobjects) to create inner ranges that properly exclude braces, following the same pattern used by the official C textobjects
- Empty bodies (e.g., `concept Empty {}`) gracefully produce no inner match, which is correct — there is nothing to select
- Added a documentation note that `#make-range!` is not supported by mini.ai
- Validated all queries against every example `.cto` file with `tree-sitter query` — zero errors

### Phase 8: Testing & CI

**Objective**: Add comprehensive testing beyond the corpus tests, and set up continuous integration.

**Actions**:
1. Created syntax highlighting assertion tests in `test/highlight/` (4 files, 129 assertions)
2. Created query validation test script `test/test-queries.sh` (53 tests)
3. Fixed a bug in `highlights.scm` where standalone `"@" @punctuation.special` was overriding decorator `@attribute` captures, leaving decorator names unhighlighted
4. Added `.gitignore` for the project
5. Set up GitHub Actions CI pipeline (`.github/workflows/ci.yml`)
6. Added npm scripts for running different test tiers

**Bug found and fixed**:
The highlight tests revealed that the standalone `"@" @punctuation.special` rule at the end of `highlights.scm` was taking precedence over the decorator pattern's `"@" @attribute` capture. In tree-sitter's highlight engine, later patterns override earlier ones for the same node, and this override was also preventing the decorator name's `@attribute` capture from being applied. The fix was to remove the standalone `"@" @punctuation.special` rule entirely.

**Test architecture**:

| Test Layer | Location | Count | Runner |
|---|---|---|---|
| Corpus tests | `test/corpus/*.txt` | 120 tests | `tree-sitter test` |
| Highlight tests | `test/highlight/*.cto` | 129 assertions | `tree-sitter test` (auto-discovered) |
| Query validation | `test/test-queries.sh` | 53 tests | `bash test/test-queries.sh` |
| **Total** | | **302 checks** | |

**CI pipeline** (`.github/workflows/ci.yml`):
- Multi-platform parser tests (ubuntu, macos, windows) using `tree-sitter/parser-test-action`
- Example file parsing using `tree-sitter/parse-action`
- Query validation using custom script

## Tools Used

| Tool | Version | Purpose |
|---|---|---|
| tree-sitter CLI | 0.26.7 | Grammar generation, testing, parsing |
| @accordproject/concerto-cli | 3.18.2 | Cross-validation of .cto files |
| Node.js | 25.8.1 | Runtime for CLI tools |

## Agent Collaboration Pattern

```
Architect Agent (orchestrator)
    |
    +-- Research: Fetched PEG grammar, docs, example models
    |
    +-- Implementation: Wrote grammar.js iteratively with generate/test cycles
    |
    +-- Senior Implementer Agent: Created 120-test corpus in parallel
    |
    +-- General Agent: Validated examples against both parsers in parallel
    |
    +-- Architect: Created highlights.scm, locals.scm, indents.scm, textobjects.scm
    |
    +-- Architect: Validated & rewrote textobjects.scm (Phase 7)
    |
    +-- Architect: Wrote README.md and agents.md
    |
    +-- Architect: Created highlight tests, query validation, CI pipeline (Phase 8)
```

## Metrics

- **Grammar size**: ~627 lines of JavaScript
- **Generated parser**: ~47,000 lines of C
- **Test corpus**: 120 tests across 12 files
- **Highlight tests**: 129 assertions across 4 files
- **Query validation tests**: 53 tests
- **Total test checks**: 302
- **Test pass rate**: 100%
- **Example files**: 6 validated .cto files
- **Syntax highlighting queries**: 230+ lines covering all node types
- **Text object queries**: 128 lines, 5 capture groups (`@class`, `@block`, `@parameter`, `@assignment`, `@comment`)
- **Development time**: Single session, iterative approach
- **Conflicts in grammar**: 0 (clean generation)
