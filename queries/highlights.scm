; Includes

((symbol) @include
  (#match? @include "include"))

; Keywords

((symbol) @keyword
  (#match? @keyword "^def"))

; Functions

(function_call
  name: (ident) @function.call)

; Types

(ast_block
  (symbol)
  (ident) @type)

(list
  (symbol) @type)

; Variables

(string_interpolation
  (simplexpr
    ((ident) (#set! priority 105)) @variable))

(array
  (symbol) @variable)

(binary_expression
	(simplexpr
    (ident) @variable))

(unary_expression
	(simplexpr
    (ident) @variable))

(ternary_expression
	(simplexpr
		(ident) @variable))

(array
  (symbol) @variable)

(json_access
	(simplexpr
		(ident) @variable))

(json_safe_access
	(simplexpr
		(ident) @variable))

(json_array
	(simplexpr
    (ident) @variable))

(json_dot_access
	(simplexpr
		(ident) @variable))

(json_safe_dot_access
	(simplexpr
		(ident) @variable))

(json_object
  (_)
  ":"
	(simplexpr
		(ident) @variable))

; Properties & Fields

(keyword) @property

(json_access
  (_)
  "["
	(simplexpr
		(ident) @property))

(json_safe_access
  (_)
  "?."
  "["
	(simplexpr
		(ident) @property))

(json_dot_access
  (index) @property)

(json_safe_dot_access
  (index) @property)

(json_object
	(simplexpr
		(ident) @field))

; Operators

[
  "+"
  "-"
  "*"
  "/"
  "%"
	"&&"
  "||"
  "=="
  "!="
  "=~"
	">="
	"<="
  ">"
  "<"
	"?:"
	"?."
  "!"
] @operator

(ternary_expression
  ["?" ":"] @conditional.ternary)

; Literals

(escape_sequence) @string.escape
(string) @string

(number) @number

(float) @float

(boolean) @boolean

; Misc


; Properties & Fields

(keyword) @property

(json_access
  (_)
  "["
	(simplexpr
		(ident) @property))

(json_safe_access
  (_)
  "?."
  "["
	(simplexpr
		(ident) @property))

(json_dot_access
  (index) @property)

(json_safe_dot_access
  (index) @property)

(json_object
	(simplexpr
		(ident) @field))

; Operators

[
  "+"
  "-"
  "*"
  "/"
  "%"
  "||"
  "&&"
  "=="
  "!="
  "=~"
  ">"
  "<"
  ">="
  "<="
  "!"
  "?."
] @operator

(ternary_expression
  ["?" ":"] @conditional.ternary)

; Literals

(string) @string
(escape_sequence) @string.escape

(number) @number

(float) @float

(boolean) @boolean

; Misc

[
  ":"
  "."
  ","
] @punctuation.delimiter

["{" "}"] @punctuation.bracket

["[" "]"] @punctuation.bracket

; Comments

(comment) @comment @spell

; Interpolations

(string_interpolation
	"${" @punctuation.special
  (simplexpr
	  (ident) @variable)
	"}" @punctuation.special) @embedded @none
