{ fetchurl, lib, nettools, python3Packages, texinfo, fetchFromGitHub }:

# FAILURES: The "running build_ext" phase fails to compile Twisted
# plugins, because it tries to write them into Twisted's (immutable)
# store path. The problem appears to be non-fatal, but there's probably
# some loss of functionality because of it.

python3Packages.buildPythonApplication rec {
  version = "latest";
  pname = "tahoe-lafs";
  namePrefix = "";

  src = fetchFromGitHub {
    owner = "tahoe-lafs";
    repo = "tahoe-lafs";
    rev = "8e28a9d0e02fde2388aca549da2b5c452ac4337f";
    sha256 = "sha256-MuD/ZY+die7RCsuVdcePSD0DdwatXRi7CxW2iFt22L0=";
  };

  outputs = [ "out" "doc" "info" ];

  postPatch = ''
    sed -i "src/allmydata/util/iputil.py" \
        -es"|_linux_path = '/sbin/ifconfig'|_linux_path = '${nettools}/bin/ifconfig'|g"

    # Chroots don't have /etc/hosts and /etc/resolv.conf, so work around
    # that.
    for i in $(find src/allmydata/test -type f)
    do
      sed -i "$i" -e"s/localhost/127.0.0.1/g"
    done

    sed -i 's/"zope.interface.*"/"zope.interface"/' src/allmydata/_auto_deps.py
    sed -i 's/"pycrypto.*"/"pycrypto"/' src/allmydata/_auto_deps.py
  '';

  # Remove broken and expensive tests.
  preConfigure = ''
    (
      cd src/allmydata/test

      # Buggy?
      rm cli/test_create.py test_client.py

      # These require Tor and I2P.
      rm test_connections.py test_iputil.py test_hung_server.py test_i2p_provider.py test_tor_provider.py

      # Expensive
      rm test_system.py
    )
  '';

  nativeBuildInputs = with python3Packages; [ sphinx texinfo ];

  # The `backup' command requires `sqlite3'.
  propagatedBuildInputs = with python3Packages; [
    twisted foolscap simplejson pycrypto pyasn1 zope_interface
    service-identity pyyaml magic-wormhole treq characteristic
    pyutil netifaces foolscap eliot distro zfec future appdirs
    recommonmark sphinx_rtd_theme testtools fixtures
    beautifulsoup4 html5lib
  ];

  checkInputs = with python3Packages; [ mock hypothesis twisted ];

  doCheck = false;

  # Install the documentation.
  postInstall = ''
    (
      cd docs

      make singlehtml
      mkdir -p "$doc/share/doc/${pname}-${version}"
      cp -rv _build/singlehtml/* "$doc/share/doc/${pname}-${version}"

      make info
      mkdir -p "$info/share/info"
      cp -rv _build/texinfo/*.info "$info/share/info"
    )
  '';

  # checkPhase = ''
  #   trial --rterrors allmydata
  # '';

  meta = {
    description = "Tahoe-LAFS, a decentralized, fault-tolerant, distributed storage system";
    longDescription = ''
      Tahoe-LAFS is a secure, decentralized, fault-tolerant filesystem.
      This filesystem is encrypted and spread over multiple peers in
      such a way that it remains available even when some of the peers
      are unavailable, malfunctioning, or malicious.
    '';
    homepage = "http://tahoe-lafs.org/";
    license = [ lib.licenses.gpl2Plus /* or */ "TGPPLv1+" ];
    maintainers = with lib.maintainers; [ MostAwesomeDude ];
    platforms = lib.platforms.gnu ++ lib.platforms.linux;
  };
}
