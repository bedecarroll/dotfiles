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

## Building windows-fido-bridge for WSL
Needed for 20.04 due to newer g++ required for span and openssh-client needs to be above 8.2 due to message format for windows side
https://www.debian.org/doc/manuals/apt-howto/ch-apt-get.en.html
https://medium.com/@george.shuklin/how-to-install-packages-from-a-newer-distribution-without-installing-unwanted-6584fa93208f
```
sudo sh -c 'printf "deb http://archive.ubuntu.com/ubuntu/ hirsute main restricted universe\ndeb http://archive.ubuntu.com/ubuntu/ hirsute-updates main restricted universe\ndeb http://security.ubuntu.com/ubuntu/ hirsute-security main restricted universe\n" >> /etc/apt/sources.list'
sudo sh -c 'printf "APT::Default-Release "focal";" >> /etc/apt/apt.conf'
sudo apt-get update
sudo apt-get install openssh-client/hirsute

cd
git clone https://github.com/mgbowen/windows-fido-bridge.git
sudo apt install build-essential cmake g++-mingw-w64-x86-64/hirsute
cd windows-fido-bridge
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j $(nproc)
```
