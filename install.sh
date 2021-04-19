#!/usr/bin/env bash

# Create bin dir and then make sure chezmoi is put there using -b
mkdir -p ~/.local/bin/ && sh -c "$(curl -fsLS git.io/chezmoi)" -- -b ~/.local/bin/ init --apply bedecarroll
