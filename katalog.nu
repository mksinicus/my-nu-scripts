# for book cataloging.

use std assert

export def main [file: string] {
  assert ($file | path exists)
  let extension = ($file | path parse | get extension)
  let new_name = catalog-file $file | $'($in).($extension)'
  if ($file != $new_name) {mv $file $new_name}
}

export def list [dir?: directory] {
  match $dir {
    null => {ls . | where name =~ '\.\d{14}\.'}
    $x => {ls $x | where name =~ '\.\d{14}\.'}
  }
} 
export alias ls = list

def date-id [] {
  date now | format date '%Y%m%d%H%m%S'
}

# manages log file, returns good filename
# IS NOT PURE.
def catalog-file [file]: nothing -> string {
  let default_log = {
    authors: []
    year: ''
    title: ''
    slug: ''
    extra: []
    timestamp: (date-id)
    description: ''
  }
  let log_type = $default_log | describe
  let timestamp_re = '\d{14}'

  let old_log_title = $file | path parse | update extension 'yaml'
    | format pattern '{stem}.{extension}'
  let old_log_exists = $old_log_title | path exists

  let log = if $old_log_exists {
    open $old_log_title
  } else {
    $default_log
  } | to yaml
  | [
    ('# ' + $file)
    $in
  ] | str join "\n"
  | ^vipe --suffix=yaml | from yaml

  let new_filename_stem = $log | make-filename-stem

  # IMPURE!!!
  $log | to yaml | save -f $'($new_filename_stem).yaml'

  if $old_log_exists {
    rm $old_log_title
  }

  $new_filename_stem
}


def make-filename-stem [] {
  let record = $in
  # let format = '{authors}.{year}.{title}.{timestamp}'
  let filename = [
    ($record.authors | str-regularize | str join '__')
    ($record.year | into string)
    (if ($record.slug? | is-not-empty) {
        $record.slug | str-regularize
      } else {
        $record.title | str-regularize | str substring ..42
      })
    ...($record.extra? | str-regularize)
    ($record.timestamp | into string)
  ] | filter {|x| $x | is-not-empty}

  $filename | str join '.'
}

def str-regularize [] {
  let str = $in
  let bad_chars = [
    # Windows bad chars
    '*'
    '"'
    '/'
    '\'
    '<'
    '>'
    ':'
    '|'
    '?'
    '^'
    # My bad chars
    '.'
    ','
    '#'
    '%'
    "'"
    '`'
    '('
    ')'
    '['
    ']'
    '{'
    '}'
    '~'
    "\n"
    "\t"
 ]

  $str
  | str-replace-all-of ...$bad_chars --to ' '
  | str replace -ar '\s+' '_'
  | str trim --char '_'
  | str downcase
}

def str-replace-all-of [
  ...rep: string
  --to (-t): string
]: string -> string {
  let str = $in
  # $str | str replace --all $rep ''
  $rep | reduce --fold $str {
    |it, acc|
    $acc | str replace --all $it $to
  }
}

def str-remove-all-of [
  ...rep: string
]: string -> string {
  $in | str-replace-all-of ...$rep --to ''
}

