{ stdenv, lib, fetchurl, pkgconfig, perl
, http2Support ? true, nghttp2
, idnSupport ? false, libidn ? null
, ldapSupport ? false, openldap ? null
, zlibSupport ? true, zlib ? null
, sslSupport ? zlibSupport, openssl ? null
, gnutlsSupport ? false, gnutls ? null
, wolfsslSupport ? false, wolfssl ? null
, scpSupport ? zlibSupport && !stdenv.isSunOS && !stdenv.isCygwin, libssh2 ? null
, gssSupport ? !stdenv.hostPlatform.isWindows, libkrb5 ? null
, c-aresSupport ? false, c-ares ? null
, brotliSupport ? false, brotli ? null
}:

assert http2Support -> nghttp2 != null;
assert idnSupport -> libidn != null;
assert ldapSupport -> openldap != null;
assert zlibSupport -> zlib != null;
assert sslSupport -> openssl != null;
assert !(gnutlsSupport && sslSupport);
assert !(gnutlsSupport && wolfsslSupport);
assert !(sslSupport && wolfsslSupport);
assert gnutlsSupport -> gnutls != null;
assert wolfsslSupport -> wolfssl != null;
assert scpSupport -> libssh2 != null;
assert c-aresSupport -> c-ares != null;
assert brotliSupport -> brotli != null;
assert gssSupport -> libkrb5 != null;

stdenv.mkDerivation rec {
  pname = "curl";
  version = "7.71.0";

  src = if stdenv.hostPlatform.isRedox then fetchGit {
    url = "https://gitlab.redox-os.org/redox-os/curl";
    rev = "1c5963a79ba69bc332865dfbfc2cddc7e545dc80";
  } else fetchurl {
    urls = [
      "https://curl.haxx.se/download/${pname}-${version}.tar.bz2"
      "https://github.com/curl/curl/releases/download/${lib.replaceStrings ["."] ["_"] pname}-${version}/${pname}-${version}.tar.bz2"
    ];
    sha256 = "0hfkbp51vj51s28sq2wnw5jn2f6r7ycdy78lli49ba414jn003v0";
  };

  outputs = [ "bin" "dev" "out" "man" "devdoc" ];
  separateDebugInfo = stdenv.isLinux;

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkgconfig perl ];

  # Zlib and OpenSSL must be propagated because `libcurl.la' contains
  # "-lz -lssl", which aren't necessary direct build inputs of
  # applications that use Curl.
  propagatedBuildInputs = with stdenv.lib;
    optional http2Support nghttp2 ++
    optional idnSupport libidn ++
    optional ldapSupport openldap ++
    optional zlibSupport zlib ++
    optional gssSupport libkrb5 ++
    optional c-aresSupport c-ares ++
    optional sslSupport openssl ++
    optional gnutlsSupport gnutls ++
    optional wolfsslSupport wolfssl ++
    optional scpSupport libssh2 ++
    optional brotliSupport brotli;

  # for the second line see https://curl.haxx.se/mail/tracker-2014-03/0087.html
  preConfigure = if stdenv.hostPlatform.isRedox then ''
    sed -e 's|/usr/bin|/no-such-path|g' -i.bak configure
  '' else ''
    sed -e 's|/usr/bin|/no-such-path|g' -i.bak configure
    rm src/tool_hugehelp.c
  '';

  configureFlags = [
      # Disable default CA bundle, use NIX_SSL_CERT_FILE or fallback
      # to nss-cacert from the default profile.
      "--without-ca-bundle"
      "--without-ca-path"
      # The build fails when using wolfssl with --with-ca-fallback
      ( if wolfsslSupport then "--without-ca-fallback" else "--with-ca-fallback")
      "--disable-manual"
      ( if sslSupport then "--with-ssl=${openssl.dev}" else "--without-ssl" )
      ( if gnutlsSupport then "--with-gnutls=${gnutls.dev}" else "--without-gnutls" )
      ( if scpSupport then "--with-libssh2=${libssh2.dev}" else "--without-libssh2" )
      ( if ldapSupport then "--enable-ldap" else "--disable-ldap" )
      ( if ldapSupport then "--enable-ldaps" else "--disable-ldaps" )
      ( if idnSupport then "--with-libidn=${libidn.dev}" else "--without-libidn" )
      ( if brotliSupport then "--with-brotli" else "--without-brotli" )
    ]
    ++ stdenv.lib.optional wolfsslSupport "--with-wolfssl=${wolfssl.dev}"
    ++ stdenv.lib.optional c-aresSupport "--enable-ares=${c-ares}"
    ++ stdenv.lib.optional gssSupport "--with-gssapi=${libkrb5.dev}"
       # For the 'urandom', maybe it should be a cross-system option
    ++ stdenv.lib.optional (stdenv.hostPlatform != stdenv.buildPlatform)
       "--with-random=/dev/urandom"
    ++ stdenv.lib.optionals (stdenv.hostPlatform.isWindows || stdenv.hostPlatform.isRedox) [
      "--disable-shared"
      "--enable-static"
    ]
    ++ stdenv.lib.optionals stdenv.hostPlatform.isRedox [
      "--disable-ftp"
      "--disable-ipv6"
      "--disable-ntlm-wb"
      "--disable-tftp"
      "--disable-threaded-resolver"
    ];

  CXX = "${stdenv.cc.targetPrefix}c++";
  CXXCPP = "${stdenv.cc.targetPrefix}c++ -E";

  doCheck = false; # expensive, fails

  postInstall = ''
    moveToOutput bin/curl-config "$dev"

    # Install completions
    make -C scripts install
  '' + stdenv.lib.optionalString scpSupport ''
    sed '/^dependency_libs/s|${libssh2.dev}|${libssh2.out}|' -i "$out"/lib/*.la
  '' + stdenv.lib.optionalString gnutlsSupport ''
    ln $out/lib/libcurl.so $out/lib/libcurl-gnutls.so
    ln $out/lib/libcurl.so $out/lib/libcurl-gnutls.so.4
    ln $out/lib/libcurl.so $out/lib/libcurl-gnutls.so.4.4.0
  '';

  passthru = {
    inherit sslSupport openssl;
  };

  meta = with stdenv.lib; {
    description = "A command line tool for transferring files with URL syntax";
    homepage    = "https://curl.haxx.se/";
    license = licenses.curl;
    maintainers = with maintainers; [ lovek323 ];
    platforms = platforms.all;
  };
}
