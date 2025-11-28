# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# Or ask Viktoria.

{ config, lib, pkgs, ... }:

{
  # Import nixos base iso
  imports = [ 
      <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ];

  # Network settings
  networking.hostName = "kiosk"; 
  networking.networkmanager.enable = true;  
  networking.wireless.enable = pkgs.lib.mkForce false; # Force disabled to avoid conflict

  # Set time zone
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  
  # Define admin user
  users.users.blubb = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      curl
      wget
      nano
    ];
  };
 
  # Define user for kiosk environment
  users.users.kiosk = {
    isNormalUser = true;
    packages = with pkgs; [];
  };

  # Enable "silent boot"
  boot = {
    kernelParams = [ "quiet" "splash" "boot.shell_on_fail"];
    consoleLogLevel = 3;
    initrd.verbose = false;
    loader.timeout = pkgs.lib.mkForce 0;
    # Small loading animation during boot and shutdown
    plymouth = {
      enable = true;
      theme = "spinner_alt";
      # logo  = /etc/nixos/rsrc/TU_BERLIN_Logo.png;
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "spinner_alt" ];
        })
      ];
    };
  };

  # Cage Setup
  # Keyboard layout within cage, just in case
  systemd.services.cage-tty1.environment.XKB_DEFAULT_LAYOUT = "de";

  # Start after network connection (hopefully)
  systemd.services.cage-tty1.after = [
    "network-online.target"
    "systemd-resolved.service"
  ];

  # Specify actual cage launch values
  services.cage = {
    enable = true;
    user = "kiosk";
    program = "${pkgs.firefox}/bin/firefox -kiosk -private-window https://web01.iiab.local/moodle";
  };
  
  # Disable keys for shortcuts
  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            control = "noop";
            esc = "noop";
            alt = "noop";
            tab = "noop";
            f6 = "noop";
          };
        };
      };
    };
  };

  # Firefox program and policy options
  programs.firefox = {
    enable = true;
    languagePacks = [ "de" ];
    policies = {
      # Updates
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;
      #Features
      DisableTelemetry = true;
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableFirefoxScreenshots = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      #Access Restrictions
      BlockAboutConfig = true;
      BlockAboutProfiles = true;
      BlockAboutSupport = true;
      DisableDeveloperTools = true;
    };
  };

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    plymouth
    pkgs.firefox
  ];

  # Change ISO compression to speed up build times
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  # Do NOT change the following value.
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
  };
}
