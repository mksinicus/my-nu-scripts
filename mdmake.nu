#!/usr/bin/env nu

def err-exit [
  message: string
  span
] {
  error make {
    msg: $message
    label: {
      text: $message
      start: $span.start
      end: $span.end
    }
  }
}

export def main [
  --keep (-k)                 # Keep intermediate output markdown file
  --initialize_config (-i)    # Generate a config file named `mdmake.toml`
  --quiet (-q)                # Be quiet
] {
  # Init. config on call
  if $initialize_config {
    init-config
    print "Initialized config file in the current directory."
    return
  }

  # If quiet... Nonfunctional for now.

  # Load config file
  let conf = (load-config)
  verify-config $conf
  let front_matter = $conf.front_matter
  let out_md = ($conf.out_md)
  let out_final = $conf.out_final
  let out_dir = $conf.out_dir
  let sources = if $conf.components == 'auto' or $conf.components == null {
    auto-source
  } else {
    $conf.components
  }

  # combine source files to single, intermediate source file
  open -r $front_matter | save -rf $out_md
  for source in $sources {
    echo "\n" | save -ra $out_md # Add linebreaks just in case
    open -r $source | save -ra $out_md
  }
  
  # Approach by calling R and rmarkdown::render.
  # rmd -q $out_md -o $out_final -d $out_dir
  rmd -q $out_md -o $'($out_final)' -d $out_dir
  
  # Use quarto to render. 
  # Not saving output natively, because quarto does not support saving to 
  # a different directory.
  if false {
    quarto render $out_md --output - | save -r $out_final
  
  }

  # keep intermediate artefact or not
  if not $keep { rm $out_md }

  # Link to outer dir
  do {
    cd $out_dir
    ln -sf ($out_final | path expand) ..
  }
}

def load-config [] {
  let config_formats = ['toml', 'yaml', 'yml', 'json']
  let possible_configs = (ls | get name | find -ir '^mdmake')
  # Actually should stop at first config found. But nu doesn't have breaks.
  # // It *didn't*. Nu introduced breaks in the next version.
  # // I shall consider refactoring this.
  # Nor does it have do-while loops. I hate iterations though...
  let ordered_configs = ($config_formats | each {
    |format| let config = ($possible_configs | find $format)
    # `find` results in a list, so we take its first child
    if not ($config | is-empty) {$config.0} else {null}
  })
  # Empty list is still list. And the error message may be unclear.
  # So we make one.
  if ($ordered_configs | is-empty) {
    err-exit "No config found" (metadata $ordered_configs).span
  }
  open $ordered_configs.0
}

## Auto source target `.md` files, i.e. every `.md` file in the same directory.
def auto-source [] {
  ls *md | get name
}

## Verify config file by using keywords.
## If not loadable, the error message will tell.
def verify-config [config: record] {
  let keywords = [
    'front_matter',
    'components',
    'out_dir',
    'out_md',
    'out_final'
  ]
  # But since the validator does not help us check nonexistent keys...
  for kw in $keywords {
    if ($config | transpose key value | find $kw | is-empty) {
      err-exit $'Invalid config, missing keyword `($kw)`' (metadata $config).span
    }
  }
}

def init-config [] {
  # That nonsense pipe is to keep LF ending!
  (echo `
front_matter = "front.yaml"
out_dir = "out"
out_md = "out.md"
out_final = "out.html"
components = [
  "main.md",
]
    ` | str trim | $in + "\n" | save -r "mdmake.toml")
}
