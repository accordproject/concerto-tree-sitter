# Roadmap

Current status and future plans for `concerto-tree-sitter` — the tree-sitter grammar and editor ecosystem for the [Concerto Modelling Language](https://concerto.accordproject.org).

*Last updated: March 2026*

## Project Status

### Core Grammar & Tooling — ✅ Complete

The tree-sitter grammar is feature-complete, covering the full Concerto CTO language specification:

- **Grammar**: ~630 lines of JavaScript (ESM), zero conflicts
- **Generated parser**: ~11k lines of C
- **Test coverage**: 120 corpus tests, 129 highlight assertion tests, 71 query validation tests — all passing
- **Query files**: highlights, folds, locals, indents, textobjects
- **CI pipeline**: GitHub Actions with multi-platform parser tests (Linux, macOS, Windows), query validation, ts_query_ls lint, and Rust & Go binding tests

### Language Bindings — ✅ Complete

Standard tree-sitter bindings generated for 6 ecosystems:

| Ecosystem | Package file | CI tested |
|---|---|---|
| C | `CMakeLists.txt`, `Makefile` | — |
| Node.js | `package.json`, `binding.gyp` | — |
| Rust | `Cargo.toml` | ✅ |
| Python | `pyproject.toml`, `setup.py` | — |
| Go | `go.mod` | ✅ |
| Swift | `Package.swift` | — |

### Editor Support

| Editor | Status | Detail |
|---|---|---|
| **Neovim** | ✅ Works (manual install) | Parser + queries install via symlinks. Filetype detection requires `vim.filetype.add()` in user config. |
| **Helix** | ✅ Works (manual install) | Grammar configured in `~/.config/helix/languages.toml`. Helix-specific queries in `editor/helix/`. |
| **Zed** | ✅ Extension built | [accordproject/zed-concerto](https://github.com/accordproject/zed-concerto) — installable as dev extension. |
| **VS Code** | ✅ Extension exists | Maintained separately by the Accord Project. |
| **Emacs** | ⚠️ Basic | `treesit-language-source-alist` entry documented in README. No dedicated `concerto-ts-mode` ([#20]). |

## In Progress — Upstream Editor Submissions

### Helix — PR open ([#13])

- **PR**: [helix-editor/helix#15472](https://github.com/helix-editor/helix/pull/15472)
- **Status**: Open, awaiting maintainer review
- **What it adds**: `[[language]]` and `[[grammar]]` entries in `languages.toml`, plus highlights, textobjects, indents, and locals queries in `runtime/queries/concerto/`
- **Once merged**: `.cto` files will get syntax highlighting and text objects out of the box in Helix

### Zed — PR open ([#14])

- **PR**: [zed-industries/extensions#5310](https://github.com/zed-industries/extensions/pull/5310)
- **Status**: Open, awaiting review
- **What it adds**: `concerto` extension as a submodule + entry in `extensions.toml`
- **Once merged**: Installable from Zed's Extensions panel (search "Concerto")

### Vim/Neovim — PR open (prerequisite chain)

Getting `.cto` into nvim-treesitter requires a chain of upstream acceptances:

1. **Vim filetype detection** ([#15]) — [vim/vim#19760](https://github.com/vim/vim/pull/19760) (open)
   - Adds `*.cto → concerto` to `runtime/filetype.vim`
   - One-line change + test. CI passes (one unrelated flaky Windows test).

2. **Neovim port** — *waiting on step 1*
   - Once Vim merges the filetype, Neovim ports it to `runtime/lua/vim/filetype.lua`
   - Typically happens within a release cycle via a `vim-patch:X.X.XXXX` PR

3. **nvim-treesitter parser** ([#16]) — *waiting on step 2*
   - PR [nvim-treesitter/nvim-treesitter#8594](https://github.com/nvim-treesitter/nvim-treesitter/pull/8594) was submitted and closed — maintainer requires `.cto` to be an officially recognized filetype first
   - Fork at [jamieshorten/nvim-treesitter](https://github.com/jamieshorten/nvim-treesitter) is maintained with correct capture names and ready for resubmission

4. **nvim-treesitter-textobjects** ([#17]) — *waiting on step 3*
   - Textobjects are maintained in a separate repo (`nvim-treesitter/nvim-treesitter-textobjects`)
   - PR to be submitted after the parser is accepted

## Future Work

### Package Registry Publishing ([#18])

Publish the parser to package registries so it can be consumed as a dependency:

| Registry | Package name | Status |
|---|---|---|
| npm | `tree-sitter-concerto` | ❌ Not published |
| crates.io | `tree-sitter-concerto` | ❌ Not published |
| PyPI | `tree-sitter-concerto` | ❌ Not published |

This requires:
- CI workflows triggered on git tags for automated publishing
- Registry secrets (`NPM_TOKEN`, `CARGO_REGISTRY_TOKEN`, `PYPI_API_TOKEN`) configured in GitHub
- Version tagging strategy (semantic versioning)

### WASM Artifact ([#19])

Build and publish a `tree-sitter-concerto.wasm` artifact for web-tree-sitter consumers (web editors, playground, GitHub.dev):

- Add `tree-sitter build --wasm` to CI
- Attach `.wasm` to GitHub Releases

### Emacs Major Mode ([#20])

Create a dedicated `concerto-ts-mode` for Emacs with:
- Tree-sitter-based font-lock rules
- Imenu support (outline)
- Indentation
- Publish to MELPA

## Contributing

Contributions are welcome. See the [README](README.md) for development setup and testing instructions. All commits must include a DCO sign-off (`Signed-off-by:`).

<!-- Issue references -->
[#13]: https://github.com/accordproject/concerto-tree-sitter/issues/13
[#14]: https://github.com/accordproject/concerto-tree-sitter/issues/14
[#15]: https://github.com/accordproject/concerto-tree-sitter/issues/15
[#16]: https://github.com/accordproject/concerto-tree-sitter/issues/16
[#17]: https://github.com/accordproject/concerto-tree-sitter/issues/17
[#18]: https://github.com/accordproject/concerto-tree-sitter/issues/18
[#19]: https://github.com/accordproject/concerto-tree-sitter/issues/19
[#20]: https://github.com/accordproject/concerto-tree-sitter/issues/20
