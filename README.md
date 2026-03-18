# tree-sitter-concerto

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0)

A [Tree-sitter](https://tree-sitter.github.io/tree-sitter/) grammar and parser for the [Concerto Modelling Language](https://concerto.accordproject.org/) by the [Accord Project](https://www.accordproject.org/).

Concerto is a lightweight, object-oriented data modeling (schema) language designed for business concepts. It is used to define the structure of data in smart legal contracts, supply chain applications, and other business automation systems. Files use the `.cto` extension.

## Features

- **Complete grammar** covering the full Concerto CTO language specification
- **120 tests** in the test corpus, all passing
- **Syntax highlighting queries** for editor integration
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
  queries/
    highlights.scm    # Syntax highlighting queries
    locals.scm        # Scope/definition/reference queries
    indents.scm       # Auto-indentation queries
  test/
    corpus/           # Tree-sitter test corpus (120 tests)
      namespace.txt
      imports.txt
      concepts.txt
      enums.txt
      scalars.txt
      maps.txt
      assets_participants.txt
      fields.txt
      decorators.txt
      comments.txt
      concerto_version.txt
      validators.txt
  examples/           # Example .cto files (validated with concerto-cli)
    basic.cto
    advanced.cto
    decorators.cto
    imports.cto
    scalars.cto
    maps.cto
  src/                # Generated C parser (auto-generated, do not edit)
```

## Editor Integration

### Neovim (nvim-treesitter)

Add the parser to your nvim-treesitter configuration:

```lua
local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.concerto = {
  install_info = {
    url = "https://github.com/accordproject/tree-sitter-concerto",
    files = { "src/parser.c" },
    branch = "main",
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  },
  filetype = "concerto",
}

-- Associate .cto files with the concerto filetype
vim.filetype.add({
  extension = {
    cto = "concerto",
  },
})
```

### Helix

Add to your `languages.toml`:

```toml
[[language]]
name = "concerto"
scope = "source.concerto"
file-types = ["cto"]
comment-token = "//"
indent = { tab-width = 2, unit = "  " }

[[grammar]]
name = "concerto"
source = { git = "https://github.com/accordproject/tree-sitter-concerto", rev = "main" }
```

### Emacs (tree-sitter)

```elisp
(add-to-list 'treesit-language-source-alist
  '(concerto "https://github.com/accordproject/tree-sitter-concerto"))
```

## Development

### Grammar Design Decisions

The grammar is based on the [official PEG grammar](https://github.com/accordproject/concerto/blob/main/packages/concerto-cto/lib/parser.pegjs) from the Concerto project, translated into tree-sitter's JavaScript DSL.

Key design choices:

1. **Namespace/import paths as tokens**: The dotted namespace path (e.g., `org.accordproject.money@1.0.0`) is captured as a single token to avoid ambiguity between the `@` in version tags and the `@` prefix for decorators.

2. **Distinct field nodes per type**: Rather than a single generic "field" node, each primitive type gets its own node type (`string_field`, `integer_field`, `double_field`, etc.). This enables precise syntax highlighting and type-specific validation (e.g., range validators only on numeric fields).

3. **Keyword word boundary**: The grammar uses `word: $ => $._identifier_token` to ensure keywords like `concept`, `enum`, `abstract` are only recognized as keywords when they appear as complete words, not as prefixes of identifiers.

### Validation

Example `.cto` files are cross-validated against the official Concerto parser:

```bash
# Validate with the official Concerto CLI
npx concerto parse --model examples/basic.cto

# Parse with tree-sitter
tree-sitter parse examples/basic.cto
```

### Running Tests

```bash
tree-sitter test
```

The test corpus contains 120 tests covering:
- All declaration types (concept, asset, participant, transaction, event, enum, scalar, map)
- All field types with arrays, optionals, defaults, and validators
- All import styles (single, wildcard, multi-type, aliased, with URIs)
- Decorators with all argument types
- Comments (line and block)
- Concerto version statements
- Edge cases and combinations

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
