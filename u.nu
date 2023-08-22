# u.nu / utils.nu
# should be imported before use

export def main [] {
  # default function
  let msg = date now | date format %F | "Update " + $in
  gacp -m $msg
}

# Git add, commit.
export def gac [
  --message (-m): string
] {
  git diff
  input -s "Press enter to continue, C-c to interrupt"
  git add .
  match ($message | describe) {
    'string' => {git commit -m $message}
    _ => {git commit}
  }
  git push
}
export alias g = gacp
