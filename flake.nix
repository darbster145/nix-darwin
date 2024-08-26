{
  description = "Work Mac Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin,  ... }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        neovim
        tldr
        tmux
        fastfetch
        ranger
        thefuck
        unzip
        zoxide
        fzf
        kitty
        speedtest-cli
        stow
        nerdfonts
        htop
        btop
        docker_27
        docker-client
        oh-my-posh
      ];

      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "uninstall";
          autoUpdate = true;            
          upgrade = true;
        };
        taps = [ 
          "nikitabobko/homebrew-tap"      
          "koekeishiya/formulae" 
        ];
        brews = [ 
          "yabai" 
          "skhd"
        ];
        casks = [
          "microsoft-edge"
          "1password"
          "1password-cli"
          "bartender"
          "bitwarden"
          "chromium"
          "crystalfetch"
          "disk-inventory-x"
          "displaylink"
          "firefox@developer-edition"
          "istat-menus"
          "jiggler"
          "mac-mouse-fix"
          "microsoft-office"
          "microsoft-remote-desktop"
          "notion"
          "raycast"
          "slack"
          "splashtop-business"
          "swift-quit"
          "topnotch"
          "tunnelblick"
          "utm"
          "zoom"
          "zenmap"
          "yt-music"
          "shortcat"
          "aerospace"
          "betterdisplay"
            ];
        caskArgs.no_quarantine = true;

     };

      fonts.packages = with pkgs; [
        nerdfonts
     ];

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

      # Force some settings to change that don't change until logout/in
      system.activationScripts.postUserActivation.text = ''/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u '';

      # Disable starup chime
      system.startup.chime = false;

      system.defaults = {

        # dock settings
	dock = {
	  autohide = true;
	  autohide-delay = 0.24;
	  mru-spaces = false;
	  magnification = false;
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
   };

  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#crapple
    darwinConfigurations."MacBook-Air-3" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MacBook-Air-3".pkgs;
  };
}
