#! /usr/bin/env nu
def main [
  ...filenames: string
  --output_dir (-d): string = "."
  --output_file (-o): string = "NULL"
  --quiet (-q)
  ] {
  let output_file = if $output_file != "NULL" {
    $"'($output_file)'"
    } else $output_file
  for filename in $filenames {
    Rscript --no-echo -e $"rmarkdown::render\('($filename)',
              output_file = ($output_file),
              output_dir = '($output_dir)',
              (if $quiet {'quiet = TRUE'})\)
              "
  }
}
