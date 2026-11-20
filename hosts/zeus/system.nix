{
  nixpkgs.hostPlatform = "x86_64-linux";
  services.userborn.enable = false;
  security.enableWrappers = false;

  system-manager.preActivationAssertions.buildOnly = {
    enable = true;
    script = ''
      echo 'Build-only profile: Ubuntu owns system services and accounts.' >&2
      exit 1
    '';
  };
}
