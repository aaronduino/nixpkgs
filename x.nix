{ stdenv, targetPackages, fetchurl, fetchpatch, fetchFromGitHub

, flex

, m4
, perl ? null # optional, for texi2pod (then pod2man); required for Java
, mpfr, libmpc, gettext, which
, libelf                      # optional, for link-time optimizations (LTO)
, isl ? null # optional, for the Graphite optimization framework.
, boehmgc ? null
, gnatboot ? null
, zip ? null, unzip ? null, pkgconfig ? null
, gtk2 ? null, libart_lgpl ? null
, libX11 ? null, libXt ? null, libSM ? null, libICE ? null, libXtst ? null
, libXrender ? null, xorgproto ? null
, libXrandr ? null, libXi ? null
, enableMultilib ? false
, enablePlugin ? stdenv.hostPlatform == stdenv.buildPlatform # Whether to support user-supplied plug-ins
, name ? "gcc"
, libcCross ? null
, threadsCross ? null # for MinGW
, crossStageStatic ? false
, # Strip kills static libs of other archs (hence no cross)
  stripped ? stdenv.hostPlatform == stdenv.buildPlatform
          && stdenv.targetPlatform == stdenv.hostPlatform
, gnused ? null
, cloog # unused; just for compat with gcc4, as we override the parameter on some places
, buildPackages

, withStatic ? false
}:

with stdenv.lib;
with builtins;

let majorVersion = "6";
    version = "${majorVersion}.5.0";

    inherit (stdenv) buildPlatform hostPlatform targetPlatform;


    javaEcj = fetchurl {
      # The `$(top_srcdir)/ecj.jar' file is automatically picked up at
      # `configure' time.

      # XXX: Eventually we might want to take it from upstream.
      url = "ftp://sourceware.org/pub/java/ecj-4.3.jar";
      sha256 = "0jz7hvc0s6iydmhgh5h2m15yza7p2rlss2vkif30vm9y77m97qcx";
    };

    # Antlr (optional) allows the Java `gjdoc' tool to be built.  We want a
    # binary distribution here to allow the whole chain to be bootstrapped.
    javaAntlr = fetchurl {
      url = "https://www.antlr.org/download/antlr-4.4-complete.jar";
      sha256 = "02lda2imivsvsis8rnzmbrbp8rh1kb8vmq4i67pqhkwz7lf8y6dz";
    };

    xlibs = [
      libX11 libXt libSM libICE libXtst libXrender libXrandr libXi
      xorgproto
    ];


    /* Cross-gcc settings (build == host != target) */
    crossMingw = targetPlatform != hostPlatform && targetPlatform.libc == "msvcrt";
    stageNameAddon = if crossStageStatic then "stage-static" else "stage-final";
    crossNameAddon = optionalString (targetPlatform != hostPlatform) "${targetPlatform.config}-${stageNameAddon}-";

in

# We need all these X libraries when building AWT with GTK.

stdenv.mkDerivation ({
  pname = "gmp";
  version = "1";

#   builder = ./builder.sh;

  src = fetchurl {
    url = ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2;
    sha256 = "1s3kddydvngqrpc6i1vbz39raya2jdcl042wi0ksbszgjjllk129";
  };

  patches = [./redox.patch];
    # src = ftp://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2;

  # inherit patches;

#   setOutputFlags = false;
#   NIX_NO_SELF_RPATH = true;

#   libc_dev = stdenv.cc.libc_dev;

#   hardeningDisable = [ "format" "pie" ];

  prePatch =
    # This should kill all the stdinc frameworks that gcc and friends like to
    # insert into default search paths.
    stdenv.lib.optionalString hostPlatform.isDarwin ''
      substituteInPlace gcc/config/darwin-c.c \
        --replace 'if (stdinc)' 'if (0)'

      substituteInPlace libgcc/config/t-slibgcc-darwin \
        --replace "-install_name @shlib_slibdir@/\$(SHLIB_INSTALL_NAME)" "-install_name ''${!outputLib}/lib/\$(SHLIB_INSTALL_NAME)"

      substituteInPlace libgfortran/configure \
        --replace "-install_name \\\$rpath/\\\$soname" "-install_name ''${!outputLib}/lib/\\\$soname"
    '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ m4 ];
  # # For building runtime libs
  # depsBuildTarget =
  #   if hostPlatform == buildPlatform then [
  #     targetPackages.stdenv.cc.bintools # newly-built gcc will be used
  #   ] else assert targetPlatform == hostPlatform; [ # build != host == target
  #     stdenv.cc
  #   ];

  buildInputs = [
    
    # targetPackages.stdenv.cc.bintools # For linking code at run-time
  ];

  depsTargetTarget = optional (!crossStageStatic && threadsCross != null) threadsCross;

  NIX_LDFLAGS = stdenv.lib.optionalString  hostPlatform.isSunOS "-lm -ldl";

  # preConfigure = import ../common/pre-configure.nix {
  #   inherit (stdenv) lib;
  #   inherit version hostPlatform gnatboot langJava langAda langGo;
  # };

  dontDisableStatic = true;

  # TODO(@Ericson2314): Always pass "--target" and always prefix.
  configurePlatforms = [ "build" "host" ];


checkPhase = ''
make check
'';

  doCheck = true; # requires a lot of tools, causes a dependency cycle for stdenv

  meta = {
    homepage = "https://gcc.gnu.org/";
    license = stdenv.lib.licenses.gpl3Plus;  # runtime support libraries are typically LGPLv3+
    description = "GNU Compiler Collection, version ${version}"
      + (if stripped then "" else " (with debugging info)");

    longDescription = ''
      The GNU Compiler Collection includes compiler front ends for C, C++,
      Objective-C, Fortran, OpenMP for C/C++/Fortran, Java, and Ada, as well
      as libraries for these languages (libstdc++, libgcj, libgomp,...).

      GCC development is a part of the GNU Project, aiming to improve the
      compiler used in the GNU system including the GNU/Linux variant.
    '';

    maintainers = with stdenv.lib.maintainers; [ peti ];

    platforms =
      stdenv.lib.platforms.linux ++
      stdenv.lib.platforms.freebsd ++
      stdenv.lib.platforms.illumos ++
      stdenv.lib.platforms.darwin ++
      stdenv.lib.platforms.redox;
  };
}



)

