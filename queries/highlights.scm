(ERROR) @error

(line_comment) @comment

(ident) @variable

(token) @string

(string_interpolation
  "${" @punctuation.special
  "}" @punctuation.special) @embedded

(escape_sequence) @constant.character.escape

(string
  [
    (unescaped_single_quote_string_fragment)
    (unescaped_double_quote_string_fragment)
    (unescaped_backtick_string_fragment)
    "\""
    "'"
    "`"
  ]) @string


(unary_expression
  operator: _ @operator)

(binary_expression
  operator: _ @operator)

[
  ":"
  ";"
  "."
  ","
  "="
] @punctuation.delimiter

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket
[
  ":"
  ";"
  "."
  ","
  "="
] @punctuation.delimiter
