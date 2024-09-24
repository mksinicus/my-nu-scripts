# let dir = ($env.CURRENT_FILE | path basename)
# closure is poor man's object
export-env {
  do {
    let backup_threshold = 2wk
    let backup_dir = ('~/backup' | path expand)

    cd $backup_dir
    let last_backup_time = open './last-backup-time' | into datetime
    let duration_since_last = (date now) - $last_backup_time
    if $duration_since_last > $backup_threshold {
      [
          (ansi lgr) # light_green_reverse
          $"Last backup is ($duration_since_last // 1day) days old."
          (char nl)
          "Go to ~/backup and run u.nu."
          (ansi reset)
      ] | str join | print --stderr
    }
    return null
  }
}
