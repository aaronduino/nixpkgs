{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  imports = [
    ./options.nix
  ];

  options = {
    enableZSH = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.enableZSH {
    users.defaultUserShell = pkgs.zsh;
    environment.pathsToLink = [ "/share/zsh" ]; # for zsh completion
    home-manager.users =
      let
        fzf = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
        };
        zsh = {
          enable = true;
          enableAutosuggestions = true;
          autocd = true;
          history.save = 10000000;
          history.size = 10000000;
          plugins = [
            {
              name = "zsh-nix-shell";
              src = pkgs.fetchFromGitHub {
                owner = "chisui";
                repo = "zsh-nix-shell";
                rev = "v0.1.0";
                sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
              };
            }
          ];
          initExtra = ''
            autoload -U colors && colors

            precmd () { PS1=$(zsh ${../bin/prompt.sh}) }
          '';
        };
      in
      {
        root.programs = {
          inherit fzf zsh;
        };
        "${cfg.username}".programs = {
          inherit fzf zsh;
        };
      };
  };
}
