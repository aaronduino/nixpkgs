{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options = {
    enableZSH = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.enableZSH {
    users.defaultUserShell = pkgs.zsh;
    environment.pathsToLink = [ "/share/zsh" ]; # for zsh completion
    programs.thefuck = {
      enable = true;
      alias = "f";
    };
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" ];
      };
      zsh-autoenv.enable = true;
      autosuggestions = {
        enable = true;
      };
      promptInit = ''
        autoload -U colors && colors

        precmd () { PS1=$(zsh ${../bin/prompt.sh}) }
      '';
      interactiveShellInit = ''
        export GOPATH=$HOME/go

        # z -- jump around
        source ${pkgs.fetchurl { url = "https://github.com/rupa/z/raw/2ebe419ae18316c5597dd5fb84b5d8595ff1dde9/z.sh"; sha256 = "0ywpgk3ksjq7g30bqbhl9znz3jh6jfg8lxnbdbaiipzgsy41vi10"; }}

        HISTFILE=~/.histfile
        HISTSIZE=10000
        SAVEHIST=10000
        setopt appendhistory autocd
        unsetopt beep extendedglob

        # source ${../bin/nix-shell.plugin.zsh}

        export SOPS_PGP_FP=CED96DF463D7B86A1C4B1322BE6C92145BFF4A34
        export EDITOR=vim
      '' + (
        let
          envPath = "${cfg.secrets}/restic-env.conf";
          passPath = "${cfg.secrets}/restic-password.txt";
        in
          if (
            (builtins.pathExists envPath)
            && (builtins.pathExists passPath)
          ) then ''
            r-b2 () {
             ( cd /home/${cfg.username}/backups && source ${envPath} && restic -r b2:ajanse-archive:/ -p ${passPath} $* )
            }

            r-nas () {
            ( cd /home/${cfg.username}/backups && source ${envPath} && restic -p ${passPath} -r sftp:aaron@192.168.1.160:/homes/aaron $* )
            }
          '' else ""
      );
      shellAliases = {
        c = "clear";

        pbcopy = "xclip -i -selection clipboard";
        pbpaste = "xclip -o";

        gad = "git add .";
        sgad = "sudo git add .";

        gcm = "git commit -m";
        sgcm = "sudo git commit -m";

        gp = "git push";
        sgp = "sudo git push";
      };
    };
  };
}
