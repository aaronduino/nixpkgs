{ config, lib, pkgs, ... }:
with lib;
let
  writeScript = text: "${pkgs.writeScriptBin "script" text}/bin/script";
  cfg = config.vars;
  alt = "Mod1";
  win = "Mod4";
  normal = isAlt: let
    mod = if isAlt then alt else win;
  in
    {
      XF86AudioPause = "exec ${pkgs.playerctl}/bin/playerctl pause";
      XF86AudioNext = "exec ${pkgs.playerctl}/bin/playerctl next";
      XF86AudioPrev = "exec ${pkgs.playerctl}/bin/playerctl previous";

      XF86AudioRaiseVolume = "exec amixer set Master 5%+";
      XF86AudioLowerVolume = "exec amixer set Master 5%-";
      XF86AudioMute = "exec amixer set Master 0%";

      XF86MonBrightnessUp = "exec light -A 5";
      XF86MonBrightnessDown = "exec light -U 5";


      "${mod}+minus" = "workspace prev";
      "${mod}+equal" = "workspace next";
      "${mod}+bracketleft" = "focus left";
      "${mod}+bracketright" = "focus right";

      "Shift+F1" = "exec light -S 0";
      "F1" = "exec light -U 5";
      "F2" = "exec light -A 5";

      "${mod}+Shift+X" = "exec ${../bin/clear-clipboard.sh}";

      "${mod}+Return" = "exec alacritty";

      "${mod}+Left" = "focus left";
      "${mod}+Down" = "focus down";
      "${mod}+Up" = "focus up";
      "${mod}+Right" = "focus right";

      "${mod}+Shift+Left" = "move left";
      "${mod}+Shift+Down" = "move down";
      "${mod}+Shift+Up" = "move up";
      "${mod}+Shift+Right" = "move right";

      "${mod}+g" = "gaps inner all set 10";
      "${mod}+n" = "gaps inner all set 0";

      "${mod}+y" = "split h";
      "${mod}+u" = "split v";
      "${mod}+f" = "fullscreen toggle";
      "${mod}+Shift+space" = "floating toggle";
      "${mod}+Shift+q" = "kill";
      "${mod}+Shift+c" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";
      "${mod}+Shift+e" = "reload";
      "${mod}+Shift+r" = "restart";

      "${mod}+d" = "exec rofi -show run";
      "${mod}+Shift+d" = "exec rofi -modi 'drun' -show drun";

      "${mod}+Control+Shift+d" = "exec bash ${../bin/open-layout.sh} ";

      "${mod}+s" = "layout stacking";
      "${mod}+w" = "layout tabbed";
      "${mod}+e" = "layout toggle split";
      "${mod}+r" = "mode ${if isAlt then "resizeAlt" else "resizeWin"}";

      # "${mod}+j" = "mode jump";

      "${mod}+1" = "workspace 1";
      "${mod}+2" = "workspace 2";
      "${mod}+3" = "workspace 3";
      "${mod}+4" = "workspace 4";
      "${mod}+5" = "workspace 5";
      "${mod}+6" = "workspace 6";
      "${mod}+7" = "workspace 7";
      "${mod}+8" = "workspace 8";
      "${mod}+9" = "workspace 9";
      "${mod}+0" = "workspace 10";

      "${mod}+Shift+1" = "move container to workspace 1";
      "${mod}+Shift+2" = "move container to workspace 2";
      "${mod}+Shift+3" = "move container to workspace 3";
      "${mod}+Shift+4" = "move container to workspace 4";
      "${mod}+Shift+5" = "move container to workspace 5";
      "${mod}+Shift+6" = "move container to workspace 6";
      "${mod}+Shift+7" = "move container to workspace 7";
      "${mod}+Shift+8" = "move container to workspace 8";
      "${mod}+Shift+9" = "move container to workspace 9";
      "${mod}+Shift+0" = "move container to workspace 10";
      "${if isAlt then win else alt}+Shift+M" = "mode ${if isAlt then "defaultWin" else "default"}";
    };
in
{
  imports = [
    ./options.nix
  ];

  options.vars.i3 = {
    mod = mkOption {
      type = types.enum [ "alt" "win" ];
      default = "win";
    };
  };

  config = mkIf (cfg.gui == "i3") {
    services.xserver = {
      # displayManager.default = "none+i3";
      desktopManager.session = [
        {
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };

    home-manager.users = let
      xsession = {
        enable = true;
        scriptPath = ".hm-xsession";
        windowManager.i3 = {
          enable = true;
          package = pkgs.i3-gaps;
          config = {
            window.border = 1;
            colors.focused = let
              color = "#61afef";
            in
              {
                # 61afef
                background = "#000000";
                border = color;
                childBorder = color;
                indicator = color;
                text = "#ffffff";
              };
            colors.unfocused = {
              background = "#000000";
              border = "#f8f8f2";
              childBorder = "#f8f8f2";
              indicator = "#f8f8f2";
              text = "#ffffff";
            };
            bars = [];
            fonts = [ "Roboto Mono 8" ];
            gaps = {
              inner = 3;
              smartBorders = "on";
              smartGaps = true;
            };
            startup = [
              {
                command = "bash ${writeScript ''
                  xrandr --output eDP-1 --scale 1.25x1.25
                  xinput set-prop "CUST0001:00 06CB:76AF Touchpad" "Trackpad Scroll Distance" 15
                  xinput set-prop "CUST0001:00 06CB:76AF Touchpad" "libinput Tapping Drag Enabled" 0
                  xinput set-prop "CUST0001:00 06CB:76AF Touchpad" "libinput Accel Speed" 0.22
                  sleep 0.5
                  sh ${../bin/restart-polybar.sh}

                  xsetroot -solid "#181920"
                ''}";
                always = true;
              }
            ];
            assigns = {};
            modes =
              let
                resize = returnMode: {
                  Left = "resize shrink width 10 px or 10 ppt";
                  Right = "resize grow width 10 px or 10 ppt";
                  Up = "resize shrink height 10 px or 10 ppt";
                  Down = "resize grow height 10 px or 10 ppt";

                  Escape = "mode ${returnMode}";
                  Return = "mode ${returnMode}";
                };

              in
                {
                  resizeAlt = resize "default";
                  resizeWin = resize "defaultWin";
                  defaultWin = normal false;
                };

            keybindings = normal true;
          };
        };
      };
    in
      {
        "${cfg.username}".xsession = xsession;
        root.xsession = xsession;
      };
  };
}
