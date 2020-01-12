{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options.vars = {
    sound = mkOption {
      type = types.bool;
    };
  };

  config = mkIf cfg.sound {
    sound.enable = cfg.sound;
    hardware.pulseaudio = {
      enable = cfg.sound;
      daemon.config = { flat-volumes = "no"; };
    };
  };
}
