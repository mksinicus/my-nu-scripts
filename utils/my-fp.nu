use std assert

# Split a list into stepsized chunks
export def chunk [
  size: int
] {
  let old = $in
  assert ($old | describe | str starts-with 'list')
  let len = ($old | length)
  mut cntr = 0
  mut new = []
  while $cntr < $len {
    $new ++= [($old | range $cntr..<($cntr + $size))]
    $cntr += $size
  }
  $new
}

