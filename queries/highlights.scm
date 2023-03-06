; Tags

(list
  (symbol) @tag)

; Includes

(list .
  ((symbol) @include
    (#eq? @include "include")))

; Keywords

; I think there's a bug in tree-sitter the anchor doesn't seem to be working, see
; https://github.com/tree-sitter/tree-sitter/pull/2107
(list .
  ((symbol) @keyword
    (#match? @keyword "^(defwindow|defwidget|defvar|defpoll|deflisten|geometry|children|struts)$")))

(loop_widget . "for" @keyword . (symbol) @variable . "in" @string . [((symbol) @variable) (_)] . (list) @string)

; Builtin widgets

(list .
  ((symbol) @tag.builtin
    (#match? @tag.builtin "^(box|button|calendar|centerbox|checkbox|circular-progress|color-button|color-chooser|combo-box-text|eventbox|expander|graph|image|input|label|literal|overlay|progress|revealer|scale|scroll|transform)$")))

; Variables

(ident) @variable

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

; Functions

(function_call
  name: (ident) @function.call)

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
  "?:"
] @operator

(ternary_expression
  ["?" ":"] @conditional.ternary)

; Punctuation

[
  ":"
  "."
  ","
] @punctuation.delimiter

["{" "}" "[" "]" "(" ")"] @punctuation.bracket

; Literals

(number) @number

(float) @float

(boolean) @boolean

; Strings

[ (string_fragment) "\"" "'" "`" ] @string

(string_interpolation
  "${" @punctuation.special
  "}" @punctuation.special)

(escape_sequence) @string.escape

; Comments

(comment) @comment @spell

; Errors

(ERROR) @error
