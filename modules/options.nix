{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    "${builtins.fetchGit { url = "https://github.com/rycee/home-manager"; ref = "master"; }}/nixos"
    # <home-manager/nixos>
  ];
  options.vars = {
    hardware = mkOption {
      type = types.enum [ "xps" "yoga" "usb" ];
    };

    hidpi = mkOption {
      type = types.bool;
    };

    hostname = mkOption {
      type = types.str;
    };

    username = mkOption {
      type = types.str;
    };

    gui = mkOption {
      type = types.enum [ "none" "i3" "bspwm" "pantheon" ];
    };

    secrets = mkOption {
      type = types.path;
    };

    colors = {
      background = mkOption {
        type = types.str;
        default = "#181920";
      };

      foreground = mkOption {
        type = types.str;
        default = "#f8f8f2";
      };
    };

    internal = {
      sublime-text.settings = mkOption {
        type = types.attrsOf types.unspecified;
        default = {};
      };
      sublime-merge.settings = mkOption {
        type = types.attrsOf types.unspecified;
        default = {};
      };
    };
  };
}
