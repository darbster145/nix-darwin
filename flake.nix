{
  description = "Multi-host nix-darwin flake with crapple and MacBook-Air-3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    spacebar.url = "github:cmacrae/spacebar/v1.4.0";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Homebrew taps for crapple
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    AeroSpace = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nix-darwin, spacebar, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, AeroSpace, ... } @ inputs: {
    darwinConfigurations = {
      # MacBook-Air-3 Host Configuration
      "MacBook-Air-3" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-darwin";
        modules = [ 
          ./darwin/hosts/macbook-air-3/configuration.nix
        ];
      };

      # Crapple Host Configuration
      crapple = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        system = "aarch64-darwin";
        modules = [
          ./darwin/hosts/crapple/configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
    };

    # Expose the package sets for both hosts
    darwinPackages = {
      "MacBook-Air-3" = self.darwinConfigurations."MacBook-Air-3".pkgs;
      crapple = self.darwinConfigurations.crapple.pkgs;
    };
  };
}

