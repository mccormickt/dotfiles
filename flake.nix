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
      homeConfigurations = rec {
        zeus = mkHome "x86_64-linux" [ ./home.nix ./hosts/zeus/home.nix ];
        jan0ski-linux = zeus;
        jan0ski-darwin = mkHome "aarch64-darwin" [ ./home.nix ./home/tools.nix ];
      };

      checks.x86_64-linux.system-manager-preview = let
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        preview = system-manager.lib.makeSystemConfig { modules = [ ./hosts/zeus/system.nix ]; };
      in pkgs.runCommand "system-manager-preview" {} ''
        mkdir -p "$out"
        ${pkgs.jq}/bin/jq -e 'keys | select(. == ["sysinit-reactivation.target", "system-manager-path.service", "system-manager.target"])' \
          ${preview}/services/services.json > "$out/units.json"
      '';

      nixosConfigurations = {
        zeus = mkNixos [ ./hosts/zeus/nixos.nix ];
        dotfiles-vm = mkNixos [ ./vm.nix ];
      };
    };
}
