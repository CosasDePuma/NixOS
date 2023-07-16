# Shell for bootstrapping flake-enabled nix and home-manager
{ pkgs ? (import ../nixpkgs.nix) { } }: pkgs.mkShell {
    shellHook = ''
      export NIXPKGS_ALLOW_UNFREE=1
      echo
      echo "==========================================="
      echo "    Welcome to the 'System' nix shell!"
      echo "==========================================="
      echo
    '';

    NIX_CONFIG = "experimental-features = nix-command flakes";
    packages = with pkgs; [ nix home-manager git ];
  }