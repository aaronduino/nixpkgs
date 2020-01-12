{ config, pkgs, lib, ... }:
{
  imports = [
    ../hardware/yoga.nix
    ../modules
  ];

  vars = {
    hardware = "yoga";
    username = "erik";
    hostname = "cool-laptop";

    # for git
    name = "Erik Uden";
    email = "erik.uden1@gmail.com";

    latex = false;
    enableVPN = false;

    secrets = ../secrets/erik;
  };
}
