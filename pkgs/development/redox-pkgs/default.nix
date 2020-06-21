{ lib, buildPackages, pkgs, targetPackages }:

rec {
  binutils = buildPackages.buildPackages.wrapBintoolsWith {
    bintools = binaries;
    libc = libraries;
  };
  clang = buildPackages.buildPackages.wrapCCWith {
    name = "ss";
    cc = binaries // {
      # for packages expecting libcompiler-rt, etc. to come from here (stdenv.cc.cc.lib)
      lib = libraries;
    };
    bintools = binutils;
    libc = libraries;
  };

  binaries = libraries;
  libraries = (let
    rpath = lib.makeLibraryPath [
      buildPackages.buildPackages.gcc-unwrapped
      buildPackages.buildPackages.stdenv.cc.libc
      "$out"
    ];
  in buildPackages.buildPackages.stdenv.mkDerivation {
    name = "relibc";
    src = builtins.fetchTarball
      "https://static.redox-os.org/toolchain/x86_64-unknown-redox/relibc-install.tar.gz";

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
      description = "libc for redox";
      # platforms   = lib.platforms.redox;
      maintainers = [ lib.maintainers.aaronjanse ];
    };
  });
}
# let
#   ndkVersion = "18.1.5063045";

#   buildAndroidComposition = buildPackages.buildPackages.androidenv.composeAndroidPackages {
#     includeNDK = true;
#     inherit ndkVersion;
#   };

#   androidComposition = androidenvcomposeAndroidPackages {
#     includeNDK = true;
#     inherit ndkVersion;
#   };
# in
# import ./androidndk-pkgs.nix {
#   inherit (buildPackages)
#     makeWrapper;
#   inherit (pkgs)
#     stdenv
#     runCommand wrapBintoolsWith wrapCCWith;
#   # buildPackages.foo rather than buildPackages.buildPackages.foo would work,
#   # but for splicing messing up on infinite recursion for the variants we
#   # *dont't* use. Using this workaround, but also making a test to ensure
#   # these two really are the same.
#   buildAndroidndk = buildAndroidComposition.ndk-bundle;
#   androidndk = androidComposition.ndk-bundle;
#   targetAndroidndkPkgs = targetPackages.androidndkPkgs_18b;
# }
