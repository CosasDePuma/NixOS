{
  description = "Pumita's configuration";

  inputs = {
    nixpkgs.url  = "nixpkgs/nixos-unstable";
    home-manager = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:nix-community/home-manager"; };
    # custom inputs
    dotfiles     = { inputs.nixpkgs.follows = "nixpkgs"; url = "github:cosasdepuma/.dotfiles"; };
  };

  outputs = { nixpkgs, ... } @ inputs:
  let
    # forAllSystems :: fn: str -> set
    #   generates the same configuration for multiple system archs
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

    # loadModules :: str -> list
    #   load all the default modules from inputs
    loadModules = t: nixpkgs.lib.mapAttrsToList (_: v:
      if builtins.hasAttr t v then
        if builtins.hasAttr "default" v."${t}" then
          v."${t}".default
        else {}
      else {}) inputs;

    # mkShells :: set -> set
    #   generates multiples development shells
    mkShells = pkgs: with builtins;
      listToAttrs
        (map (x: { name = (nixpkgs.lib.removeSuffix ".nix" x); value = (import ./shells/${x} { inherit pkgs; }); })
          (filter (x: (match ".+\.nix$" x) != null) (attrNames (readDir ./shells))));

    # mkHosts :: list -> set
    #   generates multiples nixosConfigutations
    mkHosts = hosts: builtins.mapAttrs (hostname: v: mkHost ({ inherit hostname; } // v)) hosts;

    # mkHost :: set -> set
    #   generates a nixosConfiguration based on the machine hostname
    mkHost = {
      hostname,
      version      ? "23.05",
      system       ? "x86_64-linux",
      layout       ? "us,es",
      allowUnfree  ? true,
      autoLogin    ? true,
      shell        ? "fish",
      editor       ? "neovim",
      overlays     ? import ./overlays,
      user         ? { name = "puma"; description = "Pumita"; },
      repository   ? "github:cosasdepuma/nixos",
      ...
    }: nixpkgs.lib.nixosSystem {
      inherit system;
      modules = (loadModules "nixosModules") ++ [
        ./hardware-configuration.nix
        ./configuration.nix
        ./host/${hostname}.nix
      ];
      specialArgs = {
        inherit inputs hostname user version;
        opts = { inherit layout allowUnfree autoLogin overlays repository; };
      };
    };

    # mkHomes :: list -> set
    #   generates multiples homeConfigurations
    mkHomes = homes: builtins.mapAttrs (user: v: mkHome ({ inherit user; } // v)) homes;

    # mkHome :: set -> set
    #   generates a homeConfiguration based on the user name
    mkHome = {
      user,
      profile     ? "default",
      version     ? "23.05",
      system      ? "x86_64-linux",
      allowUnfree ? true,
      ...
    }: inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."${system}";
        modules = (loadModules "homeManagerModules") ++ [
          ({
            programs.home-manager.enable = true;
            home.stateVersion = version;
            home.username = user;
            home.homeDirectory = "/home/${user}"; # FIXME: Make it MacOS compatible (/Users/${user})
            nixpkgs.config.allowUnfree = allowUnfree;
            nixpkgs.config.allowUnfreePreciate = (_: allowUnfree);
            systemd.user.startServices = "sd-switch";
          })
          ./home/${profile}.nix
        ];
        extraSpecialArgs = { inherit inputs user version; };
      };
  in {
    # ------------------------------
    #     Development Shells
    # ------------------------------

    # Shell environments available throught `nix develop --flake /etc/nixos#$ENVIRONMENT`
    devShells = forAllSystems (system:
      let pkgs = nixpkgs.legacyPackages."${system}";
      in mkShells pkgs
    );

    # ------------------------------
    #     System
    # ------------------------------

    # System configuration available through `nixos-rebuild switch --flake /etc/nixos#$HOSTNAME`
    nixosConfigurations = mkHosts {
      # Void VM
      void = { user.name = "entity"; user.description = "An empty entity"; };
    };

    # ------------------------------
    #     Home Manager
    # ------------------------------

    # Home configuration available through `home-manager switch --flake /etc/nixos#$USER`
    homeConfigurations = mkHomes {
      # Pumita's home
      entity = {};
    };
  };
}