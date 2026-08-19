{ pkgs, ... }:

{
  networking.hostName = "dotfiles-vm";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  users.users.jan0ski = {
    isNormalUser = true;
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "jan0ski";
  virtualisation.docker.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jan0ski = import ./home.nix;
  };

  virtualisation.vmVariant.virtualisation = {
    cores = 4;
    diskSize = 16384;
    graphics = false;
    memorySize = 4096;
  };

  system.stateVersion = "25.11";
}
