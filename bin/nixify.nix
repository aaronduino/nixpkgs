with import <nixpkgs> {};

runCommand "zsh" {
  buildInputs = [
    yarn2nix
  ];

  NIXSHELL = "nixify";
} ""
