{ branch ? "stable", pkgs }:

pkgs.callPackage ./base.nix rec {
   pname = "discord";
    binaryName = "Discord";
    desktopName = "Discord";
    version = "0.0.10";
    src = pkgs.fetchurl {
      url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
      sha256 = "0kx92i8naqr3algmyy3wyzbh8146z7gigxwf1nbpg1gl16wlplaq";
    };
}
