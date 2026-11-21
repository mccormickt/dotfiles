{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  users.users.jan0ski = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.gnupg.agent.enable = true;
  services.tailscale.enable = true;
  virtualisation.docker.enable = true;

  environment.systemPackages = [ pkgs.ghostty ];
  fonts.packages = [ pkgs.powerline-fonts ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jan0ski = {
      imports = [ ../home.nix ../home/tools.nix ];
      _module.args.dockerCredentialStore = "pass";
      home.packages = [ pkgs.pass pkgs.gnupg ];
    };
  };

  system.stateVersion = "25.11";
}
