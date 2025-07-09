{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.neologer = import ./home.nix;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Add kernel parameter to ensure the NVIDIA driver takes control of modesetting.
  # This is often important for hybrid graphics and Wayland.
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  hardware.logitech.wireless.enable = true;

  time.timeZone = "Asia/Jerusalem";
  i18n.defaultLocale = "en_IL";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  services.displayManager.sessionPackages = [ pkgs.hyprland ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = false;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;

  users.users.neologer = {
    isNormalUser = true;
    description = "NeoLoger";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [ ];
  };

  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  fonts.packages = with pkgs; [
    pkgs.nerd-fonts._3270
    pkgs.nerd-fonts.adwaita-mono
  ];

  environment.systemPackages = with pkgs; [
    wget
    git
    brave
    kitty
    pciutils
    btop
    tokyonight-gtk-theme
    papirus-icon-theme
    headsetcontrol
  ];
  
  environment.variables = {
    GTK_THEME = "Tokyo-Night-Dark-B";
    XCURSOR_THEME = "Papirus-Dark";
  };

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    
    # --- THIS IS THE CORRECTED PRIME CONFIGURATION ---
    # The structure has changed. 'enable' and 'enableOffloadCmd' are inside 'offload'.
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Example Bus IDs. You will need to uncomment and set these once the card is detected.
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  system.stateVersion = "25.05";
}
