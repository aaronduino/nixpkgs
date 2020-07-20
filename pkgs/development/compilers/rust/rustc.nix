{ stdenv, removeReferencesTo, pkgsBuildBuild, pkgsBuildHost, pkgsBuildTarget
, lib
, fetchurl, fetchgit, file, python3
, llvm_9, darwin, cmake, rust, rustPlatform
, pkgconfig, openssl
, which, libffi
, withBundledLLVM ? false
, enableRustcDev ? true
, version
, sha256
, patches ? []
, curl

, rustInputThing ? null
}:

let
  inherit (stdenv.lib) optionals optional optionalString;
  inherit (darwin.apple_sdk.frameworks) Security;

  llvmSharedForBuild = pkgsBuildBuild.llvm_9.override { enableSharedLibraries = true; };
  llvmSharedForHost = pkgsBuildHost.llvm_9.override { enableSharedLibraries = true; };
  llvmSharedForTarget = pkgsBuildTarget.llvm_9.override { enableSharedLibraries = true; };

  # For use at runtime
  llvmShared = llvm_9.override { enableSharedLibraries = true; };
in stdenv.mkDerivation rec {
  pname = "rustc";
  inherit version;

  # buildPackages.fetchgit required building a bunch of stuff; is there something like nativePackages?
  src = if (stdenv.targetPlatform.isRedox && false) then 
  
  # fetchgit {
  #   url = "https://gitlab.redox-os.org/aaronjanse/rust";
  #   rev = "4e16338cad6d408563e20afe3027afd478ae8dc6";
  #   sha256 = "12hvglr9f08x8dfkx1k5q3393cgnvmsh7fbzlp36agc1x5993h0p";
  # } 
  /home/ajanse/redox/rust-vendored
  # # ^ CHANGES:
  # #   - `cargo vendor` stuff with internet connection
  # #   - src/libcore/ops/function.rs (remove `not(bootstrap), `)
  # #     227:    #[cfg_attr(not(bootstrap), lang = "fn_once_output")]
  else fetchurl {
    url = "https://static.rust-lang.org/dist/rustc-${version}-src.tar.gz";
    inherit sha256;
  };

  __darwinAllowLocalNetworking = true;

  # rustc complains about modified source files otherwise
  dontUpdateAutotoolsGnuConfigScripts = true;

  # Running the default `strip -S` command on Darwin corrupts the
  # .rlib files in "lib/".
  #
  # See https://github.com/NixOS/nixpkgs/pull/34227
  #
  # Running `strip -S` when cross compiling can harm the cross rlibs.
  # See: https://github.com/NixOS/nixpkgs/pull/56540#issuecomment-471624656
  stripDebugList = [ "bin" ];

  NIX_LDFLAGS = toString (
       # when linking stage1 libstd: cc: undefined reference to `__cxa_begin_catch'
       optional (stdenv.isLinux && !withBundledLLVM) "--push-state --as-needed -lstdc++ --pop-state"
    ++ optional (stdenv.isDarwin && !withBundledLLVM) "-lc++"
    ++ optional stdenv.isDarwin "-rpath ${llvmSharedForHost}/lib");

  # Increase codegen units to introduce parallelism within the compiler.
  RUSTFLAGS = "-Ccodegen-units=10";

  # We need rust to build rust. If we don't provide it, configure will try to download it.
  # Reference: https://github.com/rust-lang/rust/blob/master/src/bootstrap/configure.py
  configureFlags = let
    setBuild  = "--set=target.${rust.toRustTarget stdenv.buildPlatform}";
    setHost   = "--set=target.${rust.toRustTarget stdenv.hostPlatform}";
    setTarget = "--set=target.${rust.toRustTarget stdenv.targetPlatform}";
    ccForBuild  = "${pkgsBuildBuild.targetPackages.stdenv.cc}/bin/${pkgsBuildBuild.targetPackages.stdenv.cc.targetPrefix}cc";
    cxxForBuild = "${pkgsBuildBuild.targetPackages.stdenv.cc}/bin/${pkgsBuildBuild.targetPackages.stdenv.cc.targetPrefix}c++";
    ccForHost  = "${pkgsBuildHost.targetPackages.stdenv.cc}/bin/${pkgsBuildHost.targetPackages.stdenv.cc.targetPrefix}cc";
    cxxForHost = "${pkgsBuildHost.targetPackages.stdenv.cc}/bin/${pkgsBuildHost.targetPackages.stdenv.cc.targetPrefix}c++";
    ccForTarget  = "${pkgsBuildTarget.targetPackages.stdenv.cc}/bin/${pkgsBuildTarget.targetPackages.stdenv.cc.targetPrefix}cc";
    cxxForTarget = "${pkgsBuildTarget.targetPackages.stdenv.cc}/bin/${pkgsBuildTarget.targetPackages.stdenv.cc.targetPrefix}c++";
  in [
    "--release-channel=stable"
    "--set=build.rustc=${rustPlatform.rustc}/bin/rustc"
    "--set=build.cargo=${rustPlatform.cargo}/bin/cargo"
    "--enable-rpath"
    "--build=${rust.toRustTarget stdenv.buildPlatform}"
    "--host=${rust.toRustTarget stdenv.hostPlatform}"
    "--target=${rust.toRustTarget stdenv.targetPlatform}"

    "${setBuild}.cc=${ccForBuild}"
    "${setHost}.cc=${ccForHost}"
    "${setTarget}.cc=${ccForTarget}"

    "${setBuild}.linker=${ccForBuild}"
    "${setHost}.linker=${ccForHost}"
    "${setTarget}.linker=${ccForTarget}"

    "${setBuild}.cxx=${cxxForBuild}"
    "${setHost}.cxx=${cxxForHost}"
    "${setTarget}.cxx=${cxxForTarget}"
  ] ++ optionals (!withBundledLLVM) [
    "--enable-llvm-link-shared"
    "${setBuild}.llvm-config=${llvmSharedForBuild}/bin/llvm-config"
    "${setHost}.llvm-config=${llvmSharedForHost}/bin/llvm-config"
    "${setTarget}.llvm-config=${llvmSharedForTarget}/bin/llvm-config"
  ] ++ optionals (stdenv.isLinux && !stdenv.targetPlatform.isRedox) [
    "--enable-profiler" # build libprofiler_builtins
  ] ++ optional (true) "--enable-vendor";

  # The bootstrap.py will generated a Makefile that then executes the build.
  # The BOOTSTRAP_ARGS used by this Makefile must include all flags to pass
  # to the bootstrap builder.
  postConfigure = ''
    substituteInPlace Makefile \
      --replace 'BOOTSTRAP_ARGS :=' 'BOOTSTRAP_ARGS := --jobs $(NIX_BUILD_CORES)'
  '';
  #   export VERBOSE=1

  #   cp -r ${fetchGit {
  #     url = "https://gitlab.redox-os.org/redox-os/liblibc";
  #     rev = "ac65670b09788e760603de2c153b993050ed23a5";
  #   }} src/liblibc

  #   chmod +rw -R src/liblibc

  #   sed -i 's#git = "https://gitlab.redox-os.org/redox-os/liblibc.git", branch = "redox"#path="src/liblibc"#' Cargo.toml
  #   sed -i 's/\#\!\[deny(warnings)\]//g' src/bootstrap/lib.rs
  #   cp ${./redox-root-Cargo.lock} ./Cargo.lock
  #   cp ${./redox-liblibc-Cargo.lock} ./src/liblibc/Cargo.lock
  #   chmod +rw -R .
  #   echo 'LISTING: .'
  #   ls .
  #   echo 'LISTING: src/liblibc'
  #   ls src/liblibc
  #   echo 'LISTING: src/bootstrap'
  #   ls src/bootstrap
  #   echo '###########'
  # '';

  # the rust build system complains that nix alters the checksums
  dontFixLibtool = true;

  inherit patches;

  postPatch = ''
    patchShebangs src/etc

    ${optionalString (!withBundledLLVM) ''rm -rf src/llvm''}

    # Fix the configure script to not require curl as we won't use it
    sed -i configure \
      -e '/probe_need CFG_CURL curl/d'

    # Useful debugging parameter
    # export VERBOSE=1
  '' + lib.optionalString stdenv.targetPlatform.isRedox ''
    # cp ${./redox-libc-Cargo.lock} src/libc/Cargo.lock

    # export VERBOSE=1
    # echo '######################'
    # echo '######################'
    # echo '######################'
    # echo '######################'
    # echo '######################'
    # echo '######################'
    # echo '######################'
    # echo '######################'
    # ls src/bootstrap/

    # cat configure

    # sed -i 's/^rustfmt:/#rustfmt:/g' src/stage0.txt
    # head -50 src/stage0.txt
  '';

  # rustc unfortunately needs cmake to compile llvm-rt but doesn't
  # use it for the normal build. This disables cmake in Nix.
  dontUseCmakeConfigure = true;

  nativeBuildInputs = [
    file python3 cmake
    which libffi removeReferencesTo pkgconfig
  ] ++ (if (stdenv.targetPlatform.isRedox && false) then [
    rustInputThing
  ] else [rustPlatform.rustc]);

  buildInputs = [ openssl ]
    ++ optional stdenv.isDarwin Security
    ++ optional (!withBundledLLVM) llvmShared;

  outputs = [ "out" "man" "doc" ];
  setOutputFlags = false;

  doCheck = !stdenv.targetPlatform.isRedox;

  postInstall = stdenv.lib.optionalString enableRustcDev ''
    # install rustc-dev components. Necessary to build rls, clippy...
    python x.py dist rustc-dev
    tar xf build/dist/rustc-dev*tar.gz
    cp -r rustc-dev*/rustc-dev*/lib/* $out/lib/

  '' + ''
    # remove references to llvm-config in lib/rustlib/x86_64-unknown-linux-gnu/codegen-backends/librustc_codegen_llvm-llvm.so
    # and thus a transitive dependency on ncurses
    find $out/lib -name "*.so" -type f -exec remove-references-to -t ${llvmShared} '{}' '+'
  '';

  configurePlatforms = [];

  # https://github.com/NixOS/nixpkgs/pull/21742#issuecomment-272305764
  # https://github.com/rust-lang/rust/issues/30181
  # enableParallelBuilding = false;

  setupHooks = ./setup-hook.sh;

  requiredSystemFeatures = [ "big-parallel" ];

  passthru.llvm = llvmShared;

  meta = with stdenv.lib; {
    homepage = "https://www.rust-lang.org/";
    description = "A safe, concurrent, practical language";
    maintainers = with maintainers; [ madjar cstrahan globin havvy ];
    license = [ licenses.mit licenses.asl20 ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
# // (if stdenv.targetPlatform.isRedox then {RUSTC_BOOTSTRAP=1;} else {})

