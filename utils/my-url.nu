# .url-decode.nu
# After writing this I became aware of builtin command `from url`. But that's
# not quite what I wanted.

use unicode.nu ['bytes from-string']

alias index-of = str index-of
alias replace = str replace
alias substring = str substring

# Converts url with percent-encoded escapes back to that with Unicode characters
export def "url decode" [] {
  $in | each {
    |url|
    $url | decode-once
  }
}

def decode-once [] {
  let url = $in
  if ($url | index-of '%') == -1 {
    return $url
  }
  mut muturl = $url
  mut amp_index = -999
  mut reps_found = 0
  mut reps = []

  while ($muturl | index-of '%') != -1 {
    let ind = ($muturl | index-of '%')
    let key = ($muturl | substring $ind..($ind + 3))
    let value = ($muturl | substring ($ind + 1)..($ind + 3))
    # Es 2 non 3, quia `%` ultimo es removeto
    let bytes = if $ind == ($amp_index + 2) {
      mut byte = ($reps | last)
      $byte.key += $key
      $byte.value += (' ' + $value)
      $byte
    } else {
      { key: $key, value: $value }
    }
    $reps_found += 1
    $reps = ($reps | append $bytes)
    $amp_index = $ind
    $muturl = ($muturl | replace '%' '')
  }

  for rep in $reps {
    let value = ($rep.value | bytes from-string | decode utf8)
    $muturl = ($url | replace $rep.key $value)
  }
  $muturl
}
