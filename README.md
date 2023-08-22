# my-nu-scripts

explanation: 

- `bin/`: in my `PATH`, standalone script ready to be invoked
- `externs/`: external completions
- `lib/`: extra resources
- `utils/`: a module directory, collection of QoL utilities

This repository is UNLICENSED, so use at your own risk.

'Tis a new repository to store my Nushell scripts. The old one isn't updated for a long time and is largely broken due to rapid changes of Nushell. I deleted it since I guess nobody sticks to a old version of Nushell.

- `job.nu` isn't written by me.

## workflow

- use `ignore-symlinks.nu` to auto add symlinks to `.gitignore`
- `use u.nu; u` to git add, commit with today's date as commit message, push.
