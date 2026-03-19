# Copilot Instructions for concerto-tree-sitter

## Project Overview

This is a tree-sitter grammar and parser for the Concerto Modelling Language (`.cto` files) by the Accord Project. It includes grammar definitions, comprehensive tests, syntax highlighting queries, and editor integration support for Neovim, Helix, and Emacs.

## Commit Requirements (MANDATORY)

This project follows the [Developer Certificate of Origin (DCO)](https://developercertificate.org/). **Every commit MUST include a DCO sign-off line.** Commits without a sign-off will be rejected by CI.

When creating or suggesting commits, ALWAYS include:

```
Signed-off-by: Jamie Shorten <jamie@jamieshorten.com>
```

as a trailer in the commit message. This applies to:
- Direct commits
- Squash commits
- Commits from code review suggestions
- Merge commits
- Any commit created by any means

### Example commit message

```
fix: correct Helix keybinding documentation

Update textobject keys to match Helix conventions.

Signed-off-by: Jamie Shorten <jamie@jamieshorten.com>
Co-authored-by: Copilot <175728472+Copilot@users.noreply.github.com>
```

## Tech Stack

- **Grammar**: tree-sitter JavaScript DSL (`grammar.js`, ESM)
- **Generated parser**: C (`src/parser.c` — auto-generated, do not edit)
- **Queries**: tree-sitter S-expression queries (`queries/*.scm`)
- **Language bindings**: C, Node.js, Rust, Python, Go, Swift (in `bindings/`)
- **Tests**: tree-sitter corpus tests (`test/corpus/`), highlight assertion tests (`test/highlight/`), shell-based query validation (`test/test-queries.sh`), Rust and Go binding tests
- **CLI**: tree-sitter CLI v0.26.7

## Testing

Always run tests after making changes:

```bash
tree-sitter test                # Corpus + highlight tests
bash test/test-queries.sh       # Query validation tests
cargo test                      # Rust binding test
```

## Key Files

- `grammar.js` — The grammar definition (source of truth, ESM)
- `queries/highlights.scm` — Syntax highlighting
- `queries/textobjects.scm` — Structural text objects (dual Neovim + Helix captures)
- `queries/locals.scm` — Scope and reference tracking
- `queries/indents.scm` — Auto-indentation
- `queries/folds.scm` — Code folding
- `src/` — Generated C parser (do not edit manually)
- `bindings/` — Language bindings (C, Node.js, Rust, Python, Go, Swift)
- `Cargo.toml` — Rust crate manifest
- `go.mod` — Go module manifest
- `pyproject.toml` — Python package manifest
- `Package.swift` — Swift package manifest

## Conventions

- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/) (e.g., `fix:`, `feat:`, `docs:`, `test:`)
- The grammar must generate with zero conflicts
- All tests must pass before merging
