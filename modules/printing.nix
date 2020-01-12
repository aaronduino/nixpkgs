{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options.vars = {
    printing = mkOption {
      type = types.bool;
    };
  };

  config = mkIf cfg.printing {
    services.printing.enable = true;
    services.printing.drivers = [ pkgs.brlaser pkgs.mfcl2740dwlpr pkgs.mfcl2740dwcupswrapper ];
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    networking.hosts = {
      "192.168.1.249" = [ "BRW707781875760.local" ];
    };
  };
}
