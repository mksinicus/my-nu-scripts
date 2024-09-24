export def main [
  file: path
  --pdflatex (-p)
  --lualatex (-l)
  --xelatex (-x)
] {
  let flag = match [
      $pdflatex
      $lualatex
      $xelatex
    ] {
      $x if ($x | find true | length | $in > 1) => {error-too-much-flags}
      [true false false] => 'pdflatex'
      [false true false] => 'lualatex'
      [false false true] => 'xelatex'
      _ => 'xelatex'
    }
  let command = [
      'tinytex::'
      $flag
      '('
      ($file | to json)
      ')'
    ] | str join

  Rscript -e $command
}

def error-too-much-flags [] {
  error make {
    msg: "Too much flags"
  }
}

export const temp = r#'
tinytex::tlmgr_install(c("adjustbox", "adobemapping", "amscls", "amsfonts", "amsmath", "arphic", "atbegshi", "atveryend", "auxhook", "babel", "beamer", "bibtex", "bigintcalc", "bitset", "booktabs", "caption", "cjk", "cjkpunct", "cm", "cns", "collectbox", "ctablestack", "ctex", "currfile", "dehyph", "dvipdfmx", "dvips", "ec", "elocalloc", "environ", "epstopdf-pkg", "etex", "etexcmds", "etoolbox", "euenc", "everyhook", "everyshi", "fancyvrb", "fandol", "filehook", "filemod", "firstaid", "float", "fonts-tlwg", "fontspec", "forest", "fp", "framed", "garuda-c90", "geometry", "gettitlestring", "gincltex", "glyphlist", "graphics", "graphics-cfg", "graphics-def", "grfext", "grffile", "helvetic", "hycolor", "hyperref", "hyph-utf8", "hyphen-base", "iftex", "inconsolata", "infwarerr", "inlinedef", "intcalc", "knuth-lib", "kpathsea", "kvdefinekeys", "kvoptions", "kvsetkeys", "l3backend", "l3kernel", "l3packages", "latex", "latex-amsmath-dev", "latex-base-dev", "latex-bin", "latex-fonts", "latex-tools-dev", "latexconfig", "latexmk", "letltxmacro", "lm", "lm-math", "ltxcmds", "lua-alt-getopt", "lua-uni-algos", "luahbtex", "lualatex-math", "lualibs", "luaotfload", "luatex", "luatexbase", "luatexja", "makecmds", "mdwtools", "metafont", "metalogo", "mfware", "modes", "mptopdf", "ms", "natbib", "norasi-c90", "pdfescape", "pdftex", "pdftexcmds", "pgf", "pgfopts", "plain", "platex", "platex-tools", "polyglossia", "psnfss", "ptex", "ptex-base", "ptex-fonts", "refcount", "rerunfilecheck", "scheme-infraonly", "selnolig", "standalone", "stix2-otf", "stix2-type1", "stringenc", "svn-prov", "symbol", "tex", "tex-ini-files", "texdoc", "texlive-scripts", "texlive.infra", "times", "tipa", "tools", "translator", "trimspaces", "ttfutils", "uhc", "ulem", "unicode-data", "unicode-math", "uniquecounter", "uplatex", "uptex", "uptex-base", "uptex-fonts", "url", "wadalab", "xcjk2uni", "xcolor", "xecjk", "xetex", "xetexconfig", "xkeyval", "xpinyin", "xunicode", "zapfding", "zhmetrics", "zhmetrics-uptex", "zhnumber"), repository = "illinois")
'#
