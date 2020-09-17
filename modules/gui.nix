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
      displayManager.autoLogin = {
        enable = true;
        user = cfg.username;
      };

      displayManager.sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
          Xft.dpi: 192
        EOF
      '';
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
              backgroundAlt = "argb:00ffffff";
              highlight = {
                inherit (cfg.colors) background;
                foreground = cfg.colors.blue;
              };
            };
          };
        };
      };

      programs.alacritty = {
        enable = true;
        settings = {
          env.TERM = "xterm-256color";
          colors = {
            primary = {
              inherit (cfg.colors) foreground background;
            };
            normal = {
              inherit (cfg.colors) red green blue magenta cyan yellow;
              black = "0x000000";
              white = "0xbbbbbb";
            };
            bright = {
              inherit (cfg.colors) red green blue magenta cyan yellow;
              black = "0x555555";
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
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          ms-vscode.cpptools
          james-yu.latex-workshop
        ] ++ vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "theme-dracula-refined";
            publisher = "mathcale";
            version = "2.22.1";
            sha256 = "03m44a3qmyz4mmfn1pzfcwc77wif4ldf2025nj9rys6lfhcz0x1n";
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
          {
            name = "better-toml";
            publisher = "bungcip";
            version = "0.3.2";
            sha256 = "08lhzhrn6p0xwi0hcyp6lj9bvpfj87vr99klzsiy8ji7621dzql3";
          }
        ];
      })
      (pkgs.callPackage (import ../pkgs/discord/default.nix) { })
      spotify
      evince
      okular

      qbittorrent

      libnotify
      xclip
      playerctl

      scrot
      feh
      imagemagick
      gnome3.nautilus
      xsecurelock

      signal-desktop
    ];

    nixpkgs.overlays = [
      (
        self: super: rec {
          signal-desktop = super.signal-desktop.overrideAttrs (
            oldAttrs: rec {
              preFixup = with cfg.colors; oldAttrs.preFixup + ''
                cp $out/lib/Signal/resources/app.asar $out/lib/Signal/resources/app.asar.bak
                cat $out/lib/Signal/resources/app.asar.bak \
                  | sed 's/background-color: #f6f6f6;/background-color: ${background};/g' \
                  | sed 's/#1b1b1b;/${foreground};/g' \
                  | sed 's/#5e5e5e;/${foreground};/g' \
                  | sed 's/-color: #ffffff;/-color: #282a36;/g' \
                  | sed 's/background: #ffffff;/background: #282a36;/g' \
                  | sed 's/#dedede;/#44475a;/g' \
                  | sed 's/#e9e9e9;/#44475a;/g' \
                  | sed 's/1px solid #ffffff;/1px solid #282a36;/g' \
                  | sed 's/#f6f6f6;/${background};/g' \
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
