# Code generated by zoxide. DO NOT EDIT.
# -- But I already did.

# =============================================================================
#
# Hook configuration for zoxide.
#

# Initialize hook to add new entries to the database.
export-env {
  if (not ($env | default false __zoxide_hooked | get __zoxide_hooked)) {
    $env.__zoxide_hooked = true
    $env.config = ($env | default {} config).config
    $env.config = ($env.config | default {} hooks)
    $env.config = ($env.config | update hooks ($env.config.hooks | default {} env_change))
    $env.config = ($env.config | update hooks.env_change ($env.config.hooks.env_change | default [] PWD))
    $env.config = ($env.config | update hooks.env_change.PWD ($env.config.hooks.env_change.PWD | append {|_, dir|
      zoxide add -- $dir
    }))
  }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.

def __zoxide-query-list []: nothing -> list<string> {
  zoxide query --list | lines | path basename
}

# Jump to a directory using only keywords.
def --env __zoxide_z [...rest: string@__zoxide-query-list] {
  let arg0 = ($rest | append '~').0
  let path = if (($rest | length) <= 1) and ($arg0 == '-' or ($arg0 | path expand | path type) == dir) {
    $arg0
  } else {
    (zoxide query --exclude $env.PWD -- $rest | str trim -r -c "\n")
  }
  cd $path
}

# Jump to a directory using interactive search.
def --env __zoxide_zi  [...rest:string] {
  cd $'(zoxide query --interactive -- $rest | str trim -r -c "\n")'
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.


export alias z = __zoxide_z
export alias zi = __zoxide_zi

# put `use zoxide.nu [z, zi]` into config.nu.
