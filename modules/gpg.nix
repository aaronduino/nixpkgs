{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.vars;
in
{
  options.vars = {
    pgpFingerprint = mkOption {
      type = types.str;
      default = "BE6C92145BFF4A34";
    };
    yubikey = mkOption {
      type = types.bool;
      default = false;
    };
  };

  config = {
    # for yubikey
    services.pcscd.enable = cfg.yubikey;
    services.udev.packages = if cfg.yubikey then [ pkgs.yubikey-personalization ] else [];

    systemd.user.sockets.gpg-agent-ssh = {
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "%t/gnupg/S.gpg-agent.ssh" ];
      socketConfig = {
        FileDescriptorName = "ssh";
        Service = "gpg-agent.service";
        SocketMode = "0600";
        DirectoryMode = "0700";
      };
    };

    environment.systemPackages = if cfg.yubikey then [ pkgs.yubikey-personalization ] else [];

    environment.shellInit = ''
      export GPG_TTY="$(tty)"
      gpg-connect-agent /bye
      export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
    '';

    programs = {
      ssh.startAgent = false;
      # gnupg.agent = {
      #   # enable = true;
      #   enableSSHSupport = true;
      # };
    };

    home-manager.users = let
      gpg = {
        services.gpg-agent = {
          enable = true;
          enableScDaemon = cfg.yubikey; # smartcard daemon
          enableSshSupport = true;
        };
        programs.gpg = {
          enable = true;
          settings = {
            personal-cipher-preferences = "AES256 AES192 AES CAST5";
            personal-digest-preferences = "SHA512 SHA384 SHA256 SHA224";
            default-preference-list = "SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed";
            cert-digest-algo = "SHA512";
            s2k-digest-algo = "SHA512";
            s2k-cipher-algo = "AES256";
            charset = "utf-8";
            fixed-list-mode = true;
            no-comments = true;
            no-emit-version = true;
            keyid-format = "0xlong";
            list-options = "show-uid-validity";
            verify-options = "show-uid-validity";
            with-fingerprint = true;
            require-cross-certification = true;
            use-agent = true;
          };
        };
      };



    in
      {
        root = gpg;
        "${cfg.username}" = gpg;
      };

  };
}
