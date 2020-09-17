{ config, lib, pkgs, options, ... }:
let
  secretsPath = ../personal/secrets.json;
  secretsAvailable = builtins.pathExists secretsPath;
  enableWithSecrets = x: if secretsAvailable then ({ enable = true; } // x) else { enable = false; };
  secrets = if secretsAvailable then builtins.fromJSON (builtins.readFile secretsPath) else {};

  cfg = config.vars;

  x11 = cfg.gui != "none";
in
{
  imports =
    let
      contents = builtins.readDir ./.;
      names = builtins.attrNames contents;
      files = builtins.filter
        (
          name: contents."${name}" != "directory"
          && name != "default.nix"
        ) names;
      paths = builtins.map (x: ./. + ("/" + x)) files;
    in
      paths;

networking.firewall.enable = false;



  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  # what does this do??
  # nix.trustedUsers = [ "@wheel" ];
  #nix.extraOptions = ''
  #  extra-platforms = aarch64-linux arm-linux
  #'';

  services.journald.extraConfig = ''MaxRetentionSec=1week'';

  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = false;

  networking = {
    hostName = cfg.hostname;
    networkmanager.enable = true;
  };

  services.dnsmasq = {
    enable = true;
    servers = [ "178.32.31.41" ];
  };

  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true;

  powerManagement.powertop.enable = true;
  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.writeScriptBin "modified-xsecurelock" ''
      export XSECURELOCK_PASSWORD_PROMPT=time_hex
      ${pkgs.xsecurelock}/bin/xsecurelock
    ''}/bin/modified-xsecurelock";
  };

  services.cjdns = {
    enable = false;
    UDPInterface = {
      bind = "0.0.0.0:43211";
      connectTo = {
        rpi = {
          hostname = "cjrpi";
          publicKey = "qkj9xdd1286p1umrldhzz0861zcq3lbyycvt90x3djvrh0rhyyh0.k";
          password = "6uoXsaH9ouJ9DxWV6CjzpvDraDvz4Ywq";
        };
      };
    };
  };

  services.gnome3.gnome-keyring.enable = true;

   virtualisation.virtualbox.host = {
     enable = true;
  #   enableExtensionPack = true; # takes a long time to build
   };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
    extraRules = builtins.concatLists [
      (
        if cfg.gui != "none" then [
          {
            commands = [
              {
                command = "${../bin/restart-polybar.sh}";
                options = [ "NOPASSWD" ];
              }
            ];
            users = [ cfg.username ];
            runAs = "root";
          }
        ] else []
      )
    ];
  };

  users.mutableUsers = true;
  users.users.${cfg.username} = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "vboxusers"
      "libvirtd" "kvm" "adbusers" "docker"
    ];
    createHome = true;
    home = "/home/${cfg.username}";
  };

  environment.variables = {
    GOPATH = "/home/${cfg.username}/.go";
    NNTPSERVER = "localhost:1119";
  };

#programs.adb.enable = true;
services.tor.torsocks.enable = true;
virtualisation.libvirtd.enable = true;

  # for more packages, see gui.nix
  environment.systemPackages = with pkgs; [
    coreutils
  
    acpi
    gnupg
    pinentry-curses
    sysstat
    powertop

    minecraft
    pstree

    git-crypt


    # nixops

    docker-compose

    # vulnix # scan system vulnerabilities

    dropbox

    vim
    wget
    killall
    bc
    htop
    lsof
    w3m
    bat
    tldr
    tree
    ranger
    jq
    hexyl
    zip
    unzip

    age

    restic
    tomb

    gist
    nixpkgs-fmt

    #android-file-transfer
    pandoc
    youtube-dl
    cmatrix
    neofetch
    libsecret
  ];

  system.stateVersion = "19.03";
}
