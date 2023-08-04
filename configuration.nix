# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:


{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.spicetify-nix.nixosModules.default
    <home-manager/nixos>
  ];
  fileSystems = {
    #"/".options = [ ]; #discard enables continuous trim
    "/swap" = {
      device = "/dev/disk/by-label/nixSwap";
      options = [ "noatime" "defaults" "noauto" "x-systemd.automount" ];
      fsType = "swap";
    };
  };
  boot = {
    kernelParams = [ 
      "intel_pstate=passive"
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
        consoleMode = "auto";
        configurationLimit = 12;
        extraEntries = {
            "windows.conf" = ''
            title Windows 11
            efi /efi/Microsoft/Boot/bootmgfw.efi
          '';
        };
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      grub = {
        enable = false;
        device = "nodev";
        efiSupport = true;
        configurationLimit = 18;
        useOSProber = true;
        #theme = ;
        extraEntries = ''
          menuentry "Firmware Interface" {
            fwsetup
          }
        '';
      };
    };
  };
  #flake stuff
  nix = {
    settings.experimental-features = [ "nix-command" "flakes"];
  };

  networking.hostName = "luunaww-satellite"; # Define your hostname.
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ]; # Cloudflare DNS
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant (not needed if networkmanager is used)
  #
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true; # disables any display manager
  # Enable the Hyprland window manager

  programs.hyprland = { # this automatically makes portals work. neat!
    enable = true;
    xwayland.enable = true;
    nvidiaPatches = true; # sometimes an additional patch needs to be applied where you make a file in /etc/modprobe.d/nvidia.conf and you add: options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1; PerfLevelSrc=0x2222; PowerMizerLevel=0x3; PowerMizerDefault=0x3; PowerMizerDefaultAC=0x3"
  };

  # Configure keymap in X11 (Hyprland keymap is configured in hyprland.conf)
  services.xserver = {
    layout = "us";
    xkbVariant = "colemak_dh";
  };
  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  environment.etc."bluetooth/main.conf".text = lib.mkForce ''
    [General]
    ControllerMode = dual
    Experimental = true

    [Policy]
    AutoEnable = true
  '';

  services.thermald.enable = true; # no setting on fire
  services.tlp.enable = true;
  systemd.services."systemd-rfkill.service".enable = false;
  systemd.services."systemd-rfkill.socket".enable = false;
  services.tlp.settings = {
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave"; #
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil"; #I LOVE SCHEDUTIL
    WIFI_PWR_ON_AC="on";
    RUNTIME_PM_ON_BAT="on";
    USB_AUTOSUSPEND="0";
    USB_EXCLUDE_BTUSB="1";
    TLP_DEFAULT_MODE="AC";
    #START_CHARGE_THRESH_BAT0="75";
    #STOP_CHARGE_THRESH_BAT0="80";
    #RADEON_DPM_PERF_LEVEL_ON_AC="high"; # radeon settings should be disabled if not on amd
    #RADEON_DPM_PERF_LEVEL_ON_BAT="medium";
    #RADEON_POWER_PROFILE_ON_AC="high";
    #RADEON_POWER_PROFILE_ON_BAT="low";
  };
  
  # Enable sound with pipewire.
  sound.enable = true;
  services = {
    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };
  };
  #hardware.pulseaudio.enable = true;
  #hardware.pulseaudio.support32Bit = true;

  #allow swaylock to auth
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  }; 

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  services.fstrim = {
    enable = true; # this enables periodic trim (better for usual use. see "/".options = [ "discard" ]; for continuous.)
    interval = "weekly"; # the default
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wiillou = {
    isNormalUser = true;
    description = "wiillou";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [
      obs-studio
      discordo
      discord
      pixelorama
      swaybg
      hyprpicker
      hyprpaper
      blueman
      pavucontrol
      helvum
      tty-clock
      networkmanager
      bottom
      themechanger
      rofi-wayland
      eidolon
      hypnotix
      ttyper
      pomodoro
      haskellPackages.Monadoro
      brightnessctl
      gamescope
      prismlauncher
      zulu8
      lunar-client
      osu-lazer-bin
      vitetris
      libva 
      looking-glass-client
      obs-studio-plugins.looking-glass-obs
      lynx
      mc
      speedread
      lolcat
      vt-cli
      fortune
      doit
      calcure
      grim
      slurp
      mpv
      libcaca
      clamav
      obsidian
      catppuccin-gtk
      lutris
      wine
    ];
  };
 

  #Its fonts!
  fonts.fonts = with pkgs; [
    nerdfonts
    jetbrains-mono
    fira-code
    fira-code-symbols
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  #make sure the default shell is whatever you set it as
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ zsh fish ];
  programs.zsh = {
    enable = true;
    promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    autosuggestions.enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.plugins = [ "git" ];
    #ohMyZsh.theme = "";
    syntaxHighlighting.enable = true;
  };

  programs.fish.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.system = "x86_64-linux";

  # NVIDIA drivers are unfree.
  services.xserver.videoDrivers = [ "nvidia" "intel" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
  
  # Variable that should fix issuse with electron and stuff with wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";  

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  # Optionally, you may need to select the appropriate driver version for your specific GPU.
  # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
  hardware.nvidia = {
    # Enable modesetting for Wayland compositors
    modesetting.enable = true;
    # Use the open source version of the kernel module (for driver 515.43.04+)
    open = true;
    # Enable the Nvidia settings menu
    nvidiaSettings = true;
    # Select the appropriate driver version for your specific GPU
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    #enable systemd services for management
    #powerManagement = {
      #enable = true;
      #finegrained = true;
    #};
    prime = {
      offload.enableOffloadCmd = true;
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  powerManagement.resumeCommands = ''
    hyprland
    bluetooth on
  '';
 
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # -- Utility -- #
    gcc # GNU C Compiler
    sbctl #secure boot keys
    lm_sensors
    aria2
    wget
    unzip
    fd
    nvtop
    nvitop
    killall
    bashmount
    onedrive
    # -- Editors And code -- #
    git
    cargo
    neovim
    neovide 
    python311 
    nodejs
    # -- Visual -- #
    waybar
    hyprpaper
    dunst 
    cava 
    kitty
    # -- Shell -- #
    oh-my-zsh
    zsh
    zsh-powerlevel10k
    zsh-autocomplete
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-you-should-use
    zsh-command-time
    nix-zsh-completions
    grc
    fishPlugins.pure
    fishPlugins.sponge
    fishPlugins.puffer
    fishPlugins.plugin-git
    fishPlugins.pisces
    fishPlugins.autopair
    fishPlugins.grc
    fishPlugins.fzf-fish
    fishPlugins.done
    fishPlugins.colored-man-pages
    fishPlugins.bass
    freshfetch
    cpufetch
    onefetch # github repo fetch :o
    nitch
    fzf
    fzf-zsh
    bluez
    blueman
    zsh-powerlevel10k
    pamixer
    playerctl
    ryzenadj
    tuir
    tlp
    bluetuith
    gitui
    tuifimanager
    bluetuith
    cmatrix
    btop
    ffmpeg-full
    python3
    playerctl
    colemak-dh
    gamescope 
    nodejs 
    bat 
    gdu 
    lsd 
    speedtest-cli 
    nms 
    pciutils 
    gparted 
    woeusb 
    wireplumber
    libsForQt5.qt5.qtwayland 
    qt6.qtwayland 
    cliphist
    wl-clipboard
    exfat
    exfatprogs
    check-uptime
    coreutils
    findutils
    swaylock-effects
    swayidle
    catppuccin-gtk # I love catppuccin!!!
    cpupower-gui
  ];
  
  services.gpm.enable = false;

  programs.firefox = {
    enable = true;
    preferences = {
      "gfx.webrender.all" = true;
      "layers.acceleration.force-enabled" = true;
      "media.ffmpeg.vaapi.enabled" = true;
      "media.mediasource.vp9.enabled" = false;
      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "svg.context-properties.content.enabled" = true;
      "browser.compactmode.show" = true;
    };
  };
  
  programs.kdeconnect.enable = true;

  
  #Package overlays
  nixpkgs = {
    overlays = [
      (self: super: {
      discord = super.discord.override { withOpenASAR = true; withVencord = true; };
        waybar = super.waybar.overrideAttrs (oldAttrs: {
          mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" "-Dmpd=enabled" ];
        });
      })
    ];
  };

  #spicetify-nix = inputs.spicetify-nix;
  # configure spicetify :)
  programs.spicetify = {
    enable = true;
    theme = inputs.spicetify-nix.packages.${pkgs.system}.default.themes.catppuccin-mocha;
    colorScheme = "lavender";
    enabledExtensions = with inputs.spicetify-nix.packages.${pkgs.system}.default.extensions; [
      fullAppDisplayMod
      playlistIcons
      powerBar
      fullAlbumDate
      goToSong
      skipStats
      wikify
      history
      adblock
      savePlaylists
      fullScreen
      playNext
      volumePercentage
      lastfm
      genre
      historyShortcut
      shuffle # shuffle+ (special characters are sanitized out of ext names)
      ];
    enabledCustomApps = with inputs.spicetify-nix.packages.${pkgs.system}.default.apps; [
      new-releases
      reddit
      marketplace
      lyrics-plus
    ];
  };

  #Increase map count to improve performance in proton
   boot.kernel.sysctl = {
     "vm.max_map_count" = 1048576;
   };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  
  security.sudo.configFile = ''
    Defaults badpass_message = " Incorrect Password"
    Defaults passprompt = "󰌆      "
  '';


  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  system.stateVersion="23.11";
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };
}