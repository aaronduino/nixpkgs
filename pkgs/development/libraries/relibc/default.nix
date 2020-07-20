{ stdenv, buildPackages, fetchurl, lib , makeRustPlatform }:

let
  rpath = lib.makeLibraryPath [
    buildPackages.stdenv.cc.libc
    "$out"
  ];
  bootstrapCrossRust = stdenv.mkDerivation {
    name = "binary-redox-rust";
    
    src = fetchTarball {
      name = "rust-install.tar.gz";
      url = "https://gateway.pinata.cloud/ipfs/QmNp6fPTjPA6LnCYvW1UmbAHcPpU7tqZhstfSpSXMJCRwp";
      sha256 = "0p1bxffbbl1bp8glwg2iqb18zjx678kyn91afjr5czlmcrrp3ybw";
    };

    dontBuild = true;
    dontPatchELF = true;
    dontStrip = true;
    installPhase = ''
      mkdir $out/
      cp -r * $out/

      find $out/ -executable -type f -exec patchelf \
          --set-interpreter "${buildPackages.stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
          --set-rpath "${rpath}" \
          "{}" \;
      find $out/ -name "*.so" -type f -exec patchelf \
          --set-rpath "${rpath}" \
          "{}" \;
    '';

    meta = {
      platforms = lib.platforms.all;
    };
  };

  redoxRustPlatform = buildPackages.makeRustPlatform {
    rustc = bootstrapCrossRust;
    cargo = bootstrapCrossRust;
  };
in  
redoxRustPlatform.buildRustPackage rec {
  pname = "relibc";
  version = "0.1.0";

  src = buildPackages.fetchgit {
    url = "https://gitlab.redox-os.org/redox-os/relibc/";
    rev = "db6a5894216a84528e02ce3c2faa3415fdf8c6a4";
    sha256 = "03lns01gg53j96d0yc522q68avalp66jh8r18v05yrrlq34mlicy";
    fetchSubmodules = true;
  };

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

  meta.platforms = lib.platforms.all;
}