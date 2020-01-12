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
      paths ++ [ ../hardware-configuration.nix ];

  boot.cleanTmpDir = true;

  networking = {
    hostName = cfg.hostname;
    networkmanager.enable = lib.mkDefault true;
  };

  services.dnsmasq = {
    enable = true;
    servers = [ "1.1.1.1" "1.0.0.1" ];
  };

  time.timeZone = "America/Los_Angeles";

  nixpkgs.config.allowUnfree = true;

  powerManagement.powertop.enable = true;
  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.xsecurelock}/bin/xsecurelock";
  };

  services.gnome3.gnome-keyring.enable = true;

  # services.usbguard = enableWithSecrets {
  #   presentDevicePolicy = "allow";
  #   rules = builtins.concatStringsSep "\n" secrets.usbguardRules;
  # };

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   # enableExtensionPack = true; # takes a long time to build
  # };

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
    ];
    createHome = true;
    home = "/home/${cfg.username}";
  };

  # for more packages, see gui.nix
  environment.systemPackages = with pkgs; [
    acpi
    gnupg
    pinentry
    sysstat
    powertop

    git-crypt

   # (import ../pkgs/mcfly.nix)

    (pkgs.callPackage ../pkgs/amp.nix {})

    nixops

    docker-compose

   # vulnix # scan system vulnerabilities

    #(import ../pkgs/ncspot.nix)

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
    fzf
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
