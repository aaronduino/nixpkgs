{ config, lib, pkgs, options, ... }:
with lib;
let
  cfg = config.vars;
  qemu-raspi4 = with pkgs; callPackage ../pkgs/qemu {
    inherit (darwin.apple_sdk.frameworks) CoreServices Cocoa Hypervisor;
    inherit (darwin.stubs) rez setfile;
    python = python3;
  };
in
{
  imports = [
    ./options.nix
  ];

  config = mkIf (cfg.gui != "none") {


    services.xserver = {
      enable = true;

      # auto login
      displayManager.lightdm.autoLogin = {
        enable = true;
        user = cfg.username;
      };


      #displayManager.sessionCommands = ''
      #  ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      #    Xft.dpi: 192
      #  EOF
      #'';
    };

    systemd.services = {
      status-bar = {
        description = "Graphical status bar";
        wantedBy = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig.ExecStart = ''
        '';
      };
    };



    # vars.colors = {
    #   background = "#343d46";
    #   green = "#8eb975";
    #   purple = "#c494c3";
    # };

    boot.plymouth.enable = false;

    vars.internal = {
      sublime-text.settings =
        {
          font_face = "Overpass Mono";
          font_size = 12;
          tab_size = 2;
          translate_tabs_to_spaces = true;

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
            background = cfg.colors.background;
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
        settings = {
          env.TERM = "xterm-256color";
          # font.normal.family = "Overpass Mono";
          colors = {
            primary = {
              background = cfg.colors.background;
              foreground = cfg.colors.foreground;
            };
            normal = {
              black = "0x000000";
              red = "0xff5555";
              green = cfg.colors.green;
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

      services.dunst = {
        settings = {
          enable = true;
          global = {
            font = "monospace 24";
            alignment = "left";
            indicate_hidden = "yes";
            format = "<b>%a: %s</b>\\n%b";
            sticky_history = "yes";
            geometry = "1000x1000-30+20";
            shrink = "yes";
            word_wrap = "yes";
            notification_height = "0";
            markup = "full";
          };
          urgency_low = {
            background = "#282c34";
            foreground = "#0979f9";
            timeout = "10";
          };
          urgency_normal = {
            background = "#282c34";
            foreground = "#abb2bf";
            timeout = "10";
          };
          urgency_critical = {
            background = "#1b182c";
            foreground = "#ff8080";
            timeout = "5";
          };
          shortcuts = {
            close = "mod4+backslash";
            close_all = "mod4+space+backslash";
            context = "mod4+slash";
          };
        };
      };
    };

    # for more packages, see default.nix
    environment.systemPackages = with pkgs; [
      firefox
      # ajanse-vscode
      # vscode
(vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          ms-vscode.cpptools
        ] ++ vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "theme-dracula";
            publisher = "dracula-theme";
            version = "2.22.1";
            sha256 = "13x8vayak9b1biqb4rvisywh1zzh5l7g63kv7y6kqgirm2b5wzsi";
          }
          {
            name = "nix-lsp";
            publisher = "aaronduino";
            version = "0.0.1";
            sha256 = "190pqcxlz98grigbppkrj5zvwk8d9si70na7jmilypaxn3zdmm9w";
          }
          {
            name = "rust";
            publisher = "rust-lang";
            version = "0.7.8";
            sha256 = "039ns854v1k4jb9xqknrjkj8lf62nfcpfn0716ancmjc4f0xlzb3";
          }
        ];
      })
      (import ../pkgs/sublime-merge).sublimeMerge
      # freeoffice
      (pkgs.callPackage (import ../pkgs/discord/default.nix) {})
      # discord
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
    ];

    nixpkgs.overlays = [
      (
        self: super: rec {
          ajanse-vscode = super.vscode-with-extensions.override {
            vscodeExtensions = with super.vscode-extensions; [ ms-vscode.cpptools ];
          };
          signal-desktop = super.signal-desktop.overrideAttrs (
            oldAttrs: rec {
              preFixup = oldAttrs.preFixup + ''
                cp $out/lib/Signal/resources/app.asar $out/lib/Signal/resources/app.asar.bak
                cat $out/lib/Signal/resources/app.asar.bak \
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
                  > $out/lib/Signal/resources/app.asar
                rm $out/lib/Signal/resources/app.asar.bak
              '';
            }
          );
        }
      )
    ];
  };
}
