{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  imports = [
    ./options.nix
  ];

  config = mkIf (cfg.gui == "pantheon") {
    services.xserver = {
    	desktopManager.pantheon.enable = true;
    	displayManager.lightdm.greeters.pantheon.enable = false;
    };
  };
}
