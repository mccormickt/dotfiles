# Dotfiles

This repository uses Home Manager to configure the `jan0ski` account on
x86_64 Linux and Apple Silicon macOS.

## Apply

```sh
# Linux
nix run github:nix-community/home-manager -- switch --flake .#jan0ski-linux

# macOS
nix run github:nix-community/home-manager -- switch --flake .#jan0ski-darwin
```

## Test VM

Build and start the headless NixOS VM. It logs in as `jan0ski`, includes the
Home Manager profile, and enables Docker.

```sh
nix build .#nixosConfigurations.dotfiles-vm.config.system.build.vm
./result/bin/run-dotfiles-vm-vm
```

Exit the VM with `Ctrl-a x`.

## Credentials

The configuration installs the 1Password CLI and selects the platform-specific
SSH agent socket. Keep secrets out of Nix expressions because evaluated values
are stored in the Nix store. Resolve 1Password references at runtime with
`op run`, `op read`, or `op inject` instead.

Docker configuration remains mutable so `docker login` can update it. Home
Manager adds the native credential store and the existing GCR, Artifact
Registry, and Chainguard helpers without copying registry credentials into the
Nix store. Existing inline credentials must be migrated once with `docker
logout` followed by `docker login` for each registry. The `cgr` helper still
requires `docker-credential-cgr` from Chainguard's `chainctl` installation.

Home Manager does not manage credentials, command history, caches, downloaded
Claude plugins, installed agent skills, generated application state, or
machine-local Claude permissions. It keeps the agent skill lock file and the
locally authored Claude security-audit skill.

Before the first switch, move any existing files that Home Manager reports as
collisions. In particular, move `~/.gitconfig`; Home Manager manages both that
legacy path and the XDG Git configuration so an old file cannot override the
declarative settings.
