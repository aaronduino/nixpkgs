{ config, pkgs, lib, ... }:
{
  imports = [
    ../hardware/xps.nix
    ../modules
  ];

  vars = {
    hardware = "xps";
    username = "mjanse";
    hostname = "xps-mjanse";

    # for git
    name = "Michael Janse";
    email = "mjanse@gmail.com";

    latex = false;
    enableVPN = false;

    secrets = ../secrets/mjanse;
  };
}
