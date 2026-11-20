{ pkgs, ... }:

{
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
