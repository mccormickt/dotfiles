{ ... }:

{
  networking.hostName = "dotfiles-vm";
  security.sudo.wheelNeedsPassword = false;
  services.getty.autologinUser = "jan0ski";

  virtualisation.vmVariant.virtualisation = {
    cores = 4;
    diskSize = 16384;
    graphics = false;
    memorySize = 4096;
  };
}
