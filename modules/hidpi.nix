{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.vars;
in
{
  imports = [
    ./options.nix
  ];

  config = mkIf cfg.hidpi {
    services.xserver.dpi = 227;

    # make sure the terminal is legible when it boots
    console = {
      earlySetup = true;
      font = "sun12x22";
    };

    environment.variables = {
      GDK_SCALE = "1.5";
      GDK_DPI_SCALE = "0.75";
      XCURSOR_SIZE = "64";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    };

    vars.internal = {
      sublime-text.settings.ui_scale = 2;
      sublime-merge.settings.ui_scale = 2;
    };
  };
}
