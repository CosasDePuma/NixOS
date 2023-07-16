# Shell for bootstrapping flake-enabled nix and home-manager
{ pkgs ? (import ../nixpkgs.nix) { } }: pkgs.mkShell {
    shellHook = ''
      export NIXPKGS_ALLOW_UNFREE=1
      echo
      echo "==========================================="
      echo "       Let's hack Active Directory!"
      echo "==========================================="
      echo
    '';

    packages = with pkgs; [
      crackmapexec
      enum4linux-ng
      nmap
      powershell
      samba
      smbmap
    ];
  }