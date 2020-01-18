{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
  # sublime scaling is broken for root
  patchSublimeScale = isRoot: settings:
    settings // (if false then { ui_scale = null; } else {});
in
{
  imports = [
    ./options.nix
  ];
  config = {
    home-manager.users = let
      dotfiles = isRoot: {
        ".config/sublime-text-3" = {
          recursive = true;
          source = ../dotfiles/sublime-text-3;
        };

        ".gnupg/gpg-agent.conf".text = "pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry";

        ".config/git/config".text = ''
          [alias]
          d=difftool --no-symlinks --dir-diff

          [commit]
          gpgSign=false

          [credential]
          helper=libsecret

          [gpg]
          program=${pkgs.gnupg}/bin/gpg2

          [user]
          email=${cfg.email}
          name=${cfg.name}
          signingKey=BE6C92145BFF4A34
        '';

        ".config/sublime-text-3/Packages/User/Preferences.sublime-settings".text =
          builtins.toJSON (patchSublimeScale isRoot cfg.internal.sublime-text.settings);

        # ".config/sublime-merge".source = ../dotfiles/sublime-merge;

        ".config/sublime-merge/Packages/User/Preferences.sublime-settings".text =
          builtins.toJSON (patchSublimeScale isRoot cfg.internal.sublime-merge.settings);
      };
    in
      {
        root.home.file = dotfiles true;
        "${cfg.username}".home.file = dotfiles false;
      };
  };
}
