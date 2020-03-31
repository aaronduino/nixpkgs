{ config, pkgs, lib, ... }:
let
  eth = "enp0s20f0u1";
in
{
  imports = [
    ../hardware/xps.nix
    ../modules
    ../cachix.nix

    # (import ./nixos-router/mkRouter.nix {
    #   internalInterface = "ens8u1";
    #   externalInterface = "wlp2s0";
    # })
  ];

  nix.extraOptions = ''
    extra-platforms = aarch64-linux arm-linux
  '';

  networking.nat.enable = true;
  networking.nat.internalIPs = [ "192.168.2.0/24" ];
  networking.nat.externalInterface = "wlp2s0";
  networking.nat.internalInterfaces = [ eth ];

  systemd.services = {
    "network-link-${eth}".wantedBy = lib.mkForce [];
    "network-addresses-${eth}".wantedBy = lib.mkForce [];
    rpi-netdev.wantedBy = lib.mkForce [];
  };

  networking.bridges.rpi = {
    interfaces = [ eth "wlp2s0" ];
    rstp = true;
  };
  # networking.interfaces.rpi.ipv4.addresses =
  #   [ { address = "192.168.2.1"; prefixLength = 24; } ];

  vars = {
    hardware = "xps";
    username = "ajanse";
    hostname = "xps-ajanse";

    gui = "sway";

    # for git
    name = "Aaron Janse";
    email = "aaron@ajanse.me";

    sound = true;
    bluetooth = true;
    printing = true;

    yubikey = true;

    latex = true;
    # enableVPN = true;

    secrets = ../secrets/ajanse;
  };

  services.tftpd = {
    enable = false;
  };

  services.redshift.enable = false;
  location.provider = "geoclue2";

  services.fcron = {
    enable = false;
    systab = ''
      &bootrun 0 13 * * * bash ${
    pkgs.writeScriptBin "fcron-backup" ''
      mkdir -p /tmp/restic
      mount -t zfs $(zfs list -t snapshot | grep hourly | tail -1 | awk '{ print $1 }') /tmp/restic
      DIR=/tmp/restic/ajanse
      source ${../secrets/ajanse/restic-env.conf}
      restic -r b2:ajanse-archive:/ -p /etc/nixos/secrets/ajanse/restic-password.txt backup $DIR/archive $DIR/dev $DIR/docs $DIR/downloads $DIR/library $DIR/tmp $DIR/private.tomb
      umount /tmp/restic
    ''}/bin/script
    '';
  };

  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";
  };


  networking.hosts = {
    #    "127.0.0.1" = [ "news.ycombinator.com" "reddit.com" "www.reddit.com" ];
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

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;

  services.zfs.trim.enable = false;

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
    };
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
    };
  };

  networking.hostId = "7988c4e1";

  # services.paperless = {
  #   enable = true;
  #   ocrLanguages = [ "eng" ];
  # };


  security.sudo.extraConfig = ''
    Defaults${"\t"}lecture_file=${../assets/sudo_lecture.txt}
    Defaults${"\t"}insults
  '';
}
