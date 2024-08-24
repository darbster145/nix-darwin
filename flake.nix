{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # Optional: Declarative tap management
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
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        neovim
        tldr
        zoxide
        fastfetch
        kitty
        google-chrome
        raycast
        htop
        btop
        ripgrep
        fd
        fzf
        ranger
      ];

      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "uninstall";
          autoUpdate = true;
          upgrade = true;
        };

        brews = [];

        casks = [
          "iterm2"
          "firefox"
          "bitwarden"
        ];

        caskArgs.no_quarantine = true;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Touch ID auth for sudo
      security.pam.enableSudoTouchIdAuth = true;

      # Disable starup chime
      system.startup.chime = false;

      system.activationScripts.postUserActivation.text = ''/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u '';

      system.defaults = {

        # dock settings
        dock = {
          autohide = true;
          autohide-delay = 0.24;
          mru-spaces = false;
          magnification = true;
          mineffect = "scale";
          minimize-to-application = true;
          persistent-others = [
            "~/Applications"
          ];
          # Show only open applications in the Dock.
          # static-only = true;

        };

        # Clock Config
        menuExtraClock = {
          Show24Hour = true;
          ShowSeconds = true;
        };

        # finder settings
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXPreferredViewStyle = "Nlsv";
          FXDefaultSearchScope = "SCcf";
          QuitMenuItem = true;
          ShowPathbar = true;
          ShowStatusBar = true;
          _FXShowPosixPathInTitle = true;
        };

        loginwindow.LoginwindowText = "sugundezz";

        screencapture.location = "~/Pictures/screenshots";

        screensaver.askForPasswordDelay = 10;

        SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

        spaces.spans-displays = false;

        # Trackpad Settings
        trackpad = {
          ActuationStrength = 1;
          Clicking = true;
          # Tap to Drag
          Dragging = false;
        };

        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          "com.apple.sound.beep.volume" = 1.0;
          NSScrollAnimationEnabled = true;
          "com.apple.swipescrolldirection" = true;
        };
      };

      # Keyboard settings
      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };

      nix-homebrew = {
        # Install Homebrew under the default prefix
        enable = true;

        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = true;

        # User owning the Homebrew prefix
        user = "yourname";

        # Optional: Declarative tap management
        taps = {
          "homebrew/homebrew-core" = homebrew-core;
          "homebrew/homebrew-cask" = homebrew-cask;
          "homebrew/homebrew-bundle = homebrew-bundle;
        };

        # Optional: Enable fully-declarative tap management
        #
        # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
        mutableTaps = false;
      };
    };

  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#crapple
    darwinConfigurations."crapple" = nix-darwin.lib.darwinSystem {
      modules = [ configuration nix-homebrew.darwinModules.nix-homebrew ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."crapple".pkgs;
  };
}
