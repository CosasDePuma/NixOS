with builtins; 
map (x: import (./. + "/${x}"))
    (filter (x: x != "default.nix")
    (attrNames (readDir ./.)))