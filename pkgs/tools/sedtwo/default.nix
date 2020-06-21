{ stdenv, fetchurl, perl }:

stdenv.mkDerivation rec {
  pname = "sedtwo";
  version = "4.8";

  src = fetchurl {
    url = "mirror://gnu/sed/sed-${version}.tar.xz";
    sha256 = "0cznxw73fzv1n3nj2zsq6nf73rvsbxndp444xkpahdqvlzz0r6zp";
  };

  outputs = [ "out" "info" ];

  nativeBuildInputs = [ perl ];
  preConfigure = if stdenv.targetPlatform.isRedox
    then ''
    echo GCC: $CC
      export LDFLAGS="-static"
      patchShebangs ./build-aux/help2man
    '' else ''
    echo AGCC: $CC
    echo WHERE: $(where $CC)
    patchShebangs ./build-aux/help2man
    '';

  configure = ''
  echo XXX: $GCC
  '';

  # Prevents attempts of running 'help2man' on cross-built binaries.
  PERL = if stdenv.hostPlatform == stdenv.buildPlatform then null else "missing";

  meta = {
    homepage = "https://www.gnu.org/software/sed/";
    description = "GNU sed, a batch stream editor";

    longDescription = ''
      Sed (stream editor) isn't really a true text editor or text
      processor.  Instead, it is used to filter text, i.e., it takes
      text input and performs some operation (or set of operations) on
      it and outputs the modified text.  Sed is typically used for
      extracting part of a file using pattern matching or substituting
      multiple occurrences of a string within a file.
    '';

    license = builtins.trace stdenv.lib.platforms.redox stdenv.lib.licenses.gpl3Plus;

    platforms = stdenv.lib.platforms.unix ++ stdenv.lib.platforms.redox;
    maintainers = [ ];
  };
}
