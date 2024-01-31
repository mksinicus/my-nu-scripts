# html-to-markdown.nu

# not quite ready
export def main [
  --strict (-s) # use markdown_strict
  --variant (-v): string # output variant; overrides $strict option
]: string -> string {
  let input = $in

  # handle output format
  let output_format = if $strict {
    'markdown_strict'
    # 'gfm'
  } else {
    'markdown'
  }
  let output_format = if not ($variant | is-empty) {
    $variant
  } else $output_format

  # here to place necessary extensions
  let input_format = [
    'html'
    '-native_divs'
    '-native_spans'
  ] | str join

  let output_format = [
    $output_format
    '-smart'
    '-grid_tables'
    '-simple_tables'
    '+pipe_tables'
    '-header_attributes'
    # '+east_asian_line_breaks' # 只在由源码转为别的格式时有用
  ] | str join

  ($input
  | pandoc -f $input_format -t $output_format
  | str trim)
}
