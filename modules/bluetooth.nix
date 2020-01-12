{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options.vars = {
    bluetooth = mkOption {
      type = types.bool;
    };
  };

  config = {
    hardware.bluetooth.powerOnBoot = cfg.bluetooth;
  } // mkIf cfg.bluetooth {
    hardware.bluetooth.enable = true;
    hardware.pulseaudio.package = pkgs.pulseaudioFull;

    services.dbus.packages = [ pkgs.blueman ];
    environment.systemPackages = [ pkgs.blueman ];

    home-manager.users.${cfg.username} = {
      services.blueman-applet.enable = true;
    };
  };
}
