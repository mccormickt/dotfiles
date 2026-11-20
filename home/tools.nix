{ config, lib, pkgs, ... }:

{
  # Resolve managed tools before any user installer paths inherited at login.
  home.sessionPath = [
    "${config.home.profileDirectory}/bin"
    "$HOME/.bun/bin" "$HOME/.cargo/bin" "$HOME/.krew/bin" "$HOME/.local/bin" "$HOME/go/bin"
  ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "$HOME/Library/pnpm"
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];
  home.packages = with pkgs; [
    # Rust
    rustup

    # Coding agents
    amp-cli
    claude-code
    codex
    gemini-cli
    github-copilot-cli
    goose-cli
    opencode
    pi-coding-agent

    # Cloud and cluster CLIs
    awscli2
    flyctl
    google-cloud-sdk
    kubectl
    kubernetes-helm
    talosctl
  ];
}
