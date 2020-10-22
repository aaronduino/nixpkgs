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
   # hardware.bluetooth.powerOnBoot = cfg.bluetooth;
    hardware.bluetooth.enable = cfg.bluetooth;
 services.blueman.enable = true;

hardware.pulseaudio = {
    enable = true;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };
  } // mkIf true {

    #services.dbus.packages = [ pkgs.blueman ];
    environment.systemPackages = [ pkgs.blueman pkgs.bluez ];

    #home-manager.users.${cfg.username} = {
    #  services.blueman-applet.enable = true;
    #};
  };
}
