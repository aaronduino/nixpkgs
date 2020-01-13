# $ cd nixpkgs/nixos
# $ nix-build -A config.system.build.isoImage -I nixos-config=/etc/nixos/configs/usb.nix default.nix

{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>

    ../modules
  ];

  vars = {
    hardware = "usb";
    username = "user";
    hostname = "nixos-usb";

    gui = "i3";
    hidpi = true;

    bluetooth = true;
    sound = true;
    printing = true;

    # for git
    name = "John Doe";
    email = "jdoe@example.com";

    latex = false;
    enableVPN = false;

    secrets = ../secrets/usb;
  };

  networking.wireless.enable = false;
}
