# Dotfiles

This repository configures the `jan0ski` account and its hosts with Nix:

| Output | Host | Tool |
| --- | --- | --- |
| `homeConfigurations.zeus` (alias `jan0ski-linux`) | Zeus on Ubuntu | Home Manager |
| `checks.x86_64-linux.system-manager-preview` | Build only | System Manager |
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
- `hosts/zeus/system.nix`: build-only System Manager preview. It declares no
  Tailscale package or service and disables userborn and security wrappers.
- `nixos/default.nix`: shared NixOS settings: user, Zsh login shell,
  Tailscale, Docker, Ghostty, and fonts.
- `hosts/zeus/nixos.nix`: NixOS host settings for Zeus.

## Home Manager

Before switching, migrate the private settings listed below. Build without
activation with `nix build --no-link .#homeConfigurations.zeus.activationPackage`
(use `jan0ski-darwin` on macOS). Use the launchers from `flake.lock`:

```sh
# Zeus on Ubuntu
nix run --inputs-from . home-manager -- switch --flake .#zeus

# macOS
nix run --inputs-from . home-manager -- switch --flake .#jan0ski-darwin
```

Ubuntu owns Tailscale. Leave its apt package, unit, defaults, and state in
place. Do not remove or purge it: removal stops the tunnel and can mask the
unit; purge deletes the state. There is no `systemConfigs.zeus` switch target.
To inspect the preview, use `nix build --no-link .#checks.x86_64-linux.system-manager-preview`.
Do not register, activate, or deactivate it. The preview rejects activation;
System Manager still generates global environment, systemd, and tmpfiles entries.

A future service handoff requires independent console access, a protected state
backup, the exact apt recovery package, and a tested cutover, rollback, and
reboot on a disposable host of the same Ubuntu release. Check the unit owner,
running executable, account access, and peer connectivity in both directions.

The Zeus login shell stays `/usr/bin/zsh`. On NixOS it is the Nixpkgs Zsh.

## NixOS

`hosts/zeus/nixos.nix` holds placeholder boot and file system settings.
Replace them with the output of `nixos-generate-config` on the target before
installing.
Set the normal user's password from the installation console (for example,
`nixos-enter --root /mnt -c 'passwd jan0ski'` after `nixos-install`), and test
a login and sudo before depending on remote access. The installer's password
prompt configures root, not the normal user. VM autologin is not a login test.

On NixOS and macOS, start a new login shell and check `command -v amp rustup`
before retiring old installers. Rustup does not install a compiler until you
select a toolchain, for example with `rustup default stable`.

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

Before the first switch, copy private SSH host blocks to `~/.ssh/config.local`
(mode 0600). Do not copy a catch-all forwarding rule. SSH includes this file
first; opt in to `ForwardAgent yes` only for named, trusted hosts. SSH keeps
`SSH_AUTH_SOCK` if it names a socket; otherwise it uses the local 1Password
socket if present. This check does not contact the agent or inspect its keys.

Move Git `user.name`, `user.email`, `user.signingKey`, and any work-specific
includes to `~/.gitconfig-local`. Move jj `user.name`, `user.email`, `signing.key`,
and any private scopes to `~/.config/jj/conf.d/local.toml`. These are runtime
files, not flake inputs. Signing stays enabled. Ubuntu and macOS require the
1Password desktop signer. NixOS uses OpenSSH `ssh-keygen`: provision a local
signing key or a public signing key with its private key in a reachable SSH
agent. Test a signed commit in a disposable repository before pushing.

Docker configuration remains mutable. If `credsStore` is a nonempty string,
Home Manager leaves the selection and registry mappings alone. Otherwise it
adds the platform default and cloud registry defaults, preserving explicit
per-registry helpers. Ubuntu uses Secret Service and macOS uses Keychain.
Headless NixOS uses `docker-credential-pass` with `pass` and GnuPG's terminal pinentry. Before
login, provision your own GPG encryption key and run `pass init <fingerprint>`
in your user session. Keep the private key and password store outside Git and
Nix. Without that setup, login fails rather than using inline storage.

Existing credentials are not migrated. To change helpers, log out using the
old helper, select and initialize the new one, then log in again. Migrate
existing inline credentials before switching profiles. The `cgr` helper
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
