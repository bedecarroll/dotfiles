# Bede's dotfiles and scripts

These are all my personal dotfiles and various scripts I've found useful. Ideally this README is to help me remember all the features I have.

## Setup

### Standard setup
```
sh -c "$(curl -fsLS git.io/JO2iE)"
```

### Podman test environment
Make sure that there are enough ids available for podman to work before starting. Refer to https://www.redhat.com/sysadmin/rootless-podman for more information.
```
$ find /etc/sub[ug]id | xargs -i sh -c 'echo {} && cat {}'
/etc/subgid
<username>:100000:65536
/etc/subuid
<username>:100000:65536
```

Run a podman container with `podman run --rm -it fedora`.

Now run the following command to get environment setup.
```
cd && dnf install git hostname vim procps -y && sh -c "$(curl -fsLS git.io/JO2iE)"
```

## Configs

### Bash

### TMUX

### Vim

## Scripts
