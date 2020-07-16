{ stdenv, gcc-unwrapped, lib }:

let
  rpath = lib.makeLibraryPath [
    gcc-unwrapped
    stdenv.cc.libc
    "$out"
  ];
in stdenv.mkDerivation {
  name = "binary-redox-latest";
  src = builtins.fetchTarball (https://static.redox-os.org/toolchain/x86_64-unknown-redox/relibc-install.tar.gz);

  dontBuild = true;
  dontPatchELF = true;
  dontStrip = true;
  installPhase = ''
    mkdir $out/
    cp -r * $out/

    find $out/ -executable -type f -exec patchelf \
        --set-interpreter "${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2" \
        --set-rpath "${rpath}" \
        "{}" \;
    find $out/ -name "*.so" -type f -exec patchelf \
        --set-rpath "${rpath}" \
        "{}" \;
  '';
}
