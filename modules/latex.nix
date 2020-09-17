{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options.vars = {
    latex = mkOption {
      type = types.bool;
    };
  };

  config = mkIf cfg.latex {
    fonts.fonts = [ pkgs.lmodern ];
    environment.systemPackages = with pkgs; [
      texlive.combined.scheme-full
    ];
  };
}
