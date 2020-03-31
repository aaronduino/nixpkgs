{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in {
  imports = [
    ./options.nix
  ];

  config = mkIf (cfg.gui == "sway") {
    # services.xserver = {
    #   desktopManager.session = [
    #     {
    #       name = "home-manager";
    #       start = ''
    #         ${pkgs.runtimeShell} $HOME/.hm-xsession &
    #         waitPID=$!
    #       '';
    #     }
    #   ];
    # };

    home-manager.users."${cfg.username}" = {
      wayland.windowManager.sway = {
enable = true;
config = {
  modifier = "Mod4";
};
};
    };
  };
}
