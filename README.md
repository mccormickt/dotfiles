# Dotfiles

This repository configures the `jan0ski` account and its hosts with Nix:

| Output | Host | Tool |
| --- | --- | --- |
| `homeConfigurations.zeus` | Zeus on Ubuntu | Home Manager |
| `systemConfigs.zeus` | Zeus on Ubuntu | System Manager |
| `homeConfigurations.jan0ski-darwin` | Apple Silicon macOS | Home Manager |
| `nixosConfigurations.zeus` | Zeus on NixOS | NixOS with Home Manager |
| `nixosConfigurations.dotfiles-vm` | Test VM | NixOS with Home Manager |

## Layout

- `home.nix`: shared Home Manager profile: Git, Jujutsu, Zsh, SSH, Helix,
  Vim, Neovim, tmux with Powerline, and coding agent configuration.
- `home/tools.nix`: Rust, coding agents, and cloud CLIs from Nixpkgs. NixOS
  and macOS import it. Zeus on Ubuntu keeps its existing snap, apt, Homebrew,
  and self-updating installations of these tools and of Ghostty.
- `hosts/zeus/home.nix`: Ubuntu shell hooks for those installations.
- `hosts/zeus/system.nix`: System Manager services. It runs `tailscaled` from
  Nixpkgs.
- `nixos/default.nix`: shared NixOS settings: user, Zsh login shell,
  Tailscale, Docker, Ghostty, and fonts.
- `hosts/zeus/nixos.nix`: NixOS host settings for Zeus.

## Apply

```sh
# Zeus on Ubuntu
nix run github:nix-community/home-manager -- switch --flake .#zeus
sudo nix run github:numtide/system-manager -- switch --flake .#zeus

# macOS
nix run github:nix-community/home-manager -- switch --flake .#jan0ski-darwin
```

Before the System Manager switch, remove the apt `tailscale` package. Both
provide `tailscaled.service`. The Nix unit uses the same state directory,
`/var/lib/tailscale`, so the node stays logged in.

The Zeus login shell stays `/usr/bin/zsh`. On NixOS it is the Nixpkgs Zsh.

## NixOS

`hosts/zeus/nixos.nix` holds placeholder boot and file system settings.
Replace them with the output of `nixos-generate-config` on the target before
installing.

## Test VM

Build and start the headless NixOS VM. It logs in as `jan0ski`, includes the
Home Manager profile, and enables Docker.

```sh
nix build .#nixosConfigurations.dotfiles-vm.config.system.build.vm
./result/bin/run-dotfiles-vm-vm
```

Exit the VM with `Ctrl-a x`.

## Credentials and private hosts

Keep secrets out of Nix expressions because evaluated values are stored in the
Nix store. Resolve 1Password references at runtime with `op run`, `op read`, or
`op inject` instead.

SSH host blocks with private names or addresses go in `~/.ssh/config.local`,
which the managed SSH configuration includes. Machine-local Git settings go in
`~/.gitconfig-local`.

Docker configuration remains mutable so `docker login` can update it. Home
Manager adds the native credential store and the existing GCR, Artifact
Registry, and Chainguard helpers without copying registry credentials into the
Nix store. Existing inline credentials must be migrated once with `docker
logout` followed by `docker login` for each registry. The `cgr` helper still
requires `docker-credential-cgr` from Chainguard's `chainctl` installation.

Home Manager does not manage credentials, command history, caches, downloaded
Claude plugins, installed agent skills, generated application state, or
machine-local Claude permissions. It does not manage the OpenCode, Gemini,
Goose, or Pi settings files, because they hold API keys, host addresses, or
state that the tools write. It keeps the agent skill lock file and the locally
authored Claude security-audit skill.

Before the first switch, move any existing files that Home Manager reports as
collisions. In particular, move `~/.gitconfig`; Home Manager manages both that
legacy path and the XDG Git configuration so an old file cannot override the
declarative settings.
