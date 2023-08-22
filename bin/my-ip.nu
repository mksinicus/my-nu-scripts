#! /usr/bin/nu

def main [
  --ifconfig (-i) # Get from <ifconfig.me>
] {
  $env.__ifconfig = if $ifconfig {true} else {false}
  let my_ip = (get-ip | process-ip $in)
  hide-env __ifconfig

  $my_ip
}

def get-ip [] {
  if $env.__ifconfig {
    curl ifconfig.me/all
  } else {
    curl cip.cc
  }
}

def process-ip [ip] {
  if $env.__ifconfig {
    $ip | lines | split column ': ' | transpose -rd
  } else {
    $ip | lines | each {|x| if ($x | is-empty) {null} else {$x} } |
    split column ': ' | str trim | transpose -rd
  }
}
