let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  pkgs' = import <nixpkgs> { overlays = [ moz_overlay ]; };
  customRust = pkgs'.rustChannelOf { date = "2019-11-24"; channel = "nightly"; };

  buildRustPackage' = pkgs'.rustPlatform.buildRustPackage.override {
    rustc = customRust.rust;
    cargo = customRust.rust;
  };
in buildRustPackage' rec {
  pname = "relibc";
  version = "0.1.0";

  src = pkgs'.fetchgit {
    url = "https://gitlab.redox-os.org/redox-os/relibc/";
    rev = "db6a5894216a84528e02ce3c2faa3415fdf8c6a4";
    sha256 = "03lns01gg53j96d0yc522q68avalp66jh8r18v05yrrlq34mlicy";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgs'.gcc ];

  RUSTC_BOOTSTRAP = 1;

  dontInstall = true;
  dontFixup = true;
  doCheck = false;

  buildPhase = ''
    make
    mkdir $out
    DESTDIR=$out make install
  '';

  cargoSha256 = "1kdh0zmbap59a3w352r55r4f3c62mp0hrpwk04amshp9m5mr8h85";

  cargoPatches = [
    ./fix-Cargo.lock.patch
  ];
}