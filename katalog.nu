# for book cataloging.

use std assert

export def main [file: string] {
  assert ($file | path exists)
  let extension = ($file | path parse | get extension)
  catalog-file $file | mv $file $'($in).($extension)'
}

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
  } | to yaml | ^vipe --suffix=yaml | from yaml

  let new_filename_stem = $log | make-filename-stem

  $log | to yaml | save -f $'($new_filename_stem).yaml'

  if $old_log_exists {
    rm $old_log_title
  }

  return $new_filename_stem
}

def str-remove [rep] {
  $in | str replace --all $rep ''
}

def str-regularize [] {
  $in | str replace -ar '\s+' '_' | str-remove '.' | str-remove ','
  | str downcase
}

def make-filename-stem [] {
  let record = $in
  let format = '{authors}.{year}.{title}.{timestamp}'
  let filename = {
    authors: ($record.authors | str-regularize | str join '__')
    year: $record.year
    title: (if $record.slug? != null {
        $record.slug | str-regularize
      } else {
        $record.title | str-regularize | str substring ..42
      })
    timestamp: $record.timestamp
  }
  $filename | format pattern $format
}
