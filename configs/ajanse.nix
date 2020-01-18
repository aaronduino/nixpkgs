{ config, pkgs, lib, ... }:
{
  imports = [
    ../hardware/xps.nix
    ../modules
  ];

  vars = {
    hardware = "xps";
    username = "ajanse";
    hostname = "xps-ajanse";

    gui = "i3";

    # for git
    name = "Aaron Janse";
    email = "ajanse@ajanse.me";

    sound = true;
    bluetooth = false;
    printing = false;

    yubikey = true;

    latex = true;
    enableVPN = false;

    secrets = ../secrets/ajanse;
  };

  services.xserver.xkbOptions = "caps:escape";
}
