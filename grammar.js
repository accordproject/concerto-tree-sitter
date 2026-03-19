/**
 * @file Tree-sitter grammar for the Concerto Modelling Language
 * @author Accord Project Contributors
 * @license Apache-2.0
 *
 * Concerto is a lightweight data modeling (schema) language and runtime
 * for business concepts, maintained by the Accord Project.
 *
 * This grammar is based on the official PEG grammar from:
 * https://github.com/accordproject/concerto/blob/main/packages/concerto-cto/lib/parser.pegjs
 *
 * @see https://concerto.accordproject.org/docs/intro
 */

/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

export default grammar({
  name: "concerto",

  extras: $ => [
    /\s/,
    $.line_comment,
    $.block_comment,
  ],

  word: $ => $._identifier_token,

  conflicts: $ => [],

  rules: {
    // ========================================================================
    // Top-level: A model file
    // ========================================================================
    source_file: $ => seq(
      optional($.concerto_version),
      optional($.decorators),
      $.namespace_declaration,
      optional($.import_list),
      optional($.declaration_list),
    ),

    // ========================================================================
    // Concerto Version Statement
    // ========================================================================
    concerto_version: $ => seq(
      "concerto",
      "version",
      $.string_literal,
    ),

    // ========================================================================
    // Namespace
    // ========================================================================
    namespace_declaration: $ => seq(
      "namespace",
      $.namespace_path,
    ),

    // A namespace path like: org.accordproject.finance@1.0.0
    // We use a single token to avoid ambiguity with decorators' @
    namespace_path: $ => /[a-zA-Z_$][a-zA-Z0-9_$]*(\.[a-zA-Z_$][a-zA-Z0-9_$]*)*(@[0-9]+\.[0-9x]+(\.[0-9x]+)?(-[a-zA-Z0-9._-]+)?(\+[a-zA-Z0-9._-]+)?)?/,

    // ========================================================================
    // Imports
    // ========================================================================
    import_list: $ => repeat1($._import),

    _import: $ => choice(
      $.import_all,
      $.import_types,
      $.import_single,
    ),

    // import org.example@1.0.0.*
    import_all: $ => seq(
      "import",
      $.import_path,
      ".",
      "*",
      optional($.from_uri),
    ),

    // import org.example@1.0.0.{Foo, Bar, Baz as Qux}
    import_types: $ => seq(
      "import",
      $.import_path,
      token.immediate(".{"),
      $.type_list,
      "}",
      optional($.from_uri),
    ),

    // import org.example@1.0.0.Foo
    import_single: $ => seq(
      "import",
      $.import_path,
      ".",
      field("type", $.identifier),
      optional($.from_uri),
    ),

    // Fully-qualified namespace path used in imports (same pattern as namespace_path)
    import_path: $ => /[a-zA-Z_$][a-zA-Z0-9_$]*(\.[a-zA-Z_$][a-zA-Z0-9_$]*)*(@[0-9]+\.[0-9x]+(\.[0-9x]+)?(-[a-zA-Z0-9._-]+)?(\+[a-zA-Z0-9._-]+)?)?/,

    type_list: $ => seq(
      $.type_list_item,
      repeat(seq(",", $.type_list_item)),
    ),

    type_list_item: $ => choice(
      $.aliased_type,
      $.identifier,
    ),

    aliased_type: $ => seq(
      field("original", $.identifier),
      "as",
      field("alias", $.identifier),
    ),

    from_uri: $ => seq(
      "from",
      $.uri,
    ),

    uri: $ => /[a-zA-Z][a-zA-Z0-9+\-.]*:\/\/[^\s]+/,

    // ========================================================================
    // Declarations (top-level type definitions)
    // ========================================================================
    declaration_list: $ => repeat1($._declaration),

    _declaration: $ => choice(
      $.concept_declaration,
      $.asset_declaration,
      $.participant_declaration,
      $.transaction_declaration,
      $.event_declaration,
      $.enum_declaration,
      $.scalar_declaration,
      $.map_declaration,
    ),

    // ========================================================================
    // Concept Declaration
    // ========================================================================
    concept_declaration: $ => seq(
      optional($.decorators),
      optional("abstract"),
      "concept",
      field("name", $.type_identifier),
      optional($._identifier_declaration),
      optional($.extends_clause),
      $.class_body,
    ),

    // ========================================================================
    // Asset Declaration
    // ========================================================================
    asset_declaration: $ => seq(
      optional($.decorators),
      optional("abstract"),
      "asset",
      field("name", $.type_identifier),
      optional($._identifier_declaration),
      optional($.extends_clause),
      $.class_body,
    ),

    // ========================================================================
    // Participant Declaration
    // ========================================================================
    participant_declaration: $ => seq(
      optional($.decorators),
      optional("abstract"),
      "participant",
      field("name", $.type_identifier),
      optional($._identifier_declaration),
      optional($.extends_clause),
      $.class_body,
    ),

    // ========================================================================
    // Transaction Declaration
    // ========================================================================
    transaction_declaration: $ => seq(
      optional($.decorators),
      optional("abstract"),
      "transaction",
      field("name", $.type_identifier),
      optional($._identifier_declaration),
      optional($.extends_clause),
      $.class_body,
    ),

    // ========================================================================
    // Event Declaration
    // ========================================================================
    event_declaration: $ => seq(
      optional($.decorators),
      optional("abstract"),
      "event",
      field("name", $.type_identifier),
      optional($._identifier_declaration),
      optional($.extends_clause),
      $.class_body,
    ),

    // ========================================================================
    // Enum Declaration
    // ========================================================================
    enum_declaration: $ => seq(
      optional($.decorators),
      "enum",
      field("name", $.type_identifier),
      $.enum_body,
    ),

    enum_body: $ => seq(
      "{",
      repeat($.enum_property),
      "}",
    ),

    enum_property: $ => seq(
      optional($.decorators),
      "o",
      field("name", $.identifier),
    ),

    // ========================================================================
    // Scalar Declaration
    // ========================================================================
    scalar_declaration: $ => seq(
      optional($.decorators),
      "scalar",
      field("name", $.type_identifier),
      "extends",
      $._scalar_type,
    ),

    _scalar_type: $ => choice(
      $.boolean_scalar,
      $.integer_scalar,
      $.long_scalar,
      $.double_scalar,
      $.string_scalar,
      $.datetime_scalar,
    ),

    boolean_scalar: $ => seq(
      "Boolean",
      optional($.boolean_default),
    ),

    integer_scalar: $ => seq(
      "Integer",
      optional($.integer_default),
      optional($.range_validator),
    ),

    long_scalar: $ => seq(
      "Long",
      optional($.integer_default),
      optional($.range_validator),
    ),

    double_scalar: $ => seq(
      "Double",
      optional($.real_default),
      optional($.range_validator),
    ),

    string_scalar: $ => seq(
      "String",
      optional($.string_default),
      optional($.regex_validator),
      optional($.length_validator),
    ),

    datetime_scalar: $ => seq(
      "DateTime",
      optional($.string_default),
    ),

    // ========================================================================
    // Map Declaration
    // ========================================================================
    map_declaration: $ => seq(
      optional($.decorators),
      "map",
      field("name", $.type_identifier),
      $.map_body,
    ),

    map_body: $ => seq(
      "{",
      $.map_key_type,
      $.map_value_type,
      "}",
    ),

    map_key_type: $ => seq(
      optional($.decorators),
      "o",
      field("type", $._map_key_type_name),
    ),

    _map_key_type_name: $ => choice(
      alias("String", $.primitive_type),
      alias("DateTime", $.primitive_type),
      $.type_identifier,
    ),

    map_value_type: $ => choice(
      $.map_value_property,
      $.map_value_relationship,
    ),

    map_value_property: $ => seq(
      optional($.decorators),
      "o",
      field("type", $._map_value_type_name),
    ),

    map_value_relationship: $ => seq(
      optional($.decorators),
      "-->",
      field("type", $.type_identifier),
    ),

    _map_value_type_name: $ => choice(
      alias("Boolean", $.primitive_type),
      alias("String", $.primitive_type),
      alias("DateTime", $.primitive_type),
      alias("Integer", $.primitive_type),
      alias("Long", $.primitive_type),
      alias("Double", $.primitive_type),
      $.type_identifier,
    ),

    // ========================================================================
    // Shared: Class body, extends, identified
    // ========================================================================
    class_body: $ => seq(
      "{",
      repeat($._field_declaration),
      "}",
    ),

    extends_clause: $ => seq(
      "extends",
      $.type_identifier,
    ),

    _identifier_declaration: $ => choice(
      $.identified_by,
      $.identified,
    ),

    identified_by: $ => seq(
      "identified",
      "by",
      field("field", $.identifier),
    ),

    identified: $ => "identified",

    // ========================================================================
    // Field / Property Declarations
    // ========================================================================
    _field_declaration: $ => choice(
      $.string_field,
      $.boolean_field,
      $.datetime_field,
      $.integer_field,
      $.long_field,
      $.double_field,
      $.object_field,
      $.relationship_field,
    ),

    string_field: $ => seq(
      optional($.decorators),
      "o",
      "String",
      optional($.array_indicator),
      field("name", $.identifier),
      optional($.string_default),
      optional($.regex_validator),
      optional($.length_validator),
      optional("optional"),
    ),

    boolean_field: $ => seq(
      optional($.decorators),
      "o",
      "Boolean",
      optional($.array_indicator),
      field("name", $.identifier),
      optional($.boolean_default),
      optional("optional"),
    ),

    datetime_field: $ => seq(
      optional($.decorators),
      "o",
      "DateTime",
      optional($.array_indicator),
      field("name", $.identifier),
      optional($.string_default),
      optional("optional"),
    ),

    integer_field: $ => seq(
      optional($.decorators),
      "o",
      "Integer",
      optional($.array_indicator),
      field("name", $.identifier),
      optional($.integer_default),
      optional($.range_validator),
      optional("optional"),
    ),

    long_field: $ => seq(
      optional($.decorators),
      "o",
      "Long",
      optional($.array_indicator),
      field("name", $.identifier),
      optional($.integer_default),
      optional($.range_validator),
      optional("optional"),
    ),

    double_field: $ => seq(
      optional($.decorators),
      "o",
      "Double",
      optional($.array_indicator),
      field("name", $.identifier),
      optional($.real_default),
      optional($.range_validator),
      optional("optional"),
    ),

    object_field: $ => seq(
      optional($.decorators),
      "o",
      field("type", $.type_identifier),
      optional($.array_indicator),
      field("name", $.identifier),
      optional($.string_default),
      optional("optional"),
    ),

    relationship_field: $ => seq(
      optional($.decorators),
      "-->",
      field("type", $.type_identifier),
      optional($.array_indicator),
      field("name", $.identifier),
      optional("optional"),
    ),

    array_indicator: $ => "[]",

    // ========================================================================
    // Defaults
    // ========================================================================
    string_default: $ => seq(
      "default",
      "=",
      $.string_literal,
    ),

    boolean_default: $ => seq(
      "default",
      "=",
      $.boolean_literal,
    ),

    integer_default: $ => seq(
      "default",
      "=",
      $.signed_integer,
    ),

    real_default: $ => seq(
      "default",
      "=",
      $.signed_real,
    ),

    // ========================================================================
    // Validators
    // ========================================================================
    regex_validator: $ => seq(
      "regex",
      "=",
      $.regex_literal,
    ),

    length_validator: $ => seq(
      "length",
      "=",
      "[",
      optional(field("min", $.signed_integer)),
      ",",
      optional(field("max", $.signed_integer)),
      "]",
    ),

    range_validator: $ => seq(
      "range",
      "=",
      "[",
      optional(field("lower", $.signed_real)),
      ",",
      optional(field("upper", $.signed_real)),
      "]",
    ),

    // ========================================================================
    // Decorators
    // ========================================================================
    decorators: $ => repeat1($.decorator),

    decorator: $ => seq(
      "@",
      field("name", $.identifier),
      optional($.decorator_arguments),
    ),

    decorator_arguments: $ => seq(
      "(",
      optional($.decorator_arg_list),
      ")",
    ),

    decorator_arg_list: $ => seq(
      $._decorator_literal,
      repeat(seq(",", $._decorator_literal)),
    ),

    _decorator_literal: $ => choice(
      $.decorator_string,
      $.decorator_number,
      $.decorator_boolean,
      $.decorator_identifier_ref,
    ),

    decorator_string: $ => $.string_literal,

    decorator_number: $ => $.signed_number,

    decorator_boolean: $ => $.boolean_literal,

    decorator_identifier_ref: $ => seq(
      $.type_identifier,
      optional($.array_indicator),
    ),

    // ========================================================================
    // Identifiers
    // ========================================================================
    type_identifier: $ => alias($._identifier_token, $.identifier),

    _identifier_token: $ => /[a-zA-Z_$][a-zA-Z0-9_$]*/,

    identifier: $ => $._identifier_token,

    // ========================================================================
    // Literals
    // ========================================================================
    string_literal: $ => choice(
      seq('"', optional($.string_content_double), '"'),
      seq("'", optional($.string_content_single), "'"),
    ),

    string_content_double: $ => repeat1(choice(
      /[^"\\]+/,
      $.escape_sequence,
    )),

    string_content_single: $ => repeat1(choice(
      /[^'\\]+/,
      $.escape_sequence,
    )),

    escape_sequence: $ => token(seq(
      "\\",
      choice(
        /['"\\bfnrtv0]/,
        /x[0-9a-fA-F]{2}/,
        /u[0-9a-fA-F]{4}/,
        /\r?\n/,
      ),
    )),

    boolean_literal: $ => choice("true", "false"),

    signed_integer: $ => /[+-]?[0-9]+/,

    signed_real: $ => /[+-]?[0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?/,

    signed_number: $ => /[+-]?[0-9]+(\.[0-9]*)?([eE][+-]?[0-9]+)?/,

    regex_literal: $ => /\/[^\/\n]+\/[gimsuy]*/,

    // ========================================================================
    // Comments
    // ========================================================================
    line_comment: $ => token(seq(
      "//",
      /[^\n]*/,
    )),

    block_comment: $ => token(seq(
      "/*",
      /[^*]*\*+([^/*][^*]*\*+)*/,
      "/",
    )),
  },
});
