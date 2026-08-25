;;; concerto-ts-mode.el --- Tree-sitter major mode for Concerto CTO -*- lexical-binding: t; -*-

;; Copyright 2026 Accord Project Contributors

;; Author: Accord Project Contributors
;; Maintainer: Accord Project Contributors
;; SPDX-License-Identifier: Apache-2.0
;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: languages
;; URL: https://github.com/accordproject/concerto-tree-sitter

;;; Commentary:

;; Major mode for editing Concerto CTO files using Emacs 29+'s built-in
;; tree-sitter support.

;;; Code:

(require 'treesit)

(defgroup concerto-ts nil
  "Tree-sitter support for the Concerto CTO language."
  :group 'languages
  :prefix "concerto-ts-")

(defcustom concerto-ts-mode-indent-offset 2
  "Number of spaces used for indentation in `concerto-ts-mode'."
  :type 'integer
  :safe 'integerp
  :group 'concerto-ts)

(defvar concerto-ts-mode--syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23" table)
    (modify-syntax-entry ?\n "> b" table)
    table)
  "Syntax table for `concerto-ts-mode'.")

(defvar concerto-ts-mode--font-lock-settings
  (treesit-font-lock-rules
   :language 'concerto
   :feature 'comment
   '([(line_comment) (block_comment)] @font-lock-comment-face)

   :language 'concerto
   :feature 'keyword
   '(["abstract" "as" "asset" "by" "concept" "concerto" "default"
      "enum" "event" "extends" "from" "identified" "import" "length"
      "map" "namespace" "optional" "participant" "range" "regex"
      "scalar" "transaction" "version"]
     @font-lock-keyword-face)

   :language 'concerto
   :feature 'type
   '(["Boolean" "DateTime" "Double" "Integer" "Long" "String"]
     @font-lock-builtin-face
     (primitive_type) @font-lock-builtin-face
     (concept_declaration name: (type_identifier) @font-lock-type-face)
     (asset_declaration name: (type_identifier) @font-lock-type-face)
     (participant_declaration name: (type_identifier) @font-lock-type-face)
     (transaction_declaration name: (type_identifier) @font-lock-type-face)
     (event_declaration name: (type_identifier) @font-lock-type-face)
     (enum_declaration name: (type_identifier) @font-lock-type-face)
     (scalar_declaration name: (type_identifier) @font-lock-type-face)
     (map_declaration name: (type_identifier) @font-lock-type-face)
     (extends_clause (type_identifier) @font-lock-type-face)
     (object_field type: (type_identifier) @font-lock-type-face)
     (relationship_field type: (type_identifier) @font-lock-type-face)
     (map_key_type type: (type_identifier) @font-lock-type-face)
     (map_value_property type: (type_identifier) @font-lock-type-face)
     (map_value_relationship type: (type_identifier) @font-lock-type-face)
     (decorator_identifier_ref (type_identifier) @font-lock-type-face)
     (import_single type: (identifier) @font-lock-type-face)
     (type_list_item (identifier) @font-lock-type-face)
     (aliased_type
      original: (identifier) @font-lock-type-face
      alias: (identifier) @font-lock-type-face))

   :language 'concerto
   :feature 'property
   '((string_field name: (identifier) @font-lock-property-name-face)
     (boolean_field name: (identifier) @font-lock-property-name-face)
     (datetime_field name: (identifier) @font-lock-property-name-face)
     (integer_field name: (identifier) @font-lock-property-name-face)
     (long_field name: (identifier) @font-lock-property-name-face)
     (double_field name: (identifier) @font-lock-property-name-face)
     (object_field name: (identifier) @font-lock-property-name-face)
     (relationship_field name: (identifier) @font-lock-property-name-face)
     (enum_property name: (identifier) @font-lock-property-name-face)
     (identified_by field: (identifier) @font-lock-property-name-face))

   :language 'concerto
   :feature 'decorator
   '((decorator "@" @font-lock-preprocessor-face
                name: (identifier) @font-lock-preprocessor-face))

   :language 'concerto
   :feature 'constant
   '((boolean_literal) @font-lock-constant-face
     (namespace_path) @font-lock-constant-face
     (import_path) @font-lock-constant-face)

   :language 'concerto
   :feature 'literal
   '((string_literal) @font-lock-string-face
     (escape_sequence) @font-lock-string-face
     (regex_literal) @font-lock-string-face
     (uri) @font-lock-string-face
     (signed_integer) @font-lock-number-face
     (signed_real) @font-lock-number-face
     (signed_number) @font-lock-number-face))
  "Tree-sitter font-lock settings for `concerto-ts-mode'.")

(defvar concerto-ts-mode--indent-rules
  `((concerto
     ((node-is "}") parent-bol 0)
     ((node-is ")") parent-bol 0)
     ((parent-is "class_body") parent-bol concerto-ts-mode-indent-offset)
     ((parent-is "enum_body") parent-bol concerto-ts-mode-indent-offset)
     ((parent-is "map_body") parent-bol concerto-ts-mode-indent-offset)
     ((parent-is "decorator_arguments") parent-bol concerto-ts-mode-indent-offset)))
  "Tree-sitter indentation rules for `concerto-ts-mode'.")

(defvar concerto-ts-mode--imenu-settings
  `(("Concept" "\\`concept_declaration\\'" nil nil)
    ("Asset" "\\`asset_declaration\\'" nil nil)
    ("Participant" "\\`participant_declaration\\'" nil nil)
    ("Transaction" "\\`transaction_declaration\\'" nil nil)
    ("Event" "\\`event_declaration\\'" nil nil)
    ("Enum" "\\`enum_declaration\\'" nil nil)
    ("Scalar" "\\`scalar_declaration\\'" nil nil)
    ("Map" "\\`map_declaration\\'" nil nil))
  "Tree-sitter Imenu settings for `concerto-ts-mode'.")

;;;###autoload
(define-derived-mode concerto-ts-mode prog-mode "Concerto"
  "Major mode for editing Concerto CTO files."
  :syntax-table concerto-ts-mode--syntax-table
  (unless (treesit-ready-p 'concerto)
    (user-error "Tree-sitter grammar for Concerto is not installed"))
  (treesit-parser-create 'concerto)
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "\\(?://+\\|/\\*+\\)\\s *")
  (setq-local block-comment-start "/* ")
  (setq-local block-comment-end " */")
  (setq-local treesit-font-lock-settings concerto-ts-mode--font-lock-settings)
  (setq-local treesit-font-lock-feature-list
              '((comment)
                (keyword type property)
                (decorator constant literal)))
  (setq-local treesit-simple-indent-rules concerto-ts-mode--indent-rules)
  (setq-local treesit-simple-imenu-settings concerto-ts-mode--imenu-settings)
  (treesit-major-mode-setup))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.cto\\'" . concerto-ts-mode))

(provide 'concerto-ts-mode)

;;; concerto-ts-mode.el ends here
