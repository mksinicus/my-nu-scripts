# A pseudo package manager in the scripts directory.
# Just so that most user definitions are greppable from here.
#
# Module definitions are marked with `export` so that these can be used
# in an external script with `use definitions.nu *`.
#
# Note that this may slightly alter the behavior of this file.
#
# Aliases, however, are to be avoided in such use cases.
# Also, we discourage using short aliases in scripting.

## Externals

export use starship.nu

export use broot.nu [br]

export use zoxide.nu [z, zi]

export use yazi.nu [yy]

## Custom completions/externs

# Subcommands ain't good for an editor
# use /home/marco/nu/externs/helix.nu *

export use externs/zellij.nu *

export use externs/tar.nu *

export use externs/pijul.nu *

# Get just the extern definitions without the custom completion commands
export use externs/git.nu *

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

## Applications outside my PATH

alias downkyi = do {
  cd ('~' | path join 'utilitate' 'downkyi')
  ^wine 'DownKyi.exe'
}

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

# switched to dir-based module
export use utils/ *

# Background Task (https://www.nushell.sh/book/background_task.html)
export use job.nu

# While they are inside $env.NU_LIB_DIRS, no need to write full path

# backup prompt; no command
export use backup-prompt.nu

export use clip.nu

export use paste.nu

export use renamer.nu
alias rnm = renamer

export use entity.nu

export use unicode.nu

export use rmd-new.nu

export use m3u82mp4.nu

export use mdmake.nu

export use video2audio.nu
alias v2a = video2audio

export use my2fa.nu

export use eval.nu

export use anki-make.nu

export use qmv.nu

export use cfg.nu

export use nota.nu
alias nt = nota

export use ifc.nu

export use html-to-markdown.nu
alias h2m = html-to-markdown

export use katalog.nu
alias ktlg = katalog
