{ config, pkgs, lib, ... }:
let
  eth = "enp0s20f0u1";
in
{
  imports = [
    ../hardware/xps.nix
    ../modules

"${builtins.fetchGit {
      url = "https://github.com/msteen/nixos-vsliveshare.git";
      ref = "refs/heads/master";
    }}"
  ];

services.vsliveshare.enable = true;

  vars = {
    hardware = "xps";
    username = "ajanse";
    hostname = "xps-ajanse";

    gui = "i3";

    # for git
    name = "Aaron Janse";
    email = "aaron@ajanse.me";

    sound = true;
    bluetooth = true;
    printing = true;

    yubikey = true;

    latex = true;
    enableVPN = true;

    secrets = ../secrets/ajanse;
  };

virtualisation.docker = {
  enable = true;
storageDriver = "zfs";
};

boot.kernelParams = [ "mem_sleep_default=deep" ];
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

nix = {
  distributedBuilds = false;
#  buildMachines = [
#    { hostName = "beta.nixbuild.net";
#      system = "x86_64-linux";
#      maxJobs = 100;
#      supportedFeatures = [ "benchmark" "big-parallel" ];
#    }
#  ];
};

programs.ssh.extraConfig = ''
  Host beta.nixbuild.net
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    PubkeyAcceptedKeyTypes ssh-ed25519
    IdentityFile /home/ajanse/.ssh/ajanse-nixbuild
'';


  networking.hosts = {
   "127.0.0.1" = ["test.dev" "abc.dev" "xyz.123.dev"];
   "fc5e:3b2e:ccfe:8eb2:a037:7955:e242:78be" = ["cjrpi.dev"];
    #    "127.0.0.1" = [ "news.ycombinator.com" "reddit.com" "www.reddit.com" ];
  };

  # boot.kernelPackages = pkgs.linuxPackages_latest;


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


services.hydra = {
    package = pkgs.hydra-unstable;
    enable = false;
    hydraURL = "http://hydra.example.org";
    notificationSender = "hydra@example.org";
    port = 8080;
    extraConfig = "binary_cache_secret_key_file = /etc/nix/hydra.example.org-1/secret";
    buildMachinesFiles = [ "/etc/nix/machines" ];
  };

environment.enableDebugInfo = true;

  services.postgresql = {
enable = false;
    dataDir = "/var/db/postgresql-${config.services.postgresql.package.psqlSchema}";
  };

}
