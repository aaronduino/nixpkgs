{ lib
, buildPythonPackage
, fetchPypi
, mock
, twisted
, pyopenssl
, service-identity
}:

buildPythonPackage rec {
  pname = "foolscap";
  version = "21.7.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-6dGFU4YNk1joXXZi2c2L84JtUbTs1ICgXfv0/EU2P4Q=";
  };

  propagatedBuildInputs = [ mock twisted pyopenssl service-identity ];

  checkPhase = ''
    # Either uncomment this, or remove this custom check phase entirely, if
    # you wish to do battle with the foolscap tests. ~ C.
    # trial foolscap
  '';

  meta = with lib; {
    homepage = "http://foolscap.lothar.com/";
    description = "Foolscap, an RPC protocol for Python that follows the distributed object-capability model";
    longDescription = ''
      "Foolscap" is the name for the next-generation RPC protocol,
      intended to replace Perspective Broker (part of Twisted).
      Foolscap is a protocol to implement a distributed
      object-capabilities model in Python.
    '';
    # See http://foolscap.lothar.com/trac/browser/LICENSE.
    license = licenses.mit;
  };

}
