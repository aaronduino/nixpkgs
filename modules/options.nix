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
      default = false;
    };

    hostname = mkOption {
      type = types.str;
    };

    username = mkOption {
      type = types.str;
    };

    gui = mkOption {
      type = types.enum [ "none" "i3" "bspwm" "pantheon" "kde" "sway" ];
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

      red = mkOption {
        type = types.str;
        default = "#ff5555";
      };

      orange = mkOption {
        type = types.str;
        default = "#ffb86c";
      };

      yellow = mkOption {
        type = types.str;
        default = "#f1fa8c";
      };

      green = mkOption {
        type = types.str;
        default = "#50fa7b";
      };

      cyan = mkOption {
        type = types.str;
        default = "#8be9fd";
      };

      blue = mkOption {
        type = types.str;
        default = "#bd93f9";
      };

      magenta = mkOption {
        type = types.str;
        default = "#ff79c6";
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
