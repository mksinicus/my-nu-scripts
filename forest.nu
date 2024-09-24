#!/usr/bin/env nu

use tinytex.nu

const forest_code_0 = r#'
\documentclass{standalone}
\usepackage{tikz}
\usepackage[linguistics]{forest}
\usepackage{amssymb}
\usepackage{unicode-math}
\usepackage{xeCJK}
\setmainfont{STIX Two Text}
% \setmathfont[Path=D:/\string~fonts/]{STIXTwoMath-Regular.otf}
% \setCJKmainfont{Noto Serif CJK SC}
\newcommand{\tx}{\text}

\begin{document} 

\begin{forest}
'#

const forest_code_1 = r#'
\end{forest}

\end{document}
'#

export def main [...filenames: glob] {
  $filenames
  | each {|x|
    glob $x
  } | flatten
  | par-each {|x|
    do-once $x
  } | ignore
}

def do-once [filename: string] {
  let tempfile = mktemp --suffix $'.($filename | path basename).tex'
  let tempfile_stem = $tempfile | path parse | get stem

  open -r $filename | str trim
  | [$forest_code_0 $in $forest_code_1] | str join
  | save -f $tempfile

  try {
    tinytex $tempfile

    mv $'($tempfile_stem).pdf' $'($filename).pdf'
    ^pdftocairo -svg $'($filename).pdf' $'($filename).svg'
  }
  
  ifexist-rm $'($tempfile_stem).pdf'
  ifexist-rm $'($tempfile_stem).tex'
  ifexist-rm $'($tempfile_stem).aux'
  ifexist-rm $'($tempfile_stem).log'
}

def ifexist-rm [file] {
  if ($file | path exists) {
    rm -f $file
  }
}

def test [] {
  let forest_code = r#'
  [S
    [NP
      [Det [The]]
        [N$'$
          [N [lack]]
          [PP$_1$ [P [of]]
            [NP
              [N$'$ [N [teachers]]
                [PP$_2$
                  [P [with]]
                  [NP [any qualifications, roof]]]]]]]]
    [VP [bothered them, roof]]]
  '#

  let forest_code_with_math = r#'
  [nP
    [n]
    [{$\sqrt{\tx{P}}$}
      [{$\sqrt{\tx{老}}$}]
      [nP
        [n]
        [{$\sqrt{\tx{资格}}$}]]]]
  '#

  cd /tmp
  test-once $forest_code
  test-once $forest_code_with_math
}

def test-once [code] {
  mktemp --suffix '.tex' | collect {|x|
    $code | save -f $x
    main $x
  }
}
