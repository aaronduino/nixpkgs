{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
  patchSublimeScale = isRoot: settings:
    settings // (if isRoot then { ui_scale = null; } else {});
in
{
  imports = [
    ./options.nix
  ];

  config = {
    home-manager.users = let
      dotfiles = isRoot: {
        ".gnupg/gpg-agent.conf".text = "pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry";

        ".config/git/config".text = ''
          [alias]
          d=difftool --no-symlinks --dir-diff

          [commit]
          gpgSign=false

          [credential]
          helper=libsecret

          [merge]
          conflictstyle=diff3

          [gpg]
          program=${pkgs.gnupg}/bin/gpg2

          [user]
          email=${cfg.email}
          name=${cfg.name}
          signingKey=BE6C92145BFF4A34
        '';
      };
    in
      {
        root.home.file = dotfiles true;
        "${cfg.username}".home.file = dotfiles false;
      };
  };
}
