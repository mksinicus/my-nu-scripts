# A pseudo package manager.
# So that most definitions are greppable from here.

## Externals

use starship.nu

use broot.nu [br]

use zoxide.nu [z, zi]

## Custom completions/externs

# Subcommands ain't good for an editor
# use /home/marco/nu/externs/helix.nu *

use externs/zellij.nu *

use externs/tar.nu *

use externs/pijul.nu *

# Get just the extern definitions without the custom completion commands
use externs/git.nu *

## Applications aliases/shorthands

alias python = ^python3

alias grep = ^rg

alias code = ^codium

# I'd rather use Nushell as my build system tho...
alias j = ^just

alias lua = ^lua5.4

alias tarxz = ^tar -c -I 'xz -6 -T0' -f
alias unzip-gbk = ^unzip -O cp936
alias unzip-jis = ^unzip -O shift-jis

alias zqi = ^zoxide query -i

# Let's keep this internal
alias editor = ^($env.EDITOR)
# "gvim"
alias ghx = ^alacritty -t Helix -e hx

alias r = ^radian

alias pc = ^proxychains

## Shell command shorthands

alias l = ls
alias ll = ls -la

# DOS-ish
alias md = mkdir

alias rmt = rm -t

alias now = date now

# I like it, reminds me of the view-source protocol
alias view-source = view source

alias cls = clear

alias ":q" = exit

# special use
alias uu = overlay use -p u.nu
alias uh = overlay hide u


## Private

# While they are inside $env.NU_LIB_DIRS, no need to write full path

# backup prompt; no command
use backup-prompt.nu

use clip.nu

use paste.nu

use renamer.nu
alias rnm = renamer

use entity.nu

use unicode.nu

use rmd-new.nu

use m3u82mp4.nu

use mdmake.nu

use video2audio.nu
alias v2a = video2audio

use my2fa.nu

use eval.nu

use anki-make.nu

use qmv.nu

use cfg.nu

use nota.nu
alias nt = nota

# switched to dir-based module
use utils/ *

# Background Task (https://www.nushell.sh/book/background_task.html)
use job.nu
