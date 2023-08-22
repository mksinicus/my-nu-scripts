# .into-hex.nu

# Convert value to hex
export def "into hex" [] {
  # I wonder if this compatibility with `each` can be later implemented 
  # separately in the way of Python's decorator.
  # $in | each {
  #   |in_dec|
  #   let hexits = "0123456789abcdef"
  #   mut in_dec = ($in_dec | into int)
  #   let is_negative = (if $in_dec < 0 { $in_dec = 0 - $in_dec; true } else { false })
  #   mut out_hex = ""
  #   loop {
  #     let remainder = ($in_dec mod 16)
  #     let hexit = ($hexits | str substring $remainder..($remainder + 1))
  #     $out_hex = ($out_hex + $hexit)
  #     $in_dec = $in_dec // 16
  #     if $in_dec == 0 {
  #       break
  #     }
  #   }
  #   if $is_negative { $out_hex = $out_hex + "-"}
  #   $out_hex | str reverse
  # }

  # The naive part above is preserved, but for best performance, use
  # builtin cellpath-compatible commands.
  
  # Perfomance note: conversion of 10000 random integers (ranging from 70 to
  # 18000) cost 7s265ms before and 251ms after.
  $in | fmt | get upperhex
}


# Convert value to number of certain radix. Max: 36
export def "into radix" [
  radix: int
  --from (-f): int = 10
] {
  let in_decs = $in
  let span = (metadata $radix).span
  $in_decs | each {
    |in|
    let in_dec = ($in | into int -r $from)
    if $radix > 36 or $radix < 2 {
      error make {
        msg: "Invalid radix"
        label: {
          text: "Radix must be between 2 and 36",
          start: $span.start, end: $span.end
        }
      }
    }
    let digits = "0123456789abcdefghijklmnopqrstuvwxyz"
    mut in_dec = ($in_dec | into int)
    let is_negative = (if $in_dec < 0 { $in_dec = 0 - $in_dec; true } else { false })
    mut out_rad = ""
    loop {
      let remainder = ($in_dec mod $radix)
      let digit = ($digits | str substring $remainder..($remainder + 1))
      $out_rad = ($out_rad + $digit)
      $in_dec = $in_dec // $radix
      if $in_dec == 0 {
        break
      }
    }
    if $is_negative { $out_rad = $out_rad + "-"}
    $out_rad | str reverse
  }
}

