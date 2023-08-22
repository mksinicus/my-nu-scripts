# my-dirs.nu
# use with `use my-dirs.nu *`

# std dirs
export use std dirs

export def d [] {
  help dirs
}

export alias "d g" = dirs goto
export alias "d a" = dirs add .
export alias "d e" = dirs enter
export alias "d p" = dirs prev
export alias "d n" = dirs next
export alias "d l" = dirs show
export alias "d d" = dirs drop

