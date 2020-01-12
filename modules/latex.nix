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
      biber

      (
        pkgs.texlive.combine {
          inherit (texlive)
            apa6 threeparttable endfloat biblatex-apa
            scheme-small
            collection-fontutils
            collection-fontsrecommended
            collection-fontsextra
            fontaxes
            csquotes
            biblatex
            logreq xstring
            tcolorbox environ trimspaces
            beamer
            ;
        }
      )
    ];
  };
}
