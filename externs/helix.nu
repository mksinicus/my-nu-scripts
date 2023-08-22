# def files [] {
#   ls | get name
# }

def fetch-or-build [] {
  ["fetch", "build"]
}

def categories [] {
  ^hx --health languages | lines | split column -c '  ' | str trim | headers |
  drop column 1 | get Language | append ['clipboard' 'languages']
}

# helix-term 22.12 (96ff64a8)
# Blaž Hrastnik <blaz@mxxn.io>
# A post-modern text editor.
export extern hx [
  --help (-h) # Prints help information
  --tutor # Loads the tutorial
  --health: string@categories  # Checks for potential errors in editor setup. CATEGORY can be a language or one of 'clipboard', 'languages'
  --grammar (-g): string@fetch-or-build # Fetches or builds tree-sitter grammars listed in languages.toml
  --config (-c): string # Specifies a file to use for configuration
  -v # Increases logging verbosity each use for up to 3 times
  --log # Specifies a file to use for logging (default file: /home/marco/.cache/helix/helix.log)
  --version (-V) # Prints version information
  --vsplit # Splits all given files vertically into different windows
  --hsplit # Splits all given files horizontally into different windows
  ...files # Sets the input file to use, position can also be specified via file[:row[:col]]
]

# Checks for potential errors in editor setup.
# CATEGORY can be a language or one of 'clipboard', 'languages'
export def "hx health" [
  language?: string@categories
] {
  if $language == null {
    let original = (^hx --health | lines)
    let info = ($original | take 6 | split column ': ' | str trim | transpose -rd)
    let status = ($original | skip 7 | split column -c '  ' | str trim | headers |
    drop column 1)
    {info: $info, status: $status}
  } else {
    ^hx --health $language | lines |  split column ': ' | transpose -rd
  }
}
