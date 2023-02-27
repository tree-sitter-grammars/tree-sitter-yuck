/**
 * @file Yuck grammar for tree-sitter
 * @author Philipp Mildenberger <philipp@mildenberger.me>
 * @author Amaan Qureshi <amaanq12@gmail.com>
 * @license MIT
 * @see {@link https://github.com/elkowar/eww/blob/master/docs/src/configuration.md#creating-your-first-window|official syntax spec}
 * @see {@link https://github.com/elkowar/eww| official source}
 */

// deno-lint-ignore-file ban-ts-comment
/* eslint-disable arrow-parens */
/* eslint-disable camelcase */
/* eslint-disable-next-line spaced-comment */
/// <reference types="tree-sitter-cli/dsl" />
// @ts-check

const PREC = {
  ternary: 0,
  or: 1,
  and: 2,
  elvis: 2,
  equality: 6,
  relation: 7,
  add: 8,
  times: 9,
  unary: 10,
  json_access: 11,
  json: 12,
};

module.exports = grammar({
  name: 'yuck',

  externals: $ => [
    $._unescaped_single_quote_string_fragment,
    $._unescaped_double_quote_string_fragment,
    $._unescaped_backtick_string_fragment,
  ],

  conflicts: $ => [[$.string]],

  extras: $ => [$.comment, /\s/],

  supertypes: $ => [$.ast_block, $.literal],

  word: $ => $.symbol,

  rules: {
    source_file: $ => repeat($.ast_block),

    ast_block: $ =>
      choice($.list, $.array, $.keyword, $.symbol, $.literal, $.string, $.expr),

    simplexpr: $ =>
      choice(
        $.literal,
        $.string,
        $.ident,
        $.json_array,
        $.json_object,
        $.json_access,
        $.json_safe_access,
        $.json_dot_access,
        $.json_safe_dot_access,
        $.function_call,
        $.unary_expression,
        $.binary_expression,
        $.ternary_expression,
        $.parenthesized_expression
      ),

    expr: $ => seq('{', $.simplexpr, '}'),

    json_array: $ => prec.left(PREC.json, seq('[', commaSep($.simplexpr), ']')),

    json_object: $ =>
      prec.left(
        PREC.json,
        seq('{', commaSep(seq($.simplexpr, ':', $.simplexpr)), '}')
      ),

    json_access: $ =>
      prec.right(PREC.json_access, seq($.simplexpr, '[', $.simplexpr, ']')),
    json_safe_access: $ =>
      prec.right(
        PREC.json_access,
        seq($.simplexpr, '?.', '[', $.simplexpr, ']')
      ),
    json_dot_access: $ =>
      prec.right(
        PREC.json_access,
        seq($.simplexpr, '.', alias($.ident, $.index))
      ),
    json_safe_dot_access: $ =>
      prec.right(
        PREC.json_access,
        seq($.simplexpr, '?.', alias($.ident, $.index))
      ),

    function_call: $ =>
      seq(field('name', $.ident), '(', commaSep($.simplexpr), ')'),

    list: $ => seq('(', repeat($.ast_block), ')'),
    array: $ => seq('[', repeat($.ast_block), ']'),

    binary_expression: $ => {
      const table = [
        ['+', PREC.add],
        ['-', PREC.add],
        ['*', PREC.times],
        ['/', PREC.times],
        ['%', PREC.times],
        ['&&', PREC.and],
        ['||', PREC.or],
        ['==', PREC.equality],
        ['!=', PREC.equality],
        ['=~', PREC.equality],
        ['>=', PREC.relation],
        ['<=', PREC.relation],
        ['>', PREC.relation],
        ['<', PREC.relation],
        ['?:', PREC.elvis],
      ];

      return choice(
        ...table.map(([operator, precedence]) => {
          return prec.left(
            precedence,
            seq(
              field('left', $.simplexpr),
              // @ts-ignore
              field('operator', operator),
              field('right', $.simplexpr)
            )
          );
        })
      );
    },

    unary_expression: $ =>
      prec(
        PREC.unary,
        seq(
          field('operator', choice('+', '-', '!')),
          field('argument', $.simplexpr)
        )
      ),

    ternary_expression: $ =>
      prec.right(
        PREC.ternary,
        seq(
          field('condition', $.simplexpr),
          '?',
          field('consequence', $.simplexpr),
          ':',
          field('alternative', $.simplexpr)
        )
      ),

    parenthesized_expression: $ => seq('(', $.simplexpr, ')'),

    literal: $ => choice($.number, $.boolean),

    number: $ => choice($.integer, $.float),

    integer: _ => /\d+/,

    float: _ => /\d+\.\d+/,

    boolean: _ => choice('true', 'false'),

    // Here we tolerate unescaped newlines in double-quoted and
    // single-quoted string literals.
    string: $ => {
      const str = (fragment, q) => {
        const frag = repeat1(choice(fragment, $._escape_sequence));
        const strLit = alias(frag, $.string_lit_fragment);
        return seq(q, repeat(choice($.string_interpolation, strLit)), q);
      };
      return choice(
        str($._unescaped_double_quote_string_fragment, '"'),
        str($._unescaped_single_quote_string_fragment, "'"),
        str($._unescaped_backtick_string_fragment, '`')
      );
    },

    string_interpolation: $ => seq('${', $.simplexpr, '}'),

    _escape_sequence: $ =>
      choice(
        prec(2, token.immediate(seq('\\', /[^abfnrtvxu'\"\\\?]/))),
        prec(1, $.escape_sequence)
      ),
    escape_sequence: _ =>
      token.immediate(
        seq(
          '\\',
          choice(
            /[^xu0-7]/,
            /[0-7]{1,3}/,
            /x[0-9a-fA-F]{2}/,
            /u[0-9a-fA-F]{4}/,
            /u{[0-9a-fA-F]+}/
          )
        )
      ),

    ident: _ => /[a-zA-Z_][a-zA-Z0-9_-]*/,
    keyword: _ => /:[^\s\)\]}]+/,
    symbol: _ => /[a-zA-Z_!\?<>/\.\*-\+\-][^\s{}\(\)\[\](){}]*/,

    comment: _ => token(seq(';', /.*/)),
  },
});

/**
 * Creates a rule to optionally match one or more of the rules separated by a comma
 *
 * @param {Rule} rule
 *
 * @return {ChoiceRule}
 *
 */
function commaSep(rule) {
  return optional(commaSep1(rule));
}

/**
 * Creates a rule to match one or more of the rules separated by a comma
 *
 * @param {Rule} rule
 *
 * @return {SeqRule}
 *
 */
function commaSep1(rule) {
  return seq(rule, repeat(seq(',', rule)));
}
