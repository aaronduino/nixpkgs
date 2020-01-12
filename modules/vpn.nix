{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options.vars = {
    enableVPN = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enableVPN {
    services.openvpn.servers.proton = {
      config = "config ${../secrets/ajanse/vpn.ovpn}";
      updateResolvConf = true;
    };
    networking.enableIPv6 = true;
  };
}
