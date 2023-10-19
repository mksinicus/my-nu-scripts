# paste.nu

export def main [] {
  xclip -sel clipboard -o
}

export def html [] {
  xclip -sel clipboard -t text/html -o
  | str replace -r '^<meta.*?>' ''
}
