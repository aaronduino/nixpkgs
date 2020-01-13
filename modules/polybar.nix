{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
  onBottom = false;

  writeScript = text: "${pkgs.writeScriptBin "script" text}/bin/script";
in
{
  imports = [
    ./options.nix
  ];

  config = mkIf (cfg.gui == "i3") {
    home-manager.users."${cfg.username}".services.polybar = {
      enable = true;
      script = "";
      package = pkgs.polybar.override {
        i3GapsSupport = true;
        # alsaSupport = true;
        # iwSupport = true;
      };
      config = let
        fonts = {
          font-0 = "Overpass Mono:size=9;0";
          font-1 = "Overpass Mono:style=Bold:size=9;0";
          font-2 = "Overpass:style=Regular:size=9;0";
          font-3 = "Font Awesome 5 Free:style=Regular:pixelsize=9;1";
          font-4 = "Font Awesome 5 Free:style=Solid:pixelsize=9;1";
          font-5 = "Font Awesome 5 Brands:pixelsize=9;1";
        };
        default-bar = {
          dpi = cfg.hidpi;
        };
      in
        {
          "settings" = {
            compositing-background = "over";
            pseudo-transparency = true;
          };

          "bar/status" = fonts // default-bar // {
            bottom = onBottom;

            width = "100%";
            height = if cfg.hidpi then 55 else 22;
            modules-left = "i3 music";
            modules-center = "cpu temp wifi memory";
            modules-right = "date";
            overline-size = if onBottom then 0 else 4;
            underline-size = if onBottom then 4 else 0;
            module-margin = 1;
            border-top-size = 0;
            border-bottom-size = 0;
            border-left-size = 0;
            border-right-size = 0;
            radius-top = 0;
            background = cfg.colors.background;
            foreground = cfg.colors.foreground;
            border-color = "#00ffffff";

            padding-left = 1;
            padding-right = 0;
          };

          "bar/tray" = default-bar // {
            modules-left = "nop";

            background = "#00ffffff";
            bottom = false;
            width = "25%:-50";
            height = 60;
            offset-y = -9;
            override-redirect = true;

            tray-background = "#20222B";
            tray-position = "right";
            tray-detached = true;
            tray-offset-x = -35;
            tray-maxsize = 30;
          };

          "module/nop" = {
            type = "custom/text";
            content = " ";
          };

          "module/music" = { # Uptown Vibes
            type = "custom/script";
            exec = writeScript ''
              title=$(playerctl metadata 'xesam:title' 2> /dev/null)
              filteredTitle=$(echo $title | sed "s/ [(][^)]*[)]//g" | sed "s/-.*//g")

              if [ -n "$title" ]; then
                echo "  $filteredTitle"
              fi
            '';
            interval = 5;
            label = "%output%";
            label-foreground = "#50fa7b";
            label-font = 3;
          };

          "module/memory" = {
            type = "custom/script";
            exec = writeScript ''
              totalKB=$(free | head -2 | tail -1 | awk '{ print $2 }')
              availableKB=$(free | head -2 | tail -1 | awk '{ print $7 }')

              usedKB=$(echo "$totalKB - $availableKB" | bc)
              usedMB=$(echo "$usedKB / 1024" | bc)
              usedGB=$(echo "scale=2; $usedKB / 1048576" | bc)

              # echo -n "%{u"
              # if   (( $(echo "$usedGB < 3.0" | bc -l) )); then
              #   echo -n "#209CF5"; # blue
              # elif (( $(echo "$usedGB < 4.0" | bc -l) )); then
              #   echo -n "#12F68E"; # green
              # elif (( $(echo "$usedGB < 5.0" | bc -l) )); then
              #   echo -n "#FFC313"; # yellow
              # elif (( $(echo "$usedGB < 7.0" | bc -l) )); then
              #   echo -n "#CF6D26"; # orange
              # else
              #   echo -n "#F52032"; # red
              # fi
              # echo -n " +u}"

              echo -n "$usedGB"
              echo -n " GB "
              # echo "%{u-}"
            '';
            interval = 10;
          };

          "module/cpu" = {
            type = "custom/script";
            exec = writeScript ''
              percentage=$(mpstat 1 1 | awk '$3 ~ /CPU/ { for(i=1;i<=NF;i++) { if ($i ~ /%idle/) field=i } } $3 ~ /all/ { printf("%d",100 - $field) }')
              padded=$(printf "%2s" $percentage)
              echo -n "$padded%"
            '';
            interval = 10;
          };

          "module/temp" = {
            type = "custom/script";
            exec = writeScript ''
              maxTemp=$(cat /sys/class/thermal/thermal_zone*/temp | sort | tail -1)
              tempCelcius=$(echo "$maxTemp / 1000" | bc)
              echo "$tempCelcius°"
            '';
            interval = 5;
          };

          "module/wifi" = {
            type = "custom/script";
            exec = writeScript ''
              nmcli c | grep wifi | grep -ve "--" | awk '{print $1}'
            '';
            interval = "60";
            label = "%output%";
          };

          # "module/wifi" = {
          #   type = "custom/text";
          #   content = "DunderMifflinAP";
          # };

          "module/date" = {
            type = "custom/script";
            exec = "date +'%Y-%m-%d  %H:%M  '";
            interval = 60;
            label-foreground = cfg.colors.foreground;
            label-font = 2;
          };

          "module/i3" = if (cfg.hardware == "xps") then {
            type = "custom/script";
            exec = "nix-shell -p python36 python36Packages.i3ipc --run \"python3 -u ${../bin/i3.py}\"";
            tail = true;
            label-foreground = cfg.colors.foreground;
          } else { type = "internal/i3"; };
        };
    };
  };
}
