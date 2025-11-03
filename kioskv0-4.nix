# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
# Or ask Viktoria.

{ config, lib, pkgs, ... }:

{
  imports = [ 
      <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    ];

  # Network settings
  networking.hostName = "kiosk"; # Define your hostname.
  networking.networkmanager.enable = true;  
  networking.wireless.enable = pkgs.lib.mkForce false;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    earlySetup = true;
    font = "Lat2-Terminus16";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Configure keymap in X11
  services.xserver.xkb.layout = "de";
  services.xserver.xkb.options = "nodeadkeys";

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.blubb = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      curl
      wget
      nano
    ];
  };
 
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
    plymouth = {
      enable = true;
      theme = "spinner_alt";
      logo  = /etc/nixos/rsrc/TU_BERLIN_Logo.png;
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "spinner_alt" ];
        })
      ];
    };
  };

  # Short sleep during boot for splash animation
  systemd.services.wait-for-animation = {
    enable = true;
    before = [ "plymouth-quit.service" "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/usr/bin/sleep 3";
    };
    wantedBy = [ "plymouth-start.service" ];
  };

  # Cage Setup
  systemd.services.cage-tty1.environment.XKB_DEFAULT_LAYOUT = "de";

  services.cage = {
    enable = true;
    user = "kiosk";
    program = "${pkgs.firefox}/bin/firefox -kiosk -private-window https://tu.berlin";
    # extraArguments = [ 
    #   "-s"
    # ];
  };

  # Firefox program options
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
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    plymouth
    pkgs.firefox
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
  };
}

