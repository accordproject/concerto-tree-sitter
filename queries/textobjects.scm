; Concerto Language - Text Object Queries
; =========================================
; Compatible with nvim-treesitter-textobjects and Helix.
;
; Uses standard `_+ @capture` patterns (no custom directives).
; Works with Neovim 0.10+, nvim-treesitter-textobjects, and Helix.
;
; For Helix, map capture names: .outer -> .around, .inner -> .inside

; Classes / declarations (@class.outer, @class.inner)
; vac / vic — select whole declaration / body contents (excluding braces)

(concept_declaration
  (class_body
    .
    "{"
    _+ @class.inner
    "}")) @class.outer

(asset_declaration
  (class_body
    .
    "{"
    _+ @class.inner
    "}")) @class.outer

(participant_declaration
  (class_body
    .
    "{"
    _+ @class.inner
    "}")) @class.outer

(transaction_declaration
  (class_body
    .
    "{"
    _+ @class.inner
    "}")) @class.outer

(event_declaration
  (class_body
    .
    "{"
    _+ @class.inner
    "}")) @class.outer

(enum_declaration
  (enum_body
    .
    "{"
    _+ @class.inner
    "}")) @class.outer

(map_declaration
  (map_body
    .
    "{"
    _+ @class.inner
    "}")) @class.outer

; Scalar declarations have no body braces — outer only
(scalar_declaration) @class.outer

; Block (@block.outer, @block.inner)
; vab / vib — select whole block / block contents (excluding braces)

(class_body
  .
  "{"
  _+ @block.inner
  "}") @block.outer

(enum_body
  .
  "{"
  _+ @block.inner
  "}") @block.outer

(map_body
  .
  "{"
  _+ @block.inner
  "}") @block.outer

; Comments (@comment.outer)
(line_comment) @comment.outer
(block_comment) @comment.outer

; Parameters (@parameter.inner) — fields and enum values
; dap / vip — operate on individual field/property declarations
; These are the closest analog to "parameters" in a schema language

(string_field) @parameter.inner
(boolean_field) @parameter.inner
(datetime_field) @parameter.inner
(integer_field) @parameter.inner
(long_field) @parameter.inner
(double_field) @parameter.inner
(object_field) @parameter.inner
(relationship_field) @parameter.inner
(enum_property) @parameter.inner
(map_key_type) @parameter.inner
(map_value_type) @parameter.inner

; Assignment (@assignment.outer, @assignment.inner)
; daa / via — operate on default value clauses

(string_default
  "=" (_) @assignment.inner) @assignment.outer

(boolean_default
  "=" (_) @assignment.inner) @assignment.outer

(integer_default
  "=" (_) @assignment.inner) @assignment.outer

(real_default
  "=" (_) @assignment.inner) @assignment.outer
