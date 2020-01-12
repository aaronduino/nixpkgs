{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  imports = [
    ./options.nix
  ];

  options.vars = {};

  config = {
    services.xserver.windowManager.bspwm = {
      enable = cfg.gui == "bspwm";
      configFile = pkgs.writeText "bspwmrc" ''
        ( sleep 3 && bspc monitor -d 1 2 3 4 5 6 7 8 9 0 )

        bspc config border_width         2
        bspc config window_gap          12

        bspc config automatic_scheme longest_side
        bspc config split_ratio          0.52
        bspc config borderless_monocle   true
        bspc config gapless_monocle      true

        bspc config border_width         1
        bspc config focused_border_color "#61afef"
      '';
      sxhkd.configFile = pkgs.writeText "sxhkdrc" ''
        # ================
        # APPS
        # ================

        mod4 + BackSpace
            notify-send -u low "Status" "$(bash ${../bin/status.sh})"

        # Terminal emulator
        mod4 + Return
            cd && kitty

        # Browser
        mod4 + shift + w
            firefox

        # App launcher
        mod4 + d
            cd && zsh -c "rofi -show run"

        # Music hotkeys
        XF86Audio{Play,Prev,Next}
            playerctl {pause, previous, next}


        XF86MonBrightness{Down,Up}
            brightnessctl s {5%-, 5%+}

        # ================
        # BSPWM FUNCTIONS
        # ================

        # Windows
        # ------------
        # Close window
        mod4 + shift + q
            bspc node -c

        # Focus window
        mod4 + {Left, Down, Up, Right}
            change-split-or-window {west,south,north,east}

        # Focus window by prev/next
        mod4 + {_,shift + }c
            bspc node -f {next,prev}.local

        # Move window
        mod4 + shift + {Left, Down, Up, Right}
           ${../bin/euclid_mover.sh} {west,south,north,east}

        # Resize window by moving bounds out
        mod4 + alt + {Left, Down, Up, Right}
            bspc node -z {left -20 0,down 20 0,top 0 -20,right 20 0}

        # Resize window by moving bounds in
        mod4 + alt + shift + {Left, Down, Up, Right}
            bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

        # Desktops
        # ------------
        # Focus the given desktop
        mod4 + {1-9,0}
            bspc desktop -f '^{1-9,10}'

        # Send focused window to given desktop
        mod4 + shift + {1-9,0}
            bspc node -d '^{1-9,10}'

        # Toggle monocle layout
        mod4 + m
            bspc desktop -l next

        # ================
        # SYSTEM
        # ================

        # Reconfigure sxhkd
        mod4 + shift + r
            run-sxhkd

        # Volume
        {XF86AudioMute,XF86AudioLowerVolume,XF86AudioRaiseVolume}
            amixer -D pulse sset Master {toggle,5%-,5%+}

      '';
    };
  };
}
