{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.vars;
in
{
  imports = [
    ./options.nix
  ];

  config = mkIf (cfg.gui != "none") {
    services.xserver = {
      enable = true;

      # auto login
      displayManager.auto = {
        enable = true;
        user = cfg.username;
      };
    };

    boot.plymouth.enable = false;

    vars.internal = {
      sublime-text.settings =
        {
          font_face = "Overpass Mono";
          font_size = 12;

          hot_exit = false;
          remember_open_files = false;
          menu_visible = false;
          update_check = false;
          ignored_packages = [ "Vintage" ];
          theme = "Adaptive.sublime-theme";
          color_scheme = "Packages/Dracula Color Scheme/Dracula.tmTheme";
        };
    };

    fonts = {
      enableFontDir = true;
      fonts =
        with pkgs;
        builtins.concatLists [
          [
            corefonts
            inconsolata
            terminus_font
            dejavu_fonts
            ubuntu_font_family
            source-code-pro
            source-sans-pro
            source-serif-pro
            roboto-mono
            roboto
            overpass
            libre-baskerville
            (import ../pkgs/font-awesome.nix)
          ]
        ];
    };

    home-manager.users.${cfg.username} = {
      xsession = {
        enable = cfg.gui == "i3";
        pointerCursor = {
          name = "Vanilla-DMZ";
          package = pkgs.vanilla-dmz;
          size = 128;
        };
      };
      programs.rofi = {
        enable = cfg.gui == "i3" || cfg.gui == "bspwn";
        fullscreen = false;
        padding = 25;
        separator = "solid";
        scrollbar = false;
        rowHeight = 1;
        font = "Roboto Mono 24";
        lines = 15;
        width = 800;
        colors = {
          window = {
            background = "#181920";
            border = "#F8F8F2";
            separator = "#c3c6c8";
          };

          rows = {
            normal = rec {
              foreground = "#fafbfc";
              background = "argb:00ffffff";
              backgroundAlt = "argb:00ffffff"; # argb:58455a64
              highlight = {
                background = "#181920";
                foreground = "#BD93F9";
              };
            };
          };
        };
      };

      programs.alacritty = {
        enable = true;
        settings.colors = {
          primary = {
            background = "0x181920";
            foreground = "0xf8f8f2";
          };
          normal = {
            black = "0x000000";
            red = "0xff5555";
            green = "0x50fa7b";
            yellow = "0xf1fa8c";
            blue = "0xbd93f9";
            magenta = "0xff79c6";
            cyan = "0x8be9fd";
            white = "0xbbbbbb";
          };
          bright = {
            black = "0x555555";
            red = "0xff5555";
            green = "0x50fa7b";
            yellow = "0xf1fa8c";
            blue = "0xbd93f9";
            magenta = "0xff79c6";
            cyan = "0x8be9fd";
            white = "0xffffff";
          };
        };
      };
    };

    # for more packages, see default.nix
    environment.systemPackages = with pkgs; [
      firefox
      vscode
      (import ../pkgs/sublime-merge).sublimeMerge
      freeoffice
      discord
      spotify
      evince
      okular

      qbittorrent

      sublime3

      libnotify
      xclip
      playerctl
      keynav

      scrot
      feh
      pinta
      gimp
      imagemagick
      gnome3.nautilus

      yubioath-desktop
      xsecurelock

      signal-desktop

      cava

      qemu
    ];

    nixpkgs.overlays = [
      (
        self: super: {
          signal-desktop = super.signal-desktop.overrideAttrs (
            oldAttrs: rec {
              phases = [ "unpackPhase" "installPhase" "fixupPhase" ];
              fixupPhase = ''
                cp $out/libexec/resources/app.asar $out/libexec/resources/app.asar.bak
                cat $out/libexec/resources/app.asar.bak \
                  | sed 's/background-color: #f6f6f6;/background-color: #181920;/g' \
                  | sed 's/#1b1b1b;/#f8f8f2;/g' \
                  | sed 's/#5e5e5e;/#f8f8f2;/g' \
                  | sed 's/-color: #ffffff;/-color: #282a36;/g' \
                  | sed 's/background: #ffffff;/background: #282a36;/g' \
                  | sed 's/#dedede;/#44475a;/g' \
                  | sed 's/#e9e9e9;/#44475a;/g' \
                  | sed 's/1px solid #ffffff;/1px solid #282a36;/g' \
                  | sed 's/#f6f6f6;/#181920;/g' \
                  | sed 's/#b9b9b9;/#44475a;/g' \
                  | sed 's/2px solid #ffffff;/2px solid #282a36;/g' \
                  | sed 's/setMenuBarVisibility(visibility);/setMenuBarVisibility(false     );/g' \
                  | sed 's/setFullScreen(true)/setFullScreen(0==1)/g' \
                  > $out/libexec/resources/app.asar
                rm $out/libexec/resources/app.asar.bak
              '';
            }
          );
        }
      )
    ];
  };
}
