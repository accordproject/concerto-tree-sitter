; Concerto Language - Indent Queries
; ===================================
; Indent inside declaration bodies
[
  (class_body)
  (enum_body)
  (map_body)
  (decorator_arguments)
] @indent

; Outdent at closing braces
[
  "}"
  ")"
] @outdent
