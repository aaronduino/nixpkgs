{ stdenv, lemonbar-xft, python36, python36Packages }:
stdenv.mkDerivation rec {
  name = "lemonbar";
  buildInputs = [
    lemonbar-xft
    python36
    python36Packages.psutil
    python36Packages.i3ipc
  ];
  shellHook = ''
    python3 ${../bin/i3.py} | lemonbar -f "Overpass Mono:pixelsize=30;0" -f "Font Awesome 5 Free:pixelsize=30;0" -f "Font Awesome 5 Free:style=Solid:pixelsize=30;0" -u 4 -g x60 -B "#181920"
  '';
}
