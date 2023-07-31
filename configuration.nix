{ config,
  lib,
  hostname ,
  pkgs     ? import ./nixpkgs.nix,
  version  ? "23.05",
  user     ? { name = "puma"; description = "Pumita"; },
  opts     ? { allowUnfree = true; autoLogin = true; overlays = []; },
  ...
}: {
  # ------------------------------
  #     Boot
  # ------------------------------

  # Systemd
  boot.loader.systemd-boot.configurationLimit = 10;                       # max to 10 generations
  boot.loader.systemd-boot.consoleMode = "max";                           # max resolution available
  boot.loader.systemd-boot.editor = false;                                # don't allow editing the kernel command-line before boot

  # GRUB 2
  # TODO: Grub 2 auto config if EFI (or not)

  # ------------------------------
  #     Documentation
  # ------------------------------

  documentation.enable = true;                                            # enable documentation
  documentation.man.enable = true;                                        # man(ual) pages: `man` command
  documentation.doc.enable = false;                                       # don't install `/share/doc` documents
  documentation.dev.enable = false;                                       # don't install documentation for developers
  documentation.info.enable = false;                                      # don't install info(rmation) pages: `info` command

  # ------------------------------
  #     Graphics
  # ------------------------------

  hardware.opengl.enable = true;                                          # OpenGL drivers
  hardware.opengl.driSupport = true;                                      # accelerated OpenGL through DRI
  hardware.opengl.driSupport32Bit = true;                                 # 32-bit support (useful for Wine) 
  hardware.opengl.extraPackages = with pkgs; [                            # extra drivers (FIXME: evaluate the importance)
    mesa.drivers
    libGL
    libglvnd
  ];

  # ------------------------------
  #     Internationalization
  # ------------------------------

  i18n.defaultLocale = "en_US.UTF-8";                                     # default english system
  i18n.extraLocaleSettings = {                                            # spanish measurement format
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # ------------------------------
  #     Location
  # ------------------------------

  time.timeZone = "Europe/Madrid";                                        # spanish time zone ❤️
  location = {                                                            # galician location 💙
    provider = "manual";
    latitude = 42.8805200;
    longitude = -8.5456900;
  };

  # ------------------------------
  #     Keyboard
  # ------------------------------

  services.xserver.layout = opts.layout;                                  # keyboard layout
  services.xserver.xkbOptions = "grp:alt_shift_toggle";                   # alt+shift to toggle between layouts

  # ------------------------------
  #     Sound
  # ------------------------------

  sound.enable = true;                                                    # enable sound
  hardware.pulseaudio.enable = false;                                     # disable pulseaudio
  services.pipewire.enable = true;                                        # enable pipewire
  services.pipewire.pulse.enable = true;                                  # enable pulseaudio support
  services.pipewire.wireplumber.enable = true;                            # enable wireplumber (useful for screen-sharing)
  services.pipewire.alsa.enable = true;                                   # enable alsa support
  services.pipewire.alsa.support32Bit = true;                             # 32-bit support (useful for Wine)
  users.groups."audio".members = [ user.name ];

  # ------------------------------
  #     TTY
  # ------------------------------

  console.enable = true;                                                  # enable virtual consoles
  console.useXkbConfig = true;                                            # system layouts as default

  # ------------------------------
  #     System
  # ------------------------------

  system.stateVersion = version;                                          # NixOS version
  system.autoUpgrade.enable = true;                                       # enable auto upgrade
  system.autoUpgrade.flake = opts.repository;                             # NixOS flake
  system.autoUpgrade.dates = "daily";                                     # daily upgrades
  system.autoUpgrade.operation = "switch";                                # switch the current configuration
  system.autoUpgrade.allowReboot = true;                                  # allow auto reboot the system
  system.autoUpgrade.rebootWindow = {                                     # only reboot at night
    lower = "00:00";
    upper = "08:00";
  };    

  # ------------------------------
  #     Security
  # ------------------------------

  security.audit.enable = true;                                           # enable audit (auditctl: monitor system files and directories)
  security.auditd.enable = true;                                          # enable auditd
  security.polkit.enable = true;                                          # enable polkit (policy kit: authorization framework)
  security.rtkit.enable = true;                                           # enable rtkit (realtime kit: realtime scheduling)
  nix.settings.trusted-users = [ "root" "@wheel" ];                       # users who can modify nix cache and use unsigned user repositories
  users.mutableUsers = true;                                              # allow users to modify users and groups (and change passwords)

  # doas (sudo alternative)
  security.sudo.enable = false;                                           # disable sudo
  security.doas.enable = true;                                            # enable doas
  environment.etc."doas.conf".text = lib.mkForce ''
    permit nopass keepenv root
    permit persist keepenv :wheel
  '';
  environment.shellAliases."doas" = "/run/wrappers/bin/doas ";
  environment.shellAliases."sudo" = "/run/wrappers/bin/doas -- ";
  environment.shellAliases."pls" = "/run/wrappers/bin/doas -- ";
  environment.shellAliases."please" = "/run/wrappers/bin/doas -- ";

  # ------------------------------
  #     Networking
  # ------------------------------

  networking.hostName = hostname;                                         # hostname
  networking.enableIPv6 = false;                                          # disable IPv6
  networking.networkmanager.enable = true;                                # interfaces managed through NetworkManager
  users.groups.networkmanager.members = [ user.name ];

  # ------------------------------
  #     Package Manager
  # ------------------------------

  nix.enable = true;                                                      # enable Nix packages
  nix.package = pkgs.nix;                                                 # stable nix
  nix.settings.auto-optimise-store = true;                                # optimise store automatically
  nix.settings.keep-outputs = false;                                      # remove outputs
  nix.settings.keep-derivations = false;                                  # remove derivations
  nix.settings.experimental-features = [
    "flakes"                                                              # enable flake support
    "nix-command"                                                         # enable new commands (develop, profile, ...)
  ];
  nix.gc.automatic = true;                                                # run `nix-collect-garbage` automatically
  nix.gc.dates = "weekly";                                                # delete unused files each week
  nix.gc.options = "--delete-older-than 7d";                              # delete unused files older than a week
  nix.gc.persistent = true;                                               # force missed runs of the service when the system was powered down

  # Aliases
  environment.shellAliases."try"   = "${pkgs.nix}/bin/nix-shell --packages ";
  environment.shellAliases."yay"   = "${pkgs.nix}/bin/nix-env --file '<nixpkgs>' --install ";
  environment.shellAliases."yeet"  = "${pkgs.nix}/bin/nix-env --file '<nixpkgs>' --uninstall ";
  environment.shellAliases."shell" = "${pkgs.nix}/bin/nix develop --file /etc/nixos ";

  # ------------------------------
  #     Fonts
  # ------------------------------

  fonts.enableDefaultPackages = true;                                     # enable default fonts
  fonts.fontDir.enable = true;                                            # enable fonts in `/run/current-system/sw/share/X11/fonts`
  fonts.packages = with pkgs; [                                           # default fonts
    font-awesome
    ubuntu_font_family
    (nerdfonts.override {                                                 # only specific nerd font families
      fonts = [
        "FiraCode"
        "JetBrainsMono"
      ];
    })
  ];

  # ------------------------------
  #     Services
  # ------------------------------

  services.gvfs.enable  = true;                                           # MTP (Android - Media Transfer Protocol)
  services.fwupd.enable = true;                                           # firmware updates (`fwupd` command)
  services.printing.enable = true;                                        # printing (cups)

  services.avahi.enable = true;                                           # zeroconf (discover services on the local network)
  services.avahi.nssmdns = true;                                          # resolve .local hostnames
  services.avahi.openFirewall = true;                                     # open firewall ports

  services.locate.enable = true;                                          # locate database (`locate` command)
  services.locate.locate = pkgs.plocate;                                  # better and faster locate package
  services.locate.interval = "hourly";                                    # update the locate database hourly
  services.locate.output = "/var/cache/locatedb";                         # locate database location
  services.locate.localuser = null;                                       # fix `mlocate` and `plocate` compatibility disabling local user

  # environment (display, desktop and window managers)
  services.xserver.enable = true;                                         # enable X server (graphical environment)

  # display managers
  services.xserver.displayManager.autoLogin.enable = opts.autoLogin;      # enable auto login (don't ask for password)
  services.xserver.displayManager.autoLogin.user = user.name;             # auto login user

  services.xserver.displayManager.gdm.enable = true;                      # Gnome Display Manager (recommended for beginners)

  # desktop managers
  services.xserver.desktopManager.xterm.enable = false;                   # xterm as desktop

  # window managers
  services.xserver.windowManager.xmonad.enableContribAndExtras = true;    # enable contrib and extras packages
  services.xserver.windowManager.xmonad.enableConfiguredRecompile = true; # enable recompilation of the configuration (nix is inmutable by default)
  services.xserver.windowManager.xmonad.extraPackages = with pkgs;        # extra packages
    haskellPackages: [ haskellPackages.xmobar ];

  programs.dconf.enable = true;                                           # dconf (configuration system)
  programs.light.enable = true;                                           # light (backlight control)

  users.groups."input".members = [ user.name ];                           # allow user to use input devices (keyboard, mouse, ...)
  users.groups."video".members = [ user.name ];                           # allow user to use video devices (webcam, ...)

  # ------------------------------
  #     Nixpkgs (Packages)
  # ------------------------------

  nixpkgs.overlays = opts.overlays;                                       # custom packages
  nixpkgs.config.allowUnfree = opts.allowUnfree;                          # allow unfree packages
  nixpkgs.config.allowBroken = false;                                     # don't allow broken packages
  nixpkgs.config.allowInseure = false;                                    # don't allow insecure packages
  nixpkgs.config.allowUnsupportedSystem = false;                          # don't allow unsupported packages

  # Cache (Cachix)
  nix.settings.substituters = [
    "https://nix-community.cachix.org"
    "https://cache.nixos.org/"
  ];
  nix.settings.trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
 
  # Default installed packages
  environment.defaultPackages = with pkgs;[                               # default packages
    btop                                                                  # Resource monitor
    curl                                                                  # HTTP client
    git                                                                   # version control
    rsync                                                                 # file transfer/synchronization
    wget                                                                  # HTTP client
  ];

  # Aliases
  environment.shellAliases."top"  = "${pkgs.btop}/bin/btop ";
  environment.shellAliases."htop" = "${pkgs.btop}/bin/btop ";
  environment.shellAliases."btop" = "${pkgs.btop}/bin/btop ";
}