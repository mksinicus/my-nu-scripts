#!/usr/bin/env nu

# pip install --upgrade pyotp
const CURRENT_FILE = path self
use std assert

def my-secrets [] {
  [
    'github'
  ]
}

export def main [
  app: string@my-secrets
] {
  assert ($app in (my-secrets))
  let secret_path = $CURRENT_FILE | path dirname | path join secrets $app
  let pyscript = [
  'import pyotp'
  $'secret_path = "($secret_path)"'
  'secret_key = open(secret_path).read().strip()'
  '# print(secret_key)'
  'print(pyotp.TOTP(secret_key).now())'
  ] | str join "\n"
  python3 -c $pyscript
}

