{ config, lib, pkgs, ... }:
with lib;
{}
# let
#   cfg = config.vars;
# in
# {
#   options.vars.rpiBridge = {
#     enable = mkEnableOption "RPi ethernet-to-wifi bridge";
#     eth = mkOption {
#       type = types.str;
#     };
#     wifi = mkOption {
#       type = types.str;
#     };
#   };

#   config = mkIf cfg.rpiBridge.enable {
#     environment.systemPackages = [
#       (pkgs.writeScriptBin "rpi-bridge" ''
#     #     if [ "$1" == "-h" ]; then
#     #       echo "Available parameters: enable, disable, -h"
#     #     elif [ "$1" == "enable" ]; then
#     #       echo "ENABLE"
#     #     elif [ "$1" == "disable" ]; then
#     #       echo "DISABLE"
#     #     else
#     #       echo "Unrecognized argument. Try -h for help."
#     #     fi
#     #   '')
#       (pkgs.writeScriptBin "start-rpi-bridge" ''
#                 ${pkgs.dhcp}/sbin/dhcpd "dhcpd4" "-4"
#                          "-pf" "/run/dhcpd4/dhcpd.pid"
#                          "-cf" "${pkgs.writeText "dhcpd-rpi-config" ''
#                             default-lease-time 600;
#                             max-lease-time 7200;
#                             authoritative;
#                             ddns-update-style interim;
#                             log-facility local1; # see dhcpd.nix
#                             ddns-update-style none;
#                             one-lease-per-client true;

#                             subnet 192.168.2.0 netmask 255.255.255.0 {
#                               range 192.168.2.10 192.168.10.254;
#                             authoritative;
#                             max-lease-time 604800;
#                             default-lease-time 86400;
#                             option subnet-mask 255.255.255.0;
#                             option broadcast-address 192.168.2.255;
#                             option routers 192.168.2.1;
#                             option domain-name-servers 8.8.8.8, 8.8.4.4;
#                             }
#                          ''}"
#                          "-lf" "${services.dhcpd4.stateDir}/dhcpd.leases"
#                          "-user" "dhcpd" "-group" "nogroup"
#               '')
#     ];
#     # services.udev.extraRules = ''
#     #   ACTION=="add", SUBSYSTEM=="net", KERNEL=="ens8u1", RUN+="${
#     #     pkgs.writeScriptBin "start-rpi-bridge" ''
#     #       ${pkgs.dhcp}/sbin/dhcpd "dhcpd4" "-4"
#     #                "-pf" "/run/dhcpd4/dhcpd.pid"
#     #                "-cf" "${pkgs.writeText "dhcpd-rpi-config" ''
#     #                   default-lease-time 600;
#     #                   max-lease-time 7200;
#     #                   authoritative;
#     #                   ddns-update-style interim;
#     #                   log-facility local1; # see dhcpd.nix
#     #                   ddns-update-style none;
#     #                   one-lease-per-client true;

#     #                   subnet 192.168.2.0 netmask 255.255.255.0 {
#     #                     range 192.168.2.10 192.168.10.254;
#     #                   authoritative;
#     #                   max-lease-time 604800;
#     #                   default-lease-time 86400;
#     #                   option subnet-mask 255.255.255.0;
#     #                   option broadcast-address 192.168.2.255;
#     #                   option routers 192.168.2.1;
#     #                   option domain-name-servers 8.8.8.8, 8.8.4.4;
#     #                   }
#     #                ''}"
#     #                "-lf" "${cfg.stateDir}/dhcpd.leases"
#     #                "-user" "dhcpd" "-group" "nogroup"
#     #     ''}/bin/start-rpi-bridge"
#     # '';
#   };
# }

# { config, lib, pkgs, ... }:

# with lib;

# let

#   cfg4 = config.services.dhcpd4;
#   cfg6 = config.services.dhcpd6;

#   writeConfig = cfg: pkgs.writeText "dhcpd.conf"
#     ''
#       default-lease-time 600;
#       max-lease-time 7200;
#       authoritative;
#       ddns-update-style interim;
#       log-facility local1; # see dhcpd.nix

#       ${cfg.extraConfig}

#       ${lib.concatMapStrings
#           (machine: ''
#             host ${machine.hostName} {
#               hardware ethernet ${machine.ethernetAddress};
#               fixed-address ${machine.ipAddress};
#             }
#           '')
#           cfg.machines
#       }
#     '';

#   dhcpdService = postfix: cfg: optionalAttrs cfg.enable {
#     "dhcpd${postfix}" = {
#       description = "DHCPv${postfix} server";
#       wantedBy = [ "multi-user.target" ];
#       after = [ "network.target" ];

#       preStart = ''
#         mkdir -m 755 -p ${cfg.stateDir}
#         chown dhcpd:nogroup ${cfg.stateDir}
#         touch ${cfg.stateDir}/dhcpd.leases
#       '';

#       serviceConfig =
#         let
#           configFile = if cfg.configFile != null then cfg.configFile else writeConfig cfg;
#           args = [ "@${pkgs.dhcp}/sbin/dhcpd" "dhcpd${postfix}" "-${postfix}"
#                    "-pf" "/run/dhcpd${postfix}/dhcpd.pid"
#                    "-cf" "${configFile}"
#                    "-lf" "${cfg.stateDir}/dhcpd.leases"
#                    "-user" "dhcpd" "-group" "nogroup"
#                  ] ++ cfg.extraFlags
#                    ++ cfg.interfaces;

#         in {
#           ExecStart = concatMapStringsSep " " escapeShellArg args;
#           Type = "forking";
#           Restart = "always";
#           RuntimeDirectory = [ "dhcpd${postfix}" ];
#           PIDFile = "/run/dhcpd${postfix}/dhcpd.pid";
#         };
#     };
#   };

#   machineOpts = { ... }: {

#     options = {

#       hostName = mkOption {
#         type = types.str;
#         example = "foo";
#         description = ''
#           Hostname which is assigned statically to the machine.
#         '';
#       };

#       ethernetAddress = mkOption {
#         type = types.str;
#         example = "00:16:76:9a:32:1d";
#         description = ''
#           MAC address of the machine.
#         '';
#       };

#       ipAddress = mkOption {
#         type = types.str;
#         example = "192.168.1.10";
#         description = ''
#           IP address of the machine.
#         '';
#       };

#     };
#   };

#   dhcpConfig = postfix: {

#     enable = mkOption {
#       type = types.bool;
#       default = false;
#       description = ''
#         Whether to enable the DHCPv${postfix} server.
#       '';
#     };

#     stateDir = mkOption {
#       type = types.path;
#       # We use /var/lib/dhcp for DHCPv4 to save backwards compatibility.
#       default = "/var/lib/dhcp${if postfix == "4" then "" else postfix}";
#       description = ''
#         State directory for the DHCP server.
#       '';
#     };

#     extraConfig = mkOption {
#       type = types.lines;
#       default = "";
#       example = ''
#         option subnet-mask 255.255.255.0;
#         option broadcast-address 192.168.1.255;
#         option routers 192.168.1.5;
#         option domain-name-servers 130.161.158.4, 130.161.33.17, 130.161.180.1;
#         option domain-name "example.org";
#         subnet 192.168.1.0 netmask 255.255.255.0 {
#           range 192.168.1.100 192.168.1.200;
#         }
#       '';
#       description = ''
#         Extra text to be appended to the DHCP server configuration
#         file. Currently, you almost certainly need to specify something
#         there, such as the options specifying the subnet mask, DNS servers,
#         etc.
#       '';
#     };

#     extraFlags = mkOption {
#       type = types.listOf types.str;
#       default = [];
#       description = ''
#         Additional command line flags to be passed to the dhcpd daemon.
#       '';
#     };

#     configFile = mkOption {
#       type = types.nullOr types.path;
#       default = null;
#       description = ''
#         The path of the DHCP server configuration file.  If no file
#         is specified, a file is generated using the other options.
#       '';
#     };

#     interfaces = mkOption {
#       type = types.listOf types.str;
#       default = ["eth0"];
#       description = ''
#         The interfaces on which the DHCP server should listen.
#       '';
#     };

#     machines = mkOption {
#       type = with types; listOf (submodule machineOpts);
#       default = [];
#       example = [
#         { hostName = "foo";
#           ethernetAddress = "00:16:76:9a:32:1d";
#           ipAddress = "192.168.1.10";
#         }
#         { hostName = "bar";
#           ethernetAddress = "00:19:d1:1d:c4:9a";
#           ipAddress = "192.168.1.11";
#         }
#       ];
#       description = ''
#         A list mapping Ethernet addresses to IPv${postfix} addresses for the
#         DHCP server.
#       '';
#     };

#   };

# in

# {

#   ###### interface

#   options = {

#     services.dhcpd4 = dhcpConfig "4";
#     services.dhcpd6 = dhcpConfig "6";

#   };


#   ###### implementation

#   config = mkIf (cfg4.enable || cfg6.enable) {

#     users = {
#       users.dhcpd = {
#         uid = config.ids.uids.dhcpd;
#         description = "DHCP daemon user";
#       };
#     };

#     systemd.services = dhcpdService "4" cfg4 // dhcpdService "6" cfg6;

#   };

# }
