{ config, lib, pkgs, ... }:
let
  cfg = config.vars;
in
{
  imports = [
    ../modules
  ];

  vars = {
    hidpi = true;
    sound = lib.mkDefault true;
    bluetooth = lib.mkDefault true;
    printing = lib.mkDefault true;
    # gui = lib.mkDefault "i3";
  };

  # use systemd-boot with uefi
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    grub.enable = false;
  };

  # battery life and temperature control
  services.tlp.enable = true;

  # sorry, stallman
  hardware.enableRedistributableFirmware = true;

  services.undervolt = {
    enable = true;
    coreOffset = "-70";
    gpuOffset = "-50";
  };

  programs.light.enable = true;

  # configure touchpad
  services.xserver.libinput = {
    enable = true;
    tappingDragLock = false;
    naturalScrolling = true;
  };

  boot.kernelPackages = pkgs.linuxPackages_5_3;
  boot.kernelPatches = [
    {
      name = "fix-display";
      patch = pkgs.fetchpatch {
        url = "https://bugs.freedesktop.org/attachment.cgi?id=144765";
        sha256 = "sha256-Fc6V5UwZsU6K3ZhToQdbQdyxCFWd6kOxU6ACZKyaVZo=";
      };
    }
  ];
}
