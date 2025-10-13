# Bede's dotfiles and scripts

These are all my personal dotfiles and various scripts I've found useful.
Ideally this README is to help me remember all the features I have.

## Setup

### Standard setup

```bash
sh -c "$(curl -fsLS git.io/JO2iE)"
```

### Podman test environment

Make sure that there are enough ids available for podman to work before starting.
Refer to <https://www.redhat.com/sysadmin/rootless-podman> for more information.

```bash
$ find /etc/sub[ug]id | xargs -i sh -c 'echo {} && cat {}'
/etc/subgid
<username>:100000:65536
/etc/subuid
<username>:100000:65536
```

Run a podman container with `podman run --rm -it fedora`.

Now run the following command to get environment setup.

```bash
cd && dnf install git hostname vim procps -y && sh -c "$(curl -fsLS git.io/JO2iE)"
```

### WSL

```bash
rustup default stable
bat cache --build
```

## Configs

### Bash

### TMUX

### Vim

## Scripts

## Building windows-fido-bridge for WSL

Needed for 20.04 due to newer g++ required for span and openssh-client
needs to be above 8.2 due to message format for windows side
<https://www.debian.org/doc/manuals/apt-howto/ch-apt-get.en.html>
<https://medium.com/@george.shuklin/how-to-install-packages-from-a-newer-distribution-without-installing-unwanted-6584fa93208f>

```bash
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

## Euler VM Deployment

Build and deploy the euler NixOS VM to Proxmox:

```bash
# Build VM image
nix build .#vms.x86_64-linux.euler -o ~/euler-vm

# Import VMA file to Proxmox
# Transfer the VMA file to your Proxmox host, then:
qmrestore ~/euler-vm/nixos.vma <VM_ID> --storage local-lvm --unique

# Start the VM
qm start <VM_ID>

# Get SOPS key from VM
ssh bc@euler "sudo age-keygen -y /var/lib/sops-nix/key.txt"

# Add public key to SOPS and encrypt secrets
# Edit nix/system-configs/euler/secrets.sops.yaml
sops -e -i nix/system-configs/euler/secrets.sops.yaml

# Deploy configuration changes
deploy .#euler
```

## Pascal Reverse Proxy Deployment

Deploy pascal NixOS reverse proxy to Oracle OCI:

```bash
# Create Oracle OCI instance with Ubuntu/Oracle Linux

# Install NixOS via nixos-infect
curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-25.05 bash

# Get SOPS key from server
ssh bc@pascal "sudo age-keygen -y /var/lib/sops-nix/key.txt"

# Add public key to SOPS and encrypt secrets
# Edit nix/system-configs/pascal/secrets.sops.yaml
sops -e -i nix/system-configs/pascal/secrets.sops.yaml

# Deploy configuration
deploy .#pascal
```

## References

* Delta catppuccin config comes from: [Delta catppuccin](https://github.com/catppuccin/delta)
* Bat catppuccin config comes from: [Bat catppuccin](https://github.com/catppuccin/bat)
