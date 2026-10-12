; extends

; github actions
([
  (string_scalar)
  (block_scalar)
  (double_quote_scalar)
  (single_quote_scalar)
  (ERROR)
] @injection.content
  (#lua-match? @injection.content "[$]{{")
  (#set! injection.language "ghactions"))

; jinja (ansible)
([
  (string_scalar)
  (block_scalar)
  (double_quote_scalar)
  (single_quote_scalar)
] @injection.content
  (#lua-match? @injection.content "[^$]{[%%{].*[%%}]}")
  (#set! injection.language "jinja"))
