{ branch ? "stable", pkgs }:

pkgs.callPackage ./base.nix rec {
  pname = "discord";
  binaryName = "Discord";
  desktopName = "Discord";
  version = "0.0.9";
  pkgs.src = pkgs.fetchurl {
    url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
    sha256 = "1i0f8id10rh2fx381hx151qckvvh8hbznfsfav8w0dfbd1bransf";
  };
}
