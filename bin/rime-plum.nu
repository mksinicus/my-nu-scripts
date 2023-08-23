#!/usr/bin/env nu

def main [
  ...packages: string
  --frontend (-f): string = "fcitx5-rime"
  ] {
  $env.rime_frontend = $frontend
  bash -c $"~/utilitate/plum/rime-install ($packages | str join ' ')"
  hide-env rime_frontend
}
