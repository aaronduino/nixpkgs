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

  services.redshift.enable = false;
  location.provider = "geoclue2";


  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";
  };

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
}
