_: pkgs: {
  picom-dccsillag = pkgs.picom.overrideAttrs (attrs: {
    src = pkgs.fetchFromGitHub {
      owner  = "dccsillag";
      repo   = "picom";
      rev    = "51b21355696add83f39ccdb8dd82ff5009ba0ae5";
      sha256 = "crCwRJd859DCIC0pEerpDqdX2j8ZrNAzVaSSB3mTPN8=";
    };
    buildInputs = attrs.buildInputs ++ (with pkgs;[ xorg.xcbutil pcre2 ]);
  });

  picom-pijulius = pkgs.picom.overrideAttrs (attrs: {
    src = pkgs.fetchFromGitHub {
      owner  = "pijulius";
      repo   = "picom";
      rev    = "982bb43e5d4116f1a37a0bde01c9bda0b88705b9";
      sha256 = "YiuLScDV9UfgI1MiYRtjgRkJ0VuA1TExATA2nJSJMhM=";
    };
    buildInputs = attrs.buildInputs ++ (with pkgs;[ xorg.xcbutil pcre2 ]);
  });
}