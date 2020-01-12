{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  imports = [
    ./options.nix
  ];

  options.vars = {
    name = mkOption {
      type = types.str;
    };
    email = mkOption {
      type = types.str;
    };
  };

  config = {
    #   home-manager.users = let
    #     git = {
    #       enable = false;
    #       package = pkgs.gitAndTools.gitFull;
    #       userName = cfg.name;
    #       userEmail = cfg.email;
    #       aliases = {
    #         d = "difftool --no-symlinks --dir-diff";
    #       };
    #       signing = {
    #         key = cfg.pgpFingerprint;
    #         signByDefault = false;
    #       };
    #       extraConfig = {
    #         credential = {
    #           helper = "libsecret";
    #         };
    #       };
    #     };
    #   in
    #     {
    #       "${cfg.username}".programs.git = git;
    #     };
    environment.systemPackages = [ pkgs.gitAndTools.gitFull ];

  };

}
