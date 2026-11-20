# Starting point for Zeus on NixOS. Replace the boot and file system settings
# with the output of `nixos-generate-config` on the target before installing.
{ ... }:

{
  networking.hostName = "zeus";
  networking.networkmanager.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };
}
