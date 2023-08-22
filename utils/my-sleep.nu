export alias core-sleep = sleep
export def sleep [
  duration: any
  ...rest: any
]: nothing -> nothing {
  let durations = [$duration] | append $rest
  match ($durations | describe) {
    'list<int>' => {$durations | into string | par-each {|$x| $x + 'sec'} | into duration | each {|x| core-sleep $x}}
    _ => {$durations | each {|x| core-sleep $x}}
  }
  return null
}


