# tree-sitter-concerto

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar and parser for the [Concerto Modelling Language](https://concerto.accordproject.org/) by the [Accord Project](https://www.accordproject.org/).

Concerto is a lightweight, object-oriented data modeling (schema) language designed for business concepts. It is used to define the structure of data in smart legal contracts, supply chain applications, and other business automation systems. Files use the `.cto` extension.

## Features

- **Complete grammar** covering the full Concerto CTO language specification
- **120 corpus tests** all passing, plus **129 highlight assertions** and **63 query validation tests**
- **CI pipeline** via GitHub Actions (multi-platform parser tests, query validation)
- **Syntax highlighting queries** for editor integration
- **Text object queries** for structural editing (compatible with nvim-treesitter-textobjects and Helix)
- **Fold queries** for code folding
- **Locals queries** for scope-aware features
- **Indent queries** for auto-indentation
- **Cross-validated** against the official `@accordproject/concerto-cli` parser

### Supported Language Constructs

| Construct | Status |
|---|---|
| Namespace declarations (versioned) | Supported |
| Imports (single, wildcard, multiple, aliased, with URI) | Supported |
| Concerto version statement | Supported |
| Concept declarations | Supported |
| Asset declarations | Supported |
| Participant declarations | Supported |
| Transaction declarations | Supported |
| Event declarations | Supported |
| Enum declarations | Supported |
| Scalar declarations (all primitive types) | Supported |
| Map declarations | Supported |
| All primitive types (String, Boolean, DateTime, Integer, Long, Double) | Supported |
| Object (reference) fields | Supported |
| Relationship fields (`-->`) | Supported |
| Array fields (`[]`) | Supported |
| Optional fields | Supported |
| Default values | Supported |
| Range validators | Supported |
| Regex validators | Supported |
| Length validators | Supported |
| Decorators (with all argument types) | Supported |
| `abstract` modifier | Supported |
| `extends` clause | Supported |
| `identified` / `identified by` | Supported |
| Line comments (`//`) | Supported |
| Block comments (`/* */`) | Supported |

## Quick Start

### Prerequisites

- [Node.js](https://nodejs.org/) v16+
- [tree-sitter CLI](https://tree-sitter.github.io/tree-sitter/cli/installation.html)

### Installation

```bash
# Clone the repository
git clone https://github.com/accordproject/tree-sitter-concerto.git
cd tree-sitter-concerto

# Install dependencies
npm install --ignore-scripts

# Generate the parser
tree-sitter generate
```

### Usage

#### Parse a Concerto file

```bash
tree-sitter parse examples/basic.cto
```

#### Run the test suite

```bash
tree-sitter test
```

#### View syntax highlighting

```bash
tree-sitter highlight examples/basic.cto
```

#### Launch the interactive playground

```bash
npm run prestart  # builds wasm first
npm start
```

## Example

Here is a simple Concerto model:

```concerto
namespace test@1.0.0

enum Country {
  o UK
  o USA
  o FRANCE
}

concept Address {
  o String street
  o String city
  o String postCode
  o Country country
}

concept Person identified by name {
  o String name
  o Address address optional
  @description("Height (cm)")
  o Double height range=[0.0,]
  o DateTime dateOfBirth
}
```

The parser produces a concrete syntax tree like:

```
(source_file
  (namespace_declaration
    (namespace_path))
  (declaration_list
    (enum_declaration
      name: (type_identifier (identifier))
      (enum_body
        (enum_property name: (identifier))
        (enum_property name: (identifier))
        (enum_property name: (identifier))))
    (concept_declaration
      name: (type_identifier (identifier))
      (class_body
        (string_field name: (identifier))
        (string_field name: (identifier))
        (string_field name: (identifier))
        (object_field
          type: (type_identifier (identifier))
          name: (identifier))))
    (concept_declaration
      name: (type_identifier (identifier))
      (identified_by field: (identifier))
      (class_body
        (string_field name: (identifier))
        (object_field
          type: (type_identifier (identifier))
          name: (identifier))
        (double_field
          (decorators
            (decorator
              name: (identifier)
              (decorator_arguments
                (decorator_arg_list
                  (decorator_string
                    (string_literal (string_content_double)))))))
          name: (identifier)
          (range_validator lower: (signed_real)))
        (datetime_field name: (identifier))))))
```

## Project Structure

```
tree-sitter-concerto/
  grammar.js          # The tree-sitter grammar definition
  tree-sitter.json    # Tree-sitter configuration
  package.json        # Node.js package manifest
  .github/
    workflows/
      ci.yml          # GitHub Actions CI pipeline
  queries/
    highlights.scm    # Syntax highlighting queries
    textobjects.scm   # Text object queries (Neovim + Helix compatible)
    locals.scm        # Scope/definition/reference queries
    indents.scm       # Auto-indentation queries
    folds.scm         # Code folding queries
  test/
    corpus/           # Tree-sitter test corpus (120 tests)
    highlight/        # Syntax highlighting assertion tests (129 assertions)
    test-queries.sh   # Query validation test script (63 tests)
  examples/           # Example .cto files (validated with concerto-cli)
  src/                # Generated C parser (auto-generated, do not edit)
```

## Text Objects

The `queries/textobjects.scm` file provides structural text objects compatible with both [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) and [Helix](https://helix-editor.com/) using a dual-capture naming pattern.

Each node carries both naming conventions (e.g. `@class.outer @class.around`). Each editor reads only the captures it recognises and ignores the rest.

| Concept | Neovim captures | Helix captures | Description |
|---|---|---|---|
| Class | `@class.outer` / `@class.inner` | `@class.around` / `@class.inside` | concept, asset, participant, transaction, event, enum, map, scalar |
| Block | `@block.outer` / `@block.inner` | — | class, enum, and map bodies (Neovim only) |
| Parameter | `@parameter.inner` | `@parameter.inside` | All field types, enum values, map key/value types |
| Assignment | `@assignment.outer` / `@assignment.inner` | — | Default value clauses (Neovim only) |
| Comment | `@comment.outer` | `@comment.around` / `@comment.inside` | Line and block comments |

**Neovim keybindings** (with nvim-treesitter-textobjects):
- `vic` — select the fields inside a concept (excluding braces)
- `vac` — select an entire declaration including its decorators
- `]c` / `[c` — jump to the next / previous declaration
- `dap` — delete a single field declaration
- `cia` — change the value in a `default = ...` clause

**Helix keybindings**:
- `]c` / `[c` — jump to next / previous declaration
- `mac` / `mic` — select around / inside a declaration
- `]a` / `[a` — jump to next / previous parameter (field)
- `]C` / `[C` — jump to next / previous comment

## Editor Integration

### Neovim

#### Option A: Using nvim-treesitter (recommended)

Register the parser and filetype in your Neovim config:

```lua
-- Register the concerto parser with nvim-treesitter
vim.treesitter.language.register("concerto", "concerto")

-- Associate .cto files with the concerto filetype
vim.filetype.add({
  extension = {
    cto = "concerto",
  },
})
```

Then install the parser:

```vim
:TSInstall concerto
```

If the parser is not yet in the nvim-treesitter registry, you can add it manually:

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.concerto = {
  install_info = {
    url = "https://github.com/accordproject/tree-sitter-concerto",
    files = { "src/parser.c" },
    branch = "main",
  },
  filetype = "concerto",
}
```

#### Option B: Using Neovim's built-in treesitter (no plugins)

Neovim 0.10+ can install parsers directly:

```lua
-- In your init.lua
vim.filetype.add({ extension = { cto = "concerto" } })

-- Install the parser (run once)
-- :lua vim.treesitter.language.add("concerto", { path = "/path/to/concerto.so" })
```

Build the shared library:

```bash
git clone https://github.com/accordproject/tree-sitter-concerto
cd tree-sitter-concerto
tree-sitter generate
cc -shared -fPIC -o concerto.so src/parser.c -I src
```

Then copy `concerto.so` to your Neovim parser directory and the `queries/` files to your runtime queries directory.

### Helix

Add to your `~/.config/helix/languages.toml`:

```toml
[[language]]
name = "concerto"
scope = "source.concerto"
file-types = ["cto"]
comment-token = "//"
indent = { tab-width = 2, unit = "  " }
roots = ["package.json"]

[[grammar]]
name = "concerto"
source = { git = "https://github.com/accordproject/tree-sitter-concerto", rev = "main" }
```

Then fetch and build the grammar:

```bash
hx --grammar fetch
hx --grammar build
```

Copy the query files to your Helix runtime:

```bash
mkdir -p ~/.config/helix/runtime/queries/concerto
cp queries/highlights.scm ~/.config/helix/runtime/queries/concerto/
cp queries/textobjects.scm ~/.config/helix/runtime/queries/concerto/
cp queries/indents.scm ~/.config/helix/runtime/queries/concerto/
cp queries/locals.scm ~/.config/helix/runtime/queries/concerto/
```

### Emacs (tree-sitter)

```elisp
(add-to-list 'treesit-language-source-alist
  '(concerto "https://github.com/accordproject/tree-sitter-concerto"))

;; Install with: M-x treesit-install-language-grammar RET concerto RET
```

## Development

### Grammar Design Decisions

The grammar is based on the [official PEG grammar](https://github.com/accordproject/concerto/blob/main/packages/concerto-cto/lib/parser.pegjs) from the Concerto project, translated into tree-sitter's JavaScript DSL.

Key design choices:

1. **Namespace/import paths as tokens**: The dotted namespace path (e.g., `org.accordproject.money@1.0.0`) is captured as a single token to avoid ambiguity between the `@` in version tags and the `@` prefix for decorators.

2. **Distinct field nodes per type**: Rather than a single generic "field" node, each primitive type gets its own node type (`string_field`, `integer_field`, `double_field`, etc.). This enables precise syntax highlighting and type-specific validation (e.g., range validators only on numeric fields).

3. **Keyword word boundary**: The grammar uses `word: $ => $._identifier_token` to ensure keywords like `concept`, `enum`, `abstract` are only recognized as keywords when they appear as complete words, not as prefixes of identifiers.

### Validation

Example `.cto` files have been cross-validated against the official Concerto parser. To repeat this validation yourself, install the CLI separately (it is not a project dependency):

```bash
# Install the Concerto CLI globally (optional, for cross-validation only)
npm install -g @accordproject/concerto-cli

# Validate with the official Concerto CLI
concerto parse --model examples/basic.cto

# Parse with tree-sitter
tree-sitter parse examples/basic.cto
```

### Running Tests

```bash
# Run all tests (corpus + highlights + query validation)
npm test

# Run only corpus and highlight tests
npm run test:corpus

# Run only query validation tests
npm run test:queries
```

#### Test Suite

The project has three layers of testing:

**1. Corpus tests** (120 tests in `test/corpus/`)
- Tree structure assertions for all language constructs
- Covers all declaration types, field types, imports, decorators, validators, comments
- Run via `tree-sitter test`

**2. Highlight tests** (129 assertions in `test/highlight/`)
- Verifies syntax highlighting captures are correctly assigned
- Tests keyword, type, property, attribute, string, number, and punctuation highlighting
- Uses tree-sitter's built-in Sublime Text–style assertion format
- Run automatically as part of `tree-sitter test`

**3. Query validation tests** (63 tests in `test/test-queries.sh`)
- Verifies all 5 query files compile and execute against all 6 examples without errors
- Asserts expected textobject captures (`@class.outer`, `@class.inner`, `@block.outer`, `@block.inner`, `@parameter.inner`, `@assignment.*`, `@comment.outer`) are present
- Asserts expected fold captures are present
- Asserts expected highlight captures across all major categories
- Run via `bash test/test-queries.sh`

## About Concerto

Concerto is maintained by the [Accord Project](https://www.accordproject.org/), an open source, non-profit initiative working to transform contract management and contract automation by digitizing contracts. Accord Project operates under the umbrella of the [Linux Foundation](https://www.linuxfoundation.org/).

### Resources

- [Concerto Documentation](https://concerto.accordproject.org/docs/intro)
- [Concerto GitHub Repository](https://github.com/accordproject/concerto)
- [Accord Project Model Repository](https://models.accordproject.org)
- [Discord Community](https://discord.gg/Zm99SKhhtA)

## License

This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full text.

Copyright 2024-2026 Accord Project Contributors.
