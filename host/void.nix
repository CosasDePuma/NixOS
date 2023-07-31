{ config, pkgs, user, ... }: {
  # ------------------------------
  #     Environment
  # ------------------------------

  services.xserver.windowManager.xmonad.enable = true;                    # XMonad window manager (haskell)

  # ------------------------------
  #     Users
  # ------------------------------

  programs.fish.enable = true;                                            # enable default shell
  users.defaultUserShell = pkgs.fish;                                     # default user shell
  users.users."${user.name}" = {                                          # default user
    description = user.description;                                       # user description
    initialPassword = user.name;                                          # user password (default is same as username)
    uid = 1000;                                                           # user ID
    group = "users";                                                      # user group (i dont like usernames groups)
    home = "/home/${user.name}";                                          # user home directory
    createHome = true;                                                    # create home directory
    homeMode = "0700";                                                    # user home directory permissions (only owner can read/write/exec)
    isNormalUser = true;                                                  # it is not a system user
    extraGroups = [ "wheel" ];                                            # user groups (sudo privileges)
    useDefaultShell = true;                                               # use default shell
  };

  # ------------------------------
  #     Installed Packages
  # ------------------------------

  programs.neovim.enable = true;                                          # enable default editor
  programs.neovim.defaultEditor = true;                                   # force default editor
  environment.shellAliases."vi"    = "${pkgs.neovim}/bin/nvim ";          # `vi` repalced by the default editor
  environment.shellAliases."vim"   = "${pkgs.neovim}/bin/nvim ";          # `vim` repalced by the default editor
  environment.shellAliases."nvim"  = "${pkgs.neovim}/bin/nvim ";          # `nvim` repalced by the default editor
  environment.shellAliases."edit"  = "${pkgs.neovim}/bin/nvim ";          # `edit` repalced by the default editor
  environment.shellAliases."emacs" = "${pkgs.neovim}/bin/nvim ";          # `emacs` repalced by the default editor
  environment.shellAliases."nano"  = "${pkgs.neovim}/bin/nvim ";          # `nano` repalced by the default editor
  environment.variables."TERMINAL" = "${pkgs.kitty}/bin/kitty ";          # `TERMINAL` variable

  # System packages
  environment.systemPackages = with pkgs; [
    cherrytree                                                            # Notes
    eww                                                                   # Bar & Widgets
    feh                                                                   # Wallpaper
    firefox                                                               # Browser
    flameshot                                                             # Screenshot
    keepassxc                                                             # Password Manager
    kitty                                                                 # Terminal
    krabby                                                                # Pokemon Sprites
    neofetch                                                              # System Info
    neovim                                                                # Text Editor
    picom-dccsillag                                                       # Compositor
    (rofi.override                                                        # Launcher
      { plugins = [ rofi-emoji ]; })                                      # Launcher plugins
    starship                                                              # Prompt
    tldr                                                                  # Man Pages
    xclip                                                                 # Clipboard
    xdotool                                                               # Keyboard Automation
    xfce.thunar                                                           # File Manager
    xmobar                                                                # Status Bar
  ];
}