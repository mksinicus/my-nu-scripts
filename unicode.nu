# unicode.nu

# Local aliases
alias remove = do {|x| str replace -sa ($x | into string) ''}
alias replace = str replace -sa
alias contains = str contains
alias ncontains = str contains -n
alias core-get = get

# Conversions
# To get a decimal, use the native `into int -r {2 or 16}`

def "dec2hex" [] {
  $in | into int | fmt | core-get upperhex | str substring 2..
}

def "dec2bin" [] {
  $in | into int | fmt | core-get binary | str substring 2..
}

def "hex2bin" [] {
  $in | into int -r 16 | dec2bin
}

def "bin2hex" [] {
  $in | into int -r 2 | dec2hex
}

#"

export def main [] {
  help unicode
}

alias core-parse = parse
# Parse text as hex and print Unicode character.
export def parse [
  --decimal (-d)  # From decimal instead of hex.
] {
  let temp = [(metadata $in).span, $in]
  let span = $temp.0
  let uni = $temp.1
  $uni | each {
    |e|
    let uni = ($e | into string)
    let decimal = (
      if ($uni | contains '&#') and ($uni | ncontains '&#x')
      and (($uni | ncontains '0x') and ($uni | ncontains '\u')) {
        true
      } else {
        $decimal
      }
    )
    $uni | uni-normalize | each {
      |e|
      $e | if $decimal {
        char -i ($in | into int)
      } else {
        char -u $in
      }
    } | str join
  }
}

def uni-normalize [] {
  $in | remove '0x' |
  remove 'U+' |
  remove '&#x' | remove '&#' |
  remove '{' | remove '}' |
  replace '\u' ' ' |
  replace ';' ' ' | str trim | split row ' '
}

# Convert hex-represented Unicode into UTF-8
export def get-utf8 [
  --raw (-r) # Output as raw octets instead of Nushell's binary primitive
  --decimal (-d) # Treat input as decimal
  span?: string # Only useful when called by other functions. Do not fill it.
] {
  # A shame there is not yet pattern matching in Nushell, while `$in` can be
  # used only once and at the beginning of a function.
  let temp = [(metadata $in).span, $in]
  let span = if $span != null {
    $span
  } else {
    $temp.0
  }
  let in_hexes = $temp.1
  
  $in_hexes | each {
    |in_hex|
    $in_hex | split row ' ' | each {
      |in_hex|
      let in_hex = if $decimal {
        # Without limiting it, it returns something but not exactly the result...
        try { let _ = ($in_hex | into int) } catch {
          panic {
            msg: "Input cannot be parsed as decimal"
            label: "Try removing `-d` if input was hex"
            span: $span
          }
        }
        $in_hex | into int
      } else {
        try { let _ = ($in_hex | into int -r 16) } catch {
          panic {
            msg: "Input cannot be parsed as hex"
            label: "Invalid hex"
            span: $span
          }
        }
        $in_hex
      }
      let in_int = ($in_hex | into int -r 16)
      if $in_int < 0 {
        panic { # fancy error make
          msg: "Invalid hex"
          label: "Unicode hex cannot be a negative number"
          span: $span
        }
      }
      let octets = if $in_int < 0x80 {
        [] | prepend ($in_int | dec2bin)
      } else {
        get-octets $in_int
      }
      if $raw {
        # # This is buggy. 
        # # BUG: `'我' | into unicode | into utf8 -r` gets `0x386 0x88 0x91` 
        # stringify-octets $octets
        # # And I've found a better builtin solution.
        def chunk [
          size: int
        ] {
          let old = $in
          # assert ($old | describe | $in =~ '^list')
          let len = ($old | length)
          mut cntr = 0
          mut new = []
          while $cntr < $len {
            $new ++= [($old | range $cntr..<($cntr + $size))]
            $cntr += $size
          }
          $new
        }

        $in_hex | parse | encode utf8 | encode hex
        | split chars | chunk 2 | each {|| ['0' 'x'] ++ $in | str join}
        | str join ' '
      } else {
        # fuck, this is buggy anyway
        # binarize-octets $octets
        # I forgot why I didn't do it in the first place
        $in_hex | parse | encode utf8 
      }
      } | if $raw {
      $in | str join ' '
    } else {
      $in | bytes collect
    }
  }
}

def get-octets [in_int: int] {
  mut octets = []
  mut in_bytes = ($in_int | dec2bin)
  # let octet_meta = get-octet-meta $in_int
  let octet_meta = (get-octet-meta $in_int)
  let prefix = ($octet_meta | core-get prefix)
  mut octet_num = ($octet_meta | core-get octet)
  while $octet_num > 1 {
    $octets = ($octets | prepend (
      "10" + ($in_bytes | str substring (-6..))
    ))
    $in_bytes = ($in_bytes | str substring ..-6)
    if ($in_bytes | str length) < 6 {
      $in_bytes = ($in_bytes | fill -a r -w 6 -c '0')
    }
    $octet_num -= 1
  }
  let remaining = (8 - ($prefix | str length))

  $octets | prepend ($prefix + ($in_bytes | fill -a r -w $remaining -c '0'))
}

def get-octet-meta [in_int: int] {
  # ASCII-compatibles are previously handled
  [0x800, 0x10000, 0x200000, 0x4000000, 0x80000000] | enumerate | each {
    |el|
    if $in_int < $el.item {
      {
        prefix: ("0" | fill -a r -w ($el.index + 3) -c "1"),
        octet: ($el.index + 2)
      }
    }
  } | core-get 0
}

def stringify-octets [octets: list] {
  $octets | each {
    |e| $e | bin2hex | into string | '0x' + $in
  } | str join ' '
}

def binarize-octets [octets: list] {
  $octets | str join | into int -r 2 | each {$in | into binary} |
  bytes remove -a 0x[00] | bytes reverse
}


# get Unicode representation of character(s)
export def get [
  --html(-w)      # HTML Style, p.ex. `&#x13000;`
  --c (-c)        # `\u13000`
  --rust (-r)     # `\u{13000}`
  --decimal (-d)  # Use decimal instead of hex. Does not work with `--c` and `--rust`.
  --unicode (-u)  # `U+13000`
] {
  let temp = [(metadata $in).span, $in]
  let span = $temp.0
  let in_chars = $temp.1

  # Really don't know why but assignment inside closure is buggy
  # I don't know how to describe or reproduce it so I can't create an issue
  $in_chars | each {
    |in_chars|
    $in_chars | split chars | each {
      |e| $e | utf82unicode | str upcase
    } |
    if $html {
      if $decimal {
        $in | into int -r 16 | into string | each {
          |e| '&#' + $e + ';'
        } | str join
      } else {
        $in | each {
          |e| '&#x' + $e + ';'
        } | str join
      }
    } else if $c {
      $in | each {
        |e| '\u' + $e
      } | str join
    } else if $rust {
      $in | each {
        |e| '\u{' + $e + '}'
      } | str join
    } else if $unicode {
      $in | each {
        |e| 'U+' + $e
      } | str join ' '
    } else if $decimal {
      $in | into int -r 16 | into string | str join ' '
    } else {
      $in | each {
        |e| '0x' + $e
      } | str join ' '
    }
  }
}

# Convert UTF-8 to Unicode hex
def utf82unicode [] {
  let utf8_hex = ($in | encode utf8 | dec2hex | 
  if ($in | str length) mod 2 != 0 {'0' + $in} else {$in} | into string)
  $utf8_hex | hex2str
}

def hex2str [] {
  # Dunno why, but without this shit it becomes "capture of mutable variable"
  let utf8_hex = $in
  mut utf8_hex = $utf8_hex
  mut utf8_bytes = []
  while not ($utf8_hex | is-empty) {
    let byte = ($utf8_hex | str substring ..2 | '0x' + $in)
    $utf8_hex = ($utf8_hex | str substring 2..)
    $utf8_bytes = ($utf8_bytes | append $byte)
  }
  $utf8_bytes | hex2bin | fill -a r -w 8 -c '0' | each {
    |e|
    [0 10 110 1110 11110 111110 1111110] | into string | enumerate | each {
      |prefix|
      if ($e | str starts-with $prefix.item) {
        $e | str substring ($prefix.index + 1)..
      }
    } | core-get 0
  } | str join  | bin2hex
}

export def "bytes from-string" [] {
  # Not sure why, but `str trim` is buggy here, by Nu 0.74
  # And comments inside closure will make it malfunction... How strange!
  $in | each {
    |e| 
    $e | into string | split row ' ' |
    into int -r 16 | each {$in | into binary} |
    bytes remove -a 0x[00] | bytes collect
  }
}

# Should be deprecated with `std assert`... Well, let's not touch what works.
def assert-eq [x y info] {
  if $x == $y {true} else {panic $info}
}

def panic [info] {
  error make {
    msg: $info.msg
    label: {
      text: $info.label
      start: $info.span.start
      end: $info.span.end
    }
  }
}

