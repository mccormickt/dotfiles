{
  description = "Home Manager, System Manager, and NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, system-manager, ... }:
    let
      mkHome = system: modules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          inherit modules;
        };
      mkNixos = modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ home-manager.nixosModules.home-manager ./nixos ] ++ modules;
        };
    in {
      homeConfigurations = {
        zeus = mkHome "x86_64-linux" [ ./home.nix ./hosts/zeus/home.nix ];
        jan0ski-darwin = mkHome "aarch64-darwin" [ ./home.nix ./home/tools.nix ];
      };

      systemConfigs.zeus = system-manager.lib.makeSystemConfig {
        modules = [ ./hosts/zeus/system.nix ];
      };

      nixosConfigurations = {
        zeus = mkNixos [ ./hosts/zeus/nixos.nix ];
        dotfiles-vm = mkNixos [ ./vm.nix ];
      };
    };
}
