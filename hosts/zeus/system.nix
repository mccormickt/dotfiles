# System Manager configuration for Zeus on Ubuntu. Tailscale keeps its node
# state in /var/lib/tailscale, outside the repository and the Nix store.
{ pkgs, ... }:

{
  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = [ pkgs.tailscale ];

  systemd.services.tailscaled = {
    description = "Tailscale node agent";
    documentation = [ "https://tailscale.com/kb/" ];
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-pre.target" ];
    after = [ "network-pre.target" "NetworkManager.service" "systemd-resolved.service" ];
    path = with pkgs; [ getent iproute2 iptables kmod procps ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${pkgs.tailscale}/bin/tailscaled --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock --port=41641";
      ExecStopPost = "${pkgs.tailscale}/bin/tailscaled --cleanup";
      Restart = "on-failure";
      RuntimeDirectory = "tailscale";
      RuntimeDirectoryMode = "0755";
      StateDirectory = "tailscale";
      StateDirectoryMode = "0700";
      CacheDirectory = "tailscale";
      CacheDirectoryMode = "0750";
    };
  };
}
