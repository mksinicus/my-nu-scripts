# about name:
# mtm (macro text markup)
# mmt (macro markup text)
# smm (shellish macro markup)
# smt (shellish macro-markup text)

# Currently JUST A PREPROCESSOR.


# capture group shorthands
# let BEGIN = '('
# let SEP = '|'
# let END = ')'

# # separate patterns to be combined later
# let PAT_F = '\\[\w_\-!]+?'
# let PAT_A = '\[.*?\]'
# let PAT_B = '\{.*?\}'

# let PAT_G_F = ($BEGIN + $PAT_F + ';' $END)
# let PAT_G_A = ($BEGIN + $PAT_F + $PAT_A + $END)
# let PAT_G_B = ($BEGIN + $PAT_F + $PAT_B + $END)
# let PAT_G_FA = ($BEGIN + $PAT_F + $PAT_A + $END)
# let PAT_G_FB = ($BEGIN + $PAT_F + $PAT_B + $END)
# let PAT_G_FAB = ($BEGIN + $PAT_F + $PAT_A + $PAT_B + $END)

# same. no need for fancy regex actually
# each stage would look like `(?:[^\{\}]|\{.*?\})*?`, to increase the level
# simply replace `.*?` inside with this string itself.

# const PAT_G_F = '(\\[\w_\-!]+?;)'
# # max 3 levels of nesting
# const PAT_G_A = '(\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\])'
# const PAT_G_B = '(\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})'
# const PAT_G_FA = '(\\[\w_\-!]+?\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\])'
# # Support max. 7 levels of nesting. Cf. table > tbody > tr > td > strong > em > u.
# const PAT_G_FB = '(\\[\w_\-!]+?\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?\})'
# const PAT_G_FAB = '(\\[\w_\-!]+?\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\]\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?\})'

# # pay attention to the order!
# const PATS =  $PAT_G_FAB + $SEP + $PAT_G_FA + $SEP + $PAT_G_FB + $SEP + $PAT_G_F + $SEP + $PAT_G_A + $SEP + $PAT_G_B


# combined patterns
# No, let's rename later
# const PAT_LAB = '(?<f>\\[\w_\-]+?;)|(?<co>\\[\w_\-]+?\[.*?\]\{.*?\})|(?<o>\\[\w_\-]+?\[.*?\])|(?<c>\\[\w_\-]+?\{.*?\})'
# const PAT_NOLAB = '(\\[\w_\-]+?;)|(\\[\w_\-]+?\[.*?\]\{.*?\})|(\\[\w_\-]+?\[.*?\])|(\\[\w_\-]+?\{.*?\})'

export def main [
  filename?: string
  --out (-o): string
  --lib (-l): string # library file to load
] {
  let text = (if ($filename | is-empty) {$in} else {open --raw $filename})
  let-env MMT_PARSER_EXTRA_LIB = $lib

  $text | mmt-process |
  if ($out | is-empty) {$in} else {$in | save -f $out}
}

def mmt-process [] {
  let file_str = $in
  let noexpr_lst = ($file_str | split-by-expr)
  if ($noexpr_lst | length) == 1 {
    return $file_str
  }
  let expr_tbl = ($file_str | get-expr | parse-expr)
  let evaled_lst = ($expr_tbl  | eval-expr)
  $noexpr_lst | zip $evaled_lst | flatten | str join
}

# I want to propose a separate pattern for definitions. 
# `\def[name][args]{body}`
def split-by-expr [] {
  let text = $in
  let SEP = '|'
  let PAT_G_F = '(\\[\w_\-!]+?;)'
  # max 3 levels of nesting
  let PAT_G_A = '(\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\])'
  let PAT_G_B = '(\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})'
  let PAT_G_FA = '(\\[\w_\-!]+?\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\])'
  # Support max. 7 levels of nesting. Cf. table > tbody > tr > td > strong > em > u.
  let PAT_G_FB = '(\\[\w_\-!]+?\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?\})'
  let PAT_G_FAB = '(\\[\w_\-!]+?\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\]\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?\})'

  # pay attention to the order!
  let PATS =  $PAT_G_FAB + $SEP + $PAT_G_FA + $SEP + $PAT_G_FB + $SEP + $PAT_G_F + $SEP + $PAT_G_A + $SEP + $PAT_G_B

  $text | split row -r $PATS
}

# There are 6 types of expressions. 
# 1. f: just a function, e.g. `\foo;`
# 2. fa: a function with argument(s), e.g. `\foo[bar]`
# 3. fb: a function with a body, e.g. `\foo{baz}`
# 4. fab: a function with argument(s) and a body. e.g. `\foo[bar]{baz}`
# 5. b: body-like text, e.g. `{baz}`
# 6. a: argument-like text, e.g. `[bar]`
#
# The last two types are just there to prevent overlaps. They don't change.
def get-expr [] {
  let text = $in
  let SEP = '|'
  let PAT_G_F = '(\\[\w_\-!]+?;)'
  # max 3 levels of nesting
  let PAT_G_A = '(\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\])'
  let PAT_G_B = '(\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})'
  let PAT_G_FA = '(\\[\w_\-!]+?\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\])'
  # Support max. 7 levels of nesting. Cf. table > tbody > tr > td > strong > em > u.
  let PAT_G_FB = '(\\[\w_\-!]+?\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?\})'
  let PAT_G_FAB = '(\\[\w_\-!]+?\[(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?\]\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?\})'

  # pay attention to the order!
  let PATS =  $PAT_G_FAB + $SEP + $PAT_G_FA + $SEP + $PAT_G_FB + $SEP + $PAT_G_F + $SEP + $PAT_G_A + $SEP + $PAT_G_B

  $text | parse -r $PATS | rename fab fa fb f a b | each {
    |rec|
    $rec | transpose key val | filter {|col| $col.val | is-empty | not $in} |
    get 0 | {type: $in.key, expr: $in.val}
  }
}

# out: table, cols: type, expr, name, args, body
def parse-expr [] {
  $in | update type {
    |col| if ($col.expr | str starts-with '\def') {'def'} else {$col.type}
    } | each {
      |rec|
      $rec | merge (
        match $rec.type {
          'a' | 'b' => {
            {name: null, args: '', body: '', ret: $rec.expr}
          }
          'f' => {
            {
              name: ($rec.expr | str substring 1..-1)
              args: ''
              body: ''
              ret: tbd
            }
          }
          'fa' => {
            $rec.expr | parse -r '\\(?<name>[\w_\-!]+?)\[(?<args>(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?)\]' | get 0 | merge {body: '', ret: tbd}
          }
          'fb' => {
            $rec.expr | parse -r '\\(?<name>[\w_\-!]+?)\{(?<body>(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?)\}' | get 0 | merge {args: '', ret: tbd}
          }
          'fab' => {
            $rec.expr | parse -r '\\(?<name>[\w_\-!]+?)\[(?<args>(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?)\]\{(?<body>(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?)\}' | get 0 | merge {ret: tbd}
          }
          'def' => {
            $rec.expr | parse -r '\\(?<name>[\w_\-!]+?)\[(?<args>(?:[^\[\]]|\[(?:[^\[\]]|\[.*?\])*?\])*?)\]\{(?<body>(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{(?:[^\{\}]|\{.*?\})*?\})*?\})*?\})*?\})*?\})*?)\}' | get 0 | merge {ret: 'def'}
          }
        }
      )
    }
  # since multiple match is inevitable in this approach, use `each`
  # insert name {
  #   |col| match $col.type {
  #     'a' | 'b' | 'def' => null,
  #     'f' => {$col.expr | str substring 1..-1},
  #     _ => {$col.expr | parse -r '\\(?<name>[\w\-_!]+?)[\[\{]' | get name.0}
  #   }
  # } | insert args)
  # $exprs_tbl | merge
}

# divide expr into definitions (return null), those with a return value,
# and comments etc.
# structure: expr, ret
def eval-expr [] {
  let expr_tbl = $in
  let mmt_stdlib = (load-stdlib)
  let defs = ($expr_tbl | where type == def | reduce -f '' {
    |it acc|
    $acc + $it.name + ' ' + $it.args + ' ' + $it.body + "\n\n"
  } | $mmt_stdlib + "\n" + 
  ((try {open $env.MMT_PARSER_EXTRA_LIB}) | into string) + "\n" + $in)
  # Here's where the recursion occurred.
  $expr_tbl |
  update body {|c| $c.body | if not ($in | is-empty) {$c.body | mmt-process}} |
  reduce -f '[' {
    |it acc|
    match $it.ret {
      'tbd' => {
        '(' + $it.name + ' ' + $it.args? + ' --body ' + ($it.body? | to nuon) + ')' + (char nl)
      }
      'def' => {'""' + "\n"},
      _ => {$it.ret | to nuon}
    } | $acc + $in
    
  } | $in + '] | to nuon' | nu -c ($defs + $in) | from nuon
}

# Call another Nu process to eval; return the results as a list with nuon
def eval-run-nu-process [
  defs: string
  exprs: list
] {
  let commnand = (
    $defs + (char nl)
  )
}


# before this round of parsing, 
# 1) escapes
# 2) verbatims
# should have been plucked out.
# And handle `{something}` simultaneously beforehand; they are not evaluated,
# but may influence the parse result.
# ...And maybe `[something]` too! Because we may want to take advantage of the
# list in Nushell.
# export def __parse [filename: string] {
#   let file_str = (open $filename --raw)
#   let expr_tbl = ($file_str | parse -r $PATS)
#   let expr_lst = ($expr_tbl | each {
#     |rec|
#     $rec | values | each {
#       |val|
#       match $val {
#         '' => null,
#         _  => $val
#       }
#     }
#   } | flatten)

#   # test purpose
#   # But necessary: should match first, if not such command is defined, return the original string
#   let expr_rec = (
#     $expr_lst | par-each {
#       |expr|
#       {$expr: ($expr + 'done')}
#     }
#   )

#   # also test purpose
#   let expr_lst = (
#     $expr_lst | each {
#       |expr|
#       '$done' + $expr + 'done$'
#     }
#   )
  
#   let file_lst = ($file_str | split row -r $pat_nolab | zip $expr_lst | flatten)
#   # `reduce`?
# }

# commands: a list of {name: foo, args: <record>}
# ...But no. This will be called parallelly, but not parallel itself.
# and the conditional judgment is made outside of this function.
# def call-commands [
#   commands: list<record>
#   definitions: list<record>
# ] {
#   let def_keys = 
#   $commands | par-each {
#     |command|
#     {
#       expr: $command.expr
#       ret: (
#         if $command.expr in
#       )
#     }
#   }
# }

def call-command [
  command: record
] {
  $command | compose-command $in | nu -c $in
}


# commands: a list of {name: foo, args: <record>}
def compose-command [command: record] {
  match $command {
    {name: $name} => {
      '(' + $name + ')'
    }
    {name: $name, args: $args} => {
      # [$name, $args] | str join ' '
      match $name {
        'def' => {compose-definition $name $args.body},
        _ => {
          '(' + ($name + (
              $args | transpose key value | par-each {
                $' --($in.key) ($in.value | to nuon) '
              } | str join
          )) + ')'
        }
      }
      
    }
  } | to nuon
}

def compose-definition [name: string, body: string] {
  'def ' + $name + ' ' + $body
}


def load-stdlib [] {
  '
### XML composition
def xtag [
  tag: string
  --class (-c): list # but must be joined into a string before passing on
  --id (-i): string
  --lang (-l): string
  --attrs (-a): record
  --body (-b): string
] {
  {
    tag: $tag
    class: $class
    id: $id
    lang: $lang
    attrs: $attrs
    body: $body
  } | compose-xml
}

def compose-xml [] {
  let entry = $in
  let attrs = (
    {
      class: $entry.class?
      id: $entry.id?
      lang: $entry.lang?
    } | if not ($entry.attrs | is-empty) {merge $entry.attrs} else {$in} |
    reject-empty
  )
  {
    tag: $entry.tag
    attributes: $attrs
    content: [$entry.body]
  } | to xml
}

# reject empty values in records
def reject-empty [] {
  $in | transpose key value | update value {
    $in.value | empty-to-null
  } | compact value | transpose -rd
}

def empty-to-null [] {
  if ($in | is-empty) {null} else {$in}
}
  '
}
