# my utils 
# please use with global import
# only simple ones are stored in this file

export use my-math.nu *
export use my-path.nu *
export use my-sleep.nu *
export use my-fp.nu *
export use my-dirs.nu *
export use my-url.nu *
export use my-ls.nu *
export use my-fs.nu *
export use conversions/ *

export use recent.nu
export use move-recent.nu ['mv-recent']

# use `history | recent` instead
# export use history-recent.nu ['history recent']

use std assert

# Simple closures
# P.ex. `ls | recent 10min`
export alias parse-extension = collect { |x|
  $x | insert extension {|c| $c.name | path parse | get extension}
  | sort-by extension
}
export alias dehuman  = do {update modified {|c| $c.modified | format date %+}}
export alias today    = do {date now | format date %F}
export alias datetime = do {date now | format date %+}
export alias date-id = do {date now | format date %Y%m%d%H%m%S}
export alias zq       = do {|x| zoxide query $x | str trim}
export alias negate   = collect {|x| not $x}
export alias hms   = do {date now | format date %H:%M:%S}
export alias ymd = do {|| date now | format date %y-%m-%d}

# avoid confusion
# export alias 'date format' = do {|x| date now | format date $x}

# cd and then ls
export def --env c [path: path] {
  cd $path
  ls -a
}

# mdcd
# mkdir then cd there
export def --env mdcd [dir: string] {
  # Had to use `def --env`! I didn't know.
  mkdir $dir
  cd $dir
}
export alias mc = mdcd

# touchmod.nu
export def touchmod [
  filename: string
  mode: string
] {
  let span_f = (metadata $filename).span
  let span_m = (metadata $mode).span
  assert (
    $mode
    | find -r '[ugoa]*([-+=]([rwxXst]*|[ugo]))+|[-+=][0-7]+'
    | is-empty
    | negate
  ) --error-label {
    span: $span_m
    text: ([$"chmod: invalid mode: '($mode)'"
             "try 'chmod --help' for more information."] | str join "\n")
  }
  touch $filename
  chmod $mode $filename
}

# Use kdeconnect-cli to send files to phone
export def send2phone [
  ...files: string
] {
  # To be modified to read from local file!
  let phone_name = 'oryzaParvaMarci'
  let files = $files | flatten
  | each {|e| try {glob $e} catch {$e | path expand}} | flatten
  for file in $files {
    kdeconnect-cli -n $phone_name --share $file
  }
}
export alias s2p = send2phone

export def ls-gstat [] {
  ls | pcd-do { print ((ansi lgr) + (pwd) + (ansi reset)); git status }
}

export def font-install [path? = '.'] {
  let is_font = {|x|
    ['.ttf' '.ttc' '.otf']
    | any {|y| $x | str ends-with --ignore-case $y}
  }
  ls $path
  | get name
  | filter $is_font
  | par-each {|x| cp -v $x ~/.local/share/fonts/}
  | ignore
}

export def upgrade-all [] {
  # apt
  sudo apt update; sudo apt upgrade -y
}
