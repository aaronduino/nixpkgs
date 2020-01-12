{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options.vars = {
    offlineimap = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = {
    # services.offlineimap = {
    #   enable = false;
    #   install = false;

    # };
  };
}
