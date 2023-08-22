#!/usr/bin/env nu

# convert HTML to PDF with headless Chromium
def main [...filenames] {
  $filenames | each {
    |filename|
    let newname = $"($filename).pdf"
    nu -c $'chromium --headless --print-to-pdf=($newname) ($filename)'
  }
}
