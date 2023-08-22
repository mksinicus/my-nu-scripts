#!/usr/bin/env nu

def main [] {
  let yes = (input "Upgrade apt? [Y/n]")
  if not ($yes | str contains 'n') {
    sudo apt upgrade
  } else {
    "Apt upgrade aborted."
  }

  # let yes = (input "Refresh snap? [Y/n]")
  # if not ($yes | str contains 'n') {
  #   snap refresh
  # } else {
  #   "Snap refresh aborted."
  # }
  # echo "Your softwares are latest. Have a nice day!"
}
