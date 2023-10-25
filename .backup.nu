# let dir = ($env.CURRENT_FILE | path basename)
def __check-backup [] {
  let backup_dir = ('~/backup' | path expand)
  cd $backup_dir
  open 'last-backup-time' | into datetime
  | if $in < ((date now) - 4wk) {
    [
        (ansi lgr)
        "Last backup is 4 weeks old. Go to ~/backup and run u.nu."
        (ansi reset)
    ] | str join | print --stderr
  }
}

__check-backup


