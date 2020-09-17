{ config, lib, pkgs, ... }:
let
  cfg = config.vars;
in
{
  imports = [
    ../modules
  ];

  vars = {
    hidpi = true;
    bluetooth = lib.mkDefault true;
    printing = lib.mkDefault true;
  };

  # use systemd-boot with uefi
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
    grub.enable = false;
  };

  # sorry, stallman
  hardware.enableRedistributableFirmware = true;

  programs.light.enable = true;

  # configure touchpad
  services.xserver.libinput = {
    enable = true;
    tappingDragLock = false;
    naturalScrolling = true;
  };

  boot.kernelPackages =
    let
      linux_pkg =
        { stdenv, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:
          with stdenv.lib;
          buildLinux (
            args // rec {
              version = "5.3.16";

              modDirVersion = if (modDirVersionArg == null) then concatStringsSep "." (take 3 (splitVersion "${version}.0")) else modDirVersionArg;

              kernelPatches = [
                {
                  name = "fix-display";
                  patch = pkgs.fetchpatch {
                    url = "https://bugs.freedesktop.org/attachment.cgi?id=144765";
                    sha256 = "sha256-Fc6V5UwZsU6K3ZhToQdbQdyxCFWd6kOxU6ACZKyaVZo=";
                  };
                }
              ];

              src = fetchurl {
                url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
                sha256 = "19asdv08rzp33f0zxa2swsfnbhy4zwg06agj7sdnfy4wfkrfwx49";
              };
            } // (args.argsOverride or {})
          );
      linux = pkgs.callPackage linux_pkg {};
    in
      pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux);
}
