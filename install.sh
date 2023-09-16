#!/usr/bin/env bash

# Create bin dir and then make sure chezmoi is put there using -b
PATH="$HOME/.local/bin:$PATH"

# If we have a SSH key use SSH to clone from git
CHEZMOI_INSTALL_ARGS="-b ~/.local/bin/ -- init --apply bedecarroll"
if [[ -f .ssh/id_ed25519_sk.pub ]]; then
  CHEZMOI_INSTALL_ARGS+=" --ssh"
fi

mkdir -p ~/.local/bin/ && sh -c "$(curl -fsLS git.io/chezmoi) ${CHEZMOI_INSTALL_ARGS}"
