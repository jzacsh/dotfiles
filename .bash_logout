#!/bin/bash
# ~/.bash_logout: executed by bash(1) when login shell exits.

if [[ "$SHLVL" -eq 1 ]]; then
  clear # when leaving the console clear the screen to increase privacy

  # Clear out dotfile runtime indicators
  forest_runtime_dir="$XDG_RUNTIME_DIR"/"$(whoami)".dotfiles.management.d
  rm -rf "$forest_runtime_dir"
fi
