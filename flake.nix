{
  description = "Cross-platform Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      mkHome = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [ ./home.nix ];
        };
    in {
      homeConfigurations = {
        jan0ski-linux = mkHome "x86_64-linux";
        jan0ski-darwin = mkHome "aarch64-darwin";
      };

      nixosConfigurations.dotfiles-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./vm.nix
        ];
      };
    };
}
