; extends

;; Comments: hide only the comment text, not the whole line.
((comment) @comment
  (#set! conceal ""))

;; Module docstring
(module
  . (expression_statement (string) @string.documentation.python)
  (#set! conceal_lines ""))

;; Function docstring
(function_definition
  body: (block
    . (expression_statement (string) @string.documentation.python)
    (#set! conceal_lines "")))

;; Class docstring
(class_definition
  body: (block
    . (expression_statement (string) @string.documentation.python)
    (#set! conceal_lines "")))
