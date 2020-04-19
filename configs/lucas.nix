{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules
  ];

  vars = {
    hardware = "xps";
    username = "ajanse";
    hostname = "xps-ajanse";

    gui = "i3";

    # for git
    name = "Lucas Clark";
    email = "aaron@ajanse.me";

    sound = true;
    bluetooth = true;
    printing = true;

    yubikey = true;

    latex = true;
    # enableVPN = true;

    secrets = ../secrets/ajanse;
  };
}
