#!/usr/bin/env nu

# Use ffmpeg to extract audio from a video
def main [
  --quiet (-q)          # Be quiet!
  ...filenames: string  # Files to be processed
] {
  alias conv = do {
    |filename|
    ffmpeg -i $filename -vn -acodec copy $"($filename).m4a"
  }
  for filename in $filenames {
    if $quiet {
      alias ffmpeg = ffmpeg -loglevel quiet
      conv $filename
    } else {
      conv $filename
    }
  }
}
